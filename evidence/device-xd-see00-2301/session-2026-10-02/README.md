# 实时取证快照 2026-10-02

设备：XD-SEE00-2301（DuerShow_T616_v1.65.0.20250825010819358.R / Android 12 / SDK 31）
采集时状态：已安装并启用 `duer_cleanup` Magisk 模块
采集方式：`scripts/collect_evidence.sh`（只读，root）

复现：

```bash
./scripts/collect_via_adb.sh
# 或指定序列号 / 输出目录
./scripts/collect_via_adb.sh <已隐去的内网地址>:5555 evidence/device-xd-see00-2301/session-YYYY-MM-DD
```

## 文件

| 文件 | 说明 |
| --- | --- |
| `device_info.txt` | `getprop` 关键项（已剔除 `ro.serialno`） |
| `root_env.txt` | root / Magisk 版本 / 已装模块清单 |
| `processes.txt` | 全量 `ps -A` + 百度相关进程 |
| `packages.txt` | 百度系包：全部 / 禁用 / 启用 / 系统 / APK 路径 |
| `system_apps.txt` | `/system/app`、`/system/priv-app`、`/system_ext`、`/system/preloadapp` |
| `pcdn_artifacts.txt` | PCDN/Xray 相关文件路径 + 遮蔽状态 + 进程映射是否加载 |
| `pcdn_hashes.txt` | **APK 内嵌 `libcyber-pcdn.so` 的 sha256**（含活动 codePath） |
| `apk_scan.txt` | 全部预置 APK 内部的 pcdn/xray 条目扫描 |
| `framework_baidu.txt` | `framework.jar` / `services.jar` 的百度类清单 |
| `services.txt` | PCDN / DuerOS 相关服务与 Provider |
| `network.txt` | 连接数聚合统计（不导出原始连接表，避免泄露网络环境） |
| `hosts.txt` | `/system/etc/hosts` 内容与生效状态 |
| `check_sh_output.txt` | 增强后 `check.sh` 的完整输出 |

## 隐私处理

- 已剔除 `ro.serialno`。
- `network.txt` 只保留连接状态计数与 uid 分布，不含原始远端地址。
- 未采集联系人、短信、账号、位置、IMEI、MAC。
