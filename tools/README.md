# U-Boot 镜像分析工具

针对展锐 **DHTB** 格式的 U-Boot 镜像（`uboot_a`/`uboot_b` 分区）写的快速分析器。
用 C 而非脚本语言，因为需要在大文件上做数百万次逐字节扫描。

## 为什么用 C

第一版用 Python 写，一次全量扫描要几分钟；同样的逻辑用 C 重写后 **0.4 秒**跑完。
涉及「几 MB 文件 × 每 4 字节一次迭代 × 数千个候选值」的笛卡尔积时，
脚本语言的解释开销是决定性的。

## uboot_scan.c

转储镜像结构、字符串表，并用**指针-字符串偏移直方图**反推加载基址。

```bash
clang -O2 -o uboot_scan uboot_scan.c
./uboot_scan uboot_a.img "first_mode=%x" "cboot;cboot fastboot"
```

做的事情：

1. 解析 DHTB 头（magic `DHTB`、version、sha256、载荷大小），
   头 64 字节，载荷紧随其后；
2. 提取 NUL 分隔的可打印字符串及其载荷内偏移；
3. 收集落在候选地址区间的 8 字节值作为「指针」；
4. **反推基址**：对每个指针 V 和每个字符串偏移 O 计算 `base = V - O`，
   按 4KB 对齐做直方图，众数即基址。原理是字符串表通常配一张绝对
   指针数组，正确的基址会让大量指针同时命中字符串；
5. 用邻近基址做校准，观察命中数是否形成尖峰；
6. 对指定字符串，找它的绝对指针引用与 ARM64 `ADRP+ADD` / `ADRP+LDR` 引用。

实测本机 uboot：

```text
直方图峰值 base[19:12] = 0x9f006  命中 551 次（邻居仅 200~300）
⇒ 基址 0x9f006000
```

验证：`get_miscdata_boot_flag` 位于载荷偏移 0x92570 → 地址 `0x9f098570`，
而反汇编中确实存在

```text
0x9f038cfc   adrp x1, 0x9f098000
0x9f038d00   add  x1, x1, 0x570      → 0x9f098570  ✓
```

## adrp_xref.c

宽泛的 ARM64 取址指令交叉引用扫描，用于定位「哪个函数引用了这个字符串」。

```bash
./adrp_xref uboot_a.img 92570 a36c6 9b4cd
```

支持的取址模式（比编译器实际会生成的更宽）：

| 模式 | 说明 |
| --- | --- |
| `ADRP+ADD` | 标准字符串取址，允许 ADD 与 ADRP 间隔 1~8 条指令 |
| `ADRP+ADD.W` | 32 位变体 |
| `ADRP+LDR` | 从字面量池加载 |
| `ADR` | PC 相对 ±1MB |

指令解码要点（踩过的坑）：

```c
/* ADRP: 1 immlo 10000 immhi Rd */
(a & 0x9F000000) == 0x90000000
/* ADD (imm) 64 位: sf=1 op=0 S=0 */
(b & 0x7F000000) == 0x11000000 && (b >> 31)
/* 计算目标时 PC 必须页对齐，否则全错 */
page = (pc & ~0xFFF) + (imm << 12)
```

## 反汇编

Termux 里的 `objdump` / `llvm-objdump` **不支持 `-b binary`**，
处理裸二进制要用 radare2：

```bash
BASE=0x9f006000
# 先剥掉 DHTB 头（64 字节）
dd if=uboot_a.img of=code.bin bs=1 skip=64 count=$((0xe5c60))

r2 -q -a arm -b 64 -m $BASE -e scr.color=0 -c "pd 40 @ 0x9f038b6c; q" code.bin
```

## 已知结论

- DHTB 头 64 字节；载荷 0xe5c60；基址 0x9f006000
- `cboot [mode]` 选择启动模式，模式名：
  `recovery, fastboot, dloader, charge, normal, vlx, caliberation.`
- U-Boot 从 `miscdata` 分区读 **字符串字段** `first_mode`：
  `get mode from firstmode field: %s`
- `first_mode=%x` 同时会作为 bootargs 片段传给内核
- U-Boot fastboot 命令表完整可用（含 `reboot-fastboot`、`reboot-recovery`、
  `set_active:` 与一套 OEM 解锁命令）

## 未解决

`cboot` 模式选择相关的字符串（`get mode from firstmode field: %s`、
`cboot;cboot fastboot`、`first_mode=%x`）在**整个载荷里找不到 ADRP/ADR 引用**，
而同区域的 `get_miscdata_boot_flag` 有 7 处引用。

推测：uboot 含 **dloader 与 cboot 两个角色**的代码，另一份的链接基址不同，
需要先把第二份镜像的基址定出来，才能继续定位 `first_mode` 字段的偏移。
