# 恢复被定制 ROM 去掉的开发能力

**设备**：小度学生手机 XD-SEE00-2301（DuerShow_T616_v1.65.0.20250825010819358.R / Android 12）
**时间**：2026-10-02
**模块**：`duer_devrestore`

---

## 1. ADB 授权弹窗：ROM 只改了一处

### 1.1 现象

插上电脑、开 USB 调试，**不弹「允许 USB 调试吗？」**，任何能连上的人直接就是 shell。
设备上 `ro.adb.secure = 0`。

`ro.adb.secure=0` 的含义是 **adbd 完全不校验主机公钥**。所以问题不是"弹窗坏了"，
而是"永远不会走到弹窗那一步"。

### 1.2 弹窗组件其实还在

一开始我用 `strings` 扫 SystemUI 的 `AndroidManifest.xml`，没找到
`UsbDebuggingActivity`，差点得出"ROM 把界面删了、只能自己造"的结论。
后来用 `aapt2` 精确解析，发现**组件一直都在**：

```bash
aapt2 dump xmltree --file AndroidManifest.xml SystemUI.apk | grep -i usb
#   com.android.systemui.usb.UsbDebuggingActivity
#   com.android.systemui.UsbDebuggingActivityAlias  (targetActivity 同上)
#   com.android.systemui.usb.UsbDebuggingSecondaryUserActivity
```

`strings` 对二进制 AXML 会漏，**检查 manifest 必须用 aapt2**。这是个值得记下的坑。

框架侧的资源也仍然指向它：

```text
resource 0x01040205 string/config_customAdbPublicKeyConfirmationComponent
    = com.android.systemui/com.android.systemui.usb.UsbDebuggingActivity
resource 0x01040206 string/config_customAdbPublicKeyConfirmationSecondaryUserComponent
```

组件没被禁用（`dumpsys package com.android.systemui` 的 `disabledComponents` 里没有它），
`cmd package resolve-activity -n com.android.systemui/.usb.UsbDebuggingActivity` 也能解析。

**结论：唯一被改的就是 `ro.adb.secure`。**

### 1.3 处理

`ro.adb.secure` 是 `ro.*` 属性，只能在 adbd 启动前用 Magisk 的 `resetprop` 覆盖：

```bash
resetprop ro.adb.secure 1
setprop ctl.restart adbd      # 让 adbd 重新读取（会断开当前 adb 连接）
```

已做成模块 `duer_devrestore`：
- `post-fs-data.sh` → `resetprop ro.adb.secure 1`（赶在 adbd 起来之前）
- `service.sh` → 兜底检查

验证方式（用第二把陌生密钥去连，设备端确认 adbd 不再自动放行）：

```bash
# 主机端：用一个独立的 HOME 让 adb 生成全新密钥，另开一个 server 端口
mkdir -p /tmp/fakehome/.android
HOME=/tmp/fakehome adb -P 5038 start-server
HOME=/tmp/fakehome adb -P 5038 connect <设备IP>:5555
# 结果：连接挂起、不进 devices 列表 —— 说明 adbd 在等授权（修复前会被直接放行）
```

### 1.4 一个必须知道的前提：弹窗只在插 USB 线时出现

`UsbDebuggingActivity` 在没有 USB 连接时会**立刻 `finish()`**（AOSP 里注册了
`UsbDisconnectedReceiver`，收到 `USB_STATE` 且 `connected=false` 就退出）。

实测：设备 `kernel_state=DISCONNECTED`、`connected=false`，此时手动拉起该 Activity，
即使传入**真实合法的 RSA 公钥**，0.5 秒内也会自行退出：

```bash
am start -n com.android.systemui/.usb.UsbDebuggingActivity \
  --es key "<adbkey.pub 的内容>" --esa packages com.example
dumpsys activity activities | grep -c UsbDebugging      # => 0
```

所以：

| 场景 | 行为 |
| --- | --- |
| **插 USB 线**连接新电脑 | 正常弹出「允许 USB 调试吗？」，这和原生 Android 一致 |
| **纯无线**连接新电脑 | 弹窗无法驻留；连接会一直挂起未授权 |

这是 AOSP 的设计，不是这台 ROM 特有的问题。

### 1.5 无线场景怎么授权

既然弹窗只在插线时可用，纯无线就预置公钥：

```bash
# 主机端取公钥
cat ~/.android/adbkey.pub

# 设备端（需 root）写入
su -c 'sh /data/local/tmp/adb_authorize.sh add "<上面那行的完整内容>"'
su -c 'setprop ctl.restart adbd'
```

`scripts/adb_authorize.sh` 还支持：
- `list` —— 列出已授权公钥（显示 sha256 前 16 位指纹，便于辨认）
- `remove <指纹前缀>` —— 删除某一把（自动备份原文件）
- `backup` / `restore` —— 备份与恢复 `/data/misc/adb/adb_keys`

> ⚠️ **风险提示**：恢复 `ro.adb.secure=1` 之后，未被授权的电脑必须**插线**才能授权。
> 升级前请确认至少有一台电脑的密钥已在 `adb_keys` 里（或设备上有本地 root 终端兜底），
> 否则可能一时无法用 adb。要退回原状，移除模块并重启即可
> （`ro.adb.secure` 会由 ROM 的 build.prop 还原为 0）。

---

## 2. 被禁用的系统页面

### 2.1 来源

ROM 的禁用是通过 PackageManager 的**组件级禁用**做的，落在：

```text
/data/system/users/0/package-restrictions.xml   (二进制 AXML)
```

读它的正确姿势是先转成文本：

```bash
su -c 'abx2xml /data/system/users/0/package-restrictions.xml /data/local/tmp/pr.xml'
```

全设备共 **95 条组件级禁用**，涉及 20 个包；其中大部分是第三方 App 自己
禁用推送/自启组件（正常现象），属于 ROM 定制的只有下面这些。

### 2.2 属于 ROM 定制的那批

| 组件 | 对应的页面 |
| --- | --- |
| `com.android.settings.Settings$DevelopmentSettingsDashboardActivity` | **开发者选项（整页）** |
| `com.android.traceur.StorageProvider` / `QsService` | **系统跟踪 System Tracing** |
| `com.android.settings.Settings$NavigationBarSettingsActivity` | 导航栏设置 |
| `com.android.settings.Settings$UserSettingsActivity` | 多用户设置 |
| `com.android.permissioncontroller.role.ui.SpecialAppAccessListActivity` | 特殊应用访问权限 |
| `com.android.settings.CryptKeeper` | 加密密码界面（**未动**，属启动路径） |
| `com.android.provision.DefaultActivity` | 开机向导（**未动**） |

开发者选项被禁用得特别"讲究"：系统里同时保留了一个
`com.android.settings.development.DevelopmentSettingsDisabledActivity`，
专门用来显示「此用户无法使用开发者选项」。

### 2.3 处理

```bash
su -c 'sh /data/local/tmp/restore_dev_pages.sh'
```

即 `pm enable --user 0 <组件>` 逐项启用，并把开发者选项总开关打开：

```bash
settings put global development_settings_enabled 1
```

验证：

```bash
cmd package resolve-activity --brief -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS
# 修复前 -> com.android.settings/.development.DevelopmentSettingsDisabledActivity
# 修复后 -> com.android.settings/.Settings$DevelopmentSettingsDashboardActivity
```

`dumpsys package com.android.settings | sed -n '/disabledComponents/,/enabledComponents/p'`
由 4 条降到 1 条（只剩我有意保留的 `CryptKeeper`）。

### 2.4 已验证的一个限制

`com.android.permissioncontroller` 的特殊应用访问页**没能启用成功**：
`pm enable` 返回 `new state: enabled`，但 `dumpsys` 里仍然显示为禁用。
该包位于 APEX 内（`/apex/com.android.permission/priv-app/PermissionController/`），
其组件状态不通过常规 `pm enable` 持久化。目前未找到不修改 APEX 的解决办法。

---

## 3. 回滚

```bash
# 单独禁用某个页面（以开发者选项为例）
adb shell "su -c 'pm disable-user --user 0 com.android.settings/.Settings\$DevelopmentSettingsDashboardActivity'"

# 关闭开发者选项总开关
adb shell "su -c 'settings put global development_settings_enabled 0'"

# 移除模块（ro.adb.secure 会在下次开机由 ROM 还原为 0）
adb shell "su -c 'rm -rf /data/adb/modules/duer_devrestore'"
```

---

## 4. 复现方式

```bash
# 装模块（开机自动恢复）
./scripts/install_module.sh duer_devrestore

# 或立即执行一次
adb shell "su -c 'sh /data/adb/modules/duer_devrestore/post-fs-data.sh'"
adb shell "su -c 'sh /data/adb/modules/duer_devrestore/service.sh'"
adb shell "su -c 'setprop ctl.restart adbd'"
```
