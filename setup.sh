#!/bin/bash
# Fuck4DuerOS 内容填充脚本
# 用法: cd Fuck4DuerOS && bash ../fill.sh

set -e

if [ ! -f "README.md" ]; then
    echo "❌ 请在 Fuck4DuerOS 目录下执行"
    exit 1
fi

# ============================================================
# scripts/check.sh
# ============================================================
cat > scripts/check.sh << 'EOF_CHECK'
#!/system/bin/sh
# Fuck4DuerOS - 侦察脚本
# 不修改任何东西，只报告当前状态

echo "=========================================="
echo " Fuck4DuerOS - 侦察报告"
echo " $(date)"
echo "=========================================="

echo ""
echo "[设备信息]"
getprop ro.product.brand 2>/dev/null | sed 's/^/  品牌: /'
getprop ro.product.model 2>/dev/null | sed 's/^/  型号: /'
getprop ro.build.version.release 2>/dev/null | sed 's/^/  Android: /'
getprop ro.build.version.sdk 2>/dev/null | sed 's/^/  SDK: /'

echo ""
echo "[Root 环境]"
if [ -d /data/adb/magisk ]; then echo "  Magisk ✓"; fi
if [ -d /data/adb/ksu ]; then echo "  KernelSU ✓"; fi
if [ -d /data/adb/modules ]; then echo "  模块目录 ✓"; else echo "  ⚠️ 无模块目录"; fi

echo ""
echo "[百度进程]"
ps -A 2>/dev/null | grep -iE "baidu|duer|pcdn|goodfather" | awk '{print "  " $9}'

echo ""
echo "[已禁用包]"
pm list packages -d 2>/dev/null | grep -iE "baidu|duer|goodfather" | sed 's/package:/  /'

echo ""
echo "[通讯状态]"
echo -n "  拨号: "
cmd package resolve-activity --brief -a android.intent.action.DIAL 2>/dev/null | tail -1
echo -n "  短信: "
cmd package resolve-activity --brief -a android.intent.action.SENDTO -d sms: 2>/dev/null | tail -1

echo ""
echo "[PCDN 库文件]"
for so in \
    /system/app/DuerShowSwan/lib/arm64/libcyber-pcdn.so \
    /system/app/DuerShowMedia/lib/arm64/libcyber-pcdn.so \
    /system/app/DuerShowLauncher/lib/arm64/libcyber-pcdn.so
do
    if [ -f "$so" ]; then
        size=$(stat -c %s "$so" 2>/dev/null)
        echo "  ${so##*/} = $size 字节"
    else
        echo "  ${so##*/} 不存在"
    fi
done

echo ""
echo "[关键系统组件]"
for p in \
    /system/app/PCDN \
    /system/app/Duerguard \
    /system/app/GoodFather_DuerPhone \
    /system/priv-app/DuerShowStatistic \
    /system/priv-app/DuerShowOTA
do
    if [ -d "$p" ]; then echo "  存在: $p"; else echo "  已清: $p"; fi
done

echo ""
echo "[Magisk 模块]"
if [ -d /data/adb/modules/duer_cleanup ]; then
    if [ -f /data/adb/modules/duer_cleanup/disable ]; then
        echo "  duer_cleanup 已安装但被禁用"
    else
        echo "  duer_cleanup 已安装并启用"
    fi
else
    echo "  duer_cleanup 未安装"
fi

echo ""
echo "[hosts 屏蔽]"
if grep -q "pcdn.baidu.com" /system/etc/hosts 2>/dev/null; then
    echo "  ✓ 已屏蔽百度上报域名"
    grep baidu /system/etc/hosts 2>/dev/null | sed 's/^/    /'
else
    echo "  ✗ 未屏蔽"
fi

echo ""
echo "=========================================="
echo " 侦察完成。如果以上信息符合预期，可执行 install.sh"
echo "=========================================="
EOF_CHECK
chmod +x scripts/check.sh

# ============================================================
# scripts/install.sh
# ============================================================
cat > scripts/install.sh << 'EOF_INSTALL'
#!/system/bin/sh
# Fuck4DuerOS - 一键执行
# 生成 Magisk 模块 + 设置 hosts + 禁用组件

set -e

MODDIR="/data/adb/modules/duer_cleanup"
LOG="/data/local/tmp/fuck4dueros_install.log"

log() {
    echo "[$(date '+%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

log "=== Fuck4DuerOS 开始 ==="

if [ "$(id -u)" != "0" ]; then
    log "❌ 需要 root 权限"
    exit 1
fi

# 备份旧的
if [ -d "$MODDIR" ]; then
    log "检测到旧模块，备份到 /sdcard/fuck4dueros_backup/"
    mkdir -p /sdcard/fuck4dueros_backup
    cp -r "$MODDIR" /sdcard/fuck4dueros_backup/ 2>/dev/null || true
    rm -rf "$MODDIR"
fi

# 创建模块
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

# system 目录覆盖
log "准备 system 覆盖..."
for d in \
    app/PCDN \
    app/Duerguard \
    app/GoodFather_DuerPhone \
    app/BaiduVoiceInput \
    app/SearchQuestion \
    priv-app/DuerShowStatistic \
    priv-app/DuerShowOTA
do
    mkdir -p "$SYS/$(dirname $d)"
    mkdir -p "$SYS/$d"
    touch "$SYS/$d/.replace"
done

# PCDN 库覆盖为空
for so in \
    app/DuerShowSwan/lib/arm64/libcyber-pcdn.so \
    app/DuerShowMedia/lib/arm64/libcyber-pcdn.so \
    app/DuerShowLauncher/lib/arm64/libcyber-pcdn.so
do
    mkdir -p "$SYS/$(dirname $so)"
    : > "$SYS/$so"
done

# hosts
log "添加 hosts 屏蔽..."
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

# service.sh
log "生成 service.sh..."
cat > "$MODDIR/service.sh" << 'EOF_SVC'
#!/system/bin/sh
LOG=/data/local/tmp/fuck4dueros.log
PKG=/system/bin/pm
CMD=/system/bin/cmd

log() { echo "[$(date '+%m-%d %H:%M:%S')] $1" >> "$LOG"; }

n=0
while [ "$(getprop sys.boot_completed)" != "1" ] && [ $n -lt 120 ]; do
    sleep 5
    n=$((n+1))
done
sleep 15

log "=== Fuck4DuerOS service.sh 开始 ==="

for p in \
    com.baidu.pcdn \
    com.baidu.duerguard \
    com.baidu.duer.ota \
    com.baidu.duershow.statistic \
    com.goodfather.textbook.pad \
    com.baidu.duer.appstore \
    com.baidu.baidutranslate \
    com.baidu.input \
    com.baidu.atomkit \
    com.baidu.duer.aieye.searchquestion \
    com.baidu.duer.aieye.image.preprocessing \
    com.baidu.duer.aieye.correction
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

log "=== Fuck4DuerOS service.sh 完成 ==="
EOF_SVC
chmod 755 "$MODDIR/service.sh"

# 立即生效
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

log "=== 安装完成 ==="

echo ""
echo "=========================================="
echo " ✅ 安装完成"
echo "=========================================="
echo " 模块: $MODDIR"
echo " 日志: /data/local/tmp/fuck4dueros.log"
echo ""
echo " 请重启设备: reboot"
echo "=========================================="
EOF_INSTALL
chmod +x scripts/install.sh

# ============================================================
# scripts/rollback.sh
# ============================================================
cat > scripts/rollback.sh << 'EOF_ROLLBACK'
#!/system/bin/sh
# Fuck4DuerOS - 回滚

echo "=========================================="
echo " Fuck4DuerOS - 回滚"
echo "=========================================="

if [ -d /data/adb/modules/duer_cleanup ]; then
    echo "删除 Magisk 模块..."
    rm -rf /data/adb/modules/duer_cleanup
fi

echo "恢复禁用的组件..."
for p in \
    com.baidu.pcdn com.baidu.duerguard com.baidu.duer.ota \
    com.baidu.duershow.statistic com.goodfather.textbook.pad \
    com.baidu.duer.appstore com.baidu.baidutranslate com.baidu.input \
    com.baidu.atomkit com.baidu.duer.aieye.searchquestion \
    com.baidu.duer.aieye.image.preprocessing com.baidu.duer.aieye.correction
do
    pm enable "$p" 2>/dev/null
done

for c in \
    com.baidu.launcher/com.baidu.duer.child.service.ContactsControlService \
    com.baidu.launcher/com.xiaoyu.communication.activity.CallPhoneActivity \
    com.baidu.launcher/com.xiaoyu.communication.telecom.TelecomCallVoltePhoneActivity \
    com.baidu.launcher/com.xiaoyu.communication.activity.global.SelectDefaultPhoneActivity \
    com.baidu.launcher/com.baidu.duer.account.sms.SmsLoginActivity \
    com.baidu.launcher/com.baidu.duer.prism.PrismStatusReiver
do
    pm enable "$c" 2>/dev/null
done

echo ""
echo "=========================================="
echo " ✅ 回滚完成，请重启: reboot"
echo "=========================================="
EOF_ROLLBACK
chmod +x scripts/rollback.sh

# ============================================================
# modules/duer_cleanup/system/etc/hosts
# ============================================================
mkdir -p modules/duer_cleanup/system/etc
cat > modules/duer_cleanup/system/etc/hosts << 'EOF_HOSTS'
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
EOF_HOSTS

# ============================================================
# modules/duer_cleanup/service.sh
# ============================================================
cp modules/duer_cleanup/service.sh modules/duer_cleanup/service.sh.bak 2>/dev/null || true
cat > modules/duer_cleanup/service.sh << 'EOF_MODSVC'
#!/system/bin/sh
LOG=/data/local/tmp/fuck4dueros.log
PKG=/system/bin/pm
CMD=/system/bin/cmd

log() { echo "[$(date '+%m-%d %H:%M:%S')] $1" >> "$LOG"; }

n=0
while [ "$(getprop sys.boot_completed)" != "1" ] && [ $n -lt 120 ]; do
    sleep 5
    n=$((n+1))
done
sleep 15

log "=== Fuck4DuerOS service.sh 开始 ==="

for p in \
    com.baidu.pcdn \
    com.baidu.duerguard \
    com.baidu.duer.ota \
    com.baidu.duershow.statistic \
    com.goodfather.textbook.pad \
    com.baidu.duer.appstore \
    com.baidu.baidutranslate \
    com.baidu.input \
    com.baidu.atomkit \
    com.baidu.duer.aieye.searchquestion \
    com.baidu.duer.aieye.image.preprocessing \
    com.baidu.duer.aieye.correction
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

log "=== Fuck4DuerOS service.sh 完成 ==="
EOF_MODSVC
chmod +x modules/duer_cleanup/service.sh
rm -f modules/duer_cleanup/service.sh.bak

echo ""
echo "=========================================="
echo " ✅ scripts/ 和 modules/ 填充完成"
echo "=========================================="
echo ""
echo "文件:"
find scripts modules -type f | sort | sed 's/^/  /'
echo ""
echo "下一步:"
echo "  1. 填写 docs/ 下的三个文档"
echo "  2. git add . && git commit -m 'feat: 填充脚本和模块'"
echo "  3. git push"
