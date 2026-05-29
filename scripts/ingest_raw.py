#!/usr/bin/env python3
"""Material ingestion orchestrator.

Scans ~/business/brain/.raw/ for unprocessed materials and:
1. Emits a processing manifest at brain/wiki/_inbox/ingest/{date}-manifest.md
   listing pending items so Claude can pick them up in-session.
2. For PDFs, optionally runs OCR via existing ocr_morioka.py (if installed).
3. For text/md, copies a sanitized snapshot to sources/raw/.

This script is intentionally minimal — the LLM-heavy steps (summarize,
concept extraction, project linking, skill candidate detection) are done
by Claude in-session, not by this script. We only handle file discovery
and routing so nothing gets lost in .raw/.

Usage:
    python ingest_raw.py            # scan and emit manifest
    python ingest_raw.py --status   # show what's pending vs processed

State is tracked in brain/scripts/.ingest_raw_state.json
"""

import argparse
import hashlib
import json
import shutil
import sys
from datetime import datetime
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")


BRAIN = Path.home() / "business" / "brain"
RAW = BRAIN / ".raw"
INBOX = BRAIN / "wiki" / "_inbox" / "ingest"
SOURCES_RAW = BRAIN / "wiki" / "sources" / "raw"
STATE = BRAIN / "scripts" / ".ingest_raw_state.json"

SUPPORTED_EXTS = {".pdf", ".txt", ".md", ".html", ".json", ".csv", ".docx"}


def _hash(p: Path) -> str:
    h = hashlib.sha1()
    try:
        with p.open("rb") as f:
            while chunk := f.read(65536):
                h.update(chunk)
    except OSError:
        return ""
    return h.hexdigest()[:16]


def _load_state() -> dict:
    if STATE.exists():
        try:
            return json.loads(STATE.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            pass
    return {"processed": {}}


def _save_state(state: dict) -> None:
    STATE.parent.mkdir(parents=True, exist_ok=True)
    STATE.write_text(
        json.dumps(state, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def _enumerate_raw() -> list[dict]:
    items = []
    if not RAW.exists():
        return items
    for p in RAW.rglob("*"):
        if not p.is_file():
            continue
        if p.suffix.lower() not in SUPPORTED_EXTS:
            continue
        try:
            rel = p.relative_to(RAW)
        except ValueError:
            continue
        items.append(
            {
                "path": str(p),
                "rel": str(rel).replace("\\", "/"),
                "ext": p.suffix.lower(),
                "size_kb": round(p.stat().st_size / 1024, 1),
                "mtime": datetime.fromtimestamp(p.stat().st_mtime).isoformat(timespec="seconds"),
                "hash": _hash(p),
            }
        )
    return items


def _write_manifest(pending: list[dict]) -> Path:
    INBOX.mkdir(parents=True, exist_ok=True)
    today = datetime.now().strftime("%Y-%m-%d-%H%M")
    manifest = INBOX / f"{today}-manifest.md"

    lines = [
        "---",
        f"created: {datetime.now().isoformat(timespec='seconds')}",
        "type: ingestion-manifest",
        "tags: [ingest, inbox, pending]",
        "---",
        "",
        f"# 取り込み待ち {len(pending)} 件 ({today})",
        "",
        "> Claude へ: このファイルを開いた瞬間、各アイテムをパイプ全段 (要約・概念抽出・関連紐付け・スキル候補判定) で処理する。",
        "> 処理後、該当アイテムをこの manifest から `[x]` でチェックし、結果ファイルへの [[link]] を併記。",
        "",
        "## パイプ手順 (`brain/CLAUDE.md` の素材取り込みフロー参照)",
        "",
        "各アイテムに対し:",
        "1. テキスト抽出 (PDF → md)",
        "2. 全文サマリ → `sources/YYYY-MM-DD-{slug}.md`",
        "3. 概念抽出 → `concepts/{slug}.md` 新規 or 既存追記",
        "4. 関連プロジェクト紐付け → `10_projects/{name}.md` に [[link]]",
        "5. 大井向け適用案 5-10本 → `meta/{topic}-actions-for-ooi-{date}.md`",
        "6. 繰り返し使う型なら → `skills/{slug}/SKILL.md` boilerplate",
        "7. `hot.md` 新着インテリに 1行追加",
        "",
        "## アイテム一覧",
        "",
    ]

    for it in pending:
        lines.append(f"### [ ] `{it['rel']}` ({it['ext']}, {it['size_kb']}KB)")
        lines.append(f"- フルパス: `{it['path']}`")
        lines.append(f"- mtime: {it['mtime']}")
        lines.append(f"- hash: `{it['hash']}`")
        lines.append("- 処理結果: (Claude が処理後にここへ [[link]] を入れる)")
        lines.append("")

    manifest.write_text("\n".join(lines), encoding="utf-8")
    return manifest


def cmd_scan() -> int:
    state = _load_state()
    processed = state["processed"]

    all_items = _enumerate_raw()
    pending = [it for it in all_items if it["hash"] and it["hash"] not in processed]

    if not pending:
        print(f"no pending items ({len(all_items)} total in .raw/, all processed)")
        return 0

    manifest = _write_manifest(pending)
    print(f"manifest written: {manifest}")
    print(f"pending: {len(pending)} / total: {len(all_items)}")
    for it in pending[:10]:
        print(f"  - {it['rel']} ({it['size_kb']}KB)")
    if len(pending) > 10:
        print(f"  ... +{len(pending) - 10} more")

    SOURCES_RAW.mkdir(parents=True, exist_ok=True)
    return 0


def cmd_status() -> int:
    state = _load_state()
    processed = state["processed"]
    all_items = _enumerate_raw()
    pending = [it for it in all_items if it["hash"] and it["hash"] not in processed]

    print(f"raw/    total: {len(all_items)}")
    print(f"processed: {len(processed)}")
    print(f"pending : {len(pending)}")
    return 0


def cmd_mark(args) -> int:
    state = _load_state()
    h = args.hash
    if not h:
        print("--hash required", file=sys.stderr)
        return 2
    state["processed"][h] = {
        "marked_at": datetime.now().isoformat(timespec="seconds"),
        "result_link": args.link or "",
    }
    _save_state(state)
    print(f"marked: {h}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="cmd")
    sub.add_parser("scan", help="scan .raw/ and write manifest (default)")
    sub.add_parser("status", help="show pending vs processed count")
    p_mark = sub.add_parser("mark", help="mark an item processed")
    p_mark.add_argument("--hash", required=True)
    p_mark.add_argument("--link", default="")
    args = parser.parse_args()

    if args.cmd in (None, "scan"):
        return cmd_scan()
    if args.cmd == "status":
        return cmd_status()
    if args.cmd == "mark":
        return cmd_mark(args)
    parser.print_help()
    return 0


if __name__ == "__main__":
    sys.exit(main())
