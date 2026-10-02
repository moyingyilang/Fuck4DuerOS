# 取证数据

本目录包含设备 **XD-SEE00-2301** 的实际取证数据。

## 目录结构

```
device-xd-see00-2301/
├── process/       进程列表（ps -A）
├── packages/      包列表（enabled / disabled）
├── services/      服务列表（dumpsys activity services）
├── apps/          系统应用目录（/system/app、/system/priv-app）
├── framework/     框架层取证：framework.jar / services.jar 中的百度类
└── session-2026-10-02/   实时快照（含 PCDN 库哈希与遮蔽验证）

reports/                        调查报告（docx 格式）
pcdn_backup_README.md           PCDN 库文件备份说明
```

## 一键复现

设备需已 root：

```bash
./scripts/collect_via_adb.sh
```

采集脚本 `scripts/collect_evidence.sh` 是**只读**的：不 disable 任何包、
不写 `/system`、不改网络配置。

## 数据用途

1. 技术研究：分析百度 DuerOS 定制 ROM 的组件构成
2. 法律维权：作为消费者权益侵害的证据
3. 同类设备用户参考：确认自己的设备是否有相同组件

## 数据来源

所有数据均通过设备端命令直接采集：

```bash
ps -A                              # process/
pm list packages -e / -d           # packages/
dumpsys activity services          # services/
ls /system/app /system/priv-app    # apps/
unzip -l <apk> | grep pcdn         # 内嵌 native 库
dexdump classes*.dex               # framework/
```

## 隐私说明

采集数据时已排除以下内容：

- 用户账号、联系人、短信
- 序列号、IMEI、MAC 地址
- 位置信息
- 应用使用记录
- 原始网络连接表（仅保留聚合统计）

仅包含系统级组件信息。

`ro.serialno` 曾被早期版本的采集脚本写入，自 2026-10-02 起已在脚本层面剔除。
