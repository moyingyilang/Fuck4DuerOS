#!/system/bin/sh
# Fuck4DuerOS - 设备取证采集（只读）
#
# 在设备上以 root 运行，把 DuerOS 定制痕迹导出成一组纯文本文件，便于提交到仓库
# 或用于同类设备比对。本脚本不修改设备上的任何状态：不 disable/卸载任何包，不写
# /system，不改变网络配置。
#
# 用法（设备端）：
#   su -c 'sh /data/local/tmp/collect_evidence.sh [输出目录]'
# 用法（主机端，推荐）：
#   ./scripts/collect_via_adb.sh
#
# 默认输出目录：/data/local/tmp/f4d_evidence

OUT="${1:-/data/local/tmp/f4d_evidence}"
mkdir -p "$OUT" || exit 1

say() { echo "==> $1"; }

# ---------------------------------------------------------------------------
say "device_info"
{
  for p in ro.product.brand ro.product.model ro.product.device ro.product.name \
           ro.build.display.id ro.build.version.release ro.build.version.sdk \
           ro.build.fingerprint ro.build.date ro.build.type ro.build.tags \
           ro.product.manufacturer ro.boot.verifiedbootstate \
           ro.boot.flash.locked ro.secure ro.debuggable; do
    printf '%-32s %s\n' "$p" "$(getprop "$p")"
  done
} > "$OUT/device_info.txt" 2>&1

# ---------------------------------------------------------------------------
say "root_env"
{
  echo "# id"
  id
  echo
  echo "# su -c id"
  su -c id 2>&1
  echo
  echo "# magisk"
  command -v magisk
  magisk -V 2>&1
  echo
  echo "# modules (/data/adb/modules)"
  ls -1 /data/adb/modules 2>&1
  echo
  echo "# enabled modules (module.prop)"
  for d in /data/adb/modules/*/; do
    [ -f "$d/module.prop" ] || continue
    [ -f "$d/disable" ] && continue
    echo "--- ${d%/}"
    cat "$d/module.prop"
  done
} > "$OUT/root_env.txt" 2>&1

# ---------------------------------------------------------------------------
say "processes"
{
  echo "# ps -A"
  ps -A -o PID,PPID,USER,NAME 2>/dev/null || ps -A
  echo
  echo "# baidu/duer/pcdn/xray 相关进程"
  ps -A -o PID,PPID,USER,NAME 2>/dev/null | grep -iE 'baidu|duer|pcdn|xray|goodfather|xiaodu'
} > "$OUT/processes.txt" 2>&1

# ---------------------------------------------------------------------------
say "packages"
{
  echo "# 所有含 baidu/duer/xiaodu/goodfather 的包"
  pm list packages 2>/dev/null | grep -iE 'baidu|duer|xiaodu|goodfather'
  echo
  echo "# 已禁用"
  pm list packages -d 2>/dev/null | grep -iE 'baidu|duer|xiaodu|goodfather'
  echo
  echo "# 已启用"
  pm list packages -e 2>/dev/null | grep -iE 'baidu|duer|xiaodu|goodfather'
  echo
  echo "# 系统预置"
  pm list packages -s 2>/dev/null | grep -iE 'baidu|duer|xiaodu|goodfather'
  echo
  echo "# APK 路径"
  for p in $(pm list packages 2>/dev/null | grep -iE 'baidu|duer|xiaodu|goodfather' | sed 's/^package://'); do
    echo "--- $p"
    pm path "$p" 2>/dev/null
  done
} > "$OUT/packages.txt" 2>&1

# ---------------------------------------------------------------------------
say "system_apps"
{
  echo "# /system/app"
  ls -1 /system/app 2>&1
  echo
  echo "# /system/priv-app"
  ls -1 /system/priv-app 2>&1
  echo
  echo "# /system_ext/app"
  ls -1 /system_ext/app 2>&1
  echo
  echo "# /system_ext/priv-app"
  ls -1 /system_ext/priv-app 2>&1
  echo
  echo "# /system/preloadapp"
  ls -1 /system/preloadapp 2>&1
} > "$OUT/system_apps.txt" 2>&1

# ---------------------------------------------------------------------------
say "pcdn_artifacts"
{
  echo "# 路径名含 pcdn/xray 的文件"
  find /system /system_ext /product /vendor /data/app 2>/dev/null \
    \( -iname '*pcdn*' -o -iname '*xray*' \) -print
  echo
  echo "# libcyber-pcdn.so 大小（0 表示已被 Magisk 模块遮蔽）"
  for f in \
      /system/app/DuerShowSwan/lib/arm64/libcyber-pcdn.so \
      /system/app/DuerShowMedia/lib/arm64/libcyber-pcdn.so \
      /system/app/DuerShowLauncher/lib/arm64/libcyber-pcdn.so; do
    printf '%-70s %s\n' "$f" "$(stat -c %s "$f" 2>/dev/null || echo MISSING)"
  done
  echo
  echo "# 已加载的 pcdn/xray 映射（运行中的进程）"
  for pid in $(ls /proc 2>/dev/null | grep -E '^[0-9]+$'); do
    grep -ilE 'pcdn|xray' /proc/$pid/maps 2>/dev/null | while read -r m; do
      echo "PID $pid $(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ') $m"
    done
  done
} > "$OUT/pcdn_artifacts.txt" 2>&1

# ---------------------------------------------------------------------------
say "pcdn_hashes"
# APK 内嵌的 libcyber-pcdn.so 才是「活的」副本：只遮蔽 /system/app/*/lib/ 覆盖不掉它。
# 这里对每个载体 APK 内嵌的库做哈希，便于同类设备比对与后续追踪。
{
  echo "# APK 内嵌 libcyber-pcdn.so 哈希"
  echo "# 字段: 载体APK  条目  解压后大小  sha256"
  for a in \
      /system/app/DuerShowSwan/DuerShowSwan.apk \
      /system/app/DuerShowMedia/DuerShowMedia.apk \
      /system/app/DuerShowLauncher/DuerShowLauncher.apk; do
    entry=$(unzip -l "$a" 2>/dev/null | awk '/libcyber-pcdn\.so/ {print $4; exit}')
    [ -n "$entry" ] || continue
    tmp=/data/local/tmp/.f4d_pcdn.$$
    unzip -p "$a" "$entry" > "$tmp" 2>/dev/null
    printf '%s  %s  %s  %s\n' "$a" "$entry" "$(stat -c %s "$tmp" 2>/dev/null)" \
      "$(sha256sum "$tmp" 2>/dev/null | cut -d' ' -f1)"
    rm -f "$tmp"
  done
  echo
  echo "# 活动 codePath 处的同名库（UPDATED_SYSTEM_APP 会落在 /data/app）"
  for p in com.baidu.launcher com.baidu.duershow.media com.baidu.atomkit; do
    code=$(dumpsys package "$p" 2>/dev/null | grep -E '^ *codePath=' | head -1 | sed 's/^ *codePath=//')
    [ -n "$code" ] || continue
    apk="$code/base.apk"
    [ -f "$apk" ] || continue
    entry=$(unzip -l "$apk" 2>/dev/null | awk '/libcyber-pcdn\.so/ {print $4; exit}')
    if [ -n "$entry" ]; then
      tmp=/data/local/tmp/.f4d_pcdn.$$
      unzip -p "$apk" "$entry" > "$tmp" 2>/dev/null
      printf '%s  %s  %s  %s\n' "$p" "$apk!$entry" \
        "$(stat -c %s "$tmp" 2>/dev/null)" "$(sha256sum "$tmp" 2>/dev/null | cut -d' ' -f1)"
      rm -f "$tmp"
    else
      printf '%s  %s  (无内嵌 libcyber-pcdn.so)\n' "$p" "$apk"
    fi
  done
  echo
  echo "# /system/app 遮蔽状态"
  for f in \
      /system/app/DuerShowSwan/lib/arm64/libcyber-pcdn.so \
      /system/app/DuerShowMedia/lib/arm64/libcyber-pcdn.so \
      /system/app/DuerShowLauncher/lib/arm64/libcyber-pcdn.so; do
    printf '%s  %s bytes\n' "$f" "$(stat -c %s "$f" 2>/dev/null || echo MISSING)"
  done
} > "$OUT/pcdn_hashes.txt" 2>&1

# ---------------------------------------------------------------------------
say "apk_scan"
{
  echo "# 扫描所有预置 APK 内的 pcdn/xray 条目"
  for a in $(find /system/app /system/priv-app /system_ext/app /system_ext/priv-app \
                  /product/app /product/priv-app /system/preloadapp \
                  -iname '*.apk' 2>/dev/null | sort); do
    hits=$(unzip -l "$a" 2>/dev/null | grep -iE 'pcdn|xray')
    [ -n "$hits" ] && { echo "=== $a"; echo "$hits"; }
  done
  echo
  echo "# 名称可疑的预置 APK"
  find /system/app /system/priv-app /system_ext/app /system_ext/priv-app \
       /product/app /product/priv-app /system/preloadapp \
       -iname '*.apk' 2>/dev/null | grep -iE 'pcdn|xray|duer|baidu|xiaodu|goodfather' | sort
} > "$OUT/apk_scan.txt" 2>&1

# ---------------------------------------------------------------------------
say "framework_baidu"
{
  echo "# framework.jar / services.jar 中的 Baidu 类清单（字符串级）"
  for jar in /system/framework/framework.jar /system/framework/services.jar; do
    echo "=== $jar"
    d=$(mktemp -d)
    unzip -o "$jar" 'classes*.dex' -d "$d" >/dev/null 2>&1
    cat "$d"/classes*.dex 2>/dev/null | strings -a \
      | grep -oE 'L(android|com)/[A-Za-z0-9_/$]*[Bb]aidu[A-Za-z0-9_/$]*' \
      | sort -u
    rm -rf "$d"
  done
} > "$OUT/framework_baidu.txt" 2>&1

# ---------------------------------------------------------------------------
say "services_dump"
{
  echo "# PCDN / Duer 相关服务"
  dumpsys activity services 2>/dev/null | grep -iE 'pcdn|duershow|duer\.ota|statistic'
  echo
  echo "# 已注册的 Baidu ContentProvider"
  dumpsys activity providers 2>/dev/null | grep -iE 'baidu|duer' | grep -vE '^\s*$'
} > "$OUT/services.txt" 2>&1

# ---------------------------------------------------------------------------
say "network"
{
  echo "# 说明：为避免泄露用户网络环境，这里只导出聚合统计，不导出原始连接表。"
  echo
  echo "# 连接状态统计（st 字段）"
  echo "## tcp"
  awk 'NR>1 {c[$4]++} END {for (s in c) print s, c[s]}' /proc/net/tcp 2>/dev/null | sort
  echo
  echo "## udp"
  awk 'NR>1 {c[$4]++} END {for (s in c) print s, c[s]}' /proc/net/udp 2>/dev/null | sort
  echo
  echo "# 连接数"
  printf 'tcp  entries: %s\n' "$(awk 'NR>1' /proc/net/tcp 2>/dev/null | wc -l)"
  printf 'udp  entries: %s\n' "$(awk 'NR>1' /proc/net/udp 2>/dev/null | wc -l)"
  echo
  echo "# 连接数最多的 uid（PCDN 曾表现为海量 UDP 连接；uid 1000=system）"
  echo "## udp"
  awk 'NR>1 {print $8}' /proc/net/udp 2>/dev/null | sort | uniq -c | sort -rn | head -20
  echo "## tcp"
  awk 'NR>1 {print $8}' /proc/net/tcp 2>/dev/null | sort | uniq -c | sort -rn | head -20
  echo
  echo "# DNS"
  getprop | grep -iE 'net\.dns|net\.change'
} > "$OUT/network.txt" 2>&1

# ---------------------------------------------------------------------------
say "hosts"
{
  echo "# /system/etc/hosts"
  cat /system/etc/hosts 2>&1
  echo
  echo "# 生效的 hosts（考虑 Magisk 挂载）"
  ls -la /system/etc/hosts
} > "$OUT/hosts.txt" 2>&1

echo
echo "取证完成：$OUT"
ls -la "$OUT"
