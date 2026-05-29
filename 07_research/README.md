---
type: department-readme
dept_code: 07_research
dept_name: リサーチ室
director: researcher
openclaw_tag: research
updated: 2026-05-27
---

# 07_research — リサーチ室

## 責務
市場調査、技術調査、競合分析、ビジコン情報、トレンド。根拠付きレポートを生成。朝の市場シグナル偵察。

## 部長 & 部下
- **部長**: `researcher` (根拠付きレポート)
- 偵察: `scout` (毎朝の定期調査、競合動向・顧客不満・法規制変化)
- ドキュメント参照: `docs-lookup` (Context7 経由のライブラリドキュメント取得)

## OpenClaw タグ
`research` (qwen3.6 へ「競合5社調査」「市場シグナル集約」を委任)

## 主要MCP
- WebSearch / WebFetch (公開情報)
- Context7 (技術ドキュメント)
- Notion (調査結果DB化)
- Sentry/Vercel/Linear (自社プロダクトのメタ調査)

## このフォルダの構成
- `_log.md` — 部署日報
- `competitors/` — Phase 2-C で `wiki/research/competitors/` から移動
- `contests/` — Phase 2-C で `wiki/research/contests/` から移動 (ビジコン132件)
- `trends/` — 市場/技術トレンド
- `monitors/` — Phase 2-C で `wiki/_monitor/` から移動 (朝08:30 監視結果)
- `reports/` — 統合レポート

## 連携
- → 02_newbiz: 新事業の市場性検証
- → 04_sales_mkt_cs: 競合の動向・営業材料
- ← scout: 朝の自動偵察結果

## 朝の定期調査 (Phase 2-D で再有効化)
- 競合動向 / 市場シグナル / ビジコン締切 / プロジェクト動向 / 朝の問い
