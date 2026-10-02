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

---

# 补充：`cboot` 模式选择逻辑已被移除（2026-10-02 22:0x）

## 现象

在载荷偏移 `0x9b497`、`0x9b4cd`、`0x9b8f8`、`0xa36c6` 处的这四个字符串

```text
0x9b497  'Detect the firsrt_mode flag in the miscdata partition'
0x9b4cd  'get mode from firstmode field: %s\n'
0x9b8f8  'cboot;cboot fastboot'
0xa36c6  'first_mode=%x'
```

在**整个载荷（[0x40, 0xe6358)）里找不到任何引用**：

```text
测试项                        ADRP+ADD  ADRP+LDR  ADR  8字节绝对指针  4字节
get mode from firstmode field     0         0     0        0         0
Detect the firsrt_mode flag       0         0     0        0         0
cboot;cboot fastboot              0         0     0        0         0
first_mode=%x                     0         0     0        0         0
--- 对照 ---
get_miscdata_boot_flag            7处        -     -        1         1
```

扫描器已覆盖四种取址模式（`ADRP+ADD`、`ADRP+ADD.W`、`ADRP+LDR`、
`ADR`），ADD 与 ADRP 的间隔放宽到 1~8 条，并处理了 `sh=1` 的
`add x, x, #imm, lsl #12` 形式。**不是扫描器的问题。**

## 交叉验证

`0x9f0a96c6` 的 `first_mode=%x` 按设计是用来拼 bootargs 片段的
（它的邻居是 `cali_mode=%x`、`earlycon=...`、` androidboot.skuid=%s`）。
而实际启动时读到的 `/proc/cmdline` 是：

```text
earlycon console=ttySPRD1,115200n8 loop.max_part=7 loglevel=7 init=/init
root=/dev/ram0 rw ... androidboot.selinux=permissive
androidboot.hardware=ums9230_1h10 ... androidboot.skuid=600WW
androidboot.slot_suffix=_a androidboot.force_normal_boot=1 ...
```

**完全没有 `first_mode=`。**

⇒ 与设备所有者用 Ghidra 分析时的结论一致：
**这段模式选择实现已被从 uboot 中删除，只留下了字符串常量。**

这解释了为什么：

- `misc` 里写 `bootonce-bootloader` 后进入的模式（`18d1:4ee8`）
  与标准 fastboot 不符；
- 通过 `miscdata` 的 `first_mode` 字段安排启动模式这条路**不可用**。

## 其它观察

`/proc/cmdline` 里还有几个值得记录的字段：

```text
buildvariant=eng              ← 工程版构建（零售机不常见）
androidboot.selinux=permissive
androidboot.veritymode=enforcing
androidboot.flash.locked=0    ← 真身：未锁定
androidboot.vbmeta.device_state=unlocked
initcall_debug=1
root=/dev/ram0
androidboot.dtbo_idx=1
lcd_name=lcd_icnl9916_boe_mipi_hdp    ← 屏幕：ICNL9916
lcd_size=1612x720
```

**注意**：屏幕型号是 `icnl9916`，而之前驱动覆盖比对时设备实际加载的触摸屏模块是
`chipone_tddi_9916.ko`——两者都是 Chipone/ILITEK 系，命名相近，需注意区分
（`icnl9916` 是驱动 IC 型号，`chipone-tddi` 是驱动目录名）。

---

# 补充：BROM/FDL 救援通路确认可用（2026-10-02 22:1x）

## 来源

设备所有者在网吧（Windows）用过的一整套展锐刷机工具，存放在本仓库的
`spd/` 目录（属主是另一应用的 UID，需 root 读取）：

```text
spd_dump_it_main_248_868b732_x64_Release.zip   13 MB   spd_dump（Windows x64）
QIKU Download Assistant Setup V3.61.zip        23 MB   奇酷下载助手
ums9230_Baidu_Qinghe_V20(1)/(2).zip           1.4 MB   本机专用包
ums9230_universal_unlock_UFS.zip              1.0 MB   通用解锁（UFS）
ums9230_universal_unlock_EMMC.zip             1.1 MB   通用解锁（EMMC）
展讯公钥签名解锁BL_by酷安@某贼.zip              9.8 MB
fdl1_spl_pgpt_tools_win64only_260909.zip       114 KB
紫光驱动_R4.21.3201.zip / QIKUDriver.zip        驱动
```

本机专用包 `ums9230_Baidu_Qinghe_V20(1).zip` 内含：

```text
fdl1-dl.bin                        FDL1 loader（下载用）
fdl1-sign.bin
fdl2-dl.bin                        FDL2 loader
fdl2-sign.bin
fdl2-cboot.bin                     FDL2（cboot 角色）
custom_exec_no_verify_65015f08.bin 绕过签名校验的 payload
misc-wipe.bin
unlock_autopatch_9230.bat          解锁脚本
spd_dump.exe                       Windows x64
gen_spl-unlock.exe / chsize.exe / Channel9.dll
Channel.ini
```

## 关键：解锁脚本揭示了完整流程

`unlock_autopatch_9230.bat` 核心命令：

```bat
spd_dump --wait 300 exec_addr 0x65015f08 ^
         fdl fdl1-dl.bin 0x65000800 ^
         fdl fdl2-dl.bin 0x9efffe00 ^
         exec r splloader r uboot e splloader e splloader_bak reset
```

参数含义：

| 参数 | 含义 |
| --- | --- |
| `--wait 300` | 等待设备进入 BROM/下载模式 |
| `exec_addr 0x65015f08` | BROM 漏洞利用地址（CVE-2022-38694） |
| `fdl fdl1-dl.bin 0x65000800` | 加载 FDL1 到该地址 |
| `fdl fdl2-dl.bin 0x9efffe00` | 加载 FDL2 到该地址 |
| `r <part>` / `w <part> <file>` | 读/写任意分区 |
| `e <part>` | 擦除分区 |
| `read_part miscdata 8192 64 m.bin` | 读 miscdata 偏移 8192 的 64 字节 |
| `reset` | 重启 |

## 由此确认的事实

1. **BROM/FDL 通路存在且已验证**——这是内核刷挂后唯一的兜底，
   而且它**不依赖 uboot、不依赖 fastboot、不依赖 Android**。
   只要 SoC 的 BootROM 完好，就一定能进。

2. **FDL loader 与主机架构无关**（跑在设备 SoC 上），
   所以这份 `fdl1-dl.bin` / `fdl2-dl.bin` 可以直接复用；
   需要替换的只是主机端的 `spd_dump`（Windows x64 → Android arm64）。

3. **`miscdata` 偏移 8192（0x2000）处是 64 字节的解锁状态字段**，
   与脚本注释一致：

   > check unlock (if get 64 zeros, locked; if 32 string + 16 hash + 16 hash, unlocked)

   实测该处为非零数据，与设备 `androidboot.vbmeta.device_state=unlocked` 相符。

4. **刷写手段有两条**：
   - Android 内 root + `dd` 直接写块设备（`boot_a` 已验证可写）
   - BROM/FDL（`spd_dump`）

## 待办

- [ ] 在主机（Android arm64）上准备可用的 `spd_dump`
      （参考 `Seuj09/Spd_dump_termux` 的 root 路线：chroot Ubuntu + arm64 二进制）
- [ ] 用本机专用包的 FDL loader 验证能进入并识别设备
- [ ] 验证通过后，才考虑刷入自编译内核

---

# 补充：BROM 实机联调记录（2026-10-02 22:06-22:11）

## 环境与准备

**主机**：Redmi（Android 15 + Magisk/KernelSU root），运 `spd_dump`。
**目标**：小度设备，进入 **BROM 模式**（`1782:4d00`）。

关键前提（都是本次踩出来的）：

1. `spd_dump` 必须在**主机**上运行。用 `adb shell` 执行会跑到**目标机**上，
   而目标机的 USB 总线上没有待刷的设备——必然失败。
   （`adb shell 'su -c ...'` 在目标机执行；`su -c ...` 才在主机的本地 shell 执行。）
2. 非 root 运行会得到 `libusb_init failed: LIBUSB_ERROR_OTHER`
   （`/dev/bus/usb/*` 属主 `root:usb`）。
3. USB 节点权限需放开：`chmod 666 /dev/bus/usb/001/<devnum>`。

## 目标进入 BROM 后的枚举特征

```text
Bus 001 Device 0xx: ID 1782:4d00
  bcdDevice   0202
  speed       480          (USB 2.0 High Speed)
  bDeviceClass/SubClass/Protocol = 00/00/00
  bNumInterfaces   1
  Interface 0: class=ff sub=00 proto=00
```

设备会在 BROM 里反复重新枚举（实测 devnum 从 065 → 069 → 072 自行变化），
**每次失败尝试都会污染 BROM 的 USB 状态**，因此「全新一次枚举」的成功率最高。

## 联调结果

最完整的一次交互（`--kickto 2`，设备刚重新枚举）：

```text
ver:229, sha1:ad0ce43b210ebd0e0ffc4e436b0f350922304a3f
Waiting for boot_diag/cali_diag/dl_diag connection (240s)
libusb_control_transfer ok            ← USB 控制传输成功
CHECK_BAUD bootrom
BSL_REP_VER: "SPRD3\0"                ← BootROM 应答版本号
CMD_CONNECT bootrom                   ← BROM 连接建立
current exec_addr is 0x65015f08       ← 开始发送 exploit payload
usb_send failed : LIBUSB_ERROR_TIMEOUT
```

各变体的结果：

| 命令 | 结果 |
| --- | --- |
| 无 `--kickto` | `libusb_control_transfer failed: LIBUSB_ERROR_IO` |
| `--kickto 2`，首次枚举 | ✅ 握手 → `BSL_REP_VER: SPRD3` → `CMD_CONNECT` → 发 payload 超时 |
| `--kickto 2`，后续 | ✅ 握手 → `CMD_CONNECT` → `usb_recv failed: LIBUSB_ERROR_IO` |
| `--kickto 2`，第 3 次 | `kick reboot timeout` / `unexpected response (0x008b)` |
| `--kickto 2` + 不用 exec_addr | ✅ `CMD_CONNECT` → `usb_recv failed` |
| `--kickto 2` + sign 版 loader | ✅ `CMD_CONNECT` → `usb_send failed: TIMEOUT` |

**规律：`CMD_CONNECT bootrom` 总是能成功，但紧接着的 USB 数据收发必失败。**

⇒ BROM 协议层是通的，卡在**数据传输**阶段。

## 尚未排除的原因

1. **主机 USB 栈**：Redmi 的 xHCI + Android USB 子系统对 BROM 的
   传输模式（控制 + 批量混合）可能支持不佳。
   验证方法：换一台 PC/Linux 主机，用同一份 musl 静态二进制
   （x86_64 版同样可从 nightly.link 下载）。
2. **SELinux**：主机为 `Enforcing`，root 上下文 `u:r:ksu:s0`，
   可能限制 usbfs 的某些 ioctl（adb 走 bulk 能通，BROM 的 control 路径未必）。
3. **`--kickto 2` 的副作用**：它会触发一次 kick reboot；
   上游 README 也注明「并非所有设备都支持 mode 2」。
   而设备所有者的 `unlock_autopatch_9230.bat` **原本就没有用 `--kickto`**
   ——那是在 Windows 上用 QIKU 驱动跑的，驱动层可能代劳了模式切换。
4. **payload 与 BROM 版本匹配性**未验证。

## 结论

- ✅ **aarch64 静态 `spd_dump` 在 Android 上完全可用**（二进制层面已解决）
- ✅ **BROM 握手可复现成功**（`CMD_CONNECT bootrom`）
- ❌ 数据收发阶段失败，救援链路尚未打通
- 下一步优先验证「换主机」与「Windows 驱动 vs libusb」这两条

---

# 关键突破：fastbootd 的进入方法（2026-10-02 22:1x）

## 来源

`Seuj09/Spd_dump_termux` 的 Release 里有一个 arm64 工具包
`spreadtrum_flash_termux_arm64.zip`，其中包含两个 2048 字节的 BCB 文件：

```text
misc-fastbootd.bin   2048 B
misc-wipe.bin        2048 B
```

## 内容解析

```text
misc-fastbootd.bin:
  偏移 0x00   "boot-recovery"                ← BCB command 字段
  偏移 0x40   "recovery\n--fastboot\n"       ← BCB recovery 参数

misc-wipe.bin:
  偏移 0x00   "boot-recovery"
  偏移 0x40   "recovery\n--wipe_data\n"      ← 标准恢复出厂
```

## 机制

**`--fastboot` 是传给 recovery 的参数，走的是 AOSP 自己的路径**
（`recovery --fastboot` → 启动 fastbootd），**与 uboot 的 `cboot` 无关**。

Android 的 `init` 会读 `misc` 分区的 BCB：

1. command = `boot-recovery` → 引导 recovery ramdisk（本机是 TWRP）
2. recovery 参数含 `--fastboot` → 进入 **fastbootd**（用户空间 fastboot）

## 这解释了两件事

1. **为什么在 uboot 里找不到 `first_mode` / `cboot` 模式选择的代码引用** ——
   那条路径本来就不在 uboot 的 `cboot` 里，而是 Android 侧的 BCB 机制。
   （uboot 字符串里那两行 `recovery` / `--fastboot` 是解析 BCB 的痕迹。）
2. **为什么 `adb reboot bootloader` 出来的是 `18d1:4ee8`** ——
   那是 uboot 自己的 bootloader 模式，不是 fastbootd。

## 操作方法

从 Android（root）写入 BCB，然后重启：

```sh
dd if=misc-fastbootd.bin of=/dev/block/by-name/misc bs=2048 count=1
sync
reboot
```

之后应当出现 **fastbootd**，此时 `fastboot devices` 可用：

```sh
fastboot devices
```

**这同时提供了刷写通路与救援通路**——之前的判断是「fastboot 不可用、
只能靠 BROM」，现在可以修正为：**fastbootd 可用，只要先写对 BCB**。

## 附：写入所需文件

`misc-fastbootd.bin` 与 `misc-wipe.bin` 已随本仓库保存在
`tools/spd_dump/` 目录下。

---

# ✅ 已打通：fastbootd 进入方法（2026-10-02 22:17-22:20 实测验证）

## 结论

**写对 `misc` 分区的 BCB，即可让设备启动进 fastbootd，此时标准
`fastboot` 完全可用。整条刷写/救援链路已打通。**

## 操作（三步，全部实测通过）

```sh
# 1. 写入 BCB（仅覆盖 misc 前 2048 字节，其余不动）
dd if=misc-fastbootd.bin of=/dev/block/by-name/misc bs=2048 count=1 conv=fsync
sync

# 2. 重启
reboot

# 3. 约 40 秒后设备进入 fastbootd
fastboot devices
```

实测输出：

```text
Bus 001 Device 082: ID 18d1:4ee0
<已隐去的序列号>     fastbootd
```

## BCB 文件内容

```text
misc-fastbootd.bin (2048 B)
  偏移 0x00   "boot-recovery"              ← command
  偏移 0x40   "recovery\n--fastboot\n"     ← 传给 recovery 的参数
```

`--fastboot` 是 **AOSP recovery 的标准参数**，recovery（本机为 TWRP）
收到后启动 **fastbootd**（用户空间 fastboot）。
与 uboot 的 `cboot` 无关——这也解释了为什么在 uboot 里找不到相关代码引用。

## fastbootd 能力实测

```text
product             xps06e
current-slot        a
is-userspace        yes              ← 确认是 fastbootd
max-download-size   0x10000000       (256 MB)
slot-count          2

可刷写分区：
  boot_a / boot_b
  init_boot_a / init_boot_b
  vendor_boot_a / vendor_boot_b
  dtbo_a / dtbo_b
  vbmeta / vbmeta_system / vbmeta_vendor / vbmeta_product / vbmeta_odm …
  super
```

## 安全性验证

| 项目 | 结果 |
| --- | --- |
| BCB 是否一次性 | ✅ 是。进入 fastbootd 后 `misc` 前 2048 字节被自动清零 |
| 是否会把设备锁死在 fastbootd | ✅ 不会，`fastboot reboot` 后正常回到 Android |
| 返回正常系统后的状态 | `sys.boot_completed=1`，`slot_suffix=_a`，无线 adb 正常 |
| 原 BCB 备份 | 已备份至 `/data/local/tmp/misc-orig.bin` |

## 这对项目的意义

此前判断「fastboot 不可用，只能靠 BROM/FDL」，**这个判断需要修正**：

| 之前 | 现在 |
| --- | --- |
| fastboot 不可用（`adb reboot bootloader` → `18d1:4ee8` 无法通信） | **fastbootd 完全可用**，只要先写对 BCB |
| 内核刷挂只能靠 BROM/FDL | **可以 fastboot 刷回备份**，BROM 退化为「最后保险」 |
| Android arm64 上 spd_dump 的 BROM 数据传输问题必须先修 | **暂时不必修**——fastbootd 已提供日常刷写与救援 |

**因此，刷入自编译内核的风险从「单向门」降为「可回退」。**

## 完整救援流程（已验证可用）

```sh
# 进入 fastbootd
adb shell 'su -c "dd if=misc-fastbootd.bin of=/dev/block/by-name/misc bs=2048 count=1"'
adb reboot

# 刷回备份
fastboot flash boot     f4d_backup/boot_a.img
fastboot flash init_boot f4d_backup/init_boot_a.img
fastboot flash vendor_boot f4d_backup/vendor_boot_a.img
fastboot flash dtbo     f4d_backup/dtbo_a.img

# 重启回系统
fastboot reboot
```
