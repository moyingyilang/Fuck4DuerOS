#!/system/bin/sh
# Fuck4DuerOS - 恢复被 ROM 禁用的系统页面
#
# 这台 DuerOS 定制 ROM 通过「组件级禁用」藏掉了一批页面，最典型的是
# 开发者选项整页（Settings$DevelopmentSettingsDashboardActivity）——
# 系统里仍然有 DevelopmentSettingsDisabledActivity 专门用来显示
# 「此用户无法使用开发者选项」。
#
# 本脚本把 ROM 禁用的系统组件逐项启用，并打开开发者选项总开关。
# 每一项都可以用 pm disable 单独还原。
#
# 用法（设备端，需 root）：
#   su -c 'sh /data/local/tmp/restore_dev_pages.sh'

LOG=/data/local/tmp/f4d_restore_pages.log
log() { echo "[$(date '+%m-%d %H:%M:%S')] $*" >> "$LOG"; }

# ROM 禁用、且属于「系统/开发者功能」而不是启动关键路径的组件。
# 注意：刻意不动 com.android.settings.CryptKeeper（加密密码界面，属启动路径）
# 与 com.android.provision.DefaultActivity（开机向导）。
COMPONENTS="
com.android.settings/.Settings\$DevelopmentSettingsDashboardActivity
com.android.settings/.Settings\$NavigationBarSettingsActivity
com.android.settings/.Settings\$UserSettingsActivity
com.android.traceur/.StorageProvider
com.android.traceur/.QsService
com.android.permissioncontroller/.role.ui.SpecialAppAccessListActivity
"

log "================ 恢复系统页面 ================"

for c in $COMPONENTS; do
    # 已经是启用状态就跳过
    if dumpsys package "${c%%/*}" 2>/dev/null | grep -q "enabledComponents" ; then
        :
    fi
    out=$(pm enable --user 0 "$c" 2>&1)
    log "$c -> $out"
    echo "  $c"
    echo "      $out"
done

# 开发者选项总开关（否则「开发者选项」入口本身不显示）
settings put global development_settings_enabled 1
log "development_settings_enabled = 1"
echo
echo "  development_settings_enabled -> $(settings get global development_settings_enabled)"

log "================ 完成 ================"
echo
echo "已恢复的页面："
echo "  · 开发者选项        / 设置 -> 系统 -> 开发者选项"
echo "  · 导航栏设置"
echo "  · 多用户设置"
echo "  · 系统跟踪 System Tracing（开发者选项 -> 系统跟踪）"
echo "  · 特殊应用访问权限"
