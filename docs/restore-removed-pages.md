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

### 1.4 弹窗为什么在无线下不出现（实测）

这一节是踩了很多次坑之后才搞清楚的，记录完整结论，避免后人重复。

**（1）`UsbDebuggingActivity` 一直存在，也**没有**被禁用。**
起初用 `strings` 扫 SystemUI 的 `AndroidManifest.xml` 没找到它，差点得出
"ROM 把界面删了"的结论；换 `aapt2` 精确解析后发现组件一直在：

```bash
aapt2 dump xmltree --file AndroidManifest.xml SystemUI.apk | grep -i usb
#   com.android.systemui.usb.UsbDebuggingActivity
#   com.android.systemui.UsbDebuggingActivityAlias  (targetActivity 同上)
#   com.android.systemui.usb.UsbDebuggingSecondaryUserActivity
```

> `strings` 对二进制 AXML 会漏。**检查 manifest 必须用 aapt2。**

**（2）它是非导出组件，只有 `system_server` 能拉起。**
试图用 `am start` 手动验证时，拿到的是完整堆栈：

```
SecurityException: Permission Denial: starting Intent {
  cmp=com.android.systemui/.usb.UsbDebuggingActivity } from null (pid=..., uid=2000)
  not exported from uid 10124
    at ActivityTaskSupervisor.checkStartAnyActivityPermission
```

也就是说：**任何用 `am start` 手动测试"弹窗出没出来"的尝试都不可能成功**，
这个界面只接受系统进程的启动请求。

**（3）TCP / 无线通道根本不走授权确认。**
把手机连上 USB、打开 USB ADB 后，用另一把全新密钥（独立 adb server、独立端口）
发起无线连接，adbd 直接返回：

```
failed to authenticate to <已隐去的内网地址>:5555
```

**没有弹窗、也不给确认机会**。原因是做确认的 `UsbDebuggingManager` 属于
`UsbDeviceManager`，它服务的是 **USB 传输**。

| 通道 | 陌生密钥的行为 |
| --- | --- |
| **USB** | 由 `system_server` 拉起 `UsbDebuggingActivity`，弹窗授权（原生行为） |
| **TCP / 无线** | 直接 `failed to authenticate`，无弹窗 |

**（4）弹窗的额外参数要求**（反汇编 `onCreate` 得到）：

```
getStringExtra("fingerprints")  → 为 null 则直接 finish()
getStringExtra("key")           → 为 null 则直接 finish()
```

框架会同时传 `key` 和 `fingerprints`；只传 `key` 会走"参数不全→立刻退出"分支。

**（5）结论与可用路径：**

- 修复 `ro.adb.secure=1` 是恢复授权机制的关键（见 1.3），也是唯一被 ROM 改掉的地方；
- **要授权新电脑，用 USB 线连**，弹窗会正常出现（标准 Android 行为）；
- 只有无线可用时，用 `scripts/adb_authorize.sh` 直接写入公钥；
- 无线场景下，未被授权的密钥会被直接拒绝，这是预期行为，不是故障。

### 1.5 顺带把 USB 调试开关打开

ROM 里 `settings get global adb_enabled` 是 `0`——USB 插上电脑连 adb 接口都不会出现，
自然永远走不到授权那一步。模块会把它置 1，系统随即把 USB 功能切换为 `mtp,adb`：

```
adb_enabled   = 1
sys.usb.config = mtp,adb
```

### 1.6 一个主机侧的小坑（如果你也用 Termux 当 adb 主机）

在 Android 手机上跑 adb 去连另一台手机时，adb 会读不到 USB 设备：
`/dev/bus/usb/001/00X` 属主是 `root:usb`，而 Termux 应用不在 `usb` 组，
且 SELinux 也拦 `untrusted_app` 访问该节点。两个办法：

```bash
# 办法一：放开节点权限（每次重新枚举后 devnum 会变）
su -c 'chmod 666 /dev/bus/usb/001/008'

# 办法二：以 root 起 adb server（顺带绕开 SELinux）
su -c 'mkdir -p /data/local/tmp/adbroot/.android'
su -c 'cp ~/.android/adbkey* /data/local/tmp/adbroot/.android/'
su -c 'HOME=/data/local/tmp/adbroot adb start-server'
```

注意 root 的 `HOME` 是 `/`（只读），直接 `su -c adb start-server` 会因
`Cannot mkdir '//.android'` 而崩，必须给它一个可写的 `HOME`。

---

## 2. 被禁用的系统页面

### 2.0 开发者选项：页面能开，但一开就崩（ROM 的策略缺陷）

这是本次最费周折的一处，根因和"页面被禁用"完全是两码事。

**现象**：把开发者选项页面重新启用后，一打开就 `设置已停止运行`：

```
FATAL EXCEPTION: main
Process: com.android.settings
java.lang.RuntimeException: Unable to resume activity {...SubSettings}:
  java.lang.RuntimeException: failed to set system property
    at android.os.SystemProperties.native_set
    at android.os.SystemProperties.set
    at AbstractLogpersistPreferenceController.updateLogpersistValues:179
    at LogPersistPreferenceController.updateState:57
    at DashboardFragment.updatePreferenceStates / onResume
```

**根因**（`dmesg` 里的 avc 记录写得非常明确）：

```
avc: denied { set } for property=logd.logpersistd
  scontext=u:r:system_app:s0
  tcontext=u:object_r:logpersistd_logging_prop:s0
  tclass=property_service permissive=0
```

Settings 以 `system_app` 域运行，打开开发者选项时要执行
`SystemProperties.set("logd.logpersistd", ...)`，但**这台 ROM 的 SELinux 策略里
没有 `system_app` 对 `logpersistd_logging_prop` 的 `set` 许可**，属性设置抛异常，
整个 Settings 进程随之崩溃。

因为 ROM 把开发者选项整页禁用着，这个坑一直没人踩到；一旦把页面放出来就必崩。

**处置**：模块用 `sepolicy.rule` 补上两条**最小范围**的许可
（只针对 `logpersistd_logging_prop` 这一个属性类型）：

```
allow system_app logpersistd_logging_prop property_service set
allow system_app logpersistd_logging_prop file { open read }
```

Magisk 在开机加载策略时会自动应用模块里的 `sepolicy.rule`；
`service.sh` 里还做了一次运行时兜底，所以**装完模块不重启也能用**。

**验证**：

```
mResumedActivity: com.android.settings/.Settings$DevelopmentSettingsDashboardActivity
崩溃次数: 0
```

> 排错过程记录：中途我先怀疑是属性未定义（走 `default_prop`）而打错了目标类型，
> 也怀疑过 `UsbDisconnectedReceiver`；两者都被实测否定。
> **`dmesg` 里的 `avc: denied` 才是最终判据**，不要靠推测。

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
