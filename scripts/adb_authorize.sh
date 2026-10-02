#!/system/bin/sh
# Fuck4DuerOS - 管理 ADB 授权公钥（无线场景专用）
#
# 背景：恢复 ro.adb.secure=1 之后，未授权的电脑需要【插 USB 线】才能在设备上
# 看到授权弹窗 —— AOSP 的 UsbDebuggingActivity 在 USB 未连接时会立即 finish()。
# 如果只有无线可用，就用本脚本把主机公钥直接写进 /data/misc/adb/adb_keys。
#
# 用法（设备端，需 root）：
#   su -c 'sh /data/local/tmp/adb_authorize.sh list'
#   su -c 'sh /data/local/tmp/adb_authorize.sh add "<adbkey.pub 的完整内容>"'
#   su -c 'sh /data/local/tmp/adb_authorize.sh remove <指纹前16位>'
#   su -c 'sh /data/local/tmp/adb_authorize.sh backup'
#
# 主机端取公钥：cat ~/.android/adbkey.pub

KEYS=/data/misc/adb/adb_keys
BACKUP=/data/local/tmp/adb_keys.backup

usage() { echo "用法: $0 {list|add <pubkey>|remove <指纹前缀>|backup|restore}"; exit 1; }

cmd="$1"; shift 2>/dev/null

case "$cmd" in
  list)
    echo "已授权公钥（$KEYS）："
    if [ -f "$KEYS" ]; then
      n=0
      while IFS= read -r line; do
        [ -z "$line" ] && continue
        n=$((n+1))
        # 指纹用公钥 base64 的 sha256 前 16 位表示，便于辨认
        fp=$(printf '%s' "$line" | sha256sum | cut -c1-16)
        echo "  [$n] $fp  ...${line##* }"
      done < "$KEYS"
      echo "共 $n 条"
    else
      echo "  （文件不存在）"
    fi
    ;;

  add)
    pub="$1"
    [ -n "$pub" ] || usage
    mkdir -p /data/misc/adb
    touch "$KEYS"
    if grep -qF "$pub" "$KEYS" 2>/dev/null; then
      echo "该公钥已存在，无需重复添加"
    else
      # 确保以换行结尾，避免和上一条粘在一起
      [ -s "$KEYS" ] && [ "$(tail -c1 "$KEYS" | wc -l)" = "0" ] && echo >> "$KEYS"
      printf '%s\n' "$pub" >> "$KEYS"
      chown system:shell "$KEYS" 2>/dev/null
      chmod 640 "$KEYS"
      echo "已添加。重启 adbd 后生效： setprop ctl.restart adbd"
    fi
    ;;

  remove)
    fp="$1"
    [ -n "$fp" ] || usage
    [ -f "$KEYS" ] || { echo "无 $KEYS"; exit 1; }
    cp -af "$KEYS" "$BACKUP.$$"
    tmp=/data/local/tmp/adb_keys.new
    : > "$tmp"
    hit=0
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      this=$(printf '%s' "$line" | sha256sum | cut -c1-16)
      case "$this" in
        "$fp"*) hit=1 ;;   # 命中，跳过（即删除）
        *) printf '%s\n' "$line" >> "$tmp" ;;
      esac
    done < "$KEYS"
    if [ "$hit" = "1" ]; then
      cp -af "$tmp" "$KEYS"
      chown system:shell "$KEYS" 2>/dev/null
      chmod 640 "$KEYS"
      echo "已删除指纹以 $fp 开头的公钥（原文件备份在 $BACKUP.$$）"
      echo "重启 adbd 后生效： setprop ctl.restart adbd"
    else
      echo "没有找到指纹以 $fp 开头的公钥"
    fi
    rm -f "$tmp"
    ;;

  backup)
    cp -af "$KEYS" "$BACKUP" && echo "已备份到 $BACKUP"
    ;;

  restore)
    [ -f "$BACKUP" ] || { echo "没有备份"; exit 1; }
    cp -af "$BACKUP" "$KEYS"
    chown system:shell "$KEYS" 2>/dev/null; chmod 640 "$KEYS"
    echo "已从 $BACKUP 恢复"
    ;;

  *) usage ;;
esac
