#!/usr/bin/env python3
"""Turn `dexdump` output into a compact class -> method/field summary.

Used by Fuck4DuerOS to document the non-standard Baidu/DuerOS additions found in
/system/framework/{framework.jar,services.jar}.  Kept dependency-free so it runs
on-device or in Termux.

Usage: parse_dexdump.py DUMP.txt [-o OUT.md]
"""
import argparse
import re
import sys

CLASS_RE = re.compile(r"^\s+Class descriptor\s+: '(.+);'\s*$")
MEMBER_RE = re.compile(r"^\s+#\d+\s+: \(in .*\)\s*$")
NAME_RE = re.compile(r"^\s+name\s+: '(.*)'\s*$")
TYPE_RE = re.compile(r"^\s+type\s+: '(.*)'\s*$")
ACCESS_RE = re.compile(r"^\s+access\s+: (0x[0-9a-f]+) \((.*)\)\s*$")
SECTION_RE = re.compile(
    r"^\s+(Static fields|Instance fields|Direct methods|Virtual methods|Interfaces)\s*-?\s*$"
)


def access_label(raw: str, human: str) -> str:
    if human:
        return human
    return "PACKAGE" if raw == "0x0000" else raw


def parse(path):
    classes = []
    cur = None
    section = None
    member = None

    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        for line in fh:
            m = CLASS_RE.match(line)
            if m:
                cur = {"name": m.group(1), "super": None,
                       "interfaces": [], "methods": [], "fields": []}
                classes.append(cur)
                section = None
                member = None
                continue
            if cur is None:
                continue
            sec = SECTION_RE.match(line)
            if sec:
                section = sec.group(1)
                member = None
                continue
            if line.strip().startswith("Superclass"):
                sc = re.search(r"'(.*)'", line)
                if sc:
                    cur["super"] = sc.group(1)
                continue
            if section == "Interfaces" and line.strip() and not line.strip().startswith("#"):
                iface = re.search(r"'(.*)'", line)
                if iface:
                    cur["interfaces"].append(iface.group(1))
                continue
            if MEMBER_RE.match(line):
                member = {"name": None, "type": None, "access": None}
                if section in ("Direct methods", "Virtual methods"):
                    cur["methods"].append(member)
                elif section in ("Static fields", "Instance fields"):
                    cur["fields"].append(member)
                else:
                    member = None
                continue
            if member is None:
                continue
            nm = NAME_RE.match(line)
            if nm:
                member["name"] = nm.group(1)
                continue
            ty = TYPE_RE.match(line)
            if ty:
                member["type"] = ty.group(1)
                continue
            ac = ACCESS_RE.match(line)
            if ac and member["access"] is None:
                member["access"] = access_label(ac.group(1), ac.group(2))
                continue
            if line.strip() == "code  : (none)":
                member = None
    return classes


def shortcuts(cls):
    """The non-synthetic methods, i.e. the class's actual API surface."""
    out = []
    for meth in cls["methods"]:
        name = meth["name"] or "?"
        if "$" in name or name.startswith("lambda$"):
            continue
        out.append((name, meth["type"] or "?", meth["access"] or ""))
    return out


def render(classes, title):
    lines = [f"# {title}", "",
             f"共 **{len(classes)}** 个非标准类。数据由 `dexdump` 提取，"
             f"解析脚本见 `scripts/parse_dexdump.py`。", ""]
    total_methods = sum(len(c["methods"]) for c in classes)
    lines += [f"- 类：{len(classes)}", f"- 方法：{total_methods}", ""]

    by_pkg = {}
    for c in classes:
        pkg = c["name"].rsplit("/", 1)[0] if "/" in c["name"] else c["name"]
        by_pkg.setdefault(pkg, []).append(c)

    for pkg in sorted(by_pkg):
        lines.append(f"## `{pkg}`")
        lines.append("")
        for c in sorted(by_pkg[pkg], key=lambda x: x["name"]):
            short = c["name"].rsplit("/", 1)[-1]
            lines.append(f"### `{short}`")
            lines.append("")
            lines.append(f"- 完整类名：`{c['name']}`")
            if c["super"] and c["super"] != "Ljava/lang/Object;":
                lines.append(f"- 父类：`{c['super']}`")
            if c["interfaces"]:
                lines.append("- 接口：" + ", ".join(f"`{i}`" for i in c["interfaces"]))
            ms = shortcuts(c)
            if ms:
                lines.append(f"- 方法（{len(ms)}）：")
                lines.append("")
                lines.append("  | 方法 | 签名 | 可见性 |")
                lines.append("  | --- | --- | --- |")
                for name, sig, acc in ms:
                    lines.append(f"  | `{name}` | `{sig}` | {acc} |")
            lines.append("")
    return "\n".join(lines) + "\n"


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("dump")
    ap.add_argument("-o", "--output")
    ap.add_argument("--title", default="Baidu / DuerOS 框架层 API 面")
    args = ap.parse_args(argv)

    classes = parse(args.dump)
    text = render(classes, args.title)
    if args.output:
        with open(args.output, "w", encoding="utf-8") as fh:
            fh.write(text)
    else:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
