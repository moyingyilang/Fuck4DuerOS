
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

---

## 📜 许可证声明

本项目采用 **GNU General Public License v3.0**。

**提交 PR 即表示你同意：**

1. 你的贡献将按照 GPLv3 许可证发布
2. 你拥有所提交内容的版权，或已获得版权所有者的授权
3. 你的贡献不包含任何违反第三方许可证的代码

**GPLv3 的核心要求：**

- ✅ 可以自由使用、修改、分发
- ✅ 必须保留版权声明和许可证
- ✅ **衍生作品必须同样以 GPLv3 发布**
- ✅ 必须提供源代码
- ❌ 不能闭源分发
- ❌ 不能用于专有软件

**如果你不同意上述条款，请勿提交 PR。**

---

详细条款见 [LICENSE](LICENSE)。
