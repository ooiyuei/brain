---
type: department-readme
dept_code: 04_sales_mkt_cs
dept_name: 営業マーケCS部
director: marketer
openclaw_tag: marketing
updated: 2026-05-27
---

# 04_sales_mkt_cs — 営業マーケCS部 (THE MODEL)

## 責務
THE MODEL の4ファネル全部。リード獲得 → 商談 → クロージング → CS。LP/X/note/SEO の制作も全部ここ。

## 部長 & 部下
- **部長**: `marketer` (案件次第で `sales-rep` も部長代行)
- ファネル1 (リード): `marketer` (SEO/コンテンツ/広告/SNS/LP)
- ファネル2-3 (商談): `sales-rep` (商談準備/提案/日程/クロージング)
- ファネル4 (CS): `customer-success` (オンボ/解約防止/アップセル)
- 戦略アドバイザー: `morioka-strategist` (森岡フレーム適用)

## OpenClaw タグ
`marketing` (qwen3.6 へ「LP草稿」「Twitter原稿20本」「SEO本文」「メール草稿」を委任)

## 主要MCP
- Gmail (アウトリーチ・問い合わせ)
- Calendar (商談スケジュール)
- Stripe (売上・サブスク)
- Slack (社内コミュ)
- Notion (顧客カード)
- Fireflies (商談議事録)
- Zoom (会議)

## このフォルダの構成
- `_log.md` — 部署日報
- `leads/` — ファネル1: リード (未接触見込み客)
- `pipeline/` — ファネル2-3: 商談中
- `customers/` — ファネル4: 既存顧客
- `lp/` — LP 草稿 (Phase 2-C で `wiki/marketing/lp` から移動)
- `content/` — X/note/SEO 記事
- `proposals/` — 提案書

## 連携
- ← 02_newbiz: PRD完成後のLP草稿・モニター獲得依頼
- ← 07_research: 競合分析・市場シグナル
- → 05_corp: 契約書・請求書発行
- → 03_dev: フィードバック・要望

## 関連スキル
- `/team-proposal` — クライアント向け提案書チーム
- `morioka-probability-strategy` — 森岡確率思考フレーム
