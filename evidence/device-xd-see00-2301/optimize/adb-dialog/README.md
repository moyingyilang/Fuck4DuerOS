# ADB 授权弹窗恢复的证据

设备：XD-SEE00-2301（DuerShow_T616_v1.65.0.20250825010819358.R / Android 12）
时间：2026-10-02 20:01

## 背景

这台 ROM 有两处让 ADB 授权弹窗失效：

1. `ro.adb.secure = 0` —— adbd 根本不校验主机公钥；
2. `ro.boot.skuid = 600WW` —— 命中 SystemUI `UsbDebuggingActivity.onCreate`
   里的厂商分支，直接 `notifyService(...) + finish()`，把授权界面掐掉。

## dialog_interaction.log

在被控机本地运行、用 `setsid` 脱离 adb 会话的点击脚本日志。
流程：用全新密钥的 adb server 走 USB 发起连接 → 弹窗出现 → 脚本勾选
「一律允许」并点「允许」→ 弹窗消失。

关键行：

```
[20:01:18] 等 5s 后弹窗出现
text="允许 USB 调试吗？"
text="一律允许使用这台计算机进行调试"
text="允许"
text="取消"
text="这台计算机的 RSA 密钥指纹如下：<已隐去的主机密钥指纹>"
[20:01:24] tap -> 359,867    (复选框)
[20:01:26] tap -> 582,993    (允许)
[20:01:28] 弹窗已消失，完成
```

结果：
- 设备端 `/data/misc/adb/adb_keys` 新增一条（说明「一律允许」生效、永久写入）；
- 主机侧设备状态由 `unauthorized` 变为 `device`。

## 复现

```bash
# 被控机本地：安排好点击动作（用 setsid 脱离 adb 会话）
su -c 'setsid sh /data/local/tmp/dlg_tap2.sh >/dev/null 2>&1 </dev/null &'

# 主机侧：用全新密钥的 adb server 走 USB
su -c 'HOME=/data/local/tmp/adbfresh adb start-server'
adb devices        # 先 unauthorized，弹窗被点掉后变 device
```

完整的根因分析与反汇编见 `docs/restore-removed-pages.md`。
