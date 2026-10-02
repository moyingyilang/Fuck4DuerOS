#!/system/bin/sh
# DuerOS Optimize - 早期 IO 调优
#
# post-fs-data 阶段执行：此时块设备已就绪、系统还没开始大量读写，
# 在这里设置队列参数效果最好。
#
# 只调队列参数，不动任何数据。

MODDIR=${0%/*}
LOG=/data/local/tmp/duer_optimize.log

log() { echo "[$(date '+%m-%d %H:%M:%S')] [post-fs-data] $*" >> "$LOG"; }

for d in sda sdb sdc; do
    q="/sys/block/$d/queue"
    [ -d "$q" ] || continue

    # UFS + blk-mq：scheduler=none 省掉一层调度开销
    if [ -f "$q/scheduler" ]; then
        echo none > "$q/scheduler" 2>/dev/null && log "io $d scheduler=none"
    fi

    # 顺序读预读 128 -> 512 KB（冷启动 / 读大文件）
    if [ -f "$q/read_ahead_kb" ]; then
        echo 512 > "$q/read_ahead_kb" 2>/dev/null && log "io $d read_ahead_kb=512"
    fi
done

exit 0
