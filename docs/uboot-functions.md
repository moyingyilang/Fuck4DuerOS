# U-Boot 函数地图（带注释）

> 对象：`uboot_a.img`（xps06e / UMS9230）
> 坐标：`abs = 0x9f000000 + (file_off - 0x200)`，载荷 `[0x200, 0xe6358)`
> 候选函数 1795 个，其中 200 个可凭引用字符串命名；本文列出已确认语义的部分。

## 一、关键函数（按子系统）

### 1.1 启动与命令分发

| 地址 | 语义 | 证据 |
| --- | --- | --- |
| `0x9f00763c` | **`cboot` 命令处理函数（模式分发器）** | 命令表 `0x9f0c93b8` 的 handler 字段 |
| `0x9f006ba4` | **`download mode` 命令处理函数**，注册 17 个 FDL 命令 | 命令表 `0x9f0c94d8` 的 handler 字段 |
| `0x9f006ac8` | `register(cmd_id, handler)` | 被调用 17 次，每次带命令码 + 处理函数 |
| `0x9f0070b4` | normal 模式的直接处理（跳过探测链后调用） | `0x9f0076c8` 调用 |
| `0x9f007868` | 返回全局结构体地址 `0x9f0f0b80` | `adrp x0,0x9f0f0000; add x0,x0,0xb80; ret` |
| `0x9f00476c` | board init 序列（7 步，末尾调按键初始化） | 连续 7 个 `bl` |

### 1.2 启动模式探测链（10 个处理器）

| 序 | 地址 | 探测来源 | 字符串证据 |
| --- | --- | --- | --- |
| 1 | `0x9f007228` | miscdata 的 `first_mode` | `Detect the firsrt_mode flag in the miscdata partition` |
| 2 | `0x9f007290` | misc 的 recovery 消息 | `Detect the recovery message in the misc partition` |
| 3 | `0x9f0072ac` | 含 MFS 校验调用 `0x9f032c88` | 同上两条 |
| 4 | `0x9f0072fc` | 关机充电 | `in charging during shutdown the devices` |
| 5 | `0x9f007330` | 充电器连接 / 按键 | `Charger connected`、`Keypad trigger to recovery` |
| 6 | `0x9f0073dc` | 看门狗 + 关机闹钟 | `Watchdog reset pending and poweroff alarm` |
| 7 | `0x9f0071c8` | 看门狗异常 | `Watchdog reset pending but Shutdown alarm is abnormal` |
| 8 | `0x9f007440` | RTC 闹钟到期 | `RTC poweroff alarm expiry` |
| 9 | `0x9f00749c` | 关机充电（另一种），**调用 EIC 读取** | `bl 0x9f004a54` @ `0x9f0074cc` |
| 10 | `0x9f007558` | 按键触发 recovery | `Keypad trigger to recovery` |

### 1.3 按键

| 地址 | 语义 |
| --- | --- |
| `0x9f004a24` | GPIO 按键初始化，无条件打印 `[gpio keys] init skip!` |
| `0x9f004a54` | EIC 读取音量上键（通道 `0xa4`），失败打印 `[eic keys] volumeup : … ERROR!` |
| `0x9f04776c` | EIC 读取通道 `0xa1`，返回 `(值 != 0)`，带 3000ms 延时 |
| `0x9f006fec` | 计数器 getter：`0x9f04776c()` 返回 0 时把 `0x9f0f0b74` 自增，返回该值 |

### 1.4 模式数据与校验

| 地址 | 语义 |
| --- | --- |
| `0x9f032c88` | 读 `miscdata`（0x2420 字节）到 `0x9f255924`，校验 MFS，取模式号 |
| `0x9f029da8` | 取 `first_mode`（探测链 #1 调用） |
| `0x9f023b64` | **bootargs 拼装**，含第二次 MFS 校验，命中则拼 `first_mode=%x` |

### 1.5 安全

| 地址 | 语义 |
| --- | --- |
| `0x9f022558` | **锁状态判断**：`0x9f23d890 == 2` → 打印 `SKIP VERIFY` 并返回 |
| `0x9f0227c0` | 校验链（root of trust），调 `0x9f022558` 与 `0x9f0843f8` 等 |
| `0x9f0232a4` | 锁状态 switch 分发（0~3，经 `0x9f09a040` 偏移表） |

### 1.6 DLoader / FDL

| 地址 | 语义 |
| --- | --- |
| `0x9f01b574` | **`dload_whole_raw_file`** —— 写整个裸文件（写分区），**无分区名校验** |
| `0x9f01b3d4` | `prepare_raw_data_buf` —— 设置两个 2MB DMA 描述符（环形链） |
| `0x9f01b3d8` | 写入薄包装 → 尾调用 `0x9f01a3b8` |
| `0x9f01adb8` | `dl_cmd_repartition` |
| `0x9f01b130` | `dl_cmd_read_ref_info` |

### 1.7 FDL 命令处理函数（17 个）

| 命令码 | 地址 | | 命令码 | 地址 |
| --- | --- | --- | --- | --- |
| `0x01` | `0x9f01b498` | | `0x0d` | `0x9f01afbc` |
| `0x02` | `0x9f01ab60` | | `0x10` | `0x9f01abdc` |
| `0x03` | `0x9f01aba4` | | `0x11` | `0x9f01ac40` |
| `0x05` | `0x9f01ae10` | | `0x12` | `0x9f01acd4` |
| `0x0a` | `0x9f01ad0c` | | `0x17` | `0x9f01aee4` |
| `0x0b` | `0x9f01ad70` | | `0x19` | `0x9f01afc4` |
| `0x1a` | `0x9f01aff8` | | `0x20` | `0x9f01b0f0` |
| `0x21` | `0x9f01b1c8` | | `0x22` | `0x9f01b1ec` |
| `0x7f` | `0x9f01b1ac` | | | |

## 二、关键数据（表 / 全局）

| 地址 | 内容 |
| --- | --- |
| `0x9f0b87e0` | **全局模式处理器表**，10 项，NULL 结尾，全为函数序言 |
| `0x9f0940f0` | 模式表，12 字节/项，`[+8]` 为启动值；`field1` 恒 0x10 |
| `0x9f0942a0` | 模式名指针表，8 字节/项（指向 `0x9f09b5b3` 起） |
| `0x9f0c93b8` | `cboot` 命令表项：`{handler=0x9f00763c, name="choose boot mode", usage="mode: "}` |
| `0x9f0c94d8` | `download mode` 命令表项：`{maxargs=0x40, repeatable=1, handler=0x9f006ba4, name, usage, help}` |
| `0x9f0f0b80` | 全局结构体；`+0x40` = A/B 槽魔数（`0x55CC55CC` / `0x55DD55DD`） |
| `0x9f0f0b74` | 启动计数器（BSS，掉电清零） |
| `0x9f255924` | `miscdata` 读取缓冲区（0x2420 = 9248 字节） |
| `0x9f23d890` | 锁状态（2 = UNLOCK）；`0x9f23c000` 为 0x400 字节比较缓冲 |
| `0x9f09a040` | 锁状态 switch 的字节偏移表 |

## 三、关键字符串

| 地址 | 内容 |
| --- | --- |
| `0x9f09b228` | `download mode` |
| `0x9f09b236` | `choose to enter download mode` |
| `0x9f09b2b4` | `The pctools sends control commands` |
| `0x9f09b1ce` | `bad combination can not download,power down device now` |
| `0x9f09b206` | `check packet data error` |
| `0x9f09b4b8` | `enter boot mode %d` |
| `0x9f09b49a` | `bad combination can not boot` |
| `0x9f09b4d2` | `choose boot mode` |
| `0x9f09b4e3` | `mode: ` |
| `0x9f0a2e9e` | `WARNNING: LOCK FLAG IS : UNLOCK, SKIP VERIFY!!!` |
| `0x9f0a2e7e` | `take_action_with_vbootret` |
| `0x9f0a2f30` | `set_root_of_trust failed.` |
| `0x9f0a2f4b` | `set_root_of_trust succeeded.` |
| `0x9f0a12d7`→新坐标 `0x9f09b0d7` | `Detect the firsrt_mode flag in the miscdata partition` |
| `0x9f0a3506` | `first_mode=%x` |
| `0x9f09b773` | 模式枚举名表起点（`UNDEFINED_MODE` 等 14 项） |

## 四、环境变量与镜像标识

```
bootcmd   = cboot normal        ← 决定 w19 = 2，进而跳过探测链
bootdelay = 0                   ← 无中断窗口
preboot   = role                ← 角色选择
bootargs  = mem=512M loglevel=7 console=ttyS0,115200n8 init=/init ...
            （运行期被 0x9f023b64 重写，实际见 /proc/cmdline）

镜像内标识：
  uboot_a.img   U-Boot 2015.07 (Aug 25 2025) jenkins-DuerShow_T616-6304
  fdl2-dl.bin   U-Boot 2015.07 (Jan 24 2024) jenkins-DuerShow_T616-2450
  构建路径      /root/jenkins_build/workspace/DuerShow_T616/t616/bsp/bootloader/u-boot15/
```

## 五、附：可命名的函数清单（funcmap 输出）

由 `tools/funcmap` 生成（`funcmap uboot_a.img 9f000000 24`），
共 200 条带字符串引用的函数。完整输出可用该命令重新生成。


以下为按地址排序的完整清单（前 60 条，其余用工具重新生成）：

```
0x9f004294  48       heap@8
0x9f0042c4  48       heap@8
0x9f0042f4  48       heap@8
0x9f004324  48       heap@8
0x9f004354  156      heap@8
0x9f004554  52       heap@8
0x9f005424  116      vddemmccore
0x9f005cd0  2208     bootdelay
0x9f006878  276      wait_for_cmd_completion
0x9f0070b4  200      download mode
0x9f007bcc  96       FASTBOOT_MODE
0x9f007cbc  212      FASTBOOT_MODE
0x9f008044  612      SPRDISK_MODE
0x9f008914  240      manipulate BMP image data
0x9f00a284  124      dpu_init
0x9f00d8d4  324      A/N complete
0x9f00da80  1428     A/N enable  | A/N enable
0x9f00ea48  720      bootdelay
0x9f0109e0  236      write_mbr_and_gpt_partitions  | write_mbr_and_gpt_partitions
0x9f010acc  968      sprd_pkcs1_mgf1  | sprd_hash_update  | sprd_hash_update
0x9f0122bc  252      fdt_fixup_uboot_log_reserved
0x9f013dec  192      edit  | import
0x9f0140e8  568      A/N enable  | bootdelay
0x9f0144d8  56       Freescale MXS Boot Image
0x9f014750  688      Blackfin  | nds32
0x9f017830  496      handle_scsi_completion  | handle_scsi_completion
0x9f0186b4  436      check_phase_version_process  | check_phase_version_process  | check_phase_version_process
0x9f018b80  232      prepare_raw_data_buf  | prepare_raw_data_buf
0x9f018f74  112      boot_sprdisk
0x9f0193ec  420      BLKOFF_FROM_MAIN  | BLKOFF_FROM_MAIN  | BLKOFF_FROM_MAIN
0x9f019a10  484      test_ufs_read  | test_ufs_read  | test_ufs_read
0x9f01aee4  224      test_ufs_raw_read  | test_ufs_raw_read
0x9f01b230  256      change_ufs_power_mode
0x9f01b3e4  128      test_ufs_bufread
0x9f01b574  380      common_raw_write  | common_raw_write  | common_raw_write
0x9f01b7dc  324      dl_cmd_reboot
0x9f01b95c  116      sprd_cali_dispc_suspend
0x9f01bff0  120      dev_get_uclass_priv
0x9f01cde8  100      heap@6
0x9f01d258  776      heap@6  | of_parse_panel_power  | of_parse_panel_power
0x9f01d674  724      heap@6
0x9f01da8c  1428     usb_fastboot_exit  | usb_fastboot_exit  | usb_fastboot_exit
0x9f01e020  352      sprd_cali_panel_unprobe  | sprd_cali_panel_unprobe  | sprd_cali_panel_unprobe
0x9f01e440  368      heap@6
0x9f01ea3c  2412     heap@6
0x9f01f848  304      FDL_PacketDoIdle  | FDL_PacketDoIdle  | FDL_PacketDoIdle
0x9f01fda0  892      dl_cmd_handler  | dl_cmd_handler  | _parse_repartition_header
0x9f0202e0  204      __get_gpio_base_info  | __get_gpio_base_info
0x9f020a98  256      download mode
0x9f020b98  752      secure_load_partition  | secure_load_partition  | secure_load_partition
0x9f020e88  816      start_linux_armv8  | start_linux_armv8  | start_linux_armv8
0x9f021b64  2320     download mode  | sprd_fb_secure_vboot_prepare  | sprd_fb_secure_vboot_prepare
0x9f022790  256      download mode
0x9f02292c  64       download mode
0x9f022d98  244      _get_kernel_ramdisk_dt_offset
0x9f023664  184      parser_vendor_boot_image_header_v4
0x9f02394c  536      look_for_matching_device_from_dt  | look_for_matching_device_from_dt  | look_for_matching_device_from_dt
0x9f0241a8  232      merge_dtbo
0x9f024bc4  748      _boot_load_kernel_ramdisk_image  | _boot_load_kernel_ramdisk_image  | _boot_load_kernel_ramdisk_image
0x9f024eb0  604      sysdump_getdump_command  | sysdump_getdump_command  | sysdump_getdump_command
```
