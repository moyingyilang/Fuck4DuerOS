#!/system/bin/sh
# Fuck4DuerOS - 系统优化（可逆、幂等）
#
# 应用一组保守的系统级调优。所有被改动的参数在修改前都会备份到
# $BACKUP，可用 revert_optimize.sh 一键恢复原值。
#
# 用法（设备端，需 root）：
#   su -c 'sh /data/local/tmp/optimize.sh'
#
# 设计原则（重要）：
#   1. 不碰 CPU governor / 频率 —— 交给厂商调度器与 uperf / Scene；
#   2. 不碰 ZRAM / SWAP —— 那由 scene_swap_controller 模块管理，
#      硬改会与它的 startup.sh 打架（见 docs/optimization.md）；
#   3. 不碰用户可见功能（桌面、语音、媒体、输入法）；
#   4. 每一项都可单独回滚，脚本可重复执行。

BACKUP=/data/local/tmp/f4d_optimize_backup
LOG=/data/local/tmp/f4d_optimize.log
mkdir -p "$BACKUP" 2>/dev/null

log() { echo "[$(date '+%m-%d %H:%M:%S')] $*" >> "$LOG"; }

# ---------- 备份 ----------
bk_file() {                    # bk_file <备份名> <源文件>
  [ -f "$2" ] || return 0
  [ -f "$BACKUP/$1" ] && return 0     # 不覆盖已有备份，保证多次执行后回滚到最初值
  cat "$2" > "$BACKUP/$1" 2>/dev/null
}

set_sysctl() {                 # set_sysctl <vm.swappiness> <值>
  _k="$1"; _v="$2"
  _f="/proc/sys/$(echo "$_k" | tr . /)"
  if [ ! -f "$_f" ]; then log "skip $_k（本内核不存在）"; return 0; fi
  bk_file "$_k" "$_f"
  if echo "$_v" > "$_f" 2>/dev/null; then
    log "sysctl $_k = $_v"
  else
    log "FAIL   $_k = $_v（只读）"
  fi
}

# ===========================================================================
# 1. 关闭百度持久化日志
#
# /system_ext/bin/baidu_log 会拉起两个常驻 logcat，把【全量 Info 级以上日志】
# 和内核日志持续写进 /data/log：
#   logcat -r 10240 -n 15 -f /data/log/logcat_full.log *:I     ≈ 742 MB/天
#   logcat -r 1024  -n 19 -b kernel -f /data/log/kernel/...    ≈ 345 MB/天
# 合计约 1.09 GB/天 的持续闪存写入，同时也是一个隐私汇聚点。
#
# 这里停掉对应 init 服务；内核 logd 本身不受影响，
# 需要调试时仍然可以正常 adb logcat。
# ===========================================================================
disable_baidu_log() {
  log "--- 关闭百度持久化日志 ---"
  for s in kernel_log logcat_log log_size_control; do
    setprop ctl.stop "$s" 2>/dev/null
    log "ctl.stop $s"
  done

  # 清掉可能残留的 logcat / baidu_log 进程
  ps -A -o PID,NAME,ARGS 2>/dev/null | grep -E 'logcat|baidu_log' | grep -v grep | \
  while read -r pid name args; do
    case "$args" in
      *logcat_full.log*|*baidu_log*)
        kill -9 "$pid" 2>/dev/null && log "killed $pid ($name)"
        ;;
    esac
  done
}

# ===========================================================================
# 2. 清理历史日志（释放空间，不触碰 bugreports）
# ===========================================================================
clean_logs() {
  log "--- 清理历史日志 ---"
  _before=$(du -sk /data/log 2>/dev/null | cut -f1)
  rm -f /data/log/logcat_full.log* 2>/dev/null
  rm -f /data/log/kernel/kernel_log_* 2>/dev/null
  _after=$(du -sk /data/log 2>/dev/null | cut -f1)
  log "释放 $(( (_before - _after) / 1024 )) MB（$((_before/1024)) -> $((_after/1024)) MB）"
}

# ===========================================================================
# 3. 块设备 IO
#    UFS 配 blk-mq 时 scheduler=none 可省掉一层调度开销；
#    read_ahead 128 -> 512 KB 改善顺序读（冷启动、读大文件）。
# ===========================================================================
tune_io() {
  log "--- 块设备 IO ---"
  for d in sda sdb sdc; do
    q="/sys/block/$d/queue"
    [ -d "$q" ] || continue
    if [ -f "$q/scheduler" ]; then
      bk_file "io_$d.scheduler" "$q/scheduler"
      echo none > "$q/scheduler" 2>/dev/null && log "io $d scheduler=none"
    fi
    if [ -f "$q/read_ahead_kb" ]; then
      bk_file "io_$d.read_ahead_kb" "$q/read_ahead_kb"
      echo 512 > "$q/read_ahead_kb" 2>/dev/null && log "io $d read_ahead_kb=512"
    fi
  done
}

# ===========================================================================
# 4. 网络
# ===========================================================================
tune_net() {
  log "--- 网络 ---"
  # 空闲后不重置拥塞窗口：交互间隔大的场景吞吐更好
  set_sysctl net.ipv4.tcp_slow_start_after_idle 0
  # TFO 客户端 + 服务端
  set_sysctl net.ipv4.tcp_fastopen 3
  # 缩短 TIME_WAIT，加快端口回收
  set_sysctl net.ipv4.tcp_fin_timeout 30
  # 提高 SYN 队列
  set_sysctl net.ipv4.tcp_max_syn_backlog 1024
  # 本机不是路由器，无需转发 ICMP 重定向
  set_sysctl net.ipv4.conf.all.send_redirects 0
  # SYN flood 防护
  set_sysctl net.ipv4.tcp_syncookies 1
}

# ===========================================================================
# 5. 内存 / VM
#    注意：不动 swappiness、不碰 zram/swap（Scene 管着）
# ===========================================================================
tune_vm() {
  log "--- 内存 / VM ---"
  # 150 -> 100：少驱逐 inode/dentry 缓存，减少重复 stat/读元数据
  set_sysctl vm.vfs_cache_pressure 100
  # 10000(100s) -> 500(5s)：脏页及时平滑回写，避免攒一大波造成卡顿
  set_sysctl vm.dirty_writeback_centisecs 500
  set_sysctl vm.dirty_expire_centisecs 3000
}

# ===========================================================================
# 6. 内核信息暴露收紧
# ===========================================================================
tune_kernel() {
  log "--- 内核 ---"
  # 非 root 应用不允许读 dmesg（root 不受影响）
  set_sysctl kernel.dmesg_restrict 1
}

# ===========================================================================
# 7. 交互：动画缩放
#    纯观感提速，不改变任何功能；0.5 是常见取舍。
# ===========================================================================
tune_ui() {
  log "--- 交互动画 ---"
  for k in window_animation_scale transition_animation_scale animator_duration_scale; do
    _cur=$(settings get global "$k" 2>/dev/null)
    bk_file "ui_$k" /dev/null 2>/dev/null
    printf '%s' "$_cur" > "$BACKUP/ui_$k" 2>/dev/null
    settings put global "$k" 0.5 2>/dev/null && log "settings $k = 0.5"
  done
}

# ===========================================================================
# 8. 预装精简
#    com.baidu.duer.superapp 是用户空间应用，携带 libpcdn-jni.so（PCDN 库），
#    且不属于系统必需组件。
# ===========================================================================
disable_bloat() {
  log "--- 预装精简 ---"
  for p in com.baidu.duer.superapp; do
    if pm list packages 2>/dev/null | grep -q "package:$p$"; then
      if pm list packages -d 2>/dev/null | grep -q "package:$p$"; then
        log "$p 已经是禁用状态"
      else
        pm disable-user --user 0 "$p" 2>/dev/null && log "disabled $p"
      fi
    fi
  done
}

# ---------- 执行 ----------
log "================ 优化开始 ================"
disable_baidu_log
clean_logs
tune_io
tune_net
tune_vm
tune_kernel
tune_ui
disable_bloat
log "================ 优化结束 ================"

echo "优化已应用，日志：$LOG"
echo "备份目录：$BACKUP"
echo
tail -n 30 "$LOG"
