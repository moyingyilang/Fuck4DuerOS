# 小度青禾 V20 (xps06e) 的启动结构与救援方案

调查时间：2026-10-02

## 一、分区实况（`blockdev --getsize64`）

| 分区 | 大小 | 实际内容 |
| --- | --- | --- |
| `boot_a` / `boot_b` | 64 MB | Android boot header v4：内核 38.3 MB + ramdisk 2.1 MB(lz4_legacy)，带 AVB |
| `init_boot_a` / `init_boot_b` | 8 MB | **全 0，空分区** |
| `vendor_boot_a` / `vendor_boot_b` | 100 MB | VENDOR_BOOT header v4：platform ramdisk(空) + **recovery ramdisk 38 MB** + DTB 162,929 B |
| `dtb_a` / `dtb_b` | 8 MB | **全 0，空分区** |
| `dtbo_a` / `dtbo_b` | 8 MB | 有内容（两者不同） |
| `vbmeta*` | 1 MB | AVB 元数据 |

**`init_boot` 与 `dtb` 四个分区全为空**：`init_boot_a.img`、`init_boot_b.img`、
`dtb_a.img`、`dtb_b.img` 的 SHA256 完全相同。设备声明了这些分区但并未使用：
真正的 DTB 放在 `vendor_boot` 里（`DTB_SZ = 162929`，与 TWRP 设备树里的
`prebuilt/dtb.img` 大小一致）。

## 二、boot_a 的 ramdisk 是 Magisk 补丁版

```text
ramdisk.cpio 顶层：
  init                200 KB      ← Magisk 的 magiskinit（替换了原始 init）
  .backup/init.xz     888 KB      ← 原始 init（被压缩保存）
  .backup/.magisk     140 B       ← Magisk 补丁配置
  .backup/.rmlist     99 B
  overlay.d/sbin/                 ← 官方自定义挂载点
  debug_ramdisk dev metadata mnt proc second_stage_resources sys system
```

`magiskboot cpio ramdisk.cpio "exists magisk"` 为「无」，但 `.backup` 存在 ——
说明用的是 **magiskinit 替换 init** 的模式（二进制放在 `/data/adb/magisk/`，
不塞进 ramdisk），这是新版 Magisk 的做法。

## 三、TWRP 装在 vendor_boot 里（不是独立 recovery 分区）

`vendor_boot_a` 的 recovery ramdisk 解压后 **89 MB / 3838 个文件**，含：

```text
twres/ (93 项)   system/bin/twrp   system/etc/twrp.flags
me.twrp.twrpapp.apk              first_stage_ramdisk/fstab.ums9230_1h10
```

`first_stage_ramdisk/fstab.ums9230_1h10` 与 rtyutechstudio 的
`android_device-Xiaodu-xps06e-twrp` 完全对应，说明刷的就是那棵树编的 TWRP。

### ⚠️ 由此推出的关键风险

**GKI 结构下 recovery 与系统共用 `boot` 分区里的内核。**
vendor_boot 只提供 ramdisk，内核来自 boot。所以：

> **如果新内核本身起不来，TWRP 也一起起不来。**

这把「内核编译失败」的风险等级提到最高——不能指望 TWRP 兜底。

## 四、A/B 双槽不能当回退

`/dev/block/mapper/` 只有 `_a` 的逻辑分区：

```text
system_a  system_ext_a  product_a  vendor_a  (+ 各自的 -cow)
```

super 里没有 `_b` 的 system/vendor，且 `ro.boot.slot_count` 为空。
**B 槽没有可启动的系统**，不能靠 `fastboot set_active b` 回退。

## 五、真实的 bootloader 状态：已解锁

`ro.boot.*` 属性被伪装过（`playintegrityfix` / `tricky_store` 的常规操作），
要从 `/proc/cmdline` 看真身：

```text
androidboot.flash.locked=0                  ← 真实：未锁定
androidboot.verifiedbootstate=orange        ← 真实：orange（已解锁）
androidboot.vbmeta.device_state=unlocked
androidboot.veritymode=enforcing
androidboot.slot_suffix=_a
androidboot.force_normal_boot=1

被伪装的 runtime 属性：
  ro.boot.flash.locked        = 1     （实际 0）
  ro.boot.vbmeta.device_state = locked（实际 unlocked）
  ro.boot.verifiedbootstate   = green （实际 orange）
```

**bootloader 已解锁 ⇒ 可以刷自定义 boot 镜像**，`verifiedbootstate=orange`
意味着 AVB 不会拦。当初应该就是用 fastboot 解的锁，所以 **fastboot 大概率可用**。

## 六、救援路径排序

| 路径 | 前提 | 覆盖的故障 |
| --- | --- | --- |
| **fastboot 刷回备份** | USB 连接 + bootloader 完好 | 几乎全部（含内核 panic） |
| BROM / FDL 刷机 | 全砖、bootloader 也挂 | 最后手段 |
| TWRP（硬件键进入） | **内核能启** | 仅系统层故障 |
| TWRP 的 adb shell + dd | **内核能启** + TWRP 的 adb 可用 | 仅系统层故障（可替代 sideload） |
| RescueBrick 模块（三击音量键） | **内核能启** + Magisk 加载 | 仅模块导致的 bootloop |
| KernelSU + adb root | **内核能启** | 系统层故障 |

**结论：只有 fastboot 和 BROM 能救「内核挂了」。**
因此刷机前的必要准备是：① 备份（已完成）② 确认 fastboot 通路 ③ 准备好可回刷的镜像。

## 七、已完成的备份

15 个分区，381 MB，SHA256 全部校验通过。位置：

```text
设备端：/data/local/tmp/f4d_backup/
主机端：~/f4d_backup/f4d_backup/     （Redmi 24122RKC7C）
```

含 `boot_a/b`、`init_boot_a/b`、`vendor_boot_a/b`、`dtb_a/b`、`dtbo_a/b`、
`vbmeta_a/b`、`vbmeta_system_a`、`vbmeta_system_ext_a`、`vbmeta_vendor_a`。

> 注意：`boot_a.img` 是**已打 Magisk 补丁**的版本（ramdisk 里是 magiskinit）。
> 若要回到「未 root 的原始状态」，需要用 `magiskboot` 从 `.backup/init.xz`
> 还原，或找厂商原厂包。

---

# 补充：bootloader 模式实测（2026-10-02 21:34-21:43）

## 进入方式与 BCB 机制

`adb reboot bootloader` 与 `svc power reboot bootloader`（Magisk 应用用的就是这条）
效果相同。底层是往 `misc` 分区写 BCB 命令：

```text
dd if=/dev/block/by-name/misc  →  strings
bootonce-bootloader
BCAB
```

`bootonce-bootloader` 就是 Bootloader Control Block 的指令，说明 boot 目标
是由 misc 分区控制的（同理可写 `boot-recovery` 强制进 recovery）。

## 该模式下的 USB 描述符

设备重新枚举为 **`18d1:4ee8`**（Google VID），完整描述符：

```text
idVendor   18d1      idProduct  4ee8      bcdDevice 0404
manufacturer "Unisoc"          product "Unisoc Phone"
serial       <已隐去的序列号>
bNumInterfaces 4

Interface 0: class ff  subclass 42  protocol 01   2 endpoints
Interface 1: class ff  subclass 00  protocol 00   2 endpoints
Interface 2: class ff  subclass 00  protocol 00   2 endpoints
Interface 3: class ff  subclass 00  protocol 00   2 endpoints
```

Interface 0 的 `ff/42/01` 是 **Android ADB 接口**的标识
（fastboot 应为 `ff/42/03`）。**但实测该接口既不响应 adb 也不响应 fastboot**：

- `adb devices`（root server，已 chmod 666 节点）→ 空
- `fastboot devices`（v37.0.0，root，绝对路径，已 chmod）→ 空

结合设备所有者的说明「**这台设备的 uboot 被改过**」，可以判断：
这个模式是**定制过的 uboot 暴露的非标准接口**，需要专用工具/协议，
标准 adb/fastboot 都用不了。

## 安全性观察：该模式会自动退出

两次实测（21:34、21:40）中，设备在 `18d1:4ee8` 停留约 1~5 分钟后**自行重启回 Android**：

```text
21:34  reboot bootloader  →  18d1:4ee8
21:35  ...持续...
21:36  设备自动回到 1782:4003（Android），sys.boot_completed=1

21:40  svc power reboot bootloader  →  18d1:4ee8 (Device 042/044)
21:43  回到 1782:4003，无线 adb 恢复
```

**这本身是一道保险**：即使误入该模式，设备会自己回来，不会永久卡住。

## 由此对救援方案的修正

| 原判断 | 修正 |
| --- | --- |
| fastboot 可用（因为解锁过） | **未证实**。`18d1:4ee8` 模式下标准 fastboot 不通，需要专用工具 |
| 标准 fastboot 刷 boot 回退 | 待确认——取决于改过的 uboot 支持什么 |

**仍需向设备所有者确认：这台设备平时用什么工具刷机**（定制的 uboot 通常配
专用上位机，如展锐的 ResearchDownload / spd_dump，或作者自制的工具）。

---

# 补充：uboot 逆向分析（2026-10-02 21:48）

## 固件身份

`uboot_a` / `uboot_b`（各 3 MB，**两者 SHA256 完全相同**）：

```text
头部 magic:  "DHTB"  (44 48 54 42)  ← 展锐 bootloader 容器格式
构建路径:    /root/jenkins_build/workspace/DuerShow_T616/t616/bsp/bootloader/u-boot15/...
工具链:      aarch64-linux-gnu-gcc (Linaro GCC 4.8-2015.06) 4.8.5
```

**就是为 `DuerShow_T616`（本机）构建的展锐 U-Boot 2015 分支。**

## 启动模式选择机制

```text
bootcmd=cboot normal
bootdelay=0
preboot=role                       ← role 命令决定 uboot 扮演 dloader 还是 cboot
console=ttyS0,115200n8

cboot                              ← U-Boot 命令
choose boot mode
mode:
recovery, fastboot, dloader, charge, normal, vlx, caliberation.
cboot could enter a mode specified by the mode descriptor.
it also could enter a proper mode automatically depending on the environment
cboot;cboot fastboot               ← 用法：cboot <mode>
```

相关函数与判据字符串：

```text
get_miscdata_boot_flag / set_miscdata_boot_flag
Detect the firsrt_mode flag in the miscdata partition
get mode from firstmode field: %s
first_mode=%x
Detect the recovery message in the misc partition
check_reboot_mode:get raw reg_rst_mode is %x and sysdump_flag is %x
save_reset_mode_after_dump / update_reset_mode_from_dump
reset_mode : (%x)-(%s) .
```

⇒ **U-Boot 从 `miscdata` 分区的 `first_mode` 字段读启动模式**，
另有 `misc` 分区的 recovery 消息、以及一个 reset mode 寄存器/标志。

## U-Boot fastboot 的完整命令表

```text
   fastboot mode
getvar:   download:   is-userspace   max-download-size
flash:    erase:      powerdown
reboot-bootloader
reboot-fastboot          ← 支持在 fastboot 内重启回 fastboot
reboot-recovery
set_active:   setdump   getdump   flashing   getlcs   setrma   getsocid
tokenp%d      socidp%d
unknown reason / unknown command

OEM 命令：
  unlock_critical            get_unlock_ability
  get_unlock_bootloader_nonce
  unlock_bootloader          "Please firstly execute <fastboot oem get_identifier_token>"
  getsecurityversion         getversions      backupnv
```

`unlock_bootloader` 的交互提示（含按键确认流程）也在其中，与
`/proc/cmdline` 里 `device_state=unlocked` 相互印证——**这台机器的解锁
就是用 U-Boot 的 fastboot OEM 命令做的**，所以 U-Boot fastboot 原本可用。

## 两套 USB VID/PID 都在 uboot 里

在 `uboot_a.img` 中按小端字节序列搜索：

```text
18 d1  (Google VID)   出现 4 次
e8 4e  (PID)          出现 4 次
82 17  (Unisoc VID)   出现 4 次
03 40  (PID)          出现 9 次
```

⇒ uboot 同时定义了 `18d1:4ee8` 与 `1782:4003`。结合实测：

- 正常 Android：`1782:4003`，接口 `06/01/01`(MTP) + `ff/42/01`(ADB)
- `adb reboot bootloader` 后：`18d1:4ee8`，接口 `ff/42/01` + 3×`ff/00/00`

**该模式下 Interface 0 是 `ff/42/01`，即 ADB 协议标识**（fastboot 应为 `ff/42/03`），
但实测 adb 与 fastboot 均无响应。推测是**定制过的 uboot**在此模式下
实现了非标准协议（与设备所有者「uboot 被改过」的说明一致）。

## miscdata 分区实况（1 MB，/dev/block/sda2）

```text
偏移 0     "51PS<已隐去的序列号>"        序列号（51PS + SN）
偏移 64    "<已隐去的设备 ID>"              另一组 ID
偏移 132   12 00 00 00                       计数 = 18 (0x12)
偏移 136   18 个 16 字节定长字符串（工厂测试模式名）：
           DOWNLOAD WRITESN BT FT BBAT MMIF SMTCHECK MMI1 AGING
           MMI2 ANTENNA CURRENT DUALCAME CAMEVFY AUDIO IMEI
           FRESET CHKIMEI
偏移 448   00 01 "PASS"
偏移 9984  "~SET" + 数据
偏移 10016 "enabled" / "disabled" / "autoreboot-enable"
偏移 10112 "~~600WW"                         skuid
```

`first_mode` 字段的具体偏移尚未定位到（需进一步反汇编
`get_miscdata_boot_flag` 的调用点）。
