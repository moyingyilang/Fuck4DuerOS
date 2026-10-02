# DuerOS 隐藏框架子系统（framework.jar / services.jar）

**设备**：小度学生手机 XD-SEE00-2301
**系统**：DuerShow_T616_v1.65.0.20250825010819358.R（Android 12 / SDK 31）
**取证方式**：`unzip` 取出 `classes*.dex` → `dexdump` → 按类名过滤
**取证日期**：2026-10-02
**原始数据**：`evidence/device-xd-see00-2301/framework/`

---

## 0. 一句话结论

这台设备的 SystemServer 与 framework 里被塞进了 **107 个非 AOSP 类（1108 个方法）**，
包名统一为 `com.baidu.*` / `android.*.baidu`，全部被标记为
`hiddenapi : 0x0002 (BLOCKED)`。

它们不是普通预装应用，而是**直接改在系统框架层**的私有实现：可以绕过权限确认、
重定向「设置」页面、改通知、封广播、控输入法、记录摄像头/麦克风使用、
并且把 CPU / 内存 / 启动耗时等数据打成埋点广播发出去。

---

## 1. 取证方法（可复现）

```bash
adb shell 'su -c "
  cd /data/local/tmp && mkdir -p fw && cd fw
  unzip -o /system/framework/services.jar  \"classes*.dex\"
  unzip -o /system/framework/framework.jar \"classes*.dex\"
  dexdump classes*.dex | awk \"/Class descriptor/{ if (\\\$0 ~ /baidu\\\\//) p=1; else p=0 } p\"
"'
```

仓库内已保存解析结果：

| 文件 | 内容 |
| --- | --- |
| `framework/framework_baidu_classes.txt` | framework.jar 的 `dexdump` 原始块（62 类） |
| `framework/services_baidu_classes.txt` | services.jar 的 `dexdump` 原始块（45 类） |
| `framework/framework_baidu_api.md` | 由脚本解析出的类/方法表 |
| `framework/services_baidu_api.md` | 同上 |

解析脚本：`scripts/parse_dexdump.py`（无第三方依赖）。

---

## 2. services.jar —— 被改造的 system_server

`services.jar` 是 `system_server` 的实现。AOSP 里不该出现 `com.baidu.*`，
但这台设备有 **45 个类、386 个方法**。

### 2.1 `com.android.server.baidu` —— 私有系统服务

| 类 | 作用 |
| --- | --- |
| `DuerService` | 私有系统服务本体，`IDuerService` 的实现 |
| `DuerLocalServiceIntf` | 本地服务接口 |
| `DuerSystemConfigManager` | 系统配置下发 |
| `AppOpsUtils` | AppOps 操作封装 |

### 2.2 `com.baidu.am` —— 改造 ActivityManager

| 类 | 关键方法 | 含义 |
| --- | --- | --- |
| `ActivityStackMonitor` | `checkStartActivity`、`filterBlockedResolveInfo`、`filterBlockedServiceResolveInfo`、`forceStopPackage`、`setBlockingPackageList`、`setBlockingActivityList` | 在 AMS 启动链路里拦截：哪个包、哪个 Activity 能起来由百度名单决定 |
| `ActivityRedirection` | `isSettingsAction`、`redirectToDefaultSettingAction`、`replacePendingIntent`、`replaceTaskAffinityIfNeeded`、`shouldRedirect` | **识别「设置」类 Intent 并重定向**；**替换通知里的 PendingIntent** |
| `BroadcastBlocker` | `shouldBlock` | 拦广播 |
| `SyncManagerBlocker` | `shouldBlock` | 拦同步 |
| `AppProcessController` | `onStartProcessLocked`、`setBackgroundControllerSwitch`、`addProcessWhitelistPackage` | 控制进程能否启动 + 白名单 |
| `ClearTaskController` | `isDoNotKillPackage`、`isForceStopPackage` | 控制「一键清理」杀谁不杀谁 |
| `CrashController` | — | 崩溃处理 |
| `ProcessStartStatistics` | — | 进程启动统计 |

> `redirectToDefaultSettingAction` 与 `isSettingsAction` 尤其值得注意：
> 用户点「设置」时，最终打开的是系统原生 Settings，还是被换成了定制页面，
> 由框架层这段代码决定。

### 2.3 `com.baidu.pm` —— 旁路权限系统

| 类 | 关键方法 |
| --- | --- |
| `PermissionController` | `shouldGrantSignaturePermission`、`shouldRevokeSignaturePermission`、`revokePkgFlagsIfNeeded`、`removeLauncherIfNeeded`、`shouldNotShowConfirmationDialog`、`isDuerOsDangerousPermission`、`shouldGrantApplicationOverlayPermission` |
| `PermissionUtils` | `getSpecialPermissionStatus` |
| `PreloadAppController` | `isPreloadThirdPartyApps`、`isGelingApps` |
| `Permission` | 权限模型 |

`shouldNotShowConfirmationDialog` + `shouldGrantSignaturePermission` 组合起来就是：
**对白名单内的包，可以不弹确认框直接授予签名级权限。**

### 2.4 `com.baidu.monitors` —— 摄像头 / 麦克风 / 传感器使用记录

| 类 | 方法 |
| --- | --- |
| `CameraUseStatusMonitor` | `onCameraOpened`、`onCameraClosed`、`getCameraUseApps` |
| `MicUseStatusMonitor` | `onMicrophoneOn`、`onMicrophoneOff`、`getMicUseApps` |
| `CommonSensorUseStatusMonitor` | — |

对应 `IDuerService.getCameraUseApps()` / `getMicUseApps()`：
**当前有哪些 App 在用摄像头/麦克风，是可以被跨进程查询的。**

### 2.5 其它

| 包 | 类 | 作用 |
| --- | --- | --- |
| `com.baidu.input` | `InputMethodMonitor` | 监听输入法切换、读取启用/默认输入法 |
| `com.baidu.notification` | `NotificationController` | `isAllowedToPostNotification` 决定谁能发通知 |
| `com.baidu.log` | `AmsShellCommand`、`PmsShellCommand`、`WmsShellCommand`、`DuerOsDebugConfig` | 私有 `adb shell` 命令 |
| `com.baidu.power` | `DuerPowerManager` | 电源管理 |

---

## 3. framework.jar —— 私有 API 与埋点

framework.jar 有 **62 个类、722 个方法**。

### 3.1 `IDuerService`：63 个方法的提权接口

`Landroid/os/baidu/IDuerService` 是一个 AIDL 接口（`$Stub` / `$Stub$Proxy` 都在
framework.jar 里），共 **63 个 abstract 方法**。摘录：

| 方法 | 签名 | 能力 |
| --- | --- | --- |
| `wipe` | `()V` | 擦除设备 |
| `takeScreenshot` | `(II)Landroid/graphics/Bitmap;` | 截屏 |
| `screenshot` | `(II)[B` | 截屏（字节流） |
| `readWifiPassWd` | `()Ljava/lang/String;` | 读 WiFi 密码 |
| `sendUibcInputEvent` | `(Ljava/lang/String;)V` | 注入 UI 输入事件 |
| `copyProcessProcFiles` | `(ILjava/lang/String;)Z` | 拷贝进程 `/proc` 文件 |
| `freeStorage` | `(J)V` | 释放存储 |
| `getDataBytes` | `(Ljava/lang/String;)J` | 读某包流量 |
| `setRuntimePermissions` | `(Ljava/lang/String;Ljava/lang/String;)V` | 直接改运行时权限 |
| `setSpecialPermissionStatus` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | 改特殊权限 |
| `setBlockingPackages` / `setBlockingActivities` | `(Ljava/util/List;)V` | 设置封禁名单 |
| `setNonBlockingApplets` | `(Ljava/util/List;)V` | 设置豁免名单 |
| `disableNetwork` / `forgetWifi` | — | 断网 / 删 WiFi |
| `setActiveProfileOwner` | `(Landroid/content/ComponentName;Ljava/lang/String;)Z` | 设置 Profile Owner |
| `getAppProcessControllerWhiteList` | `()Ljava/util/List;` | 读进程白名单 |
| `registerCameraAndMicActionListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | 订阅摄像头/麦克风事件 |

`Landroid/app/baidu/DuerServiceManager` 是它的客户端封装（71 个方法），
任何拿到这个 Binder 的进程都能调用上述能力。

### 3.2 `android.app.baidu` —— 直接改 App 行为

| 类 | 关键方法 | 含义 |
| --- | --- | --- |
| `DuerShowInputEventReceiver` | `monitorGestureInput`、`pilferPointers` | **偷取触摸事件**（`pilferPointers` 会把后续手势从原 App 转走） |
| `ITouchEventMonitor` | `onTouchEvent` | 触摸事件回调 |
| `SharedPreferenceHack` | `onGetBoolean`、`onPutString` | **拦截 SharedPreferences 读写** |
| `DuerVolumeController` | — | 接管音量控制 |
| `IVolumeControllerListener` | `volumeChanged`、`masterMuteChanged` | 音量/静音事件 |
| `IPackageDataListener` | `onRemoveCompleted` | 清数据回调 |

`SharedPreferenceHack` 和 `pilferPointers` 是这次取证里最"重"的两个发现：
前者能在框架层改写 App 读到的配置值，后者能截走用户的触摸手势。

### 3.3 `com.baidu.framework.statistics` —— 框架级埋点

这套埋点是**在 framework 内部**统计系统自身，不依赖任何 App：

| 类 | 作用 |
| --- | --- |
| `StatisticController` | 埋点总控 |
| `AnalyticsReporter` / `IReporter` | 上报接口 |
| `reporter/BroadcastReporter` | 以广播形式外发 |
| `DuerCpuTracker` | CPU 占用（`processCpuRate`、`sysCpuRate`、`sysIowait`） |
| `DuerLaunchTimeReporter` | 启动耗时 |
| `PmsEventQueue` / `model/PmsEvent` | 包管理事件 |
| `model/ThirdAppDownloadEvent` | **第三方 App 下载/安装事件**（`allow_install` / `disallow_install`） |
| `model/ZcombieProcEvent` | 进程事件 |
| `model/CesEvent` | CES 事件 |

从 dex 里提取到的广播 action 与事件常量（`StatisticConstants`）：

```
com.baidu.framework.STATISTICS_ACTION
com.baidu.framework.CES_STATISTICS_ACTION
event_id 5146  进程事件
event_id 5262
event_id 5404
event_id 5477
event_page: process_dex2oat / process_healthy_data / zcombie_process
            allow_install / disallow_install
字段: event_start_time event_end_time duration processCpuRate processMemory
      sysCpuRate sysMemRate sysIowait description extension ...
```

也就是说：**设备上装了/卸了哪个第三方 App、哪个进程被 dex2oat、
CPU 和内存跑了多少，都会以广播形式在系统内流转上报。**

### 3.4 其它

| 类 | 作用 |
| --- | --- |
| `DuerShowManagerEx` / `IDuerShowManagerEx` | 跨进程管理接口 |
| `WindowFlagsCleaner` | 清窗口 flag |
| `AppDensityController` | 改 App 密度 |
| `DuerOsFeatures` / `DefaultFeatures` / `FeaturesCX15` | 机型特性开关 |
| `android.widget.baidu.ToastUtils` | Toast 封装 |

---

## 4. 与 PCDN 的关系

框架层这些能力里，和 PCDN 直接相关的是：

1. `ActivityStackMonitor` / `AppProcessController` 决定**哪些进程能常驻**——
   这解释了技术报告里「禁用 PCDN 后会自动恢复」的行为：
   拉起 PCDN 的通路在 AMS 内部，不在用户能控制的应用层。
2. `DuerOsFeatures` / `DuerSystemConfigManager` 是**云端下发开关**的落点。
3. `DuerPowerManager` 让 PCDN 进程免受省电策略影响。

---

## 5. 统计汇总

| 组件 | 类数 | 方法数 |
| --- | --- | --- |
| `/system/framework/framework.jar` | 62 | 722 |
| `/system/framework/services.jar` | 45 | 386 |
| **合计** | **107** | **1108** |

包分布：

```
framework.jar:  android/app/baidu  android/os/baidu  android/widget/baidu
                com/baidu/android/duershow  com/baidu/framework
                com/baidu/framework/features  com/baidu/framework/statistics
                com/baidu/framework/statistics/model
                com/baidu/framework/statistics/reporter
                com/baidu/framework/view  com/baidu/utils  com/baidu/view

services.jar:   com/android/server/baidu  com/baidu/am  com/baidu/input
                com/baidu/log  com/baidu/log/base  com/baidu/monitors
                com/baidu/notification  com/baidu/pm  com/baidu/power
```

---

## 6. 说明与边界

- 本文只做**静态**取证（读 dex / 类结构 / 常量），没有反编译 smali 逐行审计，
  也没有对上述方法做动态调用验证。
- 方法名来自 `dexdump` 的 `name` 字段，未被混淆（`com.baidu.*` 用的是可读名）。
- 未包含任何用户数据；序列号、原始网络连接表等已在采集脚本里剔除。
- `hiddenapi : 0x0002 (BLOCKED)` 表示这些类对普通 App 属于 hidden API，
  普通应用无法直接调用，但系统内的系统应用可以。
