#!/system/bin/sh
# DuerOS DevRestore - 早期阶段恢复 ro.adb.secure
#
# 这台 ROM 把 ro.adb.secure 设成了 0，adbd 因此完全不校验主机公钥：
# 任何能连上 5555 的人都能直接 adb shell，系统也不会弹出授权框。
#
# ro.adb.secure 由 adbd 在启动时读取，所以必须在 adbd 起来之前用 resetprop
# 改掉；service.sh 里还会再兜底重启一次 adbd。
#
# 注意：改回 1 之后，未授权的电脑必须【插 USB 线】才能看到授权弹窗 ——
# AOSP 的 UsbDebuggingActivity 在没有 USB 连接时会立刻 finish()。
# 无线首次授权请用 scripts/adb_authorize.sh 预置公钥。

MODDIR=${0%/*}
LOG=/data/local/tmp/duer_devrestore.log
log() { echo "[$(date '+%m-%d %H:%M:%S')] [post-fs-data] $*" >> "$LOG"; }

# ---------------------------------------------------------------------------
# 关键：绕开 ROM 用 SKU 值静默吞掉授权弹窗的行为
#
# SystemUI 的 UsbDebuggingActivity.onCreate 末尾有这么一段（dexdump 反汇编）：
#
#     00e0: const-string v0, "600WW"
#     00e2: v0.equals(v7)        // v7 = ro.boot.skuid
#     00e6: if-eqz v7, 00ee      // 不相等 -> 00ee: return-void（保留弹窗）
#     00e8: notifyService(v2)    // 相等   -> 通知服务
#     00eb: finish()             //          并立刻关闭弹窗
#     00ee: return-void          // 只有 skuid != 600WW 才走这里
#
# 这台设备的 ro.boot.skuid 恰好是 600WW，所以授权弹窗永远不显示，
# 陌生主机只会一直停在 unauthorized。
# 把它改成别的值即可走回正常分支，弹窗恢复。
# ---------------------------------------------------------------------------
SKU=$(getprop ro.boot.skuid)
if [ "$SKU" = "600WW" ]; then
    resetprop ro.boot.skuid 0 2>/dev/null
    log "ro.boot.skuid: 600WW -> $(getprop ro.boot.skuid)（恢复 ADB 授权弹窗）"
fi

CUR=$(getprop ro.adb.secure)
if [ "$CUR" != "1" ]; then
    resetprop ro.adb.secure 1 2>/dev/null
    log "ro.adb.secure: $CUR -> $(getprop ro.adb.secure)"
else
    log "ro.adb.secure 已经是 1"
fi

exit 0
