# 刷机实录与救援指南

> 2026-10-02 夜。自编译内核首次刷入 → 内核启动成功 → 模块不匹配导致系统半瘫
> → 回滚成功 → 二次尝试时 USB 物理链路失效，设备与主机彻底失联。
> 本文是完整的操作记录与明日救援步骤。

## 一、当前设备状态（最重要）

### 已被改动的分区（仅两处）

| 分区 | 内容 | 说明 |
| --- | --- | --- |
| `boot_a` | 自编译内核 `5.4.256-rev6` | 原始 ramdisk 未动（仍是 Magisk 补丁版） |
| `misc` | fastbootd 的 BCB | `boot-recovery` + `recovery\n--fastboot\n` |

### 未被改动的分区

```
uboot_a / uboot_b          未动
splloader / splloader_bak  未动
vendor_boot_a / _b         未动（TWRP 仍在）
init_boot_a / _b           未动（本来就是空的）
dtbo_a / _b                未动
vbmeta*                    未动
super（system/vendor/…）   未动
userdata                   未动
vendor_dlkm_a              未动（写入被 dm 层拒绝，实测 0 字节）
```

**结论：数据完好，没有任何分区被损坏。** 这是一次「够不着」，不是「弄坏了」。

### 为什么碰不到

```
USB          设备完全不出现在总线上（只有主机两个根 hub）
网络         <已隐去的内网地址> 不响应
```

关键判断依据：**展锐 BROM 在 SoC 掩膜 ROM 里，任何软件损坏都不影响它枚举。**
它此前确实出现过（`1782:4d00`，并成功握手到 `BSL_REP_VER: "SPRD3"`）。
现在连 BROM 都不出现 ⇒ **问题在物理层，不在软件层。**

## 二、本晚已确认的重大技术发现

### 1. fastbootd 的进入方法（本晚最大收获）

`misc` 分区写对 BCB 即可进 fastbootd：

```sh
dd if=misc-fastbootd.bin of=/dev/block/by-name/misc bs=2048 count=1 conv=fsync
sync
reboot
```

`misc-fastbootd.bin`（2048 B）内容：

```
偏移 0x00   "boot-recovery"
偏移 0x40   "recovery\n--fastboot\n"
```

`--fastboot` 是 **AOSP recovery 的标准参数**，走 Android `init` 读 BCB 的路径
（`recovery --fastboot` → fastbootd），**与 uboot 的 `cboot` 无关**。
这解释了为何在 uboot 里找不到相关代码引用，也解释了
`adb reboot bootloader` 为何进的是 `18d1:4ee8` 而非 fastbootd。

实测结果：

```
Bus 001 Device 082: ID 18d1:4ee0
fastboot devices → <已隐去的序列号>   fastbootd
```

`fastbootd` 能力：

```
product             xps06e
current-slot        a
is-userspace        yes
max-download-size   0x10000000 (256 MB)
slot-count          2
可刷：boot/init_boot/vendor_boot/dtbo/vbmeta*/super
```

**BCB 是一次性的**：进入 fastbootd 后 `misc` 前 2048 字节被自动清零；
`fastboot reboot` 可正常回到 Android。

### 2. adb 的 USB 功能是内建的

```
CONFIG_USB_CONFIGFS_F_FS = y     ← functionfs（adb）内建，不是模块
CONFIG_USB_CONFIGFS      = y
CONFIG_USB_GADGET        = y
CONFIG_USB_DWC3          = y
```

设备原厂配置亦然。**含义：即使一个 vendor 模块都加载不了，USB adb 依然可用。**
这是判断「内核是否启动」的兜底手段。

### 3. 自编译内核刷入后确实能启动

刷入 `boot-newkernel.img` 后：

- 设备正常枚举为 Android（`1782:4003`）
- 界面可用（能打开 WiFi 设置界面）
- 但设置崩溃、WiFi 无 —— **因为 vendor 模块全是 `5.4.161`，与 `5.4.256` 内核
  vermagic 不匹配，一个都加载不了**

⇒ **`boot-newkernel.img` 本身是好的。** 问题只在「没把匹配的模块一起送进去」。

### 4. `vendor_dlkm` 无法从 Android 内部写入

`/dev/block/mapper/vendor_dlkm_a -> /dev/block/dm-4`，实测：

```
dd if=vendor_dlkm_new.img of=/dev/block/mapper/vendor_dlkm_a bs=1M
→ 0+0 records out / 0 bytes copied
```

即使 `umount /vendor_dlkm` 之后再写，仍是 0 字节 ⇒ 被 **dm 层**（只读映射）拒绝。
**这是 fastbootd 存在的意义**：它会先 unmap 逻辑分区、写裸区、再 remap。

## 三、明日救援步骤（在 Windows 网吧环境）

### 为什么必须换 Windows 主机

Android 主机（Redmi + Termux + libusb）这条链路表现出**间歇性失效**：

```
64MB fastboot 传输  → SendBuffer() 失败
39.5MB 裁剪后        → 同样失败
BROM 握手            → CMD_CONNECT bootrom 成功，但紧接着数据收发必失败
fastboot             → 出现 < waiting for any device >
最终                 → 设备完全从总线上消失
```

而同一条链路在**小传输**上一直正常（`getvar` 全部成功）。
⇒ 不是协议问题，是链路质量。

而设备所有者此前在 Windows + QIKU 驱动 + `spd_dump.exe` 上**验证过完整流程可用**，
因为厂商驱动层代劳了 BROM 的模式切换——这正是 libusb 路径缺失的一环。

### 需要的文件

工具包（设备所有者提供，仓库 `spd/` 目录下）：

```
ums9230_Baidu_Qinghe_V20(1).zip
  fdl1-dl.bin                        FDL1 loader
  fdl2-dl.bin                        FDL2 loader
  custom_exec_no_verify_65015f08.bin BROM 签名绕过 payload
  unlock_autopatch_9230.bat          原始脚本
  misc-wipe.bin
```

备份（**两份**）：

```
主机  f4d_backup/f4d_backup/boot_a.img      67108864 B  原始 boot
设备  /data/local/tmp/f4d_backup/boot_a.img  同上（若还能访问）
主机  f4d_out/vendor_dlkm_orig.img           17244160 B  原始 vendor_dlkm
```

### 第一步：确认通路（只读，不做任何修改）

```bat
spd_dump --wait 300 exec_addr 0x65015f08 ^
  fdl fdl1-dl.bin 0x65000800 ^
  fdl fdl2-dl.bin 0x9efffe00 ^
  exec read_part miscdata 8192 64 m.bin
```

参数含义：

| 参数 | 含义 |
| --- | --- |
| `--wait 300` | 等待设备进入 BROM |
| `exec_addr 0x65015f08` | CVE-2022-38694 的 BROM 利用地址 |
| `fdl fdl1-dl.bin 0x65000800` | 加载 FDL1 到该地址 |
| `fdl fdl2-dl.bin 0x9efffe00` | 加载 FDL2 到该地址 |
| `read_part miscdata 8192 64` | 读 miscdata 偏移 8192 处 64 字节（解锁状态） |

**读到内容 = 通路活，可以继续。读不到 = 先解决 USB 物理连接。**

### 第二步：清 `misc` 的 BCB（2KB，最小风险的第一步写入）

BCB 若残留 `boot-recovery`，设备会一直尝试进 recovery。先把它清零：

```bat
spd_dump --wait 300 exec_addr 0x65015f08 ^
  fdl fdl1-dl.bin 0x65000800 ^
  fdl fdl2-dl.bin 0x9efffe00 ^
  exec w misc misc-zero.bin reset
```

`misc-zero.bin` = 2048 字节全零（可以现场用 `fsutil file createnew misc-zero.bin 2048` 生成）。

### 第三步：写回原始 `boot`

```bat
spd_dump --wait 300 exec_addr 0x65015f08 ^
  fdl fdl1-dl.bin 0x65000800 ^
  fdl fdl2-dl.bin 0x9efffe00 ^
  exec w boot boot_a.img reset
```

写完重启，设备应回到刷机前的状态（原厂内核 + 原厂模块）。

### 若 BROM 也进不去

按优先级：

1. **充电**半小时以上（之前反复进出 BROM/fastbootd 很耗电，
   电量见底时 USB 控制器可能不枚举）
2. **换线、换 OTG 转接头**（间歇性失效高度指向接触不良）
3. **BROM 键组合**：关机后按住不放再插 USB ——
   音量+ / 音量− / 两者同时 / 音量+ 与电源键
4. **USB 测试点**（硬件级强制进 BROM）：短接测试点后上电，
   SoC 会强制停在 BootROM，**无论 boot 分区什么状态都能进**。
   需要点位图，是最后的兜底，但最可靠。

## 四、模块补全（下次刷机前必须完成）

### 已完成

```
strip --strip-debug 后           140.2 MB → 12.4 MB
重命名副本                       chipone_tddi_9916.ko ← chipone-tddi.ko
                                sgm41510-charger.ko  ← sgm4154x_chg.ko
vermagic 保留                   5.4.256-rev6 SMP preempt mod_unload modversions aarch64
```

### 重建文件系统（两个坑）

**坑一：原文件系统只有 144 个 inode。**

```
e2fsck: vendor_dlkm: 137/144 files, 4111/4124 blocks
```

而我们有 179 个模块 ⇒ 必须重建文件系统。

**坑二：默认 `mkfs.ext4` 会建 journal，16MB 的盘直接爆掉。**

原始分区的参数：

```
Filesystem features: ext_attr dir_index filetype extent sparse_super large_file
                     huge_file uninit_bg dir_nlink extra_isize
                     ← 没有 has_journal！
Reserved block count: 0
Block size:  4096
Inode size:  256
Block count: 4124
```

最终可用的命令（`-d` 直接从目录填充，**不需要挂载**）：

```sh
mkfs.ext4 -F -q -b 4096 -I 256 -N 600 -m 0 \
  -O ext_attr,dir_index,filetype,extent,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize \
  -O ^has_journal,^resize_inode,^64bit,^flex_bg,^metadata_csum \
  -L vendor_dlkm -d <模块目录> out.img
```

结果：`193/608 files, 3478/4210 blocks`，features 与原始**逐字一致**。

> **为什么用 `-d` 而不是挂载**：Android 侧 loop 挂载被 SELinux 拒绝
> （`mount: Invalid argument`），chroot 侧 `/dev/loopN` 不存在
> （Android 的在 `/dev/block/loopN`）。`mkfs.ext4 -d` 完全绕开挂载。

### 仍缺的 10 个模块

设备 `modules.load` 里这些我们没有：

| 模块 | 来源 | 状态 |
| --- | --- | --- |
| `mali_kbase.ko` | `kernel_modules/kernel5.4/gpu/gondul/mali/` | 厂商用 Soong 在树外编（不走 Kconfig，设备原厂配置里连 `MALI_MIDGARD` 符号都没有） |
| `sprd_sensor.ko` | `kernel_modules/common/camera/sensor` | 同上 |
| `sprd_camera.ko` | `kernel_modules/common/camera/core` | 同上 |
| `sprd_cpp.ko` | `kernel_modules/common/camera/cpp` | 同上 |
| `flash_ic_aw3641.ko` | `kernel_modules/common/camera/flash` | 同上 |
| `mmdvfs.ko` | `kernel_modules/common/camera/mmdvfs` | 同上 |
| `sprdbt_tty.ko` | `kernel_modules/kernel5.4/wcn/bluetooth` | 同上 |
| `sprd_fm.ko` | `kernel_modules/kernel5.4/wcn/fm` | 同上 |
| `sprd_flash_drv.ko` | ？ | 待查 |
| `snd-soc-aw87xxx.ko` | 无源码 | **真缺失** |

**关键：`kernel_modules/` 里有 Kbuild/Makefile，可以用 `make M=` 树外编译**，
这是下次刷机前最值得投入的工作——尤其是 `mali_kbase`（缺了它界面很可能起不来）。

## 五、下次刷机的正确顺序

本晚的教训是「大小分治」和「先补模块」：

```
1. 补齐 10 个缺失模块（至少 mali_kbase）
2. 重建 vendor_dlkm 镜像（含补全的模块）
3. 设备与主机之间确保有稳定通路（强烈建议 Windows）
4. 先写 vendor_dlkm，再写 boot —— 两者必须同时是 5.4.256
5. 或者：都用 dd 从设备内部写（但 vendor_dlkm 是 dm 层只读，行不通）
   ⇒ 结论：vendor_dlkm 只能用 fastbootd，boot 可以 dd
```

**绝对不要单独刷 `boot`**——这正是本晚系统半瘫的原因。

## 六、工具与产物清单

### 主机（Redmi）上的产物

```
f4d_out/boot-newkernel.img      67108864 B  SHA256 0966329ae04903b4c1ecc2550f3d9b6dac687be78f2bdda36c2b04374571cd2e
f4d_out/boot-trimmed.img        40488960 B  裁剪版（38.6MB）
f4d_out/vendor_dlkm_new.img     17244160 B  SHA256 3fac48783dbecbaee536a15350cbb4d449cb64c0e72efb907c4e9f53ea247d94
f4d_out/vendor_dlkm_orig.img    17244160 B  原始备份
f4d_out/modules_stripped/       179 个 strip 后的模块
f4d_backup/f4d_backup/          15 个分区原始备份，381MB，SHA256 全通
```

### Android 主机上可用的 spd_dump

```
spd_tools/spd_dump-oldpath-aarch64-unknown-linux-musl
spd_tools/spd_dump-main-aarch64-unknown-linux-musl
```

来源 `TomKing062/action_spd_dump_it` 的 `build-musl` workflow（构建矩阵含
`aarch64-unknown-linux-musl`），产物为**静态链接**，无需 glibc/chroot 即可在
Android 运行。按上游 README，auto-unlock 批处理场景应选 **oldpath** 版。

实测可运行：

```
ver:229, sha1:ad0ce43b210ebd0e0ffc4e436b0f350922304a3f
libusb_control_transfer ok
CHECK_BAUD bootrom
BSL_REP_VER: "SPRD3\0"
CMD_CONNECT bootrom
current exec_addr is 0x65015f08
usb_send failed : LIBUSB_ERROR_TIMEOUT      ← 卡在这里（链路质量）
```

### 脚本

```
主机  .f4d_mon2.sh         USB 监控
     .f4d_flash.sh         dd 写入两个分区
     .f4d_vd2.sh           卸载后写 vendor_dlkm（失败，记录用）
设备  .f4d_*.sh            自提权脚本（[ "$(id -u)" = "0" ] || exec su -c ...）
```

## 七、本晚的教训

1. **`vendor_dlkm` 与 `boot` 必须同进同退。**单独刷 `boot` 必然导致系统半瘫。
2. **刷机前先确认救援通路真的可用，而不是"看起来可用"。**
   fastbootd 能进 ≠ 能刷（大传输失败）。
3. **USB 链路质量是隐形杀手。**握手成功不代表数据传输可靠——
   本晚所有怪现象（BROM 卡住、fastboot 失败、设备消失）根因都是它。
4. **Android 作为 USB 主机刷展锐设备不可靠。**厂商 Windows 驱动做了
   libusb 路径缺失的那一步。
5. **备份救了一切。**`dd` 回滚一次就把设备恢复了（第一次）。
   两份备份（设备 + 主机）是对的选择。
6. **`mkfs.ext4 -d` 是处理镜像的利器**——不想/不能挂载时的首选。
