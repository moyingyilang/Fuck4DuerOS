# spd_dump（展锐 BROM/FDL 刷机工具）在 Android 上的可用方案

## 问题

展锐的 `spd_dump` 官方/常见发行版都是 **Windows x64** 或 **x86_64 Linux**，
在 Android（aarch64）上跑不起来。设备所有者此前只能在 Windows 网吧环境使用。

## 解法：TomKing062 提供的 musl 静态 aarch64 构建

`TomKing062/action_spd_dump_it` 的 `build-musl` workflow 构建矩阵里包含
**`aarch64-unknown-linux-musl`**：

```yaml
matrix:
  branch: [main, oldpath]
  toolchain: [x86_64-unknown-linux-musl, aarch64-unknown-linux-musl]
```

预编译产物（nightly.link，无需登录）：

```text
https://nightly.link/TomKing062/action_spd_dump_it/workflows/build-musl/main
  spd_dump_it_main_243_<sha>_aarch64-unknown-linux-musl.zip
  spd_dump_it_oldpath_229_<sha>_aarch64-unknown-linux-musl.zip
```

> **选哪个版本**：上游 README 明确写着
> "if you use spd_dump with auto-unlock-batches, download oldpath version"。
> 而设备所有者的 `unlock_autopatch_9230.bat` 正是 auto-unlock 批处理，
> 因此应当用 **oldpath** 版。

解出来的两个二进制：

```text
spd_dump-main-aarch64-unknown-linux-musl      1.5 MB  ELF 64-bit ARM aarch64, statically linked
spd_dump-oldpath-aarch64-unknown-linux-musl   1.5 MB  ELF 64-bit ARM aarch64, statically linked
```

**静态链接是关键**：不需要 glibc、不需要 chroot，直接放在 Termux 里就能跑
（但 USB 访问仍需 root）。

## 实测

在主机（Redmi，Android + Magisk root）上：

```bash
adb push spd_dump-oldpath-aarch64-unknown-linux-musl /data/local/tmp/spd_dump
adb shell 'su -c "chmod 755 /data/local/tmp/spd_dump; /data/local/tmp/spd_dump"'
```

输出：

```text
ver:229, sha1:ad0ce43b210ebd0e0ffc4e436b0f350922304a3f
Waiting for dl_diag connection (30s)
libusb_open_device failed
```

⇒ **二进制可以正常运行**（说明了 aarch64 静态构建在 Android 上可用），
只是当时目标设备不在 download 模式，所以打不开设备。

非 root 运行会得到 `libusb_init failed: LIBUSB_ERROR_OTHER`，
因为 `/dev/bus/usb/*` 属主是 `root:usb`。

## 上游用法

```text
spd_dump [OPTIONS] [COMMANDS] [EXIT COMMANDS]

# 一行式
spd_dump --wait 300 fdl <fdl1> <fdl1_addr> fdl <fdl2> <fdl2_addr> exec path <save> r all reset

# 交互式（进入后提示符为 FDL2>）
spd_dump --wait 300 fdl <fdl1> <fdl1_addr> fdl <fdl2> <fdl2_addr> exec
```

常用选项：

| 选项 | 说明 |
| --- | --- |
| `--wait <秒>` | 等待设备连接的时间 |
| `--stage <n>` / `-r` / `--reconnect` | 在 brom/fdl1/fdl2 阶段重连 |
| `--kickto <mode>` | 连接路径 `boot_diag -> custom_diag`，mode 0/1/2 对应 ums9621 的 kickto 2 / cali_diag / dl_diag |
| `exec_addr <addr>` | **仅 brom 阶段**：把 `custom_exec_no_verify_<addr>.bin` 发到指定地址，绕过 brom 对 `splloader`/`fdl1` 的签名校验 |

## 本机专用参数（来自 ums9230_Baidu_Qinghe_V20 包里的 unlock_autopatch_9230.bat）

```bat
spd_dump --wait 300 exec_addr 0x65015f08 ^
         fdl fdl1-dl.bin 0x65000800 ^
         fdl fdl2-dl.bin 0x9efffe00 ^
         exec ... reset
```

- `exec_addr 0x65015f08` — CVE-2022-38694 的 brom 利用地址
- FDL1 加载地址 `0x65000800`
- FDL2 加载地址 `0x9efffe00`
- 需要的同名 payload：`custom_exec_no_verify_65015f08.bin`（就在那个包里）

## 待办

- [ ] 确认目标设备进入 **BROM / dl_diag** 模式的方法
      （展锐通常是关机后按住某组合键再插 USB；或 bootloader 无效时自动进入）
- [ ] 用本机专用包的 FDL loader 打通连接，先做**只读**验证（`r all` 或指定分区）
- [ ] 只读验证通过后，才算真正具备「内核刷挂也能救回」的能力
