#!/system/bin/sh
# DuerOS DevRestore - 卸载
#
# ro.adb.secure 是 ro.* 属性，重启后由 ROM 的 build.prop 还原为 0，
# 无需在这里处理。被启用的系统组件也不会被本模块重新禁用
# （如需还原，用 pm disable 单独处理，见 docs/restore-removed-pages.md）。

LOG=/data/local/tmp/duer_devrestore.log
echo "[$(date '+%m-%d %H:%M:%S')] [uninstall] duer_devrestore 已卸载" >> "$LOG"
exit 0
