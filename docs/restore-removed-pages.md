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

### 1.4 真正的元凶：`ro.boot.skuid == "600WW"`

前面几节只解决了"adbd 要不要鉴权"的问题。把 `ro.adb.secure` 改回 1 之后，
陌生主机的状态确实变成了 `unauthorized`——**但弹窗始终不出现**，一直卡在未授权。

把 SystemUI 的 `UsbDebuggingActivity.onCreate` 完整反汇编后，找到了原因：

```text
00e0: const-string v0, "600WW"
00e2: invoke-virtual {v0, v7}, Ljava/lang/String;.equals      // v7 = ro.boot.skuid
00e5: move-result v7
00e6: if-eqz v7, 00ee        // skuid != "600WW"  ->  00ee: return-void（弹窗保留）
00e8: invoke-direct {v6, v2}, notifyService:(Z)V              // skuid == "600WW"
00eb: invoke-virtual {v6}, AlertActivity;.finish:()V          //   -> 通知服务并立刻关闭
00ee: return-void            // 只有 skuid != "600WW" 才会走到这里
```

`notifyService` 的实现（同一份反汇编）：

```text
IAdbManager.allowDebugging:(ZLjava/lang/String;)V    // allow == true
IAdbManager.denyDebugging:()V                        // allow == false
```

**这台设备的 `ro.boot.skuid` 恰好是 `600WW`，所以 ROM 的定制分支直接
`notifyService(...) + finish()`，弹窗被静默吞掉，永远不会显示。**
陌生主机只会一直停在 `unauthorized`，而且没有任何提示。

这比 `ro.adb.secure` 隐蔽得多：`ro.adb.secure=0` 只是"不要求鉴权"，
而这段代码是"要求鉴权、但把授权界面掐掉"。

### 1.5 处置与端到端验证

`ro.boot.skuid` 是 `ro.*` 属性，Magisk 的 `resetprop` 可以覆盖。改成任意
非 `600WW` 的值，`onCreate` 就会走到 `00ee: return-void`，弹窗恢复：

```bash
resetprop ro.boot.skuid 0
```

因为 `am start` 会被 `not exported` 拦住（见 1.6），无法手工触发，
所以验证方式是**在被控机本地预先安排好"点允许"的动作**，再让陌生密钥去连 USB：

- 被控机上用 `setsid` 把点击脚本从 adb 会话里摘出来（`PPID=1`），
  这样 adb 断了它照样跑；
- 脚本轮询 `dumpsys window` 等弹窗，用 `uiautomator dump` 解析按钮坐标，
  再 `input tap`；
- 主机侧用一个全新密钥的 adb server 走 USB 发起连接。

实测结果（原始日志见 `evidence/device-xd-see00-2301/optimize/adb-dialog/`）：

```text
[20:01:13] 启动
[20:01:18] 等 5s 后弹窗出现
text="允许 USB 调试吗？"
text="一律允许使用这台计算机进行调试"
text="允许"
text="取消"
text="这台计算机的 RSA 密钥指纹如下：<已隐去的主机密钥指纹>"
[20:01:24] tap -> 359,867    (复选框「一律允许」)
[20:01:26] tap -> 582,993    (按钮「允许」)
[20:01:28] 弹窗已消失，完成
```

设备侧密钥表随即多出一条（说明"一律允许"生效、密钥被永久写入）：

```text
[1] a918d6f7272fc644  ...u0_a446@localhost   ← 原有
[2] 361176c6b0fc7226  ...root@localhost      ← 本次弹窗授权的
```

主机侧状态由 `unauthorized` 变为 `device`。

**结论：ADB 授权弹窗已经真正恢复，并且经过完整的端到端验证。**

### 1.6 两个容易踩的坑

**（1）弹窗组件是非导出的，不能用 `am start` 测。**
它声明了 `android:permission="android.permission.MANAGE_DEBUGGING"` 且
`exported=false`，只有 `system_server` 能拉起：

```text
SecurityException: Permission Denial: starting Intent {
  cmp=com.android.systemui/.usb.UsbDebuggingActivity } from null (uid=2000)
  not exported from uid 10124
```

所以此前所有"用 am start 试弹窗"的结论都不可靠。

**（2）检查 manifest 必须用 aapt2，不能用 strings。**
`strings` 扫二进制 AXML 会漏掉 `UsbDebuggingActivity`，我因此一度误判
"ROM 把界面删了"，差点去自己重写一个。

```bash
aapt2 dump xmltree --file AndroidManifest.xml SystemUI.apk | grep -i usb
```

### 1.7 关于无线（TCP）通道

`UsbDebuggingManager` 属于 `UsbDeviceManager`，服务的是 **USB 传输**。
实测用陌生密钥走 TCP 连接，adbd 直接返回 `failed to authenticate`，
**不弹窗、也不给确认机会**：

| 通道 | 陌生密钥的行为 |
| --- | --- |
| **USB** | 弹窗授权（修好 skuid 之后），可勾选"一律允许"永久写入 |
| **TCP / 无线** | 直接 `failed to authenticate`，无弹窗 |

所以**授权新电脑请用 USB 线**；只有无线可用时，用 `scripts/adb_authorize.sh`
直接写入公钥。

### 1.8 顺带打开 USB 调试开关

ROM 里 `settings get global adb_enabled` 是 `0`——USB 插上电脑连 adb 接口都不会出现。
模块把它置 1，系统随即把 USB 功能切换为 `mtp,adb`。

### 1.9 主机侧的小坑（如果用 Termux 当 adb 主机）

在 Android 手机上跑 adb 去连另一台手机时，adb 读不到 USB 设备：
`/dev/bus/usb/001/00X` 属主是 `root:usb`，Termux 应用不在 `usb` 组，
SELinux 也拦 `untrusted_app` 访问该节点。两个办法：

```bash
# 办法一：放开节点权限（每次重新枚举后 devnum 会变）
su -c 'chmod 666 /dev/bus/usb/001/008'

# 办法二：以 root 起 adb server（顺带绕开 SELinux）
su -c 'mkdir -p /data/local/tmp/adbroot/.android'
su -c 'cp ~/.android/adbkey* /data/local/tmp/adbroot/.android/'
su -c 'HOME=/data/local/tmp/adbroot adb start-server'
```

注意 root 的 `HOME` 是 `/`（只读），直接 `su -c adb start-server` 会因
`Cannot mkdir '//.android'` 而崩，必须给它可写的 `HOME`。

另外 **adbd 同时只接受一条 TCP 传输**：如果已经有一个 adb server 占着，
第二个 server 的 `adb connect` 会超时——排错时别误以为是网络问题。

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
| `com.android.settings.Settings$NavigationBarSettingsActivity` | 导航栏设置（**Scene 也在管，未恢复**，见 2.5） |
| `com.android.settings.Settings$UserSettingsActivity` | 多用户设置（**Scene 也在管，未恢复**，见 2.5） |
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

### 2.5 有两个页面我刻意没动（它们归 Scene 管）

重启实测时发现：`NavigationBarSettingsActivity` 与 `UserSettingsActivity`
被重新禁用了，而 `DevelopmentSettingsDashboardActivity`（开发者选项）没有。

追查结果：这两个组件名出现在 **Scene（`com.omarea.vtools`）的
`databases/scene_app_contents`** 里——也就是说，是**用户自己在 Scene 里禁用**的，
Scene 会在开机后重新应用。没有任何 ROM 侧或模块侧脚本涉及它们。

所以 `duer_devrestore` 的组件清单里**刻意移除了这两个**：

```
COMPONENTS="
com.android.settings/.Settings$DevelopmentSettingsDashboardActivity   ← ROM 禁用，已恢复
com.android.traceur/.StorageProvider                                  ← ROM 禁用，已恢复
com.android.traceur/.QsService                                        ← ROM 禁用，已恢复
"
```

理由：去抢一份用户自己配置的禁用名单，既会在每次开机产生无意义的反复，
也不尊重用户的设置。**要恢复请在 Scene 里取消勾选**，或把它们加回上面的清单。

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
