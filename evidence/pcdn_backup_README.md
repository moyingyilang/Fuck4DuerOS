# PCDN 库文件备份说明

本目录不包含实际二进制文件，仅记录原设备上的文件位置与处置方式。

## 备份来源

以下文件已备份至设备本地 `/sdcard/pcdn_backup/`：

```

libcyber-pcdn.so
Swan_libcyber-pcdn.so
Media_libcyber-pcdn.so
Launcher_libcyber-pcdn.so

```

## 原始路径

```

/system/app/PCDN/lib/arm/libpcdn.so
/system/app/PCDN/lib/arm/libpcdnsdk.so
/system/app/PCDN/lib/arm/libxray_native.so
/system/app/DuerShowSwan/lib/arm64/libcyber-pcdn.so
/system/app/DuerShowMedia/lib/arm64/libcyber-pcdn.so
/system/app/DuerShowLauncher/lib/arm64/libcyber-pcdn.so

```

## 处置方式

通过 Magisk 模块将上述路径挂载为 0 字节空文件，使动态链接器无法加载。

## 未上传原因

- 文件体积较大
- 涉及第三方版权
- 仅需记录路径与处置方式

## 验证方法

```bash
su -c 'ls -la /system/app/DuerShowSwan/lib/arm64/libcyber-pcdn.so'
su -c 'stat -c %s /system/app/DuerShowSwan/lib/arm64/libcyber-pcdn.so'
# 输出应为 0
```

