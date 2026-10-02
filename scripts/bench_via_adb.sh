#!/bin/sh
# Fuck4DuerOS - 主机端基线测量包装
#
# 把 bench.sh 推到设备、以 root 运行、再把结果拉回本地。
# 设备侧脚本只读，不修改任何状态。
#
# 用法：
#   ./scripts/bench_via_adb.sh before
#   ./scripts/bench_via_adb.sh after
#   ./scripts/bench_via_adb.sh before evidence/device-xd-see00-2301/optimize

set -e

LABEL="${1:?用法: $0 <before|after|标签> [本地输出目录]}"
OUT="${2:-evidence/device-xd-see00-2301/optimize}"
REMOTE=/data/local/tmp/f4d_bench

if [ -n "$ADB_SERIAL" ]; then
    ADB="adb -s $ADB_SERIAL"
else
    ADB="adb"
fi

if [ -z "$($ADB devices | awk 'NR>1 && $2=="device" {print $1; exit}')" ]; then
    echo "❌ 没有处于 device 状态的 adb 设备" >&2
    exit 1
fi

echo "==> 推送 bench.sh"
$ADB push scripts/bench.sh /data/local/tmp/bench.sh

echo "==> 设备端采集（$LABEL）"
$ADB shell "su -c 'sh /data/local/tmp/bench.sh $LABEL $REMOTE'"

echo "==> 拉回本地：$OUT/$LABEL"
mkdir -p "$OUT"
$ADB pull "$REMOTE/$LABEL" "$OUT/"

echo
echo "✅ 基线已保存：$OUT/$LABEL"
