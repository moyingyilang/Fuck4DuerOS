# 框架层取证原始数据

设备：XD-SEE00-2301（DuerShow_T616_v1.65.0.20250825010819358.R / Android 12 / SDK 31）
采集时间：2026-10-02
采集方式：`su` → `unzip -o <jar> 'classes*.dex'` → `dexdump` → 按类名过滤

## 文件

| 文件 | 说明 |
| --- | --- |
| `framework_baidu_classes.txt` | `/system/framework/framework.jar` 中所有类名含 `baidu` 的 `dexdump` 原始输出块（62 类） |
| `services_baidu_classes.txt` | `/system/framework/services.jar` 中同样的原始输出块（45 类） |
| `framework_baidu_api.md` | 由 `scripts/parse_dexdump.py` 解析出的类 / 方法 / 字段表 |
| `services_baidu_api.md` | 同上 |
| `baidu_framework_classes.txt` | 早期只过滤 `L(android\|com)/baidu/` 的结果，会漏掉 `android/os/baidu`，保留作对照 |

## 复现

```bash
adb shell 'su -c "
  cd /data/local/tmp && rm -rf fw && mkdir fw && cd fw
  unzip -o /system/framework/framework.jar 'classes*.dex'
  for f in classes*.dex; do
    dexdump \$f | awk \"/Class descriptor/{ if (\\\$0 ~ /baidu\\\\//) p=1; else p=0 } p\"
  done
"'
```

过滤规则是 **类描述符里出现 `baidu/`**。注意 `android/os/baidu/...` 不含
`android/baidu/`，用 `L(android|com)/baidu/` 这种写法会漏掉 4 个 AIDL 接口。

## 解析

```bash
python3 scripts/parse_dexdump.py evidence/device-xd-see00-2301/framework/framework_baidu_classes.txt \
  --title "DuerOS framework.jar 非标准 API 面" -o /tmp/framework_baidu_api.md
```

## 关键点

- `hiddenapi : 0x0002 (BLOCKED)`：这些类属于 hidden API，普通 App 无法直接引用。
- 方法名未混淆，可直接读出能力语义。
- 未包含任何用户数据。
