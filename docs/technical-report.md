# 百度 PCDN 组件技术取证报告

**设备**：小度学生手机 XD-SEE00-2301
**系统**：DuerShow_T616_v1.65.0.20250825010819358.R（Android 12 / SDK 31）
**取证方式**：Root 权限下的系统级检查、运行时进程监控、APK 反编译
**取证时间**：2026 年 9 月

---

## 法律依据

### 一、《消费者权益保护法》

**第八条**　消费者享有知悉其购买、使用的商品或者接受的服务的真实情况的权利。

**第十条**　消费者享有公平交易的权利。

### 二、《个人信息保护法》

**第十三条**　处理个人信息应当取得个人同意。

**第十七条**　处理个人信息前应当以显著方式告知。

### 三、《网络安全法》

**第二十二条第三款**　网络产品、服务具有收集用户信息功能的，其提供者应当向用户明示并取得同意。

**第四十一条**　收集、使用个人信息应遵循合法、正当、必要原则。

### 四、《电信条例》

**第七条**　经营电信业务，必须取得电信业务经营许可证。

**第八条**　电信业务分为基础电信业务和增值电信业务。

### 五、《未成年人保护法》

**第七十二条**　处理不满十四周岁未成年人个人信息的，应当征得父母或者其他监护人同意。

### 六、《民法典》

**第一千一百六十五条**　行为人因过错侵害他人民事权益造成损害的，应当承担侵权责任。

**第一千一百六十七条**　侵权行为危及他人人身、财产安全的，被侵权人有权请求侵权人承担停止侵害等侵权责任。

---

## 1. 概述

在小度学生手机设备中发现一套完整 PCDN（P2P Content Delivery Network，点对点内容分发网络）客户端及其配套监控系统。该组件具有以下特征：

- 以 system 权限常驻运行
- 具备双向 P2P 传输能力
- 配套完整的性能监控与数据采集 SDK
- 在系统分区多路径预置，形成冗余自启
- 采用类名混淆规避识别
- 无用户可见开关，禁用后自动恢复

---

## 2. 运行时进程取证

### 2.1 进程属性

```bash
ps -A -o PID,NAME,USER | grep -i pcdn
```

输出：

```
3094  com.baidu.pcdn  system
```

属性 值 说明
进程名 com.baidu.pcdn 独立 PCDN 进程
运行用户 system (uid 1000) 系统级权限
进程状态 PROC_STATE_PERSISTENT 常驻，不可杀

2.2 服务声明

```bash
dumpsys activity services | grep -A 15 PCDNService
```

输出摘录：

```
ServiceRecord{fbfc3ad u0 com.baidu.pcdn/com.baidu.pcdnlib.services.PCDNService}
  intent={act=com.baidu.action.pcdn.service pkg=com.baidu.pcdn}
  packageName=com.baidu.pcdn
  processName=com.baidu.pcdn
  permission=com.baidu.permission.pcdn.service
  baseDir=/system/app/PCDN/PCDN.apk
  dataDir=/data/user/0/com.baidu.pcdn
  app=ProcessRecord{6061a5 3094:com.baidu.pcdn/1000}
  recentCallingPackage=com.baidu.duer.ota
  tempAllowListReason:<broadcast:1000:LOCKED_BOOT_COMPLETED>
```

关键发现：

1. APK 位于 /system/app/PCDN/，属系统预置应用
2. 声明专用权限 com.baidu.permission.pcdn.service
3. 由 com.baidu.duer.ota 通过 LOCKED_BOOT_COMPLETED 广播在开机早期拉起
4. 运行用户为 uid 1000（system）

---

3. 文件系统取证

3.1 PCDN 独立 APK

```bash
find /system -iname "*pcdn*" 2>/dev/null
```

输出：

```
/system/app/PCDN/PCDN.apk
/system/app/PCDN/lib/arm/libpcdn.so
/system/app/PCDN/lib/arm/libpcdnsdk.so
```

3.2 系统应用内嵌 PCDN 库

```
/system/app/DuerShowSwan/lib/arm64/libcyber-pcdn.so
/system/app/DuerShowMedia/lib/arm64/libcyber-pcdn.so
/system/app/DuerShowLauncher/lib/arm64/libcyber-pcdn.so
```

PCDN 功能存在于四个独立的系统应用路径中：

路径 类型 作用
/system/app/PCDN/ 独立 APK 主 PCDN 客户端
DuerShowSwan 内嵌库 备用加载路径
DuerShowMedia 内嵌库 备用加载路径
DuerShowLauncher 内嵌库 备用加载路径

删除独立 APK 后，其他三个系统应用仍可加载 libcyber-pcdn.so，形成冗余自启机制。

---

4. 反编译取证

4.1 客户端整体结构

```
PCDN_src/
├── AndroidManifest.xml
├── lib/
│   ├── arm64-v8a/
│   │   ├── libpcdn.so
│   │   ├── libpcdnsdk.so
│   │   └── libxray_native.so
│   └── armeabi-v7a/
├── smali/
│   ├── com/a/a/a/a/a/a/a.smali        ← 混淆类
│   ├── com/baidu/pcdn/
│   │   ├── MainActivity.smali
│   │   └── PCDNApplication.smali
│   ├── com/baidu/pcdnlib/
│   │   ├── impls/P2pDownloader.smali
│   │   ├── impls/PCDNServiceProxy.smali
│   │   ├── services/PCDNService.smali
│   │   └── interfaces/
│   │       ├── IP2pCallback.smali
│   │       └── IP2pDownloader.smali
│   └── com/baidu/xray/
│       └── agent/
│           ├── XraySDK.smali
│           ├── battery/QapmBatteryService.smali
│           ├── instrument/*.smali
│           ├── socket/*.smali
│           └── crab/crash/NativeCrashHandler.smali
```

4.2 P2P 传输模块

```
com/baidu/pcdnlib/impls/P2pDownloader
com/baidu/pcdnlib/services/PCDNService
com/baidu/pcdnlib/impls/PCDNServiceProxy
com/baidu/pcdnlib/interfaces/IP2pCallback
com/baidu/pcdnlib/interfaces/IP2pDownloader
```

接口 IP2pCallback、IP2pDownloader 的存在，表明该组件实现了完整的 P2P 传输协议栈，具备双向数据传输能力。

4.3 Xray 监控模块

模块 采集对象
XrayHttpInstrument HTTP 请求
XrayOkHttpInstrument OkHttp 请求
XrayWebViewInstrument WebView 加载
XraySqliteInstrument 数据库操作
XrayBitmapInstrument 图片处理
QapmBatteryService 电池状态
NativeCrashHandler 原生崩溃
socket/* 网络连接

该 SDK 属于商业级 APM 系统，采集范围覆盖应用行为、网络、电量、崩溃等多个维度。

4.4 类名混淆

```
com/a/a/a/a/a/a/a.smali
com/a/a/a/a/a/a/a$a.smali
com/a/a/a/a/a/a/a$b.smali
com/a/a/a/a/a/a/a$c.smali
```

com.a.a.a.a.a.a 为无意义包名，属于典型的代码混淆产物。

---

5. 系统框架层取证

5.1 system_server 中的百度注入类

```
smali/com/android/server/baidu/AppOpsUtils.smali
smali/com/android/server/baidu/DuerSystemConfigManager.smali
smali/com/android/server/baidu/DuerService.smali
smali/com/android/server/baidu/DuerLocalServiceIntf.smali
```

5.2 DuerService 方法规模

DuerService.smali 含 100+ 方法，覆盖以下领域：

类别 方法示例
权限管理 setRuntimePermissions、setSpecialPermissionStatus
网络控制 disableNetwork、forgetWifi、readWifiPassWd
截屏 takeScreenshot、screenshot
摄像头/麦克风监控 registerCameraAndMicActionListener
蓝牙 enableBluetoothMeshOn、disableBluetoothMeshOn
应用管理 setBlockingPackages、setBlockingActivities
系统重置 wipe

5.3 PCDN 相关服务注册

ActivityStackMonitor 在多任务链路被大量调用：

文件 行 方法
ActivityStarter.smali 9019 checkStartActivity
ActivityTaskSupervisor.smali 3871 forceStopPackage
PackageManagerService.smali 68300 filterBlockedResolveInfo
PackageManagerService.smali 110939 filterBlockedServiceResolveInfo
PackageManagerService$ComputerEngine.smali 9911 filterBlockedResolveInfo

---

6. 行为验证记录

6.1 禁用后自动恢复

```bash
su -c 'pm disable com.baidu.pcdn'
su -c 'reboot'
ps -A | grep pcdn
# 输出: com.baidu.pcdn 再次运行
```

结论：存在独立于用户操作的自动恢复机制。

6.2 网络层屏蔽验证

```bash
su -c 'echo "127.0.0.1 pcdn.baidu.com" >> /system/etc/hosts'
```

效果：PCDN 进程不再出现，系统未出现异常。

结论：PCDN 组件依赖 pcdn.baidu.com 等域名进行业务通信。

---

7. 关联证据

7.1 同类行为的公开记录

2023 年 11 月，有公开记录显示小度智能屏在后台运行 PCDN：

· 单月上传流量：6TB
· 并发 UDP 连接数：4000

小度官方将 PCDN 行为命名为"智能加速"服务。

7.2 一致性

特征 公开记录 本设备
组件名称 PCDN com.baidu.pcdn
运行用户 system system
拉起方式 开机自启 LOCKED_BOOT_COMPLETED
组件性质 双向 P2P P2pDownloader
用户告知 无 无

---

8. 技术特征汇总

特征 值 技术含义
运行用户 system (uid 1000) 系统级权限
进程状态 PROC_STATE_PERSISTENT 常驻，不可杀
拉起方式 LOCKED_BOOT_COMPLETED 开机早期自启
调用来源 com.baidu.duer.ota OTA 服务拉起
存储位置 /system/app/PCDN/ 系统分区预置
冗余路径 4 个 删除困难
核心能力 P2P 双向传输 消耗上行带宽
配套系统 Xray SDK 全链路监控
混淆手段 com.a.a.a.a.a.a 规避识别
用户开关 无 无控制权
禁用恢复 自动 强制运行

---

9. 技术结论

9.1 组件性质

该组件为商业级 PCDN 客户端，具备以下完整要素：

1. 独立 APK 及原生库
2. 双向 P2P 传输协议栈
3. 配套的 Xray 监控 SDK
4. 系统级权限与常驻能力
5. 系统分区多路径预置
6. OTA 服务拉起机制
7. 类名混淆规避识别

上述要素的组合，排除了"第三方 SDK 误触发"或"功能模块误装"的可能性。

9.2 行为模式

1. 利用用户设备与带宽为服务提供方分发内容
2. 降低服务提供方 CDN 成本
3. 用户设备承担带宽、电量、闪存损耗
4. 用户对上述行为不知情且无控制权

9.3 技术不对称

1. 系统分区权限 vs 用户空间权限
2. 系统级进程 vs 用户进程
3. 混淆类名 vs 用户识别能力
4. 无开关设计 vs 用户控制需求
5. 自动恢复机制 vs 用户禁用操作

9.4 监控能力

Xray SDK 的数据采集能力覆盖：

· 网络请求（HTTP、OkHttp）
· 页面加载（WebView）
· 数据操作（SQLite）
· 图片处理（Bitmap）
· 设备状态（电池、网络）
· 崩溃信息（Native Crash）

---

10. 技术建议

10.1 组件处置

目标 方法 风险
禁用进程 pm disable com.baidu.pcdn 低（但会被恢复）
覆盖系统文件 Magisk 模块挂载空文件 低（可逆）
屏蔽域名 hosts 或 iptables 低
卸载组件 删除 /system/app/PCDN/ 中（影响 OTA）

10.2 验证方法

```bash
ps -A | grep -iE "pcdn|xray"
ls -la /system/app/*/lib/*/libcyber-pcdn.so
cat /system/etc/hosts | grep baidu
dumpsys activity services | grep PCDNService
```

---

11. 附录

附录 A：设备基本信息

```
build.brand:         xps06e
build.manufacturer:  Xiaodu
build.model:         XD-SEE00-2301
build.display:       DuerShow_T616_v1.65.0.20250825010819358.R
build.version.release: 12
build.version.sdk_int: 31
```

附录 B：取证文件清单

文件 说明
processes.txt 进程列表
services.txt 服务列表
system_apps.txt 系统应用目录
PCDN_src/ PCDN 反编译源码
services_smali/ services.jar 反编译源码

附录 C：关键路径

```
/system/app/PCDN/
/system/app/DuerShowSwan/lib/arm64/libcyber-pcdn.so
/system/app/DuerShowMedia/lib/arm64/libcyber-pcdn.so
/system/app/DuerShowLauncher/lib/arm64/libcyber-pcdn.so
/system/framework/services.jar
/system/framework/framework-res.apk
```

---

报告结束

本报告所载内容均基于设备端实际取证，数据可复现、路径可验证、代码可审计。

---

# 补充取证（2026-10-02，第二次现场取证）

本节是在设备已装 `duer_cleanup` 模块的状态下重新取证得到的结论，
用于修正、补充前文。原始数据见：

- `evidence/device-xd-see00-2301/session-2026-10-02/`
- `evidence/device-xd-see00-2301/framework/`
- `docs/framework-hooks.md`

---

## 12. 系统框架层：107 个非 AOSP 类

前文第 5 节只列出了 4 个 `com.android.server.baidu` 类。这次把
`framework.jar` 与 `services.jar` 的 `classes*.dex` 全部 `dexdump` 后，
实际数量是：

| 组件 | 类数 | 方法数 |
| --- | --- | --- |
| `/system/framework/framework.jar` | 62 | 722 |
| `/system/framework/services.jar` | 45 | 386 |
| **合计** | **107** | **1108** |

其中此前完全未记录的高价值发现：

| 类 | 关键方法 | 含义 |
| --- | --- | --- |
| `com.baidu.am.ActivityRedirection` | `isSettingsAction`、`redirectToDefaultSettingAction`、`replacePendingIntent` | 重定向「设置」Intent；替换通知里的 PendingIntent |
| `com.baidu.pm.PermissionController` | `shouldGrantSignaturePermission`、`shouldNotShowConfirmationDialog`、`revokePkgFlagsIfNeeded` | 对白名单包可跳过确认框直接授权 |
| `android.app.baidu.SharedPreferenceHack` | `onGetBoolean`、`onPutString` | 框架层拦截 SharedPreferences 读写 |
| `android.app.baidu.DuerShowInputEventReceiver` | `pilferPointers`、`monitorGestureInput` | 夺取触摸手势 |
| `android.os.baidu.IDuerService` | 63 个方法，含 `wipe`、`takeScreenshot`、`readWifiPassWd`、`sendUibcInputEvent`、`setRuntimePermissions` | 私有提权接口 |
| `com.baidu.monitors.CameraUseStatusMonitor` / `MicUseStatusMonitor` | `getCameraUseApps` / `getMicUseApps` | 跨进程查询摄像头/麦克风使用者 |
| `com.baidu.framework.statistics.*` | `BroadcastReporter`、`DuerCpuTracker`、`DuerLaunchTimeReporter`、`ThirdAppDownloadEvent` | framework 内部埋点，广播 action `com.baidu.framework.STATISTICS_ACTION` |

完整类表与方法签名见 `docs/framework-hooks.md`。

---

## 13. PCDN 库的真实载体：模块存在覆盖盲区

这是本次取证最重要的修正。

### 13.1 `libcyber-pcdn.so` 同时存在于 APK 内部

前文 3.2 节的说法是「删除独立 APK 后，其他三个系统应用仍可加载
libcyber-pcdn.so」。实测进一步发现：**该库不仅被解压到 `lib/arm64/` 目录，
还打包在 APK 自身的 `lib/arm64-v8a/` 里**：

| 载体 APK | 条目 | 大小 | sha256 |
| --- | --- | --- | --- |
| `/system/app/DuerShowSwan/DuerShowSwan.apk` | `lib/arm64-v8a/libcyber-pcdn.so` | 2794344 | `191116ace444b5745a39b4773d7f19b6425c2096349dd1887c239775eab3b329` |
| `/system/app/DuerShowMedia/DuerShowMedia.apk` | `lib/arm64-v8a/libcyber-pcdn.so` | 2794344 | `5848922be3fb24237b28eeba0b0390b8467b2ddf72180cbe518e35a7653acb7c` |
| `/system/app/DuerShowLauncher/DuerShowLauncher.apk` | `lib/arm64-v8a/libcyber-pcdn.so` | 2794344 | `5848922be3fb24237b28eeba0b0390b8467b2ddf72180cbe518e35a7653acb7c` |

`DuerShowSwan.apk` 的归属包是 `com.baidu.atomkit`；
`DuerShowMedia.apk` 是 `com.baidu.duershow.media`；
`DuerShowLauncher.apk` 是 `com.baidu.launcher`。

### 13.2 启动器实际运行在 `/data/app`

```
com.baidu.launcher
  codePath=/data/app/~~-rk9btGny9Lu9xW9pJu_dQ==/com.baidu.launcher-3M3jr0A73iFIVZYxqjmb0A==
  legacyNativeLibraryDir=/data/app/.../lib
  primaryCpuAbi=arm64-v8a
  flags=[ SYSTEM HAS_CODE ALLOW_CLEAR_USER_DATA UPDATED_SYSTEM_APP LARGE_HEAP ]
```

它是 `UPDATED_SYSTEM_APP`——OTA 更新后代码实际在 `/data/app`，
而且它的 `lib/arm64/` 目录是**空的**（native 库不落地，直接从 APK 加载）。

因此：

```
被模块遮蔽的路径：/system/app/DuerShowLauncher/lib/arm64/libcyber-pcdn.so  → 0 字节
真正被加载的路径：/data/app/.../com.baidu.launcher-.../base.apk!lib/arm64-v8a/libcyber-pcdn.so
                  → 2794344 字节，sha256 5848922be3fb...（与 /system 里那份完全相同）
```

**结论：现有 `duer_cleanup` 模块对 `com.baidu.launcher` 的 PCDN 库覆盖无效。**
`DuerShowMedia` / `com.baidu.atomkit` 因为 native 库确实解压到
`/system/app/*/lib/arm64/`，遮蔽是有效的。

### 13.3 另一个载体：`libpcdn-jni.so`

```
/data/app/~~WPlaZtJzxb8uk5Q8xrryNg==/com.baidu.duer.superapp-oJ8M9sGUJlzrsznKCFApMQ==/lib/arm/libpcdn-jni.so
```

`com.baidu.duer.superapp` 是**用户空间应用**（非系统预置），
同样携带 PCDN 动态库。前文的「4 个载体」需要更新为至少 6 个。

### 13.4 库的技术特征

对 `DuerShowSwan.apk` 内嵌的 `libcyber-pcdn.so` 做 `strings`，可直接看到
百度金矿（BJSDK）PCDN 的实现痕迹：

```
NDK_PCDN / PCDNVOD
/sdcard/Android/data/com.baidu.haokan/PCDNSDK
/sdcard/baidu/PCDNSDK
[BJSDK]BJSdkManager::Close return. Report pcdn download info. |...|
[BJSDK]Report_RealtimeTraffic. |Read(...)|DH_Down_Total(...)|
        DH_Down_P2PTasks(...)|FreeCDN_Percentage_current/total(...)|
        P2P_Percentage_current/total(...)|DP_Up(...)|DP_Down(...)|
        Reused_Tasks(...)|Reuse_Ratio(...)|
```

`DP_Up`（上行流量）、`P2P_Percentage`、`Reuse_Ratio`、`FreeCDN_Percentage`
这几项直接证明该库具备**向他人分发内容的上行能力**，
并且会对上行/复用比例做实时统计。

### 13.5 模块应有的修正方向

1. 遮蔽目标必须跟随 `pm path` 解析出的**活动 codePath**，而不是写死 `/system/app`。
2. 对 `UPDATED_SYSTEM_APP`，`/data/app` 里的 `base.apk` 内嵌库无法用
   挂载空文件的方式处理，需要替换整个 APK 或改用链接器层面的拦截。
3. `check.sh` 已加入对应检测项，运行后会明确报告「模块覆盖是否有效」。

---

## 14. 处置后的实测状态（2026-10-02）

| 项目 | 状态 |
| --- | --- |
| `com.baidu.pcdn` 进程 | 不存在 |
| `libcyber-pcdn.so` 加载映射 | 无（`/proc/*/maps` 未命中） |
| `/system/app/PCDN/` | 已被 `.replace` 置空 |
| `/system/app/*/lib/arm64/libcyber-pcdn.so` | 0 字节（Swan / Media / Launcher 三处） |
| hosts 屏蔽 | 生效（17 条百度域名） |
| 已禁用包 | `com.goodfather.textbook.pad`、`com.baidu.duer.appstore`、`com.baidu.atomkit`、`com.baidu.duer.aieye.image.preprocessing`、`com.baidu.duer.aieye.correction` |
| 残留风险 | `com.baidu.launcher` 的 APK 内嵌 PCDN 库仍完整（见 13.2） |

同时仍在运行的百度进程：

```
com.baidu.launcher, com.baidu.launcher:remote
com.baidu.duershow.dcs
com.baidu.duershow.media
```

---

报告补充结束
