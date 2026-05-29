#!/usr/bin/env python3
"""Cross-platform OpenClaw dispatcher.

Python port of dispatch.ps1. Writes a job spec to
~/business/brain/queue/inbox/ in the same JSON shape that worker.ps1
expects. Works on Mac and Windows.

On Mac, files written here are delivered to the home PC via Obsidian Sync,
where the always-on worker.ps1 picks them up and processes via Ollama.

Usage:
    python dispatch.py \
        --department research \
        --title "競合: Notion" \
        --prompt "Notion競合分析" \
        --priority normal

    python dispatch.py --status   # list recent dispatch activity

Departments:
    research / newbiz / dev / marketing / corp / secretary / misc

Priorities:
    super=0 / high=1 / normal=5 / low=9   (lower digit = processed first)
"""

import argparse
import json
import os
import re
import sys
import uuid
from datetime import datetime
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")


BRAIN = Path.home() / "business" / "brain"
INBOX = BRAIN / "queue" / "inbox"
TEMPLATES = BRAIN / "scripts" / "templates"
PREFIX_PATH = BRAIN / "scripts" / "prompt-prefix.md"
ENTITIES_DIR = BRAIN / "wiki" / "entities"

DEPARTMENTS = {"research", "newbiz", "dev", "marketing", "corp", "secretary", "misc"}
PRIORITY_DIGITS = {"super": "0", "high": "1", "normal": "5", "low": "9"}


def _load_prefix() -> str:
    if not PREFIX_PATH.exists():
        return ""
    text = PREFIX_PATH.read_text(encoding="utf-8")
    today = datetime.now()
    iso = today.strftime("%Y-%m-%d")
    week = today.strftime("%Y") + f"-W{int(today.strftime('%U')) + 1:02d}"
    month = today.strftime("%Y-%m")
    return (
        text.replace("{TODAY_ISO}", iso)
        .replace("{TODAY_WEEK}", week)
        .replace("{TODAY_MONTH}", month)
    )


def _auto_attach_entities(prompt: str, manual_ctx: list[str]) -> list[str]:
    pattern = re.compile(r"\[\[entities/([a-zA-Z0-9\-_]+)(\|[^\]]*)?\]\]")
    seen = set(manual_ctx)
    auto = []
    for m in pattern.finditer(prompt):
        name = m.group(1)
        path = ENTITIES_DIR / f"{name}.md"
        if path.exists() and str(path) not in seen:
            auto.append(str(path))
            seen.add(str(path))
    return manual_ctx + auto


def cmd_dispatch(args) -> int:
    if args.department not in DEPARTMENTS:
        print(f"error: department must be one of {sorted(DEPARTMENTS)}", file=sys.stderr)
        return 2

    INBOX.mkdir(parents=True, exist_ok=True)

    prompt = args.prompt
    if args.prompt_file:
        prompt = Path(args.prompt_file).read_text(encoding="utf-8")

    final_prompt = prompt
    if args.template:
        tpl = TEMPLATES / args.department / f"{args.template}.md"
        if tpl.exists():
            final_prompt = tpl.read_text(encoding="utf-8") + "\n\n# 依頼内容\n" + prompt
        else:
            print(f"warning: template not found: {tpl}", file=sys.stderr)

    auto_skip = len(prompt) < 200
    prefix = _load_prefix()
    if prefix and not args.skip_prefix and not auto_skip:
        final_prompt = prefix + "\n\n" + final_prompt

    context_files = list(args.context_file or [])
    context_files = _auto_attach_entities(final_prompt, context_files)

    task_id = uuid.uuid4().hex[:8]
    output_path = args.output_path or str(
        BRAIN / "queue" / "results" / args.department / f"{task_id}.md"
    )

    prio_digit = PRIORITY_DIGITS[args.priority]
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S-") + f"{datetime.now().microsecond // 1000:03d}"
    file_name = f"{prio_digit}-{stamp}-{task_id}.json"
    task_path = INBOX / file_name

    job = {
        "id": task_id,
        "title": args.title,
        "department": args.department,
        "template": args.template or "",
        "model": args.model,
        "priority": args.priority,
        "use_agent": args.use_agent,
        "prompt": final_prompt,
        "context_files": context_files,
        "output_path": output_path,
        "retries": 0,
        "created_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "requested_by": args.requested_by,
    }

    task_path.write_text(json.dumps(job, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"[{args.department}/{args.priority}] {args.title} -> {task_id}")
    print(f"  inbox : {task_path}")
    print(f"  output: {output_path}")
    print(f"  ctx   : {len(context_files)} files")
    return 0


def cmd_status(args) -> int:
    queue_root = BRAIN / "queue"
    sections = [
        ("inbox", queue_root / "inbox"),
        ("processing", queue_root / "processing"),
        ("done", queue_root / "done"),
        ("failed", queue_root / "failed"),
    ]
    for name, p in sections:
        n = sum(1 for _ in p.glob("*")) if p.exists() else 0
        print(f"queue/{name}: {n}")
    print()
    inbox_files = sorted((queue_root / "inbox").glob("*.json")) if (queue_root / "inbox").exists() else []
    if inbox_files:
        print(f"pending in inbox ({len(inbox_files)}):")
        for f in inbox_files[:10]:
            try:
                j = json.loads(f.read_text(encoding="utf-8"))
                print(f"  - [{j.get('priority','?')}] {j.get('department','?')} | {j.get('title','?')[:60]}")
            except Exception:
                print(f"  - {f.name} (parse error)")
        if len(inbox_files) > 10:
            print(f"  ... +{len(inbox_files) - 10} more")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="cmd", required=False)

    p_d = sub.add_parser("dispatch", help="enqueue a job (default)")
    p_d.add_argument("--department", required=True, choices=sorted(DEPARTMENTS))
    p_d.add_argument("--title", required=True)
    p_d.add_argument("--prompt", default="")
    p_d.add_argument("--prompt-file", default="")
    p_d.add_argument("--template", default="")
    p_d.add_argument("--context-file", action="append", default=[])
    p_d.add_argument("--output-path", default="")
    p_d.add_argument("--model", default="qwen3.6:latest")
    p_d.add_argument("--priority", default="normal", choices=list(PRIORITY_DIGITS))
    p_d.add_argument("--skip-prefix", action="store_true")
    p_d.add_argument("--use-agent", action="store_true")
    p_d.add_argument("--requested-by", default="claude-agent-py")

    sub.add_parser("status", help="show queue status")

    args = parser.parse_args()

    if args.cmd == "dispatch" or args.cmd is None and getattr(args, "department", None):
        if not args.prompt and not args.prompt_file:
            print("error: --prompt or --prompt-file required", file=sys.stderr)
            return 2
        return cmd_dispatch(args)
    if args.cmd == "status":
        return cmd_status(args)

    parser.print_help()
    return 0


if __name__ == "__main__":
    sys.exit(main())
