
---

name: 设备取证报告
about: 提交你设备上的取证数据
title: '[DEVICE] '
labels: device-report
assignees: ''

---

📱 设备信息

· 品牌：
· 型号：
· 系统版本：
· Android 版本：
· Root 方式：

🔍 check.sh 输出

```
粘贴 check.sh 完整输出
```

📋 百度相关进程

```
ps -A | grep -iE "baidu|duer|pcdn"
```

📦 百度相关包

```
pm list packages -f | grep -iE "baidu|duer"
```

📂 系统应用目录

```
ls /system/app/ /system/priv-app/
```

💡 补充说明

有什么其他发现？
