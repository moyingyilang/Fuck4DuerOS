# XD-SEE00-2301 系统优化记录

**设备**：小度学生手机 XD-SEE00-2301
**系统**：DuerShow_T616_v1.65.0.20250825010819358.R（Android 12 / SDK 31 / 内核 5.4.161）
**方式**：Magisk 模块 `duer_optimize`（开机自动）+ `scripts/optimize.sh`（可单独执行）
**时间**：2026-10-02
**数据**：`evidence/device-xd-see00-2301/optimize/{before,after}/`

---

## 0. 最重要的一个发现：百度在往闪存里写日志

`/system_ext/bin/baidu_log` 会常驻两个 `logcat` 进程，把**全量 Info 级以上日志**
和内核日志持续写进 `/data/log`：

```text
logcat -r 10240 -n 15 -v threadtime -f /data/log/logcat_full.log *:I
logcat -r 1024  -n 19 -v threadtime -b kernel -f /data/log/kernel/kernel_log_10089_...
```

对应 init 服务：`kernel_log`、`logcat_log`、`log_size_control`
（定义在 `/system_ext/etc/init/baidu_log.rc`，另有 `persist.sys.baidu.logsize=102400`）。

实测写入速率：

| 项目 | 采样值 | 折算 |
| --- | --- | --- |
| `logcat_full.log` | 270221 字节 / 30 秒 | 9007 B/s ≈ **742 MB/天** |
| kernel log 合计 | 125664 字节 / 30 秒 | 4189 B/s ≈ **345 MB/天** |
| **合计** | | **≈ 1.09 GB/天** |

`/data/log` 当时占用 **225 MB**，其中 `logcat_full.log*` 约 158 MB。

这不只是性能和寿命问题：**全量 logcat 里包含所有 App 的日志**，
等于给厂商留了一个持续写入本地的信息汇聚点。

处理方式：`setprop ctl.stop` 停掉这三个 init 服务，并清理历史日志。
内核 `logd` 本身不受影响，需要调试时 `adb logcat` 照常可用。

效果：**1.09 GB/天 → 0**，`/data/log` 225 MB → 47 MB。

---

## 1. 优化前基线（关键项）

```text
CPU        8 核，schedutil，policy0 614MHz-1.72GHz / policy6 768MHz-1.95GHz
内存       MemTotal 5.9G，MemFree 208M，MemAvailable 3.25G，Cached 3.36G
交换       zram0 2.96G(priority -2, 已用 0) + /data/swapfile 8.39G(priority 0, 已用 2.76G)
           vm.swappiness = 200
zram 算法  lzo lzo-rle [lz4] zstd
VM         vfs_cache_pressure=150  dirty_writeback_centisecs=10000  dirty_expire_centisecs=5000
IO         sda/sdb/sdc  scheduler=mq-deadline  read_ahead_kb=128  nr_requests=62
网络       cubic  tcp_slow_start_after_idle=1  tcp_fastopen=1  tcp_fin_timeout=60
内核       kernel.dmesg_restrict=0
交互       动画缩放三件套 = 1.0 / 1.0 / null
包         240 个（系统 194 / 第三方 46），已禁用 7
进程       485 个进程 / 3097 线程
```

---

## 2. 改了什么

### 2.1 遥测与日志（收益最大）

| 项 | 处理 |
| --- | --- |
| `kernel_log` / `logcat_log` / `log_size_control` | `ctl.stop` 停掉，模块每次开机执行 |
| `/data/log` 历史日志 | 清理，释放 178 MB |
| 内核 logd | **不动**，`adb logcat` 仍正常 |

### 2.2 块设备 IO

| 项 | 前 | 后 |
| --- | --- | --- |
| `sda/sdb/sdc` scheduler | `mq-deadline` | `none`（UFS + blk-mq 下省一层调度开销） |
| `read_ahead_kb` | 128 | 512（改善顺序读 / 冷启动） |

### 2.3 网络

| sysctl | 前 | 后 | 目的 |
| --- | --- | --- | --- |
| `net.ipv4.tcp_slow_start_after_idle` | 1 | 0 | 空闲后不重置拥塞窗口 |
| `net.ipv4.tcp_fastopen` | 1 | 3 | 客户端+服务端 TFO |
| `net.ipv4.tcp_fin_timeout` | 60 | 30 | 加快端口回收 |
| `net.ipv4.tcp_max_syn_backlog` | 512 | 1024 | 提高 SYN 队列 |
| `net.ipv4.conf.all.send_redirects` | 1 | 0 | 本机不是路由器 |

> `net.ipv4.tcp_syncookies` 在本内核上 **不存在**（`/proc/sys/net/ipv4/tcp_syncookies`
> 没有这个文件），脚本会打印 `skip` 并继续，不是失败。
> 拥塞控制只有 `reno cubic`，没有 `bbr`，未做改动。

### 2.4 内存 / VM

| sysctl | 前 | 后 | 目的 |
| --- | --- | --- | --- |
| `vm.vfs_cache_pressure` | 150 | 100 | 少驱逐 inode/dentry 缓存 |
| `vm.dirty_writeback_centisecs` | 10000（100 秒） | 500（5 秒） | 脏页平滑回写，避免攒一波造成卡顿 |
| `vm.dirty_expire_centisecs` | 5000 | 3000 | 同上 |

### 2.5 内核信息暴露

`kernel.dmesg_restrict` 0 → 1：非 root 应用不能读 dmesg（root 不受影响）。

### 2.6 交互

`window_animation_scale` / `transition_animation_scale` / `animator_duration_scale`
1.0 / 1.0 / null → **0.5**（纯观感提速，不改变任何功能）。

### 2.7 预装精简

`com.baidu.duer.superapp` → 禁用。
它是**用户空间应用**，携带 `libpcdn-jni.so`（PCDN 库），且不属于系统必需组件。

---

## 3. 优化前后对比

由 `scripts/compare_bench.py` 从两份快照生成：

```bash
python3 scripts/compare_bench.py \
  evidence/device-xd-see00-2301/optimize/before \
  evidence/device-xd-see00-2301/optimize/after
```

| 指标 | 前 | 后 |
| --- | --- | --- |
| **百度日志写入速率** | **≈ 1.09 GB/天** | **0 B/天** |
| **/data/log 占用** | **225 MB** | **47 MB** |
| sda scheduler | mq-deadline | none |
| sda read_ahead_kb | 128 | 512 |
| vm.vfs_cache_pressure | 150 | 100 |
| vm.dirty_writeback_centisecs | 10000 | 500 |
| vm.dirty_expire_centisecs | 5000 | 3000 |
| kernel.dmesg_restrict | 0 | 1 |
| tcp_slow_start_after_idle | 1 | 0 |
| tcp_fastopen | 1 | 3 |
| tcp_fin_timeout | 60 | 30 |
| tcp_max_syn_backlog | 512 | 1024 |
| 动画缩放 | 1.0 / 1.0 / null | 0.5 / 0.5 / 0.5 |
| 已禁用包 | 7 | 8 |
| PSI io full avg60 | 0.33 | 0.07 |
| PSI mem full avg60 | 0.21 | 0.02 |
| PSI cpu some avg60 | 3.11 | 2.29 |

> PSI 数值受当时负载影响很大，只作参考；真正确定的是**日志写入归零**与
> **配置项本身**。MemFree / Cached 这类瞬时值同理，不代表优化效果。

---

## 4. 刻意没有动的东西

这些是权衡后的决定，写出来是为了避免被误当成"漏了"：

| 对象 | 原因 |
| --- | --- |
| **ZRAM / SWAP / swappiness** | 由 `scene_swap_controller` 模块管理，它的 `startup.sh` 会在开机时重设。硬改会和它打架。 |
| **CPU governor / 频率** | 交给厂商调度器与 `uperf` / Scene；`schedutil` 本身是合理默认。 |
| **内核调度器参数** | `sched_min_granularity_ns` 等改动风险高、收益不确定。 |
| **f2fs `discard` 挂载项** | 需要改 `vendor_boot` 里的 fstab，风险和收益不成比例。 |
| **热管理 / 温控** | 直接影响稳定性与寿命。 |
| **fstrim** | `scene_swap_controller` 每次开机已经对 /data、/cache、/system 做过。 |
| **用户可见功能**（桌面、语音、媒体、输入法） | 属于用户选择，不由优化脚本代替决定。 |

### 关于 swap 的一个提醒（未改动，但值得知道）

设备当前是：

```text
/dev/block/zram0    2962820 KB   priority -2   已用 0
/data/swapfile      8388604 KB   priority  0   已用 2.76 GB
```

Linux 里 **priority 数值越大越先使用**。swapfile 的 0 高于 zram 的 -2，
所以**跑在 UFS 闪存上的 8.4 GB swapfile 被优先使用，而内存里的 zram 基本闲置**。
结果是：本可以走内存的换页跑到了闪存上，既慢又费寿命。

如果希望改成「zram 优先、swapfile 兜底」，在 Scene 的 ZRAM/SWAP 控制器里
把 zram 的优先级调到高于 swapfile 即可。这属于你的配置选择，脚本没有代劳。

---

## 5. 回滚

```bash
# 回滚本次运行时改动（sysctl / IO / 动画 / 预装包）
./scripts/optimize_via_adb.sh revert

# 移除开机自动优化模块
adb shell "su -c 'rm -rf /data/adb/modules/duer_optimize'"
```

`optimize.sh` 在修改任何参数前都会把原值备份到
`/data/local/tmp/f4d_optimize_backup/`，`revert_optimize.sh` 从那里读回。
多次执行 `optimize.sh` 不会覆盖最初的备份，所以回滚的一定是最初的值。

> 注意：`kernel_log` / `logcat_log` 这类 init 服务被停掉后，重启设备即会
> 由 init 重新拉起；要让回滚完全生效，请移除模块后重启。

---

## 6. 复现方式

```bash
# 采集基线
./scripts/bench_via_adb.sh before

# 应用优化
./scripts/optimize_via_adb.sh

# 采集优化后
./scripts/bench_via_adb.sh after

# 对比
python3 scripts/compare_bench.py \
  evidence/device-xd-see00-2301/optimize/before \
  evidence/device-xd-see00-2301/optimize/after

# 安装开机自动优化模块
./scripts/install_module.sh duer_optimize
```
