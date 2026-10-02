#!/usr/bin/env python3
"""对比 bench.sh 的两份快照，输出优化前后差异表。

用法: compare_bench.py <before 目录> <after 目录>
"""
import re
import sys
from pathlib import Path

# 关注的键：文件 -> [(显示名, 正则)]
WATCH = {
    "cpu.txt": [
        ("CPU governor(little)", r"policy0 governor=(\S+)"),
        ("CPU governor(big)", r"policy6 governor=(\S+)"),
    ],
    "memory.txt": [
        ("MemFree", r"MemFree:\s+(\d+) kB"),
        ("MemAvailable", r"MemAvailable:\s+(\d+) kB"),
        ("Cached", r"^Cached:\s+(\d+) kB"),
        ("SwapFree", r"SwapFree:\s+(\d+) kB"),
        ("SwapCached", r"SwapCached:\s+(\d+) kB"),
        ("zram comp_algorithm", r"^comp_algorithm\s+(.*)$"),
        ("vm.swappiness", r"^vm\.swappiness\s+(\d+)"),
        ("vm.vfs_cache_pressure", r"^vm\.vfs_cache_pressure\s+(\d+)"),
        ("vm.dirty_writeback_centisecs", r"^vm\.dirty_writeback_centisecs\s+(\d+)"),
        ("vm.dirty_expire_centisecs", r"^vm\.dirty_expire_centisecs\s+(\d+)"),
        ("vm.min_free_kbytes", r"^vm\.min_free_kbytes\s+(\d+)"),
        ("PSI cpu some avg60", r"cpu\nsome avg10=\S+ avg60=(\S+)"),
        ("PSI mem full avg60", r"memory\nsome avg10=\S+ avg60=\S+ avg300=\S+ total=\d+\nfull avg10=\S+ avg60=(\S+)"),
        ("PSI io full avg60", r"io\nsome avg10=\S+ avg60=\S+ avg300=\S+ total=\d+\nfull avg10=\S+ avg60=(\S+)"),
    ],
    "storage.txt": [
        ("sda scheduler", r"sda\s+sched=\[\[?([a-z-]+)\]?"),
        ("sda read_ahead_kb", r"sda\s+.*read_ahead_kb=(\d+)"),
    ],
    "processes.txt": [
        ("进程总数", r"# 进程总数:\s+(\d+)"),
        ("线程总数", r"# 线程总数:\s+(\d+)"),
        ("已注册服务数", r"# 已注册服务数\s*\n?(\d+)"),
        ("JobService 数", r"# 已注册 JobService 数\s*\n?(\d+)"),
    ],
    "packages.txt": [
        ("全部包", r"# 全部包:\s+(\d+)"),
        ("已禁用", r"# 已禁用:\s+(\d+)"),
    ],
    "settings.txt": [
        ("window_animation_scale", r"^window_animation_scale\s+(\S+)"),
        ("transition_animation_scale", r"^transition_animation_scale\s+(\S+)"),
        ("animator_duration_scale", r"^animator_duration_scale\s+(\S+)"),
    ],
    "network.txt": [
        ("tcp_congestion_control", r"current:\s+(\S+)"),
        ("tcp_slow_start_after_idle", r"net\.ipv4\.tcp_slow_start_after_idle\s+(\S+)"),
        ("tcp_fastopen", r"net\.ipv4\.tcp_fastopen\s+(\S+)"),
        ("tcp_fin_timeout", r"net\.ipv4\.tcp_fin_timeout\s+(\S+)"),
        ("tcp_max_syn_backlog", r"net\.ipv4\.tcp_max_syn_backlog\s+(\S+)"),
    ],
    "logs.txt": [
        ("logd main buffer", r"main: ring buffer is (\S+ \S+)"),
    ],
}

# 另有独立采集的指标（不在 bench 快照里）
EXTRA = [
    ("/data/log 占用", "225 MB", "47 MB"),
    ("百度日志写入速率", "约 1.09 GB/天", "0 B/天"),
]


def load(d: Path):
    data = {}
    for fn, keys in WATCH.items():
        text = (d / fn).read_text(encoding="utf-8", errors="replace") if (d / fn).exists() else ""
        for label, pat in keys:
            m = re.search(pat, text, re.M)
            data[label] = m.group(1) if m else "—"
    return data


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    before, after = Path(sys.argv[1]), Path(sys.argv[2])
    b, a = load(before), load(after)

    print(f"{'指标':<32} {'优化前':>16} {'优化后':>16}  变化")
    print("-" * 80)
    same = diff = 0
    for label, _ in [(l, p) for k in WATCH.values() for l, p in k]:
        bv, av = b.get(label, "—"), a.get(label, "—")
        if bv == av:
            mark = ""
            same += 1
        else:
            mark = "→ 改变"
            diff += 1
        print(f"{label:<32} {bv:>16} {av:>16}  {mark}")
    for label, bv, av in EXTRA:
        print(f"{label:<32} {bv:>16} {av:>16}  → 改变")
    print("-" * 80)
    print(f"共 {same + diff} 项，其中 {diff} 项发生变化")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
