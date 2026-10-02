#!/bin/sh
# Fuck4DuerOS - 通用 Magisk 模块安装脚本
#
# 用法：
#   ./scripts/install_module.sh duer_optimize
#   ./scripts/install_module.sh duer_devrestore
#
# adb push 以 shell 用户运行，写不进 /data/adb，所以先推到 /data/local/tmp
# 再由 root 拷贝到 /data/adb/modules/。
set -e

NAME="${1:?用法: $0 <模块目录名>  例如 duer_optimize}"
SRC="modules/$NAME"

[ -d "$SRC" ] || { echo "❌ 找不到模块目录 $SRC" >&2; exit 1; }

if [ -n "$ADB_SERIAL" ]; then ADB="adb -s $ADB_SERIAL"; else ADB="adb"; fi

if [ -z "$($ADB devices | awk 'NR>1 && $2=="device" {print $1; exit}')" ]; then
    echo "❌ 没有处于 device 状态的 adb 设备" >&2
    exit 1
fi

DEST="/data/adb/modules/$NAME"
STAGE="/data/local/tmp/f4d_stage_$NAME"

echo "==> 推送到暂存目录"
$ADB shell "rm -rf $STAGE && mkdir -p $STAGE"
$ADB push "$SRC/." "$STAGE/"

echo "==> 以 root 安装到 $DEST"
$ADB shell "su -c 'rm -rf $DEST && mkdir -p $DEST && cp -af $STAGE/. $DEST/ && chmod 755 $DEST/*.sh 2>/dev/null; chmod 644 $DEST/module.prop 2>/dev/null; chown -R root:root $DEST && rm -rf $STAGE && ls -la $DEST'"

echo
echo "✅ $NAME 已安装，下次开机自动生效。"
