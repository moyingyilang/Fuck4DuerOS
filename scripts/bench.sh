#!/system/bin/sh
# Fuck4DuerOS - 优化前后基线测量（只读）
#
# 采集可量化的系统指标，用于对比优化前后的实际效果。
# 本脚本不修改任何状态。
#
# 用法（设备端，需 root）：
#   su -c 'sh /data/local/tmp/bench.sh before'
#   su -c 'sh /data/local/tmp/bench.sh after'
# 或主机端：
#   ./scripts/bench_via_adb.sh before

LABEL="${1:-snapshot}"
OUT="${2:-/data/local/tmp/f4d_bench}"
DIR="$OUT/$LABEL"
mkdir -p "$DIR" || exit 1

rd() { cat "$1" 2>/dev/null; }

# ---------- 设备信息 ----------
{
  echo "# date"; date
  echo "# uptime"; cat /proc/uptime
  echo "# loadavg"; cat /proc/loadavg
  for p in ro.product.model ro.build.display.id ro.build.version.release \
           ro.build.version.sdk; do
    printf '%s=%s\n' "$p" "$(getprop "$p")"
  done
  echo "# kernel"; uname -a
} > "$DIR/device.txt" 2>&1

# ---------- CPU ----------
{
  echo "# cores=$(nproc 2>/dev/null) online=$(rd /sys/devices/system/cpu/online)"
  for p in /sys/devices/system/cpu/cpufreq/policy*; do
    printf '%s governor=%s avail=[%s] min=%s max=%s cur=%s\n' \
      "${p##*/}" "$(rd "$p/scaling_governor")" "$(rd "$p/scaling_available_governors")" \
      "$(rd "$p/scaling_min_freq")" "$(rd "$p/scaling_max_freq")" "$(rd "$p/scaling_cur_freq")"
  done
  echo
  echo "# 每核当前频率"
  for c in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq; do
    printf '%s %s\n' "$c" "$(rd "$c")"
  done
  echo
  echo "# 调度器参数"
  for k in sched_tunable_scaling sched_migration_cost_ns sched_min_granularity_ns \
           sched_wakeup_granularity_ns sched_latency_ns sched_child_runs_first; do
    printf 'kernel.%-28s %s\n' "$k" "$(rd "/proc/sys/kernel/$k")"
  done
  echo
  echo "# 热区温度"
  for z in /sys/class/thermal/thermal_zone*; do
    [ -r "$z/temp" ] || continue
    printf '%-24s %-20s %s\n' "${z##*/}" "$(rd "$z/type")" "$(rd "$z/temp")"
  done
  echo
  echo "# 热管理 throttling"
  rd /sys/class/thermal/thermal_message/cpu_limit
} > "$DIR/cpu.txt" 2>&1

# ---------- 内存 ----------
{
  echo "# /proc/meminfo"
  grep -E 'MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapCached|Active|Inactive|SwapTotal|SwapFree|Shmem|Slab|SReclaimable|SUnreclaim|KernelStack|PageTables' /proc/meminfo
  echo
  echo "# swaps"
  cat /proc/swaps
  echo
  echo "# zram0"
  for f in disksize comp_algorithm mm_stat mem_used_total; do
    printf '%-16s %s\n' "$f" "$(rd "/sys/block/zram0/$f")"
  done
  echo
  echo "# vm 参数"
  for k in swappiness vfs_cache_pressure dirty_ratio dirty_background_ratio \
           dirty_expire_centisecs dirty_writeback_centisecs min_free_kbytes \
           extra_free_kbytes watermark_scale_factor overcommit_memory page-cluster \
           stat_interval; do
    printf 'vm.%-28s %s\n' "$k" "$(rd "/proc/sys/vm/$k")"
  done
  echo
  echo "# lmk / 进程回收"
  for k in /sys/module/lowmemorykiller/parameters/*; do
    [ -r "$k" ] && printf '%s = %s\n' "$k" "$(rd "$k")"
  done
  echo
  echo "# PSI"
  for f in /proc/pressure/cpu /proc/pressure/memory /proc/pressure/io; do
    echo "--- $f"; cat "$f" 2>/dev/null
  done
} > "$DIR/memory.txt" 2>&1

# ---------- 存储 / IO ----------
{
  echo "# df"
  df -h 2>/dev/null
  echo
  echo "# 块设备调度与预读"
  for q in /sys/block/*/queue; do
    d=$(dirname "$q")
    [ -e "$q/scheduler" ] || continue
    printf '%-16s sched=[%s] read_ahead_kb=%s nr_requests=%s iostats=%s rq_affinity=%s\n' \
      "${d##*/}" "$(rd "$q/scheduler")" "$(rd "$q/read_ahead_kb")" \
      "$(rd "$q/nr_requests")" "$(rd "$q/iostats")" "$(rd "$q/rq_affinity")"
  done
  echo
  echo "# fstrim"
  for m in /sys/class/block/*/queue/discard_max_bytes; do
    printf '%s %s\n' "$m" "$(rd "$m")"
  done
  echo
  echo "# ext4/f2fs 挂载选项"
  cat /proc/mounts 2>/dev/null | grep -E ' /data | /system | /cache ' 
} > "$DIR/storage.txt" 2>&1

# ---------- 进程 / 服务 ----------
{
  echo "# 进程总数: $(ls /proc 2>/dev/null | grep -cE '^[0-9]+$')"
  echo "# 线程总数: $(ps -A -T 2>/dev/null | wc -l)"
  echo
  echo "# RSS 前 20"
  ps -A -o PID,USER,RSS,NAME 2>/dev/null | sort -k3 -rn | head -21
  echo
  echo "# 运行中的第三方/可停用进程"
  ps -A -o PID,USER,NAME 2>/dev/null | grep -vE '^\s*[0-9]+\s+(root|system|u0_a0|shell)\s' | head -40
  echo
  echo "# 已注册服务数"
  dumpsys activity services 2>/dev/null | grep -c 'ServiceRecord'
  echo "# 已注册 JobService 数"
  dumpsys jobscheduler 2>/dev/null | grep -c 'JOB #'
} > "$DIR/processes.txt" 2>&1

# ---------- 包 ----------
{
  echo "# 全部包: $(pm list packages 2>/dev/null | wc -l)"
  echo "# 系统包: $(pm list packages -s 2>/dev/null | wc -l)"
  echo "# 第三方包: $(pm list packages -3 2>/dev/null | wc -l)"
  echo "# 已禁用: $(pm list packages -d 2>/dev/null | wc -l)"
  echo
  echo "# 已禁用清单"
  pm list packages -d 2>/dev/null
} > "$DIR/packages.txt" 2>&1

# ---------- 系统设置 ----------
{
  for ns in global system secure; do
    echo "=== $ns ==="
    settings list "$ns" 2>/dev/null | grep -iE 'animation|background_process_limit|log|window_manager|activity_manager|cache|dns|timeout|standby|doze|app_standby' | head -40
  done
  echo
  echo "=== 当前动画缩放 ==="
  for k in window_animation_scale transition_animation_scale animator_duration_scale; do
    printf '%-28s %s\n' "$k" "$(settings get global $k 2>/dev/null)"
  done
} > "$DIR/settings.txt" 2>&1

# ---------- 网络 ----------
{
  echo "# TCP 拥塞控制"
  printf 'available: %s\n' "$(rd /proc/sys/net/ipv4/tcp_available_congestion_control)"
  printf 'current:   %s\n' "$(rd /proc/sys/net/ipv4/tcp_congestion_control)"
  echo
  for k in tcp_rmem tcp_wmem tcp_fastopen tcp_slow_start_after_idle \
           tcp_tw_reuse tcp_fin_timeout tcp_max_syn_backlog; do
    printf 'net.ipv4.%-28s %s\n' "$k" "$(rd "/proc/sys/net/ipv4/$k")"
  done
  echo
  echo "# 连接数"
  printf 'tcp=%s udp=%s\n' "$(awk 'NR>1' /proc/net/tcp 2>/dev/null | wc -l)" \
                            "$(awk 'NR>1' /proc/net/udp 2>/dev/null | wc -l)"
  echo
  echo "# DNS"
  getprop | grep -iE 'net\.dns' 
  echo
  echo "# 已加载内核模块"
  cat /proc/modules 2>/dev/null | awk '{print $1, $2}' | head -40
} > "$DIR/network.txt" 2>&1

# ---------- 电量 ----------
{
  dumpsys battery 2>/dev/null
  echo
  echo "# 唤醒锁"
  dumpsys power 2>/dev/null | grep -A30 'Wake Locks' | head -40
  echo
  echo "# 待机/Doze"
  dumpsys deviceidle 2>/dev/null | head -25
} > "$DIR/power.txt" 2>&1

# ---------- 日志配置 ----------
{
  echo "# logd 大小"
  getprop | grep -iE 'logd|log\.' | head -20
  echo
  echo "# 日志缓冲"
  logcat -g 2>/dev/null
} > "$DIR/logs.txt" 2>&1

echo "基线快照已保存: $DIR"
ls -la "$DIR"
