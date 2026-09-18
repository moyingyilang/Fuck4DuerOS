#!/bin/bash
# Fuck4DuerOS 项目结构初始化脚本
# 用法: bash setup.sh

set -e

ROOT="Fuck4DuerOS"

echo "==> 创建目录结构..."
mkdir -p "$ROOT"/{docs,scripts,modules/duer_cleanup/system,.github/ISSUE_TEMPLATE}
cd "$ROOT"

# ============================================================
# LICENSE
# ============================================================
cat > LICENSE << 'EOF_LICENSE'
MIT License

Copyright (c) 2026 moyingyilang

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF_LICENSE

# ============================================================
# README.md
# ============================================================
cat > README.md << 'EOF_README'
# Fuck4DuerOS

> 一个针对百度 DuerOS 定制 Android 设备（小度学生手机等）的净化工具集。
> 逆向取证、解除限制、移除 PCDN、恢复系统原生体验。

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android%2010--14-green.svg)]()
[![Root](https://img.shields.io/badge/requires-Root-red.svg)]()

---

## 📖 这是什么

百度 DuerOS 定制 Android 设备（小度学生手机、学习平板等）预装了大量未经用户同意的组件，包括：

- **PCDN**（P2P 内容分发网络）：用你的宽带帮百度给别人传文件
- **Xray SDK**：全链路数据采集（网络、电量、应用行为、崩溃日志）
- **Duerguard**：守护进程，防止用户修改系统
- **GoodFather**：家长控制，限制通讯
- **ActivityStackMonitor**：系统级 hook，拦截 HOME 解析、限制多任务

本项目通过系统级取证，定位上述组件，并提供：

- 一键检测脚本
- Magisk 模块（无损、可逆）
- 完整的取证报告与法律依据

---

## ⚠️ 适用设备

**仅适用于以下特征的设备：**

- 品牌：小度 / 百度定制
- 系统：DuerOS 定制 Android
- 型号示例：XD-SEE00-2301
- 已 Root（Magisk / KernelSU）

**不适用于普通 Android 设备。** 跑之前**必须先执行 `check.sh`** 确认匹配。

---

## 🚀 快速开始

### 1. 侦察

```bash
su -c 'sh scripts/check.sh'
```

确认输出里有 com.baidu.pcdn 等组件。

2. 执行

```bash
su -c 'sh scripts/install.sh'
su -c 'reboot'
```

3. 验证

重启后：

```bash
su -c 'ps -A | grep -iE "pcdn|duer"'
su -c 'cat /system/etc/hosts | grep baidu'
```

4. 后悔了？

```bash
su -c 'sh scripts/rollback.sh'
su -c 'reboot'
```

---

🔍 检测原理

组件 检测方式 处理方式
PCDN ps -A \| grep pcdn 禁用 + 库文件覆盖
Duerguard pm list packages -d 禁用
GoodFather pm list packages -d 禁用
通讯劫持 dumpsys activity services 组件级禁用
上报域名 cat /system/etc/hosts hosts 屏蔽

---

📚 文档

· 技术取证报告
· 法律依据
· 给普通人的说明

---

🛠️ 参与贡献

见 CONTRIBUTING.md。

如果你有同款或类似设备，欢迎提交取证数据：

· 使用 设备报告模板
· 附上 check.sh 输出
· 说明设备型号、系统版本

---

⚖️ 免责声明

使用本项目前请仔细阅读 DISCLAIMER.md。

· 本项目仅供技术研究与个人设备净化使用
· 修改系统有变砖风险，操作前务必备份
· 作者不对任何设备损坏、数据丢失、法律纠纷负责

---

📜 许可证

MIT License

---

🙏 致谢

· AOSP 开源社区
· Magisk / KernelSU 项目
· 所有提交取证数据的贡献者

---

如果这个项目帮到了你，请给一个 ⭐ Star。
EOF_README

cat > CONTRIBUTING.md << 'EOF_CONTRIB'

贡献指南

感谢你愿意为 Fuck4DuerOS 做贡献。

---

🎯 我们欢迎什么

1. 新设备的取证数据

如果你有其他型号的 DuerOS 设备，欢迎提交：

· check.sh 的完整输出
· ps -A | grep -iE "baidu|duer|pcdn" 的输出
· pm list packages -f | grep -iE "baidu|duer" 的输出
· /system/app/ 和 /system/priv-app/ 的目录列表
· 设备型号、系统版本、Android 版本

使用 设备报告模板。

2. 代码改进

· 新增检测项
· 优化脚本兼容性
· 修复 bug
· 改进 Magisk 模块

3. 文档完善

· 修正错别字
· 补充技术细节
· 新增语言版本（英文、日文等）
· 补充法律条款

4. 法律支持

· 提供其他地区的相关法律条文
· 提供维权案例参考
· 提供投诉渠道信息

---

🚫 我们不接受什么

· 恶意代码：任何破坏设备、窃取数据、损害用户的代码
· 违反法律：任何违反当地法律的用途
· 商业用途：将本项目用于盈利，需提前联系
· 无意义提交：纯格式改动、无关依赖更新

---

📝 提交流程

1. Fork 仓库

```bash
git clone https://github.com/moyingyilang/Fuck4DuerOS.git
cd Fuck4DuerOS
git checkout -b feature/your-feature-name
```

2. 修改

· 脚本：确保 sh -n script.sh 语法检查通过
· 文档：Markdown 格式，中英混排时注意空格
· 代码：保持风格一致，注释清晰

3. 测试

测试必须包含：

· 在真机上跑过（或说明无法测试的原因）
· 提供测试日志
· 说明测试设备型号和系统版本

4. 提交

```bash
git add .
git commit -m "feat: 新增 XXX 检测项"
git push origin feature/your-feature-name
```

5. 开 PR

在 GitHub 上开 Pull Request，说明：

· 改了什么
· 为什么改
· 怎么测试的
· 有什么风险

---

📋 Commit 规范

采用 Conventional Commits：

```
feat: 新增功能
fix: 修复 bug
docs: 文档更新
style: 格式调整
refactor: 重构
test: 测试相关
chore: 杂项
```

示例：

```
feat: 新增 PCDN 域名屏蔽
fix: 修复小米设备 hosts 冲突
docs: 补充未成年人保护法条款
```

---

🎨 代码风格

Shell 脚本

· 使用 #!/system/bin/sh（不是 #!/bin/bash）
· 缩进：4 空格
· 变量加双引号："$VAR"
· 日志统一格式：[$(date)] message

Markdown

· 标题：# 到 ######
· 中英文之间加空格
· 代码块标注语言
· 表格对齐

Smali（如果需要）

· 方法替换时保留 .annotation
· 注意 .locals 数量
· 修改后必须能通过 smali a 编译

---

⚠️ 注意事项

1. 不要提交用户隐私数据：如果日志里有手机号、IMEI、MAC 地址，先打码
2. 不要提交完整 APK：反编译的代码片段可以，完整 APK 涉及版权
3. 不要提交商业机密：如果发现厂商的私钥、密钥等，不要提交，直接报告安全团队
4. 保留原始证据：修改前后的对比，方便审核

---

🔒 安全问题

如果发现严重安全问题（如 RCE、提权漏洞），请不要公开提交。

发邮件到：security@example.com（自行替换）

---

📞 联系

· GitHub Issues：链接
· 讨论区：GitHub Discussions

---

感谢你的贡献。让更多用户知道他们的设备在做什么。
EOF_CONTRIB

cat > DISCLAIMER.md << 'EOF_DISCLAIMER'

免责声明

使用本项目前，请仔细阅读本声明。

---

一、项目性质

Fuck4DuerOS（以下简称"本项目"）是一个技术研究与个人设备净化工具。

本项目的目的是：

1. 通过逆向工程与系统取证，揭示百度 DuerOS 定制设备中预置的未披露组件
2. 为设备所有者提供自主管理其设备的工具
3. 促进消费者知情权与个人信息保护

本项目不是：

· 破解工具
· 盗版工具
· 商业产品
· 任何厂商的官方工具

---

二、使用风险

1. 设备风险

· 变砖：修改系统文件、替换 services.jar 等操作可能导致设备无法启动
· 数据丢失：操作过程中可能误删用户数据
· 失去保修：Root 和修改系统通常会使设备失去保修
· OTA 失败：修改系统后，官方 OTA 更新可能失败或导致系统异常

使用者必须自行承担上述风险。

2. 功能风险

· 部分功能可能失效（如 OTA、语音助手、账号同步）
· 系统可能不稳定（如随机重启、发热、耗电）
· 第三方应用可能无法正常运行

3. 法律风险

· 在某些国家或地区，修改设备可能涉及法律问题
· 使用本项目的目的必须合法（个人设备净化、学术研究）
· 不得将本项目用于攻击他人设备

---

三、操作前必读

在使用本项目前，你必须：

1. ✅ 备份所有重要数据
2. ✅ 备份原始系统文件（如 services.jar、framework-res.apk）
3. ✅ 确保能进入 Recovery 模式
4. ✅ 了解 Magisk 的安全模式
5. ✅ 确认设备型号与本项目匹配（跑 check.sh）

如果你不理解上述任何一项，请勿使用本项目。

---

四、责任限制

在法律允许的最大范围内：

1. 本项目作者不对任何直接或间接损失负责，包括但不限于：
   · 设备损坏
   · 数据丢失
   · 业务中断
   · 法律纠纷
   · 第三方索赔
2. 本项目按"现状"提供，不提供任何明示或暗示的担保，包括但不限于：
   · 适销性担保
   · 特定用途适用性担保
   · 不侵权担保
3. 使用本项目产生的任何后果，由使用者自行承担。

---

五、合法性声明

本项目仅用于合法目的：

· ✅ 个人设备的所有权管理
· ✅ 安全研究与学术研究
· ✅ 消费者权益保护
· ✅ 个人信息保护

本项目严禁用于：

· ❌ 攻击他人设备
· ❌ 窃取他人数据
· ❌ 商业竞争中的不正当行为
· ❌ 任何违反当地法律的行为

---

六、关于第三方组件

本项目引用了以下第三方组件：

· Magisk：https://github.com/topjohnwu/Magisk
· KernelSU：https://github.com/tiann/KernelSU
· apktool：https://github.com/iBotPeaches/Apktool
· baksmali / smali：https://github.com/JesusFreke/smali

上述组件的使用遵循其各自的许可证。

---

七、关于证据文件

本项目中的取证文件（如反编译代码片段、进程截图等）：

1. 仅用于技术研究与法律维权
2. 不包含完整的商业软件源代码
3. 不用于任何商业目的
4. 如涉及版权问题，请联系删除

---

八、法律条款引用

本项目在文档中引用了以下法律法规：

· 《中华人民共和国消费者权益保护法》
· 《中华人民共和国个人信息保护法》
· 《中华人民共和国网络安全法》
· 《中华人民共和国电信条例》
· 《中华人民共和国未成年人保护法》
· 《中华人民共和国民法典》

引用目的：说明技术事实涉及的法律问题，不代表法律意见。

如需法律建议，请咨询专业律师。

---

九、免责声明的变更

本项目作者保留随时修改本免责声明的权利。

修改后的声明将在 GitHub 仓库中更新，使用者应定期查看。

继续使用本项目，视为接受最新版本的免责声明。

---

十、联系方式

如有疑问、建议或法律问题，请通过 GitHub Issues 联系。

最后更新：2026 年 9 月

---

请记住：技术本身中立，使用技术的人决定了它是工具还是武器。

做一个负责任的用户。
EOF_DISCLAIMER

cat > docs/technical-report.md << 'EOF_TECH'

百度 PCDN 组件技术取证报告

待补充：完整的技术取证内容

设备：小度学生手机 XD-SEE00-2301
系统：DuerShow_T616_v1.65.0（Android 12 / SDK 31）
取证时间：2026 年 9 月

---

目录

1. 法律依据
2. 概述
3. 运行时进程取证
4. 文件系统取证
5. 反编译取证
6. 系统框架层取证
7. 行为验证记录
8. 关联证据
9. 技术特征汇总
10. 技术结论
11. 附录

---

（详细内容请参考主仓库文档）
EOF_TECH

cat > docs/legal-basis.md << 'EOF_LEGAL'

法律依据

本文件汇总本项目涉及的法律法规条款。

---

一、《中华人民共和国消费者权益保护法》

第八条　消费者享有知悉其购买、使用的商品或者接受的服务的真实情况的权利。

第十条　消费者享有公平交易的权利。

二、《中华人民共和国个人信息保护法》

第十三条　处理个人信息应取得个人同意。

第十七条　处理个人信息前应显著告知。

三、《中华人民共和国网络安全法》

第二十二条第三款　收集用户信息应明示并取得同意。

第四十一条　遵循合法、正当、必要原则。

四、《中华人民共和国电信条例》

第七条　经营电信业务需取得许可。

第八条　电信业务分为基础电信业务和增值电信业务。

五、《中华人民共和国未成年人保护法》

第七十二条　处理未成年人个人信息应征得监护人同意。

六、《中华人民共和国民法典》

第一千一百六十五条　过错侵害他人民事权益应承担侵权责任。

第一千一百六十七条　被侵权人有权请求停止侵害。
EOF_LEGAL

cat > docs/plain-language.md << 'EOF_PLAIN'

你买的"学生手机"，可能在偷偷帮百度赚钱

——一份给普通人的说明

---

一句话版本

你花钱买的手机，正在用你家的宽带，帮百度给别的用户传文件。你付电费、付网费，百度省服务器钱。

而且，你不知情，也无法关闭。

---

到底发生了什么？

你的小度学生手机里，预装了一个叫 PCDN 的东西。

PCDN 是"点对点内容分发网络"的缩写。说人话就是：

把每个人的手机，变成一个"小型服务器"，帮大公司给别人传文件。

---

百度从中省了什么？

百度省的 你出的
服务器带宽费 你家宽带的上行流量
CDN 分发成本 你家路由器的负载
机房电费 你家手机的电费
运维成本 你家手机的闪存损耗

---

你可以做什么？

如果你不懂技术

1. 打客服电话投诉
2. 向 12315 投诉
3. 向工信部举报
4. 向网信办举报
5. 不推荐再买同品牌产品

如果你懂点技术

1. Root 手机，查看 ps -A | grep pcdn
2. 用 Magisk 模块覆盖 PCDN 文件
3. 改 hosts 屏蔽上报域名
4. 路由器限制上行带宽
5. 保留证据

---

完整内容请见仓库文档
EOF_PLAIN

cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF_BUG'

---

name: Bug 报告
about: 报告脚本或模块的 bug
title: '[BUG] '
labels: bug
assignees: ''

---

🐛 问题描述

简要描述你遇到的问题。

📱 设备信息

· 设备型号：
· Android 版本：
· Root 方式（Magisk / KernelSU）：
· 本项目版本：

🔄 复现步骤

1. 
2. 
3. 

✅ 期望结果

你期望发生什么。

❌ 实际结果

实际发生了什么。

📋 日志

```
粘贴 check.sh 输出或相关日志
```

📷 截图

（如果适用）
EOF_BUG

cat > .github/ISSUE_TEMPLATE/device_report.md << 'EOF_DEV'

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
EOF_DEV

for s in check install rollback; do
cat > "scripts/$s.sh" << EOF_SCRIPT
#!/system/bin/sh

$s.sh - 占位，请从本地复制内容

echo "TODO: 请填入 $s.sh 内容"
EOF_SCRIPT
    chmod +x "scripts/$s.sh"
done

cat > modules/duer_cleanup/module.prop << 'EOF_MODPROP'
id=duer_cleanup
name=DuerOS Cleanup
version=1.0
versionCode=1
author=moyingyilang
description=Block baidu pcdn/duerguard/goodfather and system residuals
EOF_MODPROP

cat > modules/duer_cleanup/service.sh << 'EOF_MODSVC'
#!/system/bin/sh

DuerOS Cleanup - 开机运行

占位，请从本地复制内容

EOF_MODSVC
chmod +x modules/duer_cleanup/service.sh

cat > .gitignore << 'EOF_GITIGNORE'

反编译产物

*.dex
*.smali
*.apk
*.jar

备份文件

*.bak
*.orig
*.rej

日志

*.log

系统文件

.DS_Store
Thumbs.db

IDE

.idea/
.vscode/
*.swp

临时文件

tmp/
temp/
EOF_GITIGNORE

echo ""
echo "=========================================="
echo " ✅ 项目初始化完成"
echo "=========================================="
echo ""
echo "目录结构:"
find . -type f | sort | sed 's|^./|  |'
echo ""
echo "下一步:"
echo "  1. 填写 scripts/ 下的脚本（从 /sdcard/duer_killer/ 复制）"
echo "  2. 填写 modules/duer_cleanup/ 下的文件"
echo "  3. 填写 docs/ 下的文档"
echo "  4. git add . && git commit -m 'init'"
echo "  5. git push origin main"
echo ""
