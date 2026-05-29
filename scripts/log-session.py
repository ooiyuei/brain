#!/usr/bin/env python3
"""Cross-platform Claude Code hook logger.

Handles 4 hook events from Claude Code, writing to brain/wiki/:
- SessionStart      → wiki/_log/sessions.jsonl + brief append to daily/
- UserPromptSubmit  → wiki/_conversations/YYYY-MM-DD/HHMMSS-{sid}-prompt.md
                      + wiki/_log/conversations.jsonl
- PostToolUse       → wiki/_log/operations.jsonl  (Edit/Write/MultiEdit only)
- Stop              → wiki/daily/YYYY-MM-DD.md   + wiki/_log/sessions.jsonl

The raw user prompts saved by UserPromptSubmit are the "uncompressed truth" —
preserved verbatim before any context compression / conversation summarization.

Wired via ~/.claude/settings.local.json on each machine.
"""

import json
import os
import re
import socket
import sys
from datetime import datetime, timezone
from pathlib import Path


def _safe_slug(text: str, limit: int = 40) -> str:
    text = text.encode("utf-8", errors="ignore").decode("utf-8", errors="ignore")
    text = re.sub(r"[\r\n\t]+", " ", text).strip()
    text = re.sub(r"[^\w぀-ゟ゠-ヿ一-鿿ー-]+", "-", text)
    text = re.sub(r"-+", "-", text).strip("-")
    return text[:limit] or "untitled"


def main() -> int:
    raw_bytes = sys.stdin.buffer.read() if hasattr(sys.stdin, "buffer") else sys.stdin.read().encode("utf-8", errors="replace")
    if isinstance(raw_bytes, bytes):
        raw = raw_bytes.decode("utf-8", errors="replace")
    else:
        raw = raw_bytes
    if not raw.strip():
        return 0

    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        return 0

    event = data.get("hook_event_name", "")
    session_id = data.get("session_id") or "unknown"
    cwd = data.get("cwd") or "unknown"

    brain = Path.home() / "business" / "brain"
    now = datetime.now()
    date = now.strftime("%Y-%m-%d")
    time_str = now.strftime("%H:%M")
    timestamp = datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")
    host = socket.gethostname()
    session_short = session_id[:8] if len(session_id) >= 8 else session_id

    log_dir = brain / "wiki" / "_log"
    daily_dir = brain / "wiki" / "daily"
    conv_dir = brain / "wiki" / "_conversations" / date
    log_dir.mkdir(parents=True, exist_ok=True)
    daily_dir.mkdir(parents=True, exist_ok=True)

    daily_file = daily_dir / f"{date}.md"
    if not daily_file.exists():
        daily_file.write_text(
            f"# {date} 日報\n\ntags: daily-log\n\n## セッション履歴\n",
            encoding="utf-8",
        )

    if event == "SessionStart":
        source = data.get("source", "unknown")
        with daily_file.open("a", encoding="utf-8") as f:
            f.write(
                f"\n### {time_str} セッション開始 (id: {session_short}, source: {source})\n"
                f"- cwd: `{cwd}`\n- host: {host}\n"
            )
        with (log_dir / "sessions.jsonl").open("a", encoding="utf-8") as f:
            f.write(
                json.dumps(
                    {
                        "ts": timestamp,
                        "event": "SessionStart",
                        "session_id": session_id,
                        "cwd": cwd,
                        "host": host,
                        "source": source,
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
        return 0

    if event == "UserPromptSubmit":
        prompt = data.get("prompt", "")
        if not prompt:
            return 0

        conv_dir.mkdir(parents=True, exist_ok=True)
        hhmmss = now.strftime("%H%M%S")
        slug = _safe_slug(prompt.splitlines()[0] if prompt else "untitled", 30)
        conv_file = conv_dir / f"{hhmmss}-{session_short}-{slug}.md"

        body = (
            f"---\n"
            f"ts: {timestamp}\n"
            f"session_id: {session_id}\n"
            f"cwd: {cwd}\n"
            f"host: {host}\n"
            f"event: UserPromptSubmit\n"
            f"chars: {len(prompt)}\n"
            f"tags: [conversation, raw-prompt]\n"
            f"---\n\n"
            f"# 発話 {date} {time_str}\n\n"
            f"```\n{prompt}\n```\n"
        )
        conv_file.write_text(body, encoding="utf-8")

        with (log_dir / "conversations.jsonl").open("a", encoding="utf-8") as f:
            f.write(
                json.dumps(
                    {
                        "ts": timestamp,
                        "event": "UserPromptSubmit",
                        "session_id": session_id,
                        "cwd": cwd,
                        "chars": len(prompt),
                        "file": str(conv_file.relative_to(brain)).replace("\\", "/"),
                        "first_line": prompt.splitlines()[0][:120] if prompt else "",
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
        return 0

    if event == "PostToolUse":
        tool_name = data.get("tool_name", "")
        if tool_name not in ("Edit", "Write", "MultiEdit", "NotebookEdit"):
            return 0
        file_path = (data.get("tool_input") or {}).get("file_path", "")
        if not file_path:
            return 0
        with (log_dir / "operations.jsonl").open("a", encoding="utf-8") as f:
            f.write(
                json.dumps(
                    {
                        "ts": timestamp,
                        "event": "PostToolUse",
                        "tool": tool_name,
                        "file": file_path,
                        "session_id": session_id,
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
        return 0

    if event == "Stop":
        with daily_file.open("a", encoding="utf-8") as f:
            f.write(
                f"\n### {time_str} セッション終了 (id: {session_short})\n"
                f"- cwd: `{cwd}`\n- host: {host}\n"
            )
        with (log_dir / "sessions.jsonl").open("a", encoding="utf-8") as f:
            f.write(
                json.dumps(
                    {
                        "ts": timestamp,
                        "event": "Stop",
                        "session_id": session_id,
                        "cwd": cwd,
                        "host": host,
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
        return 0

    return 0


if __name__ == "__main__":
    sys.exit(main())
