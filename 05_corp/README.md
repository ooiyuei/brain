---
type: department-readme
dept_code: 05_corp
dept_name: コーポレート部
director: cfo
openclaw_tag: corp
updated: 2026-05-27
---

# 05_corp — コーポレート部

## 責務
財務・法務・人事。会社の足場を作る。

## 部長 & 部下
- **部長**: `cfo` (P/L管理、請求、キャッシュフロー、バリュエーション試算、EXIT準備)
- リーガル: `legal` (契約書、利用規約、プライバシーポリシー、M&A DD)
- HR: `hr-recruiter` (外注、フリーランス採用、チーム構築)

## OpenClaw タグ
`corp` (qwen3.6 へ「数値表整形」「契約条項の平易化」を委任)

## 主要MCP
- Stripe (売上・サブスク・請求)
- Supabase (DB、必要に応じて)
- Gmail (請求書送信)
- Notion (HR管理・契約管理)

## このフォルダの構成
- `_log.md` — 部署日報
- `finance/` — P/L、キャッシュフロー、バリュエーション
- `legal/` — 契約書、利用規約、プライバシーポリシー
- `hr/` — 採用、外注、チーム
- `infra/` — brain運用ログ、Scheduled Tasks、ハーネス設定

## 連携
- ← 04_sales_mkt_cs: 売上情報、契約依頼
- → 02_newbiz: 収益試算
- → 06_secretary: 大井宛の重要書類

## 月次ルーティン
- 月初: P/L 締め、Stripe MCPで売上集計
- 月末: バリュエーション再試算、キャッシュ残月確認
