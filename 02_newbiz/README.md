---
type: department-readme
dept_code: 02_newbiz
dept_name: 新規事業部
director: venture-director
openclaw_tag: newbiz
updated: 2026-05-27
---

# 02_newbiz — 新規事業部

## 責務
新規事業の発案から PRD・MVP 実装までの全工程。Go/Hold/Kill 判断を venture-director が下す。

## 部長 & 部下
- **部長**: `venture-director` (Sonnet 4.6)
- アイデア生成: `idea-generator`
- ブラッシュアップ: `business-refiner`
- 評価: `judge` (7-10軸採点)
- RedTeam: `red-team-reviewer` (盲点指摘)
- 仕様化: `product-spec-writer` (PRD作成)
- 実装: `builder` (MVP実装、コードは各appリポへ)

## 標準フロー (W1: 新規事業フルフロー)
```
1. idea-generator → 30案出す
2. /idea-judge skill → 10項目採点・tier判定
3. business-refiner → 磨く
4. red-team-reviewer → 穴を探す
5. /prd skill → PRD化
6. /team-design skill → 設計チーム起動
7. 03_dev (開発部) へハンドオフ
```

## OpenClaw タグ
`newbiz` (qwen3.6 へ「アイデアカード化」「PRD章別初稿」を委任)

## 主要MCP
- Notion (アイデアDB)
- Linear (PRD後の issue作成)
- Stripe (収益試算)

## このフォルダの構成
- `_log.md` — 部署日報
- `pipeline/` — Phase 2-C で `wiki/_pipeline/1_seeded〜5_prd` を移動
- `ideas/` — 採点済みアイデアカード
- `prds/` — PRD 完成版
- `prospects/` — 顧客候補リスト
- `handoff/` — 他部署 (主に03_dev) へのハンドオフ

## 連携
- → 03_dev: PRD 完成後の実装ハンドオフ
- → 04_sales_mkt_cs: モニター獲得・LP草稿依頼
- ← 07_research: 競合分析・市場シグナル
- ← _qa: red-team-reviewer による品質保証

## 関連スキル
- `/idea-judge` — 10項目採点
- `/prd` — PRD生成
- `/team-planning` `/team-design` `/team-dev` `/team-qa` — 4フェーズチーム
