# 优化前后基线快照

设备：XD-SEE00-2301（DuerShow_T616_v1.65.0.20250825010819358.R / Android 12）
采集时间：2026-10-02
采集方式：`scripts/bench.sh`（只读，root），`./scripts/bench_via_adb.sh before|after`

## 文件

| 文件 | 说明 |
| --- | --- |
| `before/` `after/` | 优化前后的同一组指标快照 |
| `disabled-components/package-restrictions.xml` | ROM 的组件级禁用清单（已脱敏，仅保留系统包） |

各快照内含：

| 文件 | 说明 |
| --- | --- |
| `device.txt` | 机型 / 版本 / 内核 / uptime / loadavg |
| `cpu.txt` | 核心、governor、频率、调度器参数、热区温度 |
| `memory.txt` | meminfo、zram、swap、vm 参数、PSI |
| `storage.txt` | df、块设备队列参数、挂载选项 |
| `processes.txt` | 进程/线程计数、RSS Top、已注册服务与 JobService 数 |
| `packages.txt` | 包计数与已禁用清单 |
| `settings.txt` | 动画缩放等全局设置 |
| `network.txt` | 拥塞控制、TCP 参数、连接数、DNS、内核模块 |
| `power.txt` | 电量、唤醒锁、Doze |
| `logs.txt` | logd 配置与环形缓冲区 |

## 对比

```bash
python3 scripts/compare_bench.py \
  evidence/device-xd-see00-2301/optimize/before \
  evidence/device-xd-see00-2301/optimize/after
```

结论见 [docs/optimization.md](../../../docs/optimization.md)。

## 隐私说明

本目录已经过 `scripts/sanitize_evidence.py` 处理：

- 去掉了第三方 App 的进程行（只保留系统 / 厂商 / 本次研究相关的包）；
- 去掉了 `package-restrictions.xml` 里的 `<preferred-activities>` 等使用痕迹段；
- 内网地址替换为占位符；
- 采集脚本本身就不采集序列号、账号、联系人、短信。

可复现：

```bash
python3 scripts/sanitize_evidence.py evidence/device-xd-see00-2301/optimize
```
