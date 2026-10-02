#!/bin/sh
# Fuck4DuerOS - 主机端取证包装脚本
#
# 把 collect_evidence.sh 推到设备、以 root 运行、再把结果拉回本地。
# 设备侧脚本是只读的：不 disable 包、不写 /system、不改网络。
#
# 用法：
#   ./scripts/collect_via_adb.sh [设备序列号] [本地输出目录]
#   ./scripts/collect_via_adb.sh <已隐去的内网地址>:5555 evidence/device-xd-see00-2301/session-2026-10-02

set -e

SERIAL="$1"
OUT="${2:-evidence/device-xd-see00-2301/session-$(date +%Y-%m-%d)}"
REMOTE=/data/local/tmp/f4d_evidence

if [ -n "$SERIAL" ]; then
    ADB="adb -s $SERIAL"
else
    ADB="adb"
fi

if [ -z "$($ADB devices | awk 'NR>1 && $2=="device" {print $1; exit}')" ]; then
    echo "❌ 没有处于 device 状态的 adb 设备" >&2
    exit 1
fi

echo "==> 推送脚本"
$ADB push scripts/collect_evidence.sh /data/local/tmp/collect_evidence.sh

echo "==> 设备端执行（需要 root）"
$ADB shell "su -c 'rm -rf $REMOTE; sh /data/local/tmp/collect_evidence.sh $REMOTE'"

echo "==> 拉回本地：$OUT"
mkdir -p "$OUT"
$ADB pull "$REMOTE/." "$OUT/"

echo
echo "✅ 取证完成：$OUT"
ls -la "$OUT"
