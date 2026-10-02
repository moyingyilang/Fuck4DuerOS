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
[ -d /data/adb/magisk ] && echo "  Magisk ✓"
[ -d /data/adb/ksu ]    && echo "  KernelSU ✓"
[ -d /data/adb/modules ] && echo "  模块目录 ✓" || echo "  ⚠️ 无模块目录"

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
echo "[PCDN 库覆盖验证]"
# 关键：Magisk 空文件覆盖只对「被解压到 lib 目录」的 native 库生效。
#   - 若 codePath 在 /system 且库已解压到 <codePath>/lib/<abi>/  -> 遮蔽有效
#   - 若应用是 UPDATED_SYSTEM_APP（codePath 在 /data/app）或 lib 目录为空
#     -> 动态链接器直接从 APK 内的 lib/<abi>-<...>/ 加载，遮蔽无效
for p in com.baidu.launcher com.baidu.duershow.media com.baidu.atomkit; do
    dump=$(dumpsys package "$p" 2>/dev/null)
    code=$(echo "$dump" | grep -E '^ *codePath=' | head -1 | sed 's/^ *codePath=//')
    abi=$(echo "$dump" | grep -E '^ *primaryCpuAbi=' | head -1 | sed 's/^ *primaryCpuAbi=//')
    [ -n "$code" ] || continue

    apk="$code/base.apk"
    [ -f "$apk" ] || apk=$(ls "$code"/*.apk 2>/dev/null | head -1)
    embeds=no
    [ -n "$apk" ] && [ -f "$apk" ] && unzip -l "$apk" 2>/dev/null | grep -q 'libcyber-pcdn\.so' && embeds=yes

    # 解压后的库是否落地在 codePath/lib 下（被遮蔽时会存在且为 0 字节）
    extracted=""
    for cand in "$code/lib/$abi/libcyber-pcdn.so" "$code/lib/arm64/libcyber-pcdn.so" "$code/lib/arm/libcyber-pcdn.so"; do
        [ -e "$cand" ] && { extracted="$cand"; break; }
    done

    if [ -n "$extracted" ]; then
        echo "  ✓  $p 库已解压并被遮蔽：$extracted"
    elif [ "$embeds" = "yes" ]; then
        echo "  ⚠️  $p 库从 APK 内直接加载，遮蔽无效"
        echo "      codePath=$code"
        echo "      apk=$apk"
    else
        echo "  ✓  $p 未发现 libcyber-pcdn.so"
    fi
done

# 用户空间应用也可能带 PCDN 库
extra=$(find /data/app -iname '*pcdn*' 2>/dev/null)
[ -n "$extra" ] && {
    echo "  ⚠️  /data/app 下发现 PCDN 库（非系统预置，模块不覆盖）："
    echo "$extra" | sed 's/^/      /'
}

echo "  ⚠️  = 该应用的 PCDN 库实际可被动态链接器加载。"

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
