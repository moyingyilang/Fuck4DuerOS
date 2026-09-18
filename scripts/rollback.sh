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
