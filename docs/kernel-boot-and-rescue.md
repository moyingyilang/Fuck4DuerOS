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
