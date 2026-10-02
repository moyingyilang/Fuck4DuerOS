#!/system/bin/sh
# DuerOS DevRestore - 开机后恢复被 ROM 禁用的系统页面
#
# ROM 通过「组件级禁用」藏掉了一批页面（在 package-restrictions.xml 里），
# 最典型的是开发者选项整页：系统里同时存在一个
# DevelopmentSettingsDisabledActivity，专门用来显示「此用户无法使用开发者选项」。
#
# 本模块把它 ROM 禁用的那批组件重新启用。刻意不动：
#   com.android.settings.CryptKeeper          —— 加密密码界面，属启动路径
#   com.android.provision.DefaultActivity     —— 开机向导

MODDIR=${0%/*}
LOG=/data/local/tmp/duer_devrestore.log
log() { echo "[$(date '+%m-%d %H:%M:%S')] [service] $*" >> "$LOG"; }

n=0
while [ "$(getprop sys.boot_completed)" != "1" ] && [ $n -lt 120 ]; do
    sleep 5; n=$((n+1))
done
[ "$(getprop sys.boot_completed)" = "1" ] || { log "等待开机超时"; exit 1; }
sleep 15

log "================ duer_devrestore 开始 ================"

# ---------- 1. 兜底：确保 adbd 以鉴权模式运行 ----------
if [ "$(getprop ro.adb.secure)" != "1" ]; then
    resetprop ro.adb.secure 1 2>/dev/null
    log "resetprop ro.adb.secure 1"
fi

# ---------- 2. 重新启用被 ROM 禁用的系统页面 ----------
COMPONENTS="
com.android.settings/.Settings\$DevelopmentSettingsDashboardActivity
com.android.settings/.Settings\$NavigationBarSettingsActivity
com.android.settings/.Settings\$UserSettingsActivity
com.android.traceur/.StorageProvider
com.android.traceur/.QsService
"

for c in $COMPONENTS; do
    pkg="${c%%/*}"
    comp="${c#*/}"
    comp="${comp#.}"
    comp="$pkg.$comp"
    if dumpsys package "$pkg" 2>/dev/null | sed -n "/disabledComponents/,/enabledComponents/p" | grep -q "$comp"; then
        out=$(pm enable --user 0 "$c" 2>&1)
        log "enable $c -> $out"
    fi
done

# ---------- 3. 开发者选项总开关 ----------
if [ "$(settings get global development_settings_enabled 2>/dev/null)" != "1" ]; then
    settings put global development_settings_enabled 1
    log "development_settings_enabled -> 1"
fi

log "================ duer_devrestore 完成 ================"
exit 0
