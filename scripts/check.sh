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
