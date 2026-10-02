#!/bin/sh
# Fuck4DuerOS - 主机端优化执行包装
#
# 用法：
#   ./scripts/optimize_via_adb.sh          # 应用优化
#   ./scripts/optimize_via_adb.sh revert   # 回滚
set -e

MODE="${1:-apply}"
if [ -n "$ADB_SERIAL" ]; then ADB="adb -s $ADB_SERIAL"; else ADB="adb"; fi

if [ -z "$($ADB devices | awk 'NR>1 && $2=="device" {print $1; exit}')" ]; then
  echo "❌ 没有处于 device 状态的 adb 设备" >&2
  exit 1
fi

if [ "$MODE" = "revert" ]; then
  SCRIPT=revert_optimize.sh
else
  SCRIPT=optimize.sh
fi

echo "==> 推送 $SCRIPT"
$ADB push "scripts/$SCRIPT" "/data/local/tmp/$SCRIPT"

echo "==> 设备端执行（需要 root）"
$ADB shell "su -c 'sh /data/local/tmp/$SCRIPT'"
