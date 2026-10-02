#!/usr/bin/env python3
"""对取证数据做隐私脱敏。

原则（对应 CONTRIBUTING.md 的隐私要求）：
  1. 只保留与「系统 / 厂商定制组件」相关的行，去掉用户第三方 App 的使用痕迹；
  2. 隐去本机内网地址；
  3. 序列号、账号、联系人等一律不采集（在采集脚本层面就已排除）。

用法: sanitize_evidence.py <目录>
"""
import re
import sys
from pathlib import Path

# 允许保留的包名前缀（系统 / 厂商 / 本次研究对象）
KEEP_PREFIXES = (
    "com.android.", "com.google.android.", "android",
    "com.baidu.", "com.xiaodu.", "com.duer.",
    "com.sprd.", "com.unisoc.", "com.spreadtrum.",
    "com.goodfather.",
)

# 内网地址 -> 占位符
PRIVATE_IP = re.compile(r"\b(?:192\.168|10|172\.(?:1[6-9]|2\d|3[01]))\.\d+\.\d+\b")


def keep_pkg(name: str) -> bool:
    return any(name == p or name.startswith(p) for p in KEEP_PREFIXES)


def sanitize_processes(text: str) -> str:
    out, dropped = [], 0
    for line in text.splitlines():
        # 保留注释行与汇总行
        if line.lstrip().startswith("#") or not line.strip():
            out.append(line)
            continue
        # ps 行最后一个字段是进程名
        parts = line.split()
        if not parts:
            continue
        name = parts[-1]
        if keep_pkg(name):
            out.append(line)
        else:
            dropped += 1
    if dropped:
        out.append(f"# 已隐藏 {dropped} 行第三方应用进程（隐私）")
    return "\n".join(out) + "\n"


def sanitize_network(text: str) -> str:
    return PRIVATE_IP.sub("<已隐去的内网地址>", text)


# 这些全局段记录的是「用户把哪个 App 设成了默认」，属于使用痕迹，整段丢弃
DROP_SECTIONS = ("preferred-activities", "last-installed", "known-packages")


def sanitize_restrictions(text: str) -> str:
    """package-restrictions.xml：逐包过滤只留系统包，并丢掉全局使用痕迹段。"""
    # 先整段删除
    for sec in DROP_SECTIONS:
        while True:
            a = text.find(f"<{sec}")
            if a == -1:
                break
            b = text.find(f"</{sec}>", a)
            if b == -1:
                text = text[:a]
                break
            text = text[:a] + text[b + len(sec) + 3:]

    out = []
    skip_depth = None
    for line in text.splitlines():
        m = re.search(r'<pkg name="([^"]+)"', line)
        if m:
            pkg = m.group(1)
            skip_depth = None if keep_pkg(pkg) else 0
        if skip_depth is not None:
            # 粗略按缩进判断块是否结束
            if re.match(r"\s*</pkg>", line):
                skip_depth = None
            continue
        out.append(line)
    return "\n".join(out) + "\n"


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    root = Path(sys.argv[1])
    changed = []

    for f in sorted(root.rglob("processes.txt")):
        f.write_text(sanitize_processes(f.read_text(encoding="utf-8", errors="replace")),
                     encoding="utf-8")
        changed.append(str(f))

    for f in sorted(root.rglob("network.txt")):
        f.write_text(sanitize_network(f.read_text(encoding="utf-8", errors="replace")),
                     encoding="utf-8")
        changed.append(str(f))

    for f in sorted(root.rglob("package-restrictions.xml")):
        f.write_text(sanitize_restrictions(f.read_text(encoding="utf-8", errors="replace")),
                     encoding="utf-8")
        changed.append(str(f))

    for c in changed:
        print("已脱敏:", c)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
