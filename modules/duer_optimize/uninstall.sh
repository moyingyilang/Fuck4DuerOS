#!/system/bin/sh
# DuerOS Optimize - 卸载时恢复
#
# 把动画缩放恢复为默认，并重新启用被本模块禁用的预装包。
# 百度日志服务会在下次开机由 init 自动恢复。

LOG=/data/local/tmp/duer_optimize.log
log() { echo "[$(date '+%m-%d %H:%M:%S')] [uninstall] $*" >> "$LOG"; }

settings delete global window_animation_scale 2>/dev/null && log "动画缩放已恢复默认"
settings delete global transition_animation_scale 2>/dev/null
settings delete global animator_duration_scale 2>/dev/null

# 恢复被禁用的包
for p in com.baidu.duer.superapp; do
    pm enable "$p" 2>/dev/null && log "enabled $p"
done

log "duer_optimize 已卸载"
exit 0
