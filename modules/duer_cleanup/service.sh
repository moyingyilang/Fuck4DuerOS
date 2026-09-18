#!/system/bin/sh
# 等 boot 完成
while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 5; done
sleep 15

PM=/system/bin/pm
for p in \
    com.baidu.pcdn \
    com.baidu.duerguard \
    com.baidu.duer.ota \
    com.baidu.duershow.statistic \
    com.baidu.duer.appstore \
    com.baidu.baidutranslate \
    com.baidu.input \
    com.baidu.atomkit \
    com.baidu.duer.aieye.searchquestion \
    com.baidu.duer.aieye.image.preprocessing \
    com.baidu.duer.aieye.correction \
    com.goodfather.textbook.pad
do
    $PM disable "$p" 2>/dev/null
    $PM disable-user --user 0 "$p" 2>/dev/null
done

# 通讯组件
for c in \
    com.baidu.launcher/com.baidu.duer.child.service.ContactsControlService \
    com.baidu.launcher/com.xiaoyu.communication.activity.CallPhoneActivity \
    com.baidu.launcher/com.xiaoyu.communication.telecom.TelecomCallVoltePhoneActivity \
    com.baidu.launcher/com.xiaoyu.communication.activity.global.SelectDefaultPhoneActivity \
    com.baidu.launcher/com.baidu.duer.account.sms.SmsLoginActivity \
    com.baidu.launcher/com.baidu.duer.prism.PrismStatusReiver
do
    $PM disable "$c" 2>/dev/null
done

# 强杀 pcdn
am force-stop com.baidu.pcdn 2>/dev/null
