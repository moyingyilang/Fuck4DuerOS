#!/system/bin/sh
# 百度定制 ROM 净化脚本
# 位置：/data/adb/service.d/baidu_killer.sh
# 权限：755

LOG="/data/local/tmp/baidu_killer.log"
PKG="/system/bin/pm"
CMD="/system/bin/cmd"

log() {
    echo "$(date '+%m-%d %H:%M:%S') $1" >> "$LOG"
}

# 等待 system_server 就绪
wait_boot() {
    local n=0
    while [ $n -lt 120 ]; do
        if [ "$(getprop sys.boot_completed)" = "1" ]; then
            return 0
        fi
        sleep 5
        n=$((n + 1))
    done
    return 1
}

log "=== baidu_killer started ==="

if ! wait_boot; then
    log "boot timeout, abort"
    exit 1
fi

sleep 15   # 再等一会儿，让 PMS 完全就绪

# ---------- 1. 禁用百度监控/家长控制 ----------
log "--- disable monitoring components ---"
for p in \
    com.baidu.duerguard \
    com.goodfather.textbook.pad \
    com.baidu.duer.child
do
    $PKG disable "$p" 2>>"$LOG" && log "disabled $p"
done

# ---------- 2. 禁用百度桌面通讯劫持组件 ----------
log "--- disable launcher telephony hooks ---"
for c in \
    com.baidu.launcher/com.baidu.duer.child.service.ContactsControlService \
    com.baidu.launcher/com.xiaoyu.communication.activity.CallPhoneActivity \
    com.baidu.launcher/com.xiaoyu.communication.telecom.TelecomCallVoltePhoneActivity \
    com.baidu.launcher/com.xiaoyu.communication.activity.global.SelectDefaultPhoneActivity \
    com.baidu.launcher/com.baidu.duer.account.sms.SmsLoginActivity \
    com.baidu.launcher/com.baidu.duer.prism.PrismStatusReiver
do
    $PKG disable "$c" 2>>"$LOG" && log "disabled $c"
done

# ---------- 3. 禁用 PCDN 与 OTA ----------
log "--- disable pcdn/ota ---"
for p in \
    com.baidu.pcdn \
    com.baidu.duer.ota \
    com.baidu.duershow.statistic
do
    $PKG disable "$p" 2>>"$LOG" && log "disabled $p"
done

# ---------- 4. 恢复系统默认拨号/短信 ----------
log "--- restore system dialer/sms ---"
$CMD role add-role-holder android.app.role.DIALER com.android.dialer 2>>"$LOG"
$CMD role add-role-holder android.app.role.SMS    com.android.messaging 2>>"$LOG"

# ---------- 5. 解除被暂停的应用 ----------
log "--- unsuspend apps ---"
for p in \
    com.android.contacts \
    com.android.dialer \
    com.android.messaging \
    com.tencent.mm \
    com.tencent.mobileqq
do
    $PKG unsuspend "$p" 2>>"$LOG" && log "unsuspended $p"
done

# ---------- 6. 强杀残留进程 ----------
log "--- force-stop pcdn ---"
am force-stop com.baidu.pcdn 2>>"$LOG"

log "=== baidu_killer done ==="
exit 0