# U-Boot 全量逆向分析：目标与路线图

> 2026-10-03 立项目标。设备已救回，转入系统性分析阶段。

## 已确立的基础事实（必须遵守）

```
镜像格式      DHTB，头 64 字节，头后 448 字节全零填充
载荷起点      文件偏移 0x200   ★ 曾误判为 0x40，导致 0x1C0 的系统性漏检
载荷末尾      文件偏移 0xe6358
载荷大小      0xe6158 (942,424) 字节
加载基址      0x9f006000
地址换算      abs(off) = 0x9f006000 + (off - 0x200)
```

**验证方式**（必做）：任何新结论都要用端到端对照检验，不能只用同区域类比。

```bash
# 已知字符串必须有引用；载荷相对偏移 = 文件偏移 - 0x200
./adrp_xref uboot_a.img 0x9b2d7    # → ADRP@0x72c8 + ADD@0x72cc
```

## 已确认的关键结论

| 项 | 内容 |
| --- | --- |
| 模式魔数 | `miscdata[0..3]` 小端字：bit0-6 为模式号，bit8-31 须为 `0x53464D`（`'M','F','S'`） |
| 校验函数 | `0x9f038c88` —— 读 miscdata → 校验 → 取模式号 → 查表 |
| 模式表 | `0x9f09a0f0`，12 字节/项，`[+8]` 为启动值 |
| 模式名表 | `0x9f09a2a0`，8 字节/项指针数组 |
| 现状 | 无任何代码写 MFS，故校验恒失败，模式分发永不激活 → 按键被 `w4<=1` 拦住 |
| 按键函数 | Ghidra 中为 `FUN_00005858`（音量上键），模式参数 `w4` 来自上述链路 |

## 分析目标（按优先级）

### P0 —— 基础设施

- [x] 修正三件工具的基址与载荷偏移（`uboot_scan` / `adrp_xref` / `funcmap`）
- [x] 端到端验证：已知字符串必须能扫到引用
- [ ] **BL 调用图工具**：扫 `bl imm26` 与 `br`/`blr` 间接跳转，产出「谁调用谁」
- [ ] **函数边界修正**：当前 1795 个候选含误报，需用「前一条是 ret / 对齐填充」过滤
- [ ] **字符串—函数索引**：反查「哪个函数用了这个串」，供后续逐子系统定位

### P1 —— 模式分发子系统（最高价值）

已知入口 `0x9f038c88`，需要完整还原：

- [ ] `0x9f09a0f0` 表的 `field2` 语义（现测值 0x00/0x01/0x05/0x0b/0x0c/0x07/0x08/0x10/0x11/0x18）
- [ ] 模式索引 0~11 与 `UNDEFINED_MODE`/`NORMAL_MODE`/`RECOVERY_MODE`/`FASTBOOT_MODE` 的对应顺序
- [ ] `0x9f09a2a0` 那张模式名表被哪段代码读取
- [ ] 写入 MFS 之后，除模式号外还需满足哪些条件
- [ ] 模式号如何传入 `FUN_00005858` 的 `w4`

**为什么优先**：这是唯一一条「不改 uboot、不用 BROM、不用按键」就能指定启动模式的路径。

### P2 —— 启动主流程

- [ ] 定位入口（`0x9f006200` 处 `b #0x28` 的落点）
- [ ] 还原 `board_init` → `main_loop` → `bootcmd`（`cboot normal`）
- [ ] 解析 `preboot=role` 的作用与 dloader/cboot 两种角色的分叉点
- [ ] 解析 `bootdelay`、`bootcmd` 环境变量的来源

### P3 —— fastboot 子系统

已提取命令表：`getvar/download/flash/erase/powerdown/reboot-bootloader/reboot-fastboot/reboot-recovery/set_active/setdump/getdump/flashing/getlcs/setrma/getsocid` 与 OEM `unlock_critical` 等。

- [ ] 命令分发表的地址与 dispatch 逻辑
- [ ] `flash` 的写入路径（是否校验 DHTB/AVB）
- [ ] `getvar` 支持的全部变量
- [ ] USB 描述符与端点配置
- [ ] `reboot-fastboot` / `reboot-recovery` 的实际行为

### P4 —— DLoader / FDL 子系统

这是 BROM 救援走的那条路，对「设备失联」场景最有用。

- [ ] `sprd_dl_check`（`0x9f017054`）的进入条件
- [ ] FDL 协议命令分发表（对照 `spd_dump` 的 `w` / `r` / `read_part` / `wl`）
- [ ] `dl_cmd_reboot`（`0x9f02199c`）的行为
- [ ] FDL1/FDL2 两阶段的交接方式
- [ ] `exec_addr 0x65015f08` 这个 BROM 利用点与 FDL 的关系

### P5 —— 安全子系统

- [ ] DHTB 签名校验代码位置与算法
- [ ] lock 状态从哪里读（efuse？miscdata？）
- [ ] `WARNNING: LOCK FLAG IS : UNLOCK, SKIP VERIFY!!!` 这条日志的上下文——是否真的会跳过校验
- [ ] 是否有可绕过的分支

### P6 —— 存储与分区

- [ ] GPT 解析、分区名查找（`0x9f01e1ec` 是读分区函数）
- [ ] UFS 读写路径（`test_ufs_read` / `change_ufs_power_mode`）
- [ ] 分区表缓存位置

### P7 —— 按键检测

- [ ] `[gpio keys] init skip!`（`0x9f00aa44`）与 `[eic keys] volumeup`（`0x9f00aa98`）所在函数
- [ ] EIC 读取失败的原因（`sprd_eic_get return ERROR!`）
- [ ] 模式参数 `w4` 的完整传递链
- [ ] `Keypad trigger to recovery`（`0x9f00d51c`）的条件

## 产出物

1. `tools/` —— 修正后的分析工具（`uboot_scan` / `adrp_xref` / `funcmap` / `callgraph`）
2. `docs/uboot-functions.md` —— 带注释的全量函数地图（按子系统分组）
3. `docs/uboot-bootflow.md` —— 启动流程端到端说明（含 ASCII 流程图）
4. `docs/uboot-full-analysis.md` —— 本文，随进度更新勾选

## 方法论（本次教训）

**这个项目已经因为「工具的系统性偏差」犯过一次错**，代价是推翻了正确结论。因此：

1. **验证输入假设**，不要假设格式文档可信。`od` 一行就能发现 0x40~0x200 全零。
2. **阳性对照要端到端**，不能用同区域类比。「另一个字符串有引用」只能证明算子大体可用，不能排除系统性漏检。
3. **阴性结果最多是「不支持」，不能作「否定」**。找不到引用时先怀疑搜索范围与坐标。
4. **每个结论都要留下可复现的验证命令**，写进文档。
