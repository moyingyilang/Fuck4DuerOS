#!/system/bin/sh
# Fuck4DuerOS - 一键安装
# 生成 Magisk 模块 + 设置 hosts + 禁用组件

set -e

MODDIR="/data/adb/modules/duer_cleanup"
LOG="/data/local/tmp/fuck4dueros_install.log"

log() { echo "[$(date '+%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }

log "=== Fuck4DuerOS 开始 ==="

[ "$(id -u)" != "0" ] && { log "❌ 需要 root 权限"; exit 1; }

if [ -d "$MODDIR" ]; then
    log "备份旧模块到 /sdcard/fuck4dueros_backup/"
    mkdir -p /sdcard/fuck4dueros_backup
    cp -r "$MODDIR" /sdcard/fuck4dueros_backup/ 2>/dev/null || true
    rm -rf "$MODDIR"
fi

log "创建 Magisk 模块..."
mkdir -p "$MODDIR/system"
cd "$MODDIR"

cat > module.prop << 'EOF'
id=duer_cleanup
name=DuerOS Cleanup
version=1.0
versionCode=1
author=moyingyilang
description=Block baidu pcdn/duerguard/goodfather and system residuals
EOF

SYS="$MODDIR/system"

log "准备 system 覆盖..."
for d in \
    app/PCDN app/Duerguard app/GoodFather_DuerPhone \
    app/BaiduVoiceInput app/SearchQuestion \
    priv-app/DuerShowStatistic priv-app/DuerShowOTA
do
    mkdir -p "$SYS/$(dirname $d)/$(basename $d)"
    touch "$SYS/$d/.replace"
done

for so in \
    app/DuerShowSwan/lib/arm64/libcyber-pcdn.so \
    app/DuerShowMedia/lib/arm64/libcyber-pcdn.so \
    app/DuerShowLauncher/lib/arm64/libcyber-pcdn.so
do
    mkdir -p "$SYS/$(dirname $so)"
    : > "$SYS/$so"
done

log "添加 hosts..."
mkdir -p "$SYS/etc"
cat > "$SYS/etc/hosts" << 'EOF'
127.0.0.1 localhost
::1 localhost

# === DuerOS / Baidu Block ===
127.0.0.1 pcdn.baidu.com
127.0.0.1 xray.baidu.com
127.0.0.1 duer.baidu.com
127.0.0.1 dueros.baidu.com
127.0.0.1 ota.baidu.com
127.0.0.1 statistic.baidu.com
127.0.0.1 ag.baidu.com
127.0.0.1 mobads.baidu.com
127.0.0.1 pos.baidu.com
127.0.0.1 cpro.baidu.com
127.0.0.1 union.baidu.com
127.0.0.1 dup.baidustatic.com
127.0.0.1 dudulu.duer.baidu.com
127.0.0.1 duer-static.baidu.com
127.0.0.1 duer.baidu.com.cn
127.0.0.1 dueros-h2.baidu.com
127.0.0.1 duer-ota.baidu.com
EOF
chmod 644 "$SYS/etc/hosts"

log "生成 service.sh..."
cat > "$MODDIR/service.sh" << 'EOF_SVC'
#!/system/bin/sh
LOG=/data/local/tmp/fuck4dueros.log
PKG=/system/bin/pm
CMD=/system/bin/cmd
log() { echo "[$(date '+%m-%d %H:%M:%S')] $1" >> "$LOG"; }

n=0
while [ "$(getprop sys.boot_completed)" != "1" ] && [ $n -lt 120 ]; do
    sleep 5; n=$((n+1))
done
sleep 15

log "=== Fuck4DuerOS 开始 ==="
for p in \
    com.baidu.pcdn com.baidu.duerguard com.baidu.duer.ota \
    com.baidu.duershow.statistic com.goodfather.textbook.pad \
    com.baidu.duer.appstore com.baidu.baidutranslate com.baidu.input \
    com.baidu.atomkit com.baidu.duer.aieye.searchquestion \
    com.baidu.duer.aieye.image.preprocessing com.baidu.duer.aieye.correction
do
    $PKG disable "$p" 2>/dev/null && log "disabled $p"
done

for c in \
    com.baidu.launcher/com.baidu.duer.child.service.ContactsControlService \
    com.baidu.launcher/com.xiaoyu.communication.activity.CallPhoneActivity \
    com.baidu.launcher/com.xiaoyu.communication.telecom.TelecomCallVoltePhoneActivity \
    com.baidu.launcher/com.xiaoyu.communication.activity.global.SelectDefaultPhoneActivity \
    com.baidu.launcher/com.baidu.duer.account.sms.SmsLoginActivity \
    com.baidu.launcher/com.baidu.duer.prism.PrismStatusReiver
do
    $PKG disable "$c" 2>/dev/null && log "disabled $c"
done

$CMD role add-role-holder android.app.role.DIALER com.android.dialer 2>/dev/null
$CMD role add-role-holder android.app.role.SMS com.android.messaging 2>/dev/null
am force-stop com.baidu.pcdn 2>/dev/null
log "=== Fuck4DuerOS 完成 ==="
EOF_SVC
chmod 755 "$MODDIR/service.sh"

log "应用变更到当前系统..."
for p in \
    com.baidu.pcdn com.baidu.duerguard com.baidu.duer.ota \
    com.baidu.duershow.statistic com.goodfather.textbook.pad \
    com.baidu.duer.appstore com.baidu.baidutranslate com.baidu.input com.baidu.atomkit
do
    pm disable "$p" 2>/dev/null
done

for c in \
    com.baidu.launcher/com.baidu.duer.child.service.ContactsControlService \
    com.baidu.launcher/com.xiaoyu.communication.activity.CallPhoneActivity \
    com.baidu.launcher/com.xiaoyu.communication.telecom.TelecomCallVoltePhoneActivity \
    com.baidu.launcher/com.xiaoyu.communication.activity.global.SelectDefaultPhoneActivity \
    com.baidu.launcher/com.baidu.duer.account.sms.SmsLoginActivity \
    com.baidu.launcher/com.baidu.duer.prism.PrismStatusReiver
do
    pm disable "$c" 2>/dev/null
done

cmd role add-role-holder android.app.role.DIALER com.android.dialer 2>/dev/null
cmd role add-role-holder android.app.role.SMS com.android.messaging 2>/dev/null
am force-stop com.baidu.pcdn 2>/dev/null

chmod -R 755 "$MODDIR"
chmod 644 "$MODDIR/module.prop"

echo ""
echo "✅ 安装完成，请重启: reboot"
