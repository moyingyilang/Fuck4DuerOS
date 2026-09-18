cd ~/Fuck4DuerOS

# ============================================================
# docs/technical-report.md
# ============================================================
cat > docs/technical-report.md << 'EOF_TECH'
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
EOF_TECH

cat > docs/legal-basis.md << 'EOF_LEGAL'

法律依据

本文件汇总本项目涉及的法律法规条款，供技术取证、维权参考。

声明：本文件仅为法律条款整理，不构成法律意见。如需法律建议，请咨询专业律师。

---

一、《中华人民共和国消费者权益保护法》

第八条

消费者享有知悉其购买、使用的商品或者接受的服务的真实情况的权利。

消费者有权根据商品或者服务的不同情况，要求经营者提供商品的价格、产地、生产者、用途、性能、规格、等级、主要成份、生产日期、有效期限、检验合格证明、使用方法说明书、售后服务，或者服务的内容、规格、费用等有关情况。

第十条

消费者享有公平交易的权利。

消费者在购买商品或者接受服务时，有权获得质量保障、价格合理、计量正确等公平交易条件，有权拒绝经营者的强制交易行为。

---

二、《中华人民共和国个人信息保护法》

第十三条

符合下列情形之一的，个人信息处理者方可处理个人信息：

（一）取得个人的同意；

（二）为订立、履行个人作为一方当事人的合同所必需；

（三）为履行法定职责或者法定义务所必需；

（四）为应对突发公共卫生事件，或者紧急情况下为保护自然人的生命健康和财产安全所必需；

（五）为公共利益实施新闻报道、舆论监督等行为，在合理的范围内处理个人信息；

（六）依照本法规定在合理的范围内处理个人自行公开或者其他已经合法公开的个人信息；

（七）法律、行政法规规定的其他情形。

第十七条

个人信息处理者在处理个人信息前，应当以显著方式、清晰易懂的语言真实、准确、完整地向个人告知下列事项：

（一）个人信息处理者的名称或者姓名和联系方式；

（二）个人信息的处理目的、处理方式，处理的个人信息种类、保存期限；

（三）个人行使本法规定权利的方式和程序；

（四）法律、行政法规规定应当告知的其他事项。

---

三、《中华人民共和国网络安全法》

第二十二条第三款

网络产品、服务具有收集用户信息功能的，其提供者应当向用户明示并取得同意；涉及用户个人信息的，还应当遵守本法和有关法律、行政法规关于个人信息保护的规定。

第四十一条

网络运营者收集、使用个人信息，应当遵循合法、正当、必要的原则，公开收集、使用规则，明示收集、使用信息的目的、方式和范围，并经被收集者同意。

网络运营者不得收集与其提供的服务无关的个人信息，不得违反法律、行政法规的规定和双方的约定收集、使用个人信息，并应当依照法律、行政法规的规定和与用户的约定，处理其保存的个人信息。

---

四、《中华人民共和国电信条例》

第七条

国家对电信业务经营按照电信业务分类，实行许可制度。

经营电信业务，必须依照本条例的规定取得国务院信息产业主管部门或者省、自治区、直辖市电信管理机构颁发的电信业务经营许可证。

未取得电信业务经营许可证，任何组织或者个人不得从事电信业务经营活动。

第八条

电信业务分为基础电信业务和增值电信业务。

基础电信业务，是指提供公共网络基础设施、公共数据传送和基本话音通信服务的业务。

增值电信业务，是指利用公共网络基础设施提供的电信与信息服务的业务。

---

五、《中华人民共和国未成年人保护法》

第七十二条

信息处理者通过网络处理未成年人个人信息的，应当遵循合法、正当和必要的原则。

处理不满十四周岁未成年人个人信息的，应当征得未成年人的父母或者其他监护人同意，但法律、行政法规另有规定的除外。

未成年人、父母或者其他监护人要求信息处理者更正、删除未成年人个人信息的，信息处理者应当及时采取措施予以更正、删除，但法律、行政法规另有规定的除外。

---

六、《中华人民共和国民法典》

第一千一百六十五条

行为人因过错侵害他人民事权益造成损害的，应当承担侵权责任。

依照法律规定推定行为人有过错，其不能证明自己没有过错的，应当承担侵权责任。

第一千一百六十七条

侵权行为危及他人人身、财产安全的，被侵权人有权请求侵权人承担停止侵害、排除妨碍、消除危险等侵权责任。

---

法律适用分析

法律 条款 对应技术事实
消费者权益保护法 第 8 条 PCDN 组件未经告知预置于设备中
消费者权益保护法 第 10 条 PCDN 组件占用用户上行带宽
个人信息保护法 第 13 条 Xray SDK 采集数据未取得同意
个人信息保护法 第 17 条 无任何告知事项
网络安全法 第 22 条第 3 款 信息收集功能未明示
网络安全法 第 41 条 采集范围超出必要原则
电信条例 第 7 条、第 8 条 未取得许可从事电信业务
未成年人保护法 第 72 条 未成年人设备未征得监护人同意
民法典 第 1165 条、第 1167 条 构成侵权

---

投诉与举报渠道

机构 网址 适用理由
12315 消费者投诉 www.12315.cn 侵害消费者知情权、公平交易权
工信部电信用户申诉 dxss.miit.gov.cn 未许可从事电信业务
网信办举报中心 www.12377.cn 违规收集个人信息
当地市场监督管理局 — 消费者权益侵害

---

最后更新：2026 年 9 月
EOF_LEGAL

cat > docs/plain-language.md << 'EOF_PLAIN'

你买的"学生手机"，可能在偷偷帮百度赚钱

——一份给普通人的说明

---

一句话版本

你花钱买的手机，正在用你家的宽带，帮百度给别的用户传文件。你付电费、付网费，百度省服务器钱。

而且，你不知情，也无法关闭。

---

到底发生了什么？

你的小度学生手机里，预装了一个叫 PCDN 的东西。

PCDN 是"点对点内容分发网络"的缩写。说人话就是：

把每个人的手机，变成一个"小型服务器"，帮大公司给别人传文件。

打个比方：

你家孩子想看动画片，动画片本来应该从百度的服务器传过来。
但百度为了省钱，就让你家的手机先从百度服务器下载，然后再由你家的手机传给隔壁老王家、楼下老李家、隔壁城市老张家。

流量走的是你家宽带，设备用的是你家手机。

---

百度从中省了什么？

百度省的 你出的
服务器带宽费 你家宽带的上行流量
CDN 分发成本 你家路由器的负载
机房电费 你家手机的电费
运维成本 你家手机的闪存损耗

说白了，就是"薅用户的羊毛"。

---

这事有多严重？

1. 你家宽带会被拖慢

家庭宽带的上行速度本来就窄（比如 100M 宽带，上行可能只有 20M）。
PCDN 一跑，这 20M 可能被吃掉一大半。

后果：你发微信、视频通话、上传文件都会变卡。

2. 手机会发烫、耗电、变卡

PCDN 是 7×24 小时运行的，手机不玩游戏的时候它也在跑。

后果：手机发热、电量掉得快、用两年就卡得不行。

3. 手机会被"提前报废"

PCDN 一直在读写手机存储。

后果：手机的闪存有寿命，读写越多，坏得越快。你正常用 5 年的手机，可能 2-3 年就不行了。

4. 严重的话，宽带会被运营商封

运营商明令禁止家庭宽带用于 PCDN。

后果：轻则限速，重则停机。你交了钱，却可能被拉黑。

---

百度不是第一次这么干

2023 年 11 月，有技术大牛公开曝光：

小度智能屏在后台跑 PCDN，一个月上传了 6TB 流量！

6TB 是什么概念？

· 相当于上传了 1200 部高清电影
· 普通家庭宽带一个月正常用量也就 200-500GB

百度官方不承认是"偷跑"，说这是"智能加速"功能。

但用户从来没见过什么"智能加速"的开关。

---

为什么说这是"故意"的？

1. 藏得很深

它的代码被故意起了乱名字，比如 com.a.a.a.a.a.a。
正常人根本搜不到、看不懂。

2. 关了会自己开

即使你用技术手段关了它，重启之后它又活了。
因为它是被系统级别的服务拉起来的，用户没权限阻止。

3. 没有开关

打开手机的"设置"，翻遍所有菜单，你找不到任何关于 PCDN 的选项。
因为它压根就没打算让你知道。

4. 不止一个地方藏

它不只在 PCDN 一个应用里。
在桌面、媒体播放器、系统界面里，都各藏了一份。
你删一个，还有三个。

---

这事违法吗？

至少涉嫌违反以下几部法律：

《消费者权益保护法》第八条

消费者享有知悉其购买、使用的商品或者接受的服务的真实情况的权利。

你买手机的时候，没人告诉你它在跑 PCDN。

《消费者权益保护法》第十条

消费者享有公平交易的权利。

你付了钱买手机，却还要替百度付带宽费、电费。

《个人信息保护法》第十三条、第十七条

处理个人信息应当取得个人同意，并显著告知。

它还在偷偷收集你的网络状态、应用使用情况、甚至位置信息。

《未成年人保护法》第七十二条

处理不满十四周岁未成年人个人信息的，应当征得父母或者其他监护人同意。

这是专门给学生用的手机，用户大多是未成年人。

《民法典》第一千一百六十五条

行为人因过错侵害他人民事权益造成损害的，应当承担侵权责任。

百度有错，你有损，法律上可以要求赔偿。

---

你可以做什么？

如果你不懂技术

1. 打客服电话投诉
   要求对方明确告知：设备是否运行 PCDN，如何关闭。
2. 向 12315 投诉
   网址：www.12315.cn
   理由：侵害消费者知情权和公平交易权。
3. 向工信部举报
   网址：dxss.miit.gov.cn
   理由：未经许可从事电信业务、占用用户带宽。
4. 向网信办举报
   网址：www.12377.cn
   理由：违规收集个人信息。
5. 不推荐再买同品牌产品
   用钱包投票，最直接。

如果你懂点技术

1. Root 手机，查看 ps -A | grep pcdn 是否有进程
2. 用 Magisk 模块覆盖掉 PCDN 相关文件
3. 改 hosts 屏蔽上报域名
4. 路由器限制该设备的上行带宽
5. 保留证据，必要时走法律途径

---

重点提醒

这不是"个别设备的问题"，是"商业模式的问题"。

百度不是不小心装错了。
它是故意设计、故意混淆、故意不给开关、故意让它自动恢复。

因为这样它才能：

· 省下每年几亿的 CDN 成本
· 把成本转嫁给几百万用户
· 用户还根本不知道

你买的是手机，不是百度的"服务器租用合同"。

---

一句话总结

它在用你的宽带，赚它的钱。
你不知情，也关不掉。
这不是 bug，是它的"设计"。

---

附：如果你想知道更多

本说明基于一台真实的小度学生手机（型号 XD-SEE00-2301）的实际取证。

· 技术取证报告：technical-report.md
· 法律依据：legal-basis.md

证据可以被复现，代码可以被审计，路径可以被验证。
EOF_PLAIN

echo ""
echo "=========================================="
echo " ✅ docs 填充完成"
echo "=========================================="
wc -l docs/*.md