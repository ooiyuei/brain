#!/usr/bin/env python3
"""OpenClaw activity reporter.

Aggregates queue/ state and writes a snapshot to:
- brain/wiki/dashboards/openclaw-activity.md   (human-readable, overwritten)
- brain/wiki/_log/openclaw-snapshots.jsonl     (append-only history)

Run on-demand or schedule (e.g., every hour). Read from Mac or Win.

Usage:
    python openclaw_activity.py            # generate report
    python openclaw_activity.py --recent   # print last N entries to stdout
"""

import argparse
import json
import sys
from collections import Counter, defaultdict
from datetime import datetime, timedelta
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BRAIN = Path.home() / "business" / "brain"
QUEUE = BRAIN / "queue"
DASHBOARDS = BRAIN / "wiki" / "dashboards"
LOG_DIR = BRAIN / "wiki" / "_log"


def _count_dir(p: Path) -> int:
    return sum(1 for _ in p.glob("*")) if p.exists() else 0


def _read_job(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def _scan(stage: str, limit: int = None) -> list[dict]:
    p = QUEUE / stage
    if not p.exists():
        return []
    files = sorted(p.glob("*.json"))
    if limit:
        files = files[-limit:]
    out = []
    for f in files:
        j = _read_job(f)
        if j:
            j["_file"] = f.name
            j["_mtime"] = datetime.fromtimestamp(f.stat().st_mtime).isoformat(timespec="seconds")
            out.append(j)
    return out


def gen_report() -> Path:
    DASHBOARDS.mkdir(parents=True, exist_ok=True)
    LOG_DIR.mkdir(parents=True, exist_ok=True)

    inbox_n = _count_dir(QUEUE / "inbox")
    processing_n = _count_dir(QUEUE / "processing")
    done_n = _count_dir(QUEUE / "done")
    failed_n = _count_dir(QUEUE / "failed")

    inbox_sample = _scan("inbox", limit=200)
    done_recent = _scan("done", limit=100)
    failed_recent = _scan("failed", limit=20)

    dept_pending = Counter([j.get("department", "?") for j in inbox_sample])
    prio_pending = Counter([j.get("priority", "?") for j in inbox_sample])
    dept_done = Counter([j.get("department", "?") for j in done_recent])

    now = datetime.now()
    today = now.strftime("%Y-%m-%d")
    last24 = now - timedelta(hours=24)
    done_24h = [j for j in done_recent if j.get("_mtime", "") >= last24.isoformat(timespec="seconds")]

    lines = [
        "---",
        f"updated: {now.isoformat(timespec='seconds')}",
        "type: dashboard",
        "tags: [dashboard, openclaw, auto-generated]",
        "---",
        "",
        f"# OpenClaw 稼働状況 ({today})",
        "",
        "> 自動生成 (`brain/scripts/openclaw_activity.py`)。直近スナップショットのみ。",
        "",
        "## ⚡ 現在の状態",
        "",
        f"| ステージ | 件数 |",
        f"|---|---|",
        f"| inbox (待ち) | **{inbox_n}** |",
        f"| processing (実行中) | {processing_n} |",
        f"| done (累計完了) | {done_n} |",
        f"| failed (失敗) | {failed_n} |",
        "",
    ]

    if inbox_n > 200:
        lines += [
            "## 🚨 アラート",
            "",
            f"- inbox に **{inbox_n}** タスク滞留。worker.ps1 が追いついてない可能性。",
            "- 対処候補: ワーカーが起動しているか確認 (`Get-Process ollama`)、queue/inbox を部署別に確認、auto-review 系の自動投入を一時停止する",
            "",
        ]

    lines += [
        "## 部署別 滞留 (inbox サンプル 最新200)",
        "",
        "| 部署 | 件数 |",
        "|---|---|",
    ]
    for d, n in dept_pending.most_common():
        lines.append(f"| {d} | {n} |")
    lines.append("")

    lines += [
        "## 優先度別 滞留",
        "",
        "| 優先度 | 件数 |",
        "|---|---|",
    ]
    for pri, n in prio_pending.most_common():
        lines.append(f"| {pri} | {n} |")
    lines.append("")

    lines += [
        "## 直近24時間で done (サンプル)",
        "",
        f"- 完了: {len(done_24h)} 件",
        "",
        "| dept | title |",
        "|---|---|",
    ]
    for j in done_24h[:20]:
        lines.append(f"| {j.get('department','?')} | {j.get('title','?')[:80]} |")
    if len(done_24h) > 20:
        lines.append(f"| ... | +{len(done_24h) - 20} more |")
    lines.append("")

    if failed_recent:
        lines += [
            "## 直近 failed (最新20)",
            "",
            "| dept | title | mtime |",
            "|---|---|---|",
        ]
        for j in failed_recent:
            lines.append(
                f"| {j.get('department','?')} | {j.get('title','?')[:60]} | {j.get('_mtime','?')} |"
            )
        lines.append("")

    out = DASHBOARDS / "openclaw-activity.md"
    out.write_text("\n".join(lines), encoding="utf-8")

    snap = {
        "ts": now.isoformat(timespec="seconds"),
        "inbox": inbox_n,
        "processing": processing_n,
        "done": done_n,
        "failed": failed_n,
        "dept_pending": dict(dept_pending),
        "prio_pending": dict(prio_pending),
        "done_24h": len(done_24h),
    }
    with (LOG_DIR / "openclaw-snapshots.jsonl").open("a", encoding="utf-8") as f:
        f.write(json.dumps(snap, ensure_ascii=False) + "\n")

    return out


def cmd_recent(args) -> int:
    log = LOG_DIR / "openclaw-snapshots.jsonl"
    if not log.exists():
        print("no snapshots yet, run without --recent first")
        return 0
    n = args.n
    lines = log.read_text(encoding="utf-8").strip().splitlines()
    for line in lines[-n:]:
        try:
            j = json.loads(line)
            print(
                f"{j['ts']} | inbox={j['inbox']:>5} proc={j['processing']:>3} "
                f"done={j['done']:>6} fail={j['failed']:>3} done24h={j['done_24h']:>4}"
            )
        except Exception:
            print(line)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--recent", action="store_true", help="show recent snapshots")
    parser.add_argument("-n", type=int, default=20, help="snapshot history length")
    args = parser.parse_args()

    if args.recent:
        return cmd_recent(args)

    out = gen_report()
    print(f"report written: {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
