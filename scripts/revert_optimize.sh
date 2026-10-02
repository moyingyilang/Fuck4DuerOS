#!/system/bin/sh
# Fuck4DuerOS - 回滚 optimize.sh 的全部改动
#
# 从 $BACKUP 读回原始值并恢复；重新启用被禁用的预装包。
#
# 用法（设备端，需 root）：
#   su -c 'sh /data/local/tmp/revert_optimize.sh'

BACKUP=/data/local/tmp/f4d_optimize_backup
LOG=/data/local/tmp/f4d_optimize.log
log() { echo "[$(date '+%m-%d %H:%M:%S')] $*" >> "$LOG"; }

if [ ! -d "$BACKUP" ]; then
  echo "❌ 找不到备份目录 $BACKUP，无法回滚"
  exit 1
fi

log "================ 回滚开始 ================"

# ---------- sysctl ----------
for f in "$BACKUP"/*; do
  [ -f "$f" ] || continue
  name="${f##*/}"
  case "$name" in
    io_*|ui_*) continue ;;
  esac
  target="/proc/sys/$(echo "$name" | tr . /)"
  [ -f "$target" ] || continue
  v=$(cat "$f" 2>/dev/null)
  echo "$v" > "$target" 2>/dev/null && log "restore $name = $v"
done

# ---------- IO ----------
for f in "$BACKUP"/io_*; do
  [ -f "$f" ] || continue
  name="${f##*/}"                 # io_sda.scheduler / io_sda.read_ahead_kb
  dev=$(echo "$name" | sed 's/^io_//; s/\..*$//')
  attr=$(echo "$name" | sed 's/^io_[^.]*\.//')
  q="/sys/block/$dev/queue/$attr"
  [ -f "$q" ] || continue
  v=$(cat "$f" 2>/dev/null)
  # scheduler 备份里带方括号（如 [mq-deadline] kyber none），只取括号内的值
  case "$attr" in
    scheduler) v=$(echo "$v" | tr ' ' '\n' | sed -n 's/^\[\(.*\)\]$/\1/p') ;;
  esac
  [ -n "$v" ] && echo "$v" > "$q" 2>/dev/null && log "restore io $dev.$attr = $v"
done

# ---------- 动画 ----------
for k in window_animation_scale transition_animation_scale animator_duration_scale; do
  f="$BACKUP/ui_$k"
  [ -f "$f" ] || continue
  v=$(cat "$f" 2>/dev/null)
  if [ -z "$v" ] || [ "$v" = "null" ]; then
    settings delete global "$k" 2>/dev/null && log "restore $k (删除，恢复默认)"
  else
    settings put global "$k" "$v" 2>/dev/null && log "restore $k = $v"
  fi
done

# ---------- 预装包 ----------
for p in com.baidu.duer.superapp; do
  if pm list packages -d 2>/dev/null | grep -q "package:$p$"; then
    pm enable "$p" 2>/dev/null && log "enabled $p"
  fi
done

log "================ 回滚结束 ================"

echo "回滚完成。"
echo
echo "注意：百度持久化日志服务（kernel_log / logcat_log / log_size_control）"
echo "被停止后，重启设备即会随 init 重新启动；若要让本次回滚完全生效，"
echo "请移除 Magisk 模块 duer_optimize 后重启。"
echo
tail -n 20 "$LOG"
