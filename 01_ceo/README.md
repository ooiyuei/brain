---
type: department-readme
dept_code: 01_ceo
dept_name: 経営企画室
director: ceo-orchestrator
openclaw_tag: (none)
updated: 2026-05-27
---

# 01_ceo — 経営企画室

## 責務
大井 (YUEI) の発話を切り分けて部署に振る。Go/No-Go 判断。部長間調整。日次/週次 REPORT を `00_YUEI/REPORT.md` に生成。

## 部長 & 部下
- **部長**: `ceo-orchestrator` (Sonnet 4.6)
- **副官**: `chief-of-staff` (メール/Slack triage、日程調整)
- **インフラ最適化**: `harness-optimizer`

## OpenClaw タグ
なし (CEO は直接 dispatch しない。各部署部長を経由)

## 主要MCP
- 全MCP使用可能 (CEO は全領域を統括)
- 特に Calendar, Gmail, Slack, Notion, Linear

## このフォルダの構成
- `_log.md` — CEO 活動ログ (時刻付き)
- `ROLES.md` — 組織構造の正本
- `routing.md` — 大井発話→部署振り分け履歴
- `status-board.md` — 全部署横断ステータス (自動生成・Phase 2-D)
- `escalations.md` — 部長から CEO へのエスカレ
- `decisions/` — Go/No-Go 判断履歴 (日付ファイル)

## 連携
- → 全部署: タスク振り分け
- ← 全部署: 完了報告・エスカレ
- → YUEI: `00_YUEI/REPORT.md` で日次サマリー
