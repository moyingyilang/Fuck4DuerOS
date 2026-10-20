# U-Boot 全量逆向分析报告

> 对象：`xps06e`（小度青禾 V20 / XD-SEE00-2301，Unisoc UMS9230 / T616）
> 镜像：`uboot_a.img`，3,145,728 字节
> 时间：2026-10-02 ~ 10-03

## 一、基础坐标（经过两次更正，务必遵守）

```
镜像格式      DHTB
头            64 字节（0x00 - 0x3F）
填充          0x40 - 0x1FF（448 字节全零）  ★ 曾误判载荷从 0x40 开始
载荷起点      文件偏移 0x200
载荷末尾      文件偏移 0xe6358
载荷大小      0xe6158 = 942,424 字节
加载基址      0x9f000000                    ★ 曾误判为 0x9f006000
地址换算      abs(file_off) = 0x9f000000 + (file_off - 0x200)
```

### DHTB 头结构

```
+0x00  "DHTB"
+0x04  0x00000001          version
+0x08  32 字节             payload 的 SHA256
+0x28  cc cc cc cc         填充
+0x2c  aa aa aa aa         填充
+0x30  0x000e5ca0          长度
+0x3c  0x000e5c60          长度
```

### 两次坐标错误的教训

| 错误 | 现象 | 后果 |
| --- | --- | --- |
| 载荷起点 0x40（应 0x200） | 0x40-0x1FF 全零未察觉 | ADRP 页基址在特定位置算错，**系统性漏检**；据此误判「模式选择代码被删」 |
| 基址 0x9f006000（应 0x9f000000） | 由错误偏移跑出的直方图得出 | 所有 8 字节指针搜索失效，函数指针表找不到 |

**第二个错误是第一个的连带后果**——初次值的依赖链必须审查。

验证方法（不依赖格式假设）：

```
对每个候选基址，统计载荷中 8 字节值有多少指向可打印串起点：
  0x9f006000 → 457
  0x9f000000 → 2632   ← 峰值，左右相邻仅 103/259/137
```

## 二、分析工具（`tools/`）

| 工具 | 作用 |
| --- | --- |
| `uboot_scan.c` | DHTB 头解析 + 字符串提取 + 指针直方图反推基址 |
| `adrp_xref.c` | ADRP+ADD/LDR/ADR 交叉引用（**参数为载荷相对偏移**） |
| `funcmap.c` | 扫函数序言 + 用引用字符串命名函数 |
| `callgraph.c` | BL/B imm26 调用图（实测 BL=12409、B=5931） |
| `findtables.c` | 扫连续函数指针表，校验目标首字节 |
| `dumptbl.c` | 按地址 dump 表 |
| `fnstr.c` | 按地址区间枚举引用的字符串 |
| `dstr.c` | 读指定地址的字符串 |
| `findval.c` | 搜 32 位值的所有出现形式（data/movz/movk/bfi） |
| `findptr.c` | 搜 8 字节绝对指针 |
| `findref.c` | 搜引用任意绝对地址的指令 |
| `basecheck.c` | 给定基址统计命中数（带比值，可判置信度） |
| `basefind.c` | (指针,字符串) 反解基址（噪声大，保留作对照） |

### 已知踩坑

```
1. adrp_xref 的目标参数是「载荷相对偏移」(abs - 0x9f000000)，不是文件偏移
2. findval 的掩码若写成 0xFFE0001F 会屏蔽立即数位，等于匹配所有 MOVZ
   正确应为 0xFF80001F 且单独比较 (w>>5)&0xFFFF
3. ADRP 计算目标时 PC 必须页对齐
4. 函数可达性至少要查四个维度：BL/B、8 字节指针表、blr 间接调用、
   结构体数组内函数指针。只查前两个会误判「死代码」
```

## 三、启动模式探测链（P1，已完成）

### 分发器：`cboot` 命令

```
命令表项 @ 0x9f0c93b8:
  handler = 0x9f00763c      ← 分发器
  name    = "choose boot mode"
  usage   = "mode: "
```

环境变量 `bootcmd = "cboot normal"` → 模式号 `w2 = 2`（NORMAL_MODE）。

### 三段式结构

**阶段一：处理器链**

```asm
0x9f0076d4  i = 0
0x9f0076f0  ldr x1, [0x9f0b87e0 + i*8]     ; 全局处理器表（10 项，NULL 结尾）
0x9f0076f4  cbz x1, 未找到
0x9f007700  blr x1                           ; 返回 0=未处理继续，非 0=命中
0x9f00770c  i++
```

**阶段二：打印**

```asm
0x9f007734  add x0, x0, 0x4b8                ; "enter boot mode %d"
0x9f00773c  bl 0x9f01270c
```

**阶段三：二次分发（栈上表）**

```asm
0x9f007740  sub w0, w19, 2
0x9f007744  cmp w0, 0x18                     ; 合法模式号 2..26
0x9f00774c  ldr x0, [x20, w19, uxtw 3]       ; x20 = x29+0x38（0xd8 字节栈表）
0x9f007754  blr x0
0x9f00775c  （未找到）bl 0x9f03d6a8 ; b .（死循环停机）
```

### 10 个处理器

| 序 | 地址 | 探测来源 |
| --- | --- | --- |
| 1 | `0x9f007228` | **miscdata 的 `first_mode`** |
| 2 | `0x9f007290` | **misc 的 recovery 消息** |
| 3 | `0x9f0072ac` | 同 1/2 的延续（内含 MFS 校验调用 `0x9f032c88`） |
| 4 | `0x9f0072fc` | 关机充电 |
| 5 | `0x9f007330` | 充电器连接 / **按键** |
| 6 | `0x9f0073dc` | 看门狗 + 关机闹钟 |
| 7 | `0x9f0071c8` | 看门狗异常 |
| 8 | `0x9f007440` | RTC 关机闹钟到期 |
| 9 | `0x9f00749c` | 关机充电（另一种）← **调用 EIC 读取** |
| 10 | `0x9f007558` | 按键触发 recovery |

### ⚠️ 最关键的一条：normal 模式跳过整条探测链

```asm
0x9f0076b8  bl 0x9f006fec
0x9f0076bc  cmp w19, 2
0x9f0076c0  b.ne 0x9f0076d4      ; w19 != 2 才进探测链
0x9f0076c4  ldr x0, [x21, 8]
0x9f0076c8  bl 0x9f0070b4
0x9f0076d0  b 0x9f007728          ; ★ w19 == 2 → 直接跳到打印
```

**`bootcmd = "cboot normal"` → `w19 = 2` → 探测链永不执行 → 按键处理器从不被调用。**

## 四、MFS 魔数机制

### 数据结构

`miscdata` 偏移 0 处的 32 位字（小端）：

```
bit  0- 6   模式号（0-127）
bit  8-31   必须为 0x53464D  → 字节 'M'(0x4D) 'F'(0x46) 'S'(0x53)
```

校验时 `and w2, w1, 0xffffff00` 把低字节排除，专供模式号。

### 两个使用点

```
0x9f032c88   读 miscdata（0x2420 字节）到缓冲区 0x9f255924，校验 MFS，取模式号
0x9f023b9c   bootargs 拼装时再次校验，命中则拼 "first_mode=%x"
```

缓冲区地址相同（`0x9f255924`），bootargs 拼装复用它，不重读分区。

### 现状与结论

设备 `miscdata` 前 4 字节是序列号 `'5' '1' 'P' 'S'`，不等于 MFS 魔数 ⇒ 校验恒失败。

**全镜像中 MFS 魔数只有比较，没有写入逻辑** —— 厂商保留读取、移除写入。

**但仅写 MFS 不够**：`0x9f032c88` 只在探测链里被调用，而 normal 模式跳过探测链
⇒ 缓冲区保持全零 ⇒ bootargs 校验也读不到。

## 五、A/B 槽魔数

```asm
0x9f007690  ldr w1, [x0, 0x40]                ; 结构体 0x9f0f0b80 + 0x40
0x9f007694  mov w0, 0x55cc ; bfi 0x10,0x10    → 0x55CC55CC
0x9f0076a0  b.eq → w1=1 → 0x9f010acc(1, 1)
0x9f0076a4  mov w0, 0x55dd ; bfi 0x10,0x10    → 0x55DD55DD
0x9f0076b0  b.eq → w1=2 → 0x9f010acc(1, 2)
```

**两个魔数在全镜像中各只出现一次，就是那两条比较指令本身，无任何写入。**

结构体在 `0x9f0f0b80`（BSS，超出载荷末尾），`+0x40` 是被比较字段。

⇒ 与 MFS 同一模式：读校验完整、写入口缺失。

## 六、按键子系统（P7）

### 三层结构

```
1  board init 序列末尾调用 GPIO 按键初始化 0x9f004a24
   （0x9f00476c 起 7 步初始化，按键在最后）
2  EIC 读取 0x9f004a54 只在探测链第 9 项被调用（0x9f0074cc）
   读 EIC 通道 0xa4，失败打印 "[eic keys] volumeup : … ERROR!"
3  FUN_00005858 等价逻辑：0x9f0074ac 的 cmp w0,#1 ; b.le 跳过扫描
   比较值来自 0x9f006fec 的返回值
```

### 计数器机制

```asm
0x9f006fec  bl 0x9f04776c                     ; 读 EIC 通道 0xa1（延时 3 秒）
0x9f006ffc  cbnz w0, 跳过
0x9f007004  ldr w2, [0x9f0f0b74] ; add 1 ; str  ; 自增
0x9f007018  ldr w0, [0x9f0f0b74]                ; 返回计数器
```

`0x9f04776c` 读 EIC 通道 `0xa1`，返回 `(值 != 0)`。

### 结论

**按键不是坏了，是「normal 模式跳过探测链」导致处理器从不执行。**

设计意图清晰：只在异常启动（`cboot <非normal>`）时才需要按键选模式。

## 七、安全子系统（P5）

### 锁状态与校验跳过

```asm
0x9f022558  stp x29, x30, [sp, -0x20]!
0x9f02256c  bl 0x9f01270c                       ; "take_action_with_vbootret"
0x9f022588  bl 0x9f07ee48                       ; strncmp(4)
0x9f022590  ldr w0, [0x9f23d890]                ; ★ 锁状态
0x9f022598  cmp w0, 2
0x9f02259c  b.eq 0x9f0225c8                     ; == 2 → UNLOCK
0x9f0225c8  → "WARNNING: LOCK FLAG IS : UNLOCK, SKIP VERIFY!!!"
```

`0x9f23d890 == 2` → 打印 SKIP VERIFY 并返回。

### 状态映射（推断）

```
0x9f0a2e9e  附近字符串：
  androidboot.verifiedbootstate=green / yellow / orange / red
  androidboot.flash.locked=0 / 1
```

设备实测 `verifiedbootstate=orange` + `flash.locked=0` → 对应 **lock = 2** ✓

⇒ **设备的解锁是真的**，由 uboot 自己设置，不是伪装。

### 校验链

```asm
0x9f0227d4  bl 0x9f083c84          ; 哈希
0x9f0227dc  bl 0x9f022490
0x9f0227e4  bl 0x9f083650
0x9f0227e8  bl 0x9f02266c
0x9f0227fc  bl 0x9f0839e4
0x9f022800  bl 0x9f022558          ; ★ 锁状态 → SKIP VERIFY
0x9f022810  bl 0x9f0843f8          ; 比较 0x400 字节（缓冲 0x9f23c000）
0x9f022844  bl 0x9f022700          ; mask 0x9df00000
→ 设置 verifiedbootstate / flash.locked
```

### ⚠️ 关键区分

**uboot 里的 SKIP VERIFY 是「uboot 验证 kernel/recovery」这一层。**

**uboot 自己的 DHTB 签名由更早的阶段（BROM / splloader）验证**，不在本镜像内。

证据：全镜像搜 `"DHTB"` 只有文件偏移 0（头本身），**代码零引用**。

## 八、DLoader / FDL 协议（P4，核心已破）

### `fdl2-dl.bin` 与 `uboot_a.img` 的关系

```
fdl2-dl.bin:  U-Boot 2015.07 (Jan 24 2024) jenkins-DuerShow_T616-2450
uboot_a.img:  U-Boot 2015.07 (Aug 25 2025) jenkins-DuerShow_T616-6304
```

字符串集 5467 vs 5466（只差构建戳）⇒ **同一源码，两次构建**。
角色由 `preboot=role` 运行期决定，不是构建差异。

DHTB 头布局与尺寸完全一致，仅哈希不同。

### 命令注册表

`download mode` 命令的 handler `0x9f006ba4` 通过 `register()`（`0x9f006ac8`）
注册全部 FDL 命令：

| 命令码 | 处理函数 | | 命令码 | 处理函数 |
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

### 已识别的函数

```
dload_whole_raw_file   0x9f01b574   写整个裸文件（写分区）
prepare_raw_data_buf   0x9f01b3e4   设置两个 2MB DMA 描述符（环形链）
dl_cmd_repartition     0x9f01adb8   重新分区
dl_cmd_read_ref_info   0x9f01b130   读参考信息
```

### 写分区路径 —— 无任何限制

```asm
0x9f01b574  dload_whole_raw_file 入口
0x9f01b5e4  mov w0, 0x80 ; bl 0x9f01a654        ; 握手
0x9f01b5fc  bl 0x9f01b554                        ; 取包长度
0x9f01b610  bl 0x9f01a35c                        ; 处理
0x9f01b61c  bl 0x9f01b3d8                        ; 写入
0x9f01b620  cmp w0, w19 ; b.eq 继续下一包
```

```asm
0x9f01b3d8  mov w1, w0 ; mov x0, 0 ; b 0x9f01a3b8   ; 薄包装
```

`prepare_raw_data_buf` 只设 DMA 描述符，无分区名判断。

**⇒ 全程无分区白名单、无签名校验。`spd_dump` 的 `w` 命令可写任意分区，包括 `uboot_a`。**

## 九、fastboot（P3）

命令字符串（`0x9f0a4e6d` 一带）：

```
getvar:  download:  is-userspace  max-download-size
flash:   erase:     powerdown
reboot-bootloader  reboot-fastboot  reboot-recovery
set_active:  setdump  getdump  flashing  oem
getlcs  setrma  getsocid  tokenp%d  socidp%d
```

`flash:` / `erase:` 均存在。

## 十、结论

### 已确认

1. **设备解锁为真**（uboot 自己设 `orange` + `locked=0`），非伪装
2. **按键「失效」是设计行为**——normal 模式跳过整条探测链，按键处理器从不执行
3. **MFS 魔数与 A/B 槽魔数都是「读校验完整、写入口缺失」**
4. **FDL 写分区无任何限制**，`spd_dump w` 可写任意分区
5. **uboot 不自校验 DHTB**——签名由 BROM/splloader 验，不在本镜像

### 三条可行的启动模式控制路径

| 路径 | 需要什么 | 状态 |
| --- | --- | --- |
| 写 `misc` 的 BCB | 只写 2KB | **已实测可行**（进 fastbootd） |
| 改 `bootcmd` | 刷改过的 uboot | 卡在 BROM 对 uboot 的签名校验 |
| 写 MFS 魔数 | 改 bootcmd **+** 写 miscdata | 依赖前一条，非独立路径 |

### 开放问题

- BROM/splloader 是否每次都校验 `uboot_a` 的 DHTB？（需 splloader 镜像）
- `0x9f23d890`（锁状态）的写入方（无直接 `str`，疑为结构体整体初始化）
- FDL 的 17 个命令处理函数中，`0x01`/`0x02`/`0x0d` 等的完整语义
- `uboot_a` 与 `uboot_b` 的关系（双备份还是 A/B 槽）
