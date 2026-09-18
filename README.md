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

### 1. 侦察

```bash
su -c 'sh scripts/check.sh'
```

确认输出里有 com.baidu.pcdn 等组件。

2. 执行

```bash
su -c 'sh scripts/install.sh'
su -c 'reboot'
```

3. 验证

重启后：

```bash
su -c 'ps -A | grep -iE "pcdn|duer"'
su -c 'cat /system/etc/hosts | grep baidu'
```

4. 后悔了？

```bash
su -c 'sh scripts/rollback.sh'
su -c 'reboot'
```

---

🔍 检测原理

组件 检测方式 处理方式
PCDN ps -A \| grep pcdn 禁用 + 库文件覆盖
Duerguard pm list packages -d 禁用
GoodFather pm list packages -d 禁用
通讯劫持 dumpsys activity services 组件级禁用
上报域名 cat /system/etc/hosts hosts 屏蔽

---

📚 文档

· 技术取证报告
· 法律依据
· 给普通人的说明

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
