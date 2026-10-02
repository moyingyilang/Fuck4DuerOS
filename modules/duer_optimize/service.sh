#!/system/bin/sh
# DuerOS Optimize - 开机后应用调优
#
# 设计原则：
#   1. 不碰 CPU governor / 频率（交给厂商调度器与 uperf / Scene）
#   2. 不碰 ZRAM / SWAP（由 scene_swap_controller 管理，硬改会打架）
#   3. 不碰用户可见功能（桌面、语音、媒体、输入法）
#   4. 每一项都可单独注释掉

MODDIR=${0%/*}
LOG=/data/local/tmp/duer_optimize.log
log() { echo "[$(date '+%m-%d %H:%M:%S')] [service] $*" >> "$LOG"; }

# 等开机完成
n=0
while [ "$(getprop sys.boot_completed)" != "1" ] && [ $n -lt 120 ]; do
    sleep 5; n=$((n+1))
done
[ "$(getprop sys.boot_completed)" = "1" ] || { log "等待开机超时，退出"; exit 1; }

# 再等一会，让 init 把 class main 的服务都拉起来
sleep 20

log "================ duer_optimize 开始 ================"

# ---------------------------------------------------------------------------
# 1. 关闭百度持久化日志
#
# /system_ext/bin/baidu_log 会常驻两个 logcat：
#   logcat -r 10240 -n 15 -f /data/log/logcat_full.log *:I   实测约 742 MB/天
#   logcat -r 1024  -n 19 -b kernel -f /data/log/kernel/...  实测约 345 MB/天
# 合计约 1.09 GB/天 的持续闪存写入，同时是隐私汇聚点。
#
# 停掉对应 init 服务即可；内核 logd 不受影响，adb logcat 仍正常。
# ---------------------------------------------------------------------------
for s in kernel_log logcat_log log_size_control; do
    setprop ctl.stop "$s" 2>/dev/null
    log "ctl.stop $s"
done

# 清掉可能残留的进程
ps -A -o PID,NAME,ARGS 2>/dev/null | grep -E 'logcat|baidu_log' | grep -v grep | \
while read -r pid name args; do
    case "$args" in
        *logcat_full.log*|*baidu_log*)
            kill -9 "$pid" 2>/dev/null && log "killed $pid ($name)"
            ;;
    esac
done

# ---------------------------------------------------------------------------
# 2. 网络
# ---------------------------------------------------------------------------
sysctl_set() {
    [ -f "$1" ] || return 0
    echo "$2" > "$1" 2>/dev/null && log "sysctl $1 = $2"
}

sysctl_set /proc/sys/net/ipv4/tcp_slow_start_after_idle 0
sysctl_set /proc/sys/net/ipv4/tcp_fastopen 3
sysctl_set /proc/sys/net/ipv4/tcp_fin_timeout 30
sysctl_set /proc/sys/net/ipv4/tcp_max_syn_backlog 1024
sysctl_set /proc/sys/net/ipv4/conf/all/send_redirects 0

# ---------------------------------------------------------------------------
# 3. 内存 / VM（swappiness 与 zram/swap 交给 Scene，不在这里动）
# ---------------------------------------------------------------------------
sysctl_set /proc/sys/vm/vfs_cache_pressure 100
sysctl_set /proc/sys/vm/dirty_writeback_centisecs 500
sysctl_set /proc/sys/vm/dirty_expire_centisecs 3000

# ---------------------------------------------------------------------------
# 4. 内核信息暴露收紧（非 root 应用不能读 dmesg）
# ---------------------------------------------------------------------------
sysctl_set /proc/sys/kernel/dmesg_restrict 1

# ---------------------------------------------------------------------------
# 5. 交互：动画缩放（纯观感提速，不改功能）
# ---------------------------------------------------------------------------
settings put global window_animation_scale 0.5 2>/dev/null
settings put global transition_animation_scale 0.5 2>/dev/null
settings put global animator_duration_scale 0.5 2>/dev/null
log "动画缩放 -> 0.5"

# ---------------------------------------------------------------------------
# 6. IO（post-fs-data 已设，这里兜底，防止被其他模块重置）
# ---------------------------------------------------------------------------
for d in sda sdb sdc; do
    q="/sys/block/$d/queue"
    [ -d "$q" ] || continue
    echo none > "$q/scheduler" 2>/dev/null
    echo 512  > "$q/read_ahead_kb" 2>/dev/null
done
log "IO 队列参数已确认"

log "================ duer_optimize 完成 ================"
exit 0
