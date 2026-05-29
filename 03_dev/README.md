---
type: department-readme
dept_code: 03_dev
dept_name: 開発部
director: architect
openclaw_tag: dev
updated: 2026-05-27
---

# 03_dev — 開発部

## 責務
PRDから実装、ビルド、テスト、リリースまで。実コードは各appリポ (`~/business/アプリ/{project}/`) に書く。brain には設計・レビュー・進捗のみ。

## 部長 & 部下
- **部長**: `architect` (Sonnet 4.6)
- 計画: `planner`
- 実装: `developer`
- TDD: `tdd-guide`
- ビルド修復: `build-error-resolver`, `kotlin-build-resolver`
- E2E: `e2e-runner`
- リファクタ: `refactor-cleaner`
- ドキュメント: `doc-updater`
- リリース判定: `release-manager`

## OpenClaw タグ
`dev` (qwen3.6 へ「README章別」「APIドキュメント」を委任)

## 主要MCP
- GitHub (`gh` CLI)
- Linear (issue管理)
- Vercel (デプロイ)
- Supabase (DB)
- Sentry (エラー監視)
- Figma (デザイン参照)

## このフォルダの構成
- `_log.md` — 部署日報
- `projects/` — `brain/10_projects/` (既存) と連携。プロジェクト別の設計ドキュメント
- `builds/` — ビルドエラー履歴・解決ログ
- `reviews/` — コードレビュー結果
- `docs/` — APIドキュメント・README 草稿

## 連携
- ← 02_newbiz: PRD完成後のハンドオフ
- → _qa: code/kotlin/python/database/security レビュアーへ
- → 04_sales_mkt_cs: リリース後のマーケ連携

## アクティブプロジェクト
- Testall — `~/business/アプリ/testall/` localhost:3010
- 他14プロダクト企画中 ([[10_projects/]])
