# Fuck4DuerOS

> 一个针对百度 DuerOS 定制 Android 设备（小度学生手机等）的净化工具集。
> 逆向取证、解除限制、移除 PCDN、恢复系统原生体验。

[![License](https://img.shields.io/badge/license-AGPLv3-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android%2010--14-green.svg)]()
[![Root](https://img.shields.io/badge/requires-Root-red.svg)]()

---

## 📖 这是什么

百度 DuerOS 定制 Android 设备（小度学生手机、学习平板等）预装了大量未经用户同意的组件，包括：

- **PCDN**（P2P 内容分发网络）：用你的宽带帮百度给别人传文件
- **Xray SDK**：全链路数据采集（网络、电量、应用行为、崩溃日志）
- **Duerguard**：守护进程，防止用户修改系统
- **GoodFather**：家长控制，限制通讯
- **ActivityStackMonitor**：系统级 hook，拦截 HOME 解析、限制多任务

本项目通过系统级取证，定位上述组件，并提供：

- 一键检测脚本
- Magisk 模块（无损、可逆）
- 完整的取证报告与法律依据

---

## ⚠️ 适用设备

**仅适用于以下特征的设备：**

- 品牌：小度 / 百度定制
- 系统：DuerOS 定制 Android
- 型号示例：XD-SEE00-2301
- 已 Root（Magisk / KernelSU）

**不适用于普通 Android 设备。** 跑之前**必须先执行 `check.sh`** 确认匹配。

---

## 🚀 快速开始

### 0. 侦察

```bash
adb shell "su -c 'sh scripts/check.sh'"      # 只读，报告当前状态
./scripts/collect_via_adb.sh                 # 完整取证落盘（可选）
```

### 1. 净化 PCDN / 监控组件

```bash
adb shell "su -c 'sh scripts/install.sh'"    # 生成并安装 duer_cleanup
adb shell "su -c 'reboot'"
```

### 2. 系统优化（可逆）

```bash
./scripts/bench_via_adb.sh before            # 采集基线
./scripts/optimize_via_adb.sh                # 应用优化
./scripts/install_module.sh duer_optimize    # 装成开机自动
./scripts/bench_via_adb.sh after             # 采集结果
python3 scripts/compare_bench.py \
  evidence/device-xd-see00-2301/optimize/before \
  evidence/device-xd-see00-2301/optimize/after
```

详见 [系统优化记录](docs/optimization.md)。最大的单项收益是关掉百度持久化日志，
实测从 **约 1.09 GB/天** 的持续闪存写入降到 **0**。

### 3. 恢复被 ROM 去掉的开发能力

```bash
./scripts/install_module.sh duer_devrestore
```

恢复 ADB 授权（`ro.adb.secure=1`）与开发者选项、系统跟踪、导航栏、多用户等页面。
详见 [恢复被定制 ROM 去掉的开发能力](docs/restore-removed-pages.md)。

### 后悔了？

```bash
adb shell "su -c 'sh scripts/rollback.sh'"   # 回滚净化
./scripts/optimize_via_adb.sh revert         # 回滚优化
adb shell "su -c 'rm -rf /data/adb/modules/duer_optimize /data/adb/modules/duer_devrestore'"
```

---

## 🧩 模块与脚本

### Magisk 模块

| 模块 | 作用 |
| --- | --- |
| `modules/duer_cleanup` | 净化：`.replace` 掉 PCDN/Duerguard/GoodFather 等，hosts 屏蔽上报域名，禁用通讯劫持组件 |
| `modules/duer_optimize` | 优化：关闭百度持久化日志、UFS IO / 网络 / VM 调优、动画 0.5x |
| `modules/duer_devrestore` | 恢复：`ro.adb.secure=1`（ADB 授权）、`adb_enabled=1` + USB ADB、重新启用被 ROM 禁用的系统页面、补 SELinux 策略修复开发者选项闪退（与 Scene 冲突的项刻意不抢） |

安装：`./scripts/install_module.sh <模块目录名>`

### 脚本

| 脚本 | 位置 | 作用 |
| --- | --- | --- |
| `check.sh` | 设备端 | 只读侦察，含 PCDN 库覆盖有效性判定 |
| `collect_evidence.sh` / `collect_via_adb.sh` | 设备 / 主机 | 完整取证采集（隐私已处理） |
| `bench.sh` / `bench_via_adb.sh` | 设备 / 主机 | 优化前后基线测量 |
| `optimize.sh` / `revert_optimize.sh` | 设备端 | 应用 / 回滚系统优化 |
| `restore_dev_pages.sh` | 设备端 | 重新启用被 ROM 禁用的系统页面 |
| `adb_authorize.sh` | 设备端 | 管理 ADB 授权公钥（无线场景用） |
| `compare_bench.py` | 主机 | 对比两份基线快照 |
| `parse_dexdump.py` | 主机 | 把 dexdump 输出解析成类/方法表 |

---

## 🔍 检测原理

| 组件 | 检测方式 | 处理方式 |
| --- | --- | --- |
| PCDN | `ps -A \| grep pcdn` | 禁用 + 库文件覆盖（注意下方说明） |
| Duerguard | `pm list packages -d` | 禁用 |
| GoodFather | `pm list packages -d` | 禁用 |
| 通讯劫持 | `dumpsys activity services` | 组件级禁用 |
| 上报域名 | `cat /system/etc/hosts` | hosts 屏蔽 |
| 百度持久化日志 | `getprop init.svc.logcat_log` | `ctl.stop` 停服务 |
| 隐藏框架类 | `dexdump framework.jar/services.jar` | 只取证，不修改 |

> ⚠️ **库文件覆盖的局限**：`libcyber-pcdn.so` 同时打包在 APK **内部**，而
> `com.baidu.launcher` 是 `UPDATED_SYSTEM_APP`（代码在 `/data/app`，native 库
> 直接从 APK 加载），因此对 `/system/app/*/lib/` 做 0 字节覆盖对它**无效**。
> `check.sh` 会按活动 `codePath` 实测并明确报告。详见技术取证报告 13 节。

---

## 📚 文档

- [技术取证报告](docs/technical-report.md)
- [系统框架层取证（framework.jar / services.jar）](docs/framework-hooks.md)
- [系统优化记录](docs/optimization.md)
- [恢复被定制 ROM 去掉的开发能力](docs/restore-removed-pages.md)
- [法律依据](docs/legal-basis.md)
- [给普通人的说明](docs/plain-language.md)

---

🛠️ 参与贡献

见 CONTRIBUTING.md。

如果你有同款或类似设备，欢迎提交取证数据：

· 使用 设备报告模板
· 附上 check.sh 输出
· 说明设备型号、系统版本

---

⚖️ 免责声明

使用本项目前请仔细阅读 DISCLAIMER.md。

· 本项目仅供技术研究与个人设备净化使用
· 修改系统有变砖风险，操作前务必备份
· 作者不对任何设备损坏、数据丢失、法律纠纷负责

---

📜 许可证

AGPL-3.0 License

---

🙏 致谢

· AOSP 开源社区
· Magisk / KernelSU 项目
· 所有提交取证数据的贡献者

---

如果这个项目帮到了你，请给一个 ⭐ Star。
