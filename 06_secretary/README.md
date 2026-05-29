---
type: department-readme
dept_code: 06_secretary
dept_name: 秘書室
director: secretary
openclaw_tag: secretary
updated: 2026-05-27
---

# 06_secretary — 秘書室

## 責務
大井専属。脳のメモリを空ける。長期目標から逆算して「今日・今週・今この時間に何をやるか」を決める。コミュニケーション (Email/Slack/LINE/Messenger) の triage。

## 部長 & 部下
- **部長**: `secretary` (大井のChief of Staff)
- 副官 (CEOと兼務): `chief-of-staff` (4tier triage: skip/info/meeting/action、ドラフト返信生成)

## OpenClaw タグ
`secretary` (qwen3.6 へ「議事録要約」「日報生成」「メール草稿」を委任)

## 主要MCP
- Gmail (受信トリアージ、ドラフト)
- Slack (read/send)
- Calendar (日程調整・suggest_time)
- Fireflies (議事録取得)
- Zoom (録画)
- LINE/Messenger (大井個人連絡、対応必要時)

## このフォルダの構成
- `_log.md` — 部署日報
- `todo/` — Phase 2-C で `wiki/_tasks/{today,inbox,done}` を移動
- `communications/` — MCP使用ログ (Gmail/Slack/Calendar の事実記録)
- `meetings/` — Fireflies/Zoom 議事録
- `handoff/` — 他部署への取り次ぎ

## 連携
- → 全部署: 大井からの取り次ぎ
- ← 全部署: 大井宛報告のフィルタリング・要約

## 朝/昼/夜ルーティン (Phase 2-D で自動化予定)
- 朝09:00 — `00_YUEI/TODAY.md` を埋める、Calendar/Gmail 確認
- 昼13:00 — PDCAレビュー (進捗確認、再調整)
- 夜22:00 — 日報生成、明日のTODAY 下準備
