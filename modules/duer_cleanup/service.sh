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
