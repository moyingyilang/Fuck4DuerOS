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

# ---------- 1. 兜底：确保授权弹窗不会被 SKU 分支吞掉 ----------
if [ "$(getprop ro.boot.skuid)" = "600WW" ]; then
    resetprop ro.boot.skuid 0 2>/dev/null
    log "ro.boot.skuid -> $(getprop ro.boot.skuid)"
fi

# ---------- 2. 兜底：确保 adbd 以鉴权模式运行 ----------
if [ "$(getprop ro.adb.secure)" != "1" ]; then
    resetprop ro.adb.secure 1 2>/dev/null
    log "resetprop ro.adb.secure 1"
fi

# ---------- 3. 重新启用被 ROM 禁用的系统页面 ----------
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

# ---------- 4. SELinux 策略补丁（不重启也生效） ----------
# Magisk 在开机加载策略时会自动应用 sepolicy.rule；
# 这里再做一次运行时兜底，这样装完模块不用重启也能打开开发者选项。
MAGISKPOLICY=/data/adb/magisk/magiskpolicy
if [ -x "$MAGISKPOLICY" ] && [ -f "$MODDIR/sepolicy.rule" ]; then
    while IFS= read -r line; do
        case "$line" in
            ""|"#"*) continue ;;
        esac
        "$MAGISKPOLICY" --live "$line" 2>/dev/null && log "sepolicy: $line"
    done < "$MODDIR/sepolicy.rule"
fi

# ---------- 5. USB 调试开关 ----------
# ROM 里 adb_enabled=0，USB 插上电脑也不会出现 adb 接口，
# 也就永远走不到授权弹窗那一步。这里把它打开。
# （USB 功能本身由系统按 adb_enabled 自动切换，脚本不强行写 sys.usb.config）
if [ "$(settings get global adb_enabled 2>/dev/null)" != "1" ]; then
    settings put global adb_enabled 1
    log "adb_enabled -> 1"
fi

# ---------- 6. 开发者选项总开关 ----------
if [ "$(settings get global development_settings_enabled 2>/dev/null)" != "1" ]; then
    settings put global development_settings_enabled 1
    log "development_settings_enabled -> 1"
fi

# ---------- 7. 恢复无线 ADB 监听端口 ----------
# service.adb.tcp.port 是 service.* 属性，非持久，重启即丢。
# 日常用无线 adb 的话必须重新设置，否则重启后只剩 USB 通道。
# 鉴权（ro.adb.secure=1）此时已开启，只有已授权密钥能连上。
# 不需要无线 adb 的话，删掉这一段即可。
if [ "$(getprop service.adb.tcp.port)" != "5555" ]; then
    setprop service.adb.tcp.port 5555
    sleep 1
    setprop ctl.restart adbd 2>/dev/null
    log "service.adb.tcp.port -> 5555（无线 adb 已恢复）"
fi

log "================ duer_devrestore 完成 ================"
exit 0
