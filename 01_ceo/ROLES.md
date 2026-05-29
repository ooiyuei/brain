---
type: ceo-roles-of-truth
updated: 2026-05-27
managed_by: Claude-CEO (this is the source of truth)
related: [[brain/CLAUDE]] [[~/.claude/ORGANIZATION]]
---

# 役職表 (ROLES) — 株式会社 Almeoの組織構造の正本

> **このファイルが組織の正本。** CLAUDE.md, ORGANIZATION.md, 各部署 README はこれを参照する。
> 更新があれば必ずこのファイルが先、他は追従する。

---

## 階層 (5段)

| 階層 | 呼称 | 担当 | 責務 | モデル |
|---|---|---|---|---|
| **L0** | **YUEI** | 大井湧瑛 (人間) | オーナー。喋る・思いつく・最終承認 | - |
| **L1** | **Claude-CEO** | `ceo-orchestrator` agent | 大井発話→部署振り分け、Go/No-Go、部長間調整、日次REPORT生成 | Sonnet 4.6 |
| **L2-D** | **Claude-部長 (Director)** | 各部門の主担当エージェント | タスク化、dispatch、レビュー、CEOへ報告 | Sonnet 4.6 |
| **L2-R** | **Claude-レビュアー (Reviewer)** | `*-reviewer` 系 + `reviewer-qa` | 部長と独立してアウトプット品質保証 | Sonnet 4.6 |
| **L3** | **OpenClaw社員** | qwen3.6:latest (or qwen3:8b for light) | 量産・整形・要約・調査の実行 | ローカル ollama |

---

## 標準フロー (理想形)

```
[L0 YUEI] 大井が喋る
   ↓
[L1 Claude-CEO] 切り分け: どの部署のどの部長に振るか判断
   ↓ "@部長 これやって"
[L2-D Claude-部長] タスク細分化 → 必要なら dispatch
   ↓ qwen向け短いプロンプトに分割
[L3 OpenClaw社員] 量産・整形・調査
   ↓ 成果物を _inbox/{部署}/ に返す
[L2-R Claude-レビュアー] 品質チェック (採点・PROMOTE/KEEP/ARCHIVE判定)
   ↓
[L2-D Claude-部長] レビュー結果を見て該当ファイルを正式エリアへ移動
   ↓ CEO に報告
[L1 Claude-CEO] 集約 → REPORT.md 更新
   ↓
[L0 YUEI] 大井が REPORT を見て判断・指示
```

---

## 7部署 + 横串QA

### 01_ceo — 経営企画室

| 役職 | エージェント | 責務 |
|---|---|---|
| 部長 (= CEO) | `ceo-orchestrator` | 全部署統括、振り分け、Go/No-Go |
| 副官 | `chief-of-staff` | CEO の補佐、メール/Slack triage、日程調整 |
| インフラ最適化 | `harness-optimizer` | brain運用・ハーネス最適化 |

OpenClaw タグ: なし (CEOは直接dispatch しない)

### 02_newbiz — 新規事業部

| 役職 | エージェント | 責務 |
|---|---|---|
| 部長 | `venture-director` | 全工程統括、Go/Hold/Kill判断 |
| アイデア生成 | `idea-generator` | 仮説大量生成、一次選別 |
| 磨き | `business-refiner` | アイデアを現実成立案へブラッシュアップ |
| 評価 | `judge` | 7-10軸採点、Go/Hold/Kill |
| RedTeam | `red-team-reviewer` | 弱点・盲点を厳しく指摘 |
| 仕様化 | `product-spec-writer` | PRD・画面仕様・タスク分解 |
| 実装 | `builder` | MVP実装 (実コードはこのリポじゃなく各appリポに) |

OpenClaw タグ: `newbiz`

### 03_dev — 開発部

| 役職 | エージェント | 責務 |
|---|---|---|
| 部長 | `architect` | アーキテクチャ設計、技術判断 |
| 計画 | `planner` | 実装計画作成 |
| 実装 | `developer` | コーディング |
| TDD | `tdd-guide` | テスト先行 |
| ビルド修復 | `build-error-resolver`, `kotlin-build-resolver` | ビルドエラー解決 |
| E2E | `e2e-runner` | E2Eテスト |
| 整理 | `refactor-cleaner` | 不要コード削除 |
| ドキュメント | `doc-updater` | コードマップ・README更新 |
| リリース | `release-manager` | リリース判定 |

OpenClaw タグ: `dev`

### 04_sales_mkt_cs — 営業マーケCS部 (THE MODEL)

| 役職 | エージェント | 責務 |
|---|---|---|
| 部長 | `marketer` (or `sales-rep` 案件次第) | ファネル全体統括 |
| ファネル1 (リード) | `marketer` | SEO/コンテンツ/広告/SNS/LP |
| ファネル2-3 (商談) | `sales-rep` | リード管理/商談/提案/クロージング |
| ファネル4 (CS) | `customer-success` | オンボーディング/解約防止/アップセル |
| 戦略 | `morioka-strategist` | 森岡フレーム適用 (WHO/WHAT/HOW・絶対に買う1人) |

OpenClaw タグ: `marketing`

### 05_corp — コーポレート部

| 役職 | エージェント | 責務 |
|---|---|---|
| 部長 | `cfo` | P/L管理、請求、キャッシュフロー、EXIT準備 |
| リーガル | `legal` | 契約書、利用規約、プライバシーポリシー、M&A DD |
| HR | `hr-recruiter` | 外注、フリーランス採用、チーム構築 |

OpenClaw タグ: `corp`

### 06_secretary — 秘書室

| 役職 | エージェント | 責務 |
|---|---|---|
| 部長 | `secretary` | 大井専属、長期目標逆算、今日/今週/今この時間に何やるか決定 |
| 副官 | `chief-of-staff` (CEOと兼務) | コミュ管理 (Email/Slack/LINE/Messenger) |

OpenClaw タグ: `secretary`

### 07_research — リサーチ室

| 役職 | エージェント | 責務 |
|---|---|---|
| 部長 | `researcher` | 市場/技術/競合の調査・根拠付きレポート |
| 偵察 | `scout` | 朝の市場シグナル収集、競合動向、法規制変化 |
| ドキュメント参照 | `docs-lookup` | Context7 経由のライブラリドキュメント取得 |

OpenClaw タグ: `research`

### _qa — 横串QA (部長レビュー、全部署共通)

| 役職 | エージェント | 責務 |
|---|---|---|
| QAリード | `reviewer-qa` | 成果物QA、リリース判定、チェックリスト |
| コードレビュー | `code-reviewer` | 一般コード品質 |
| Kotlin | `kotlin-reviewer` | Android/KMP Kotlin |
| Python | `python-reviewer` | PEP8/型/Pythonic |
| DB | `database-reviewer` | PostgreSQL/Supabase |
| セキュリティ | `security-reviewer` | OWASP Top10、脆弱性 |

OpenClaw タグ: なし (QAはClaudeがやる)

---

## 命名規約 (Phase 2-D で完全統一予定)

| パターン | 用途 | 例 |
|---|---|---|
| `*-director` | 部長 (役職) | `venture-director` |
| `*-reviewer` | レビュアー (横串) | `code-reviewer` |
| `*-resolver` | 開発エラー解決 | `build-error-resolver` |
| 業務名 (英) | 業務専門家 (部長クラス) | `marketer`, `sales-rep`, `cfo`, `legal` |
| 役職名 (英) | 役職 | `secretary`, `chief-of-staff`, `ceo-orchestrator` |

現在は混在。Phase 2-D で「全部長を `*-director` 命名」に統一する案を検討。

---

## OpenClaw 部署タグ ↔ フォルダ対応

| OpenClaw タグ | 投入先フォルダ (Phase 2-C 完了後) | 部長エージェント |
|---|---|---|
| `newbiz` | `02_newbiz/inbox/` | `venture-director` |
| `dev` | `03_dev/inbox/` | `architect` |
| `marketing` | `04_sales_mkt_cs/inbox/` | `marketer` |
| `corp` | `05_corp/inbox/` | `cfo` |
| `secretary` | `06_secretary/inbox/` | `secretary` |
| `research` | `07_research/inbox/` | `researcher` |
| `misc` | `08_openclaw/outputs/misc/` | (なし、CEOがレビュー) |

---

## 連携ルール

- **部署間ハンドオフ**: 各部署 `handoff/` フォルダ経由。「from: 02_newbiz / to: 04_sales_mkt_cs / 内容: PRD完成→LP草稿依頼」のフォーマット
- **CEO エスカレ**: 部長が判断つかない時 `01_ceo/escalations.md` に追記
- **横串QA**: 部長が完成したと判断したアウトプット → レビュアー (該当 `*-reviewer`) を Agent ツールで呼ぶ
- **OpenClaw 失敗3連続**: Discord 通知 (red) + `01_ceo/escalations.md` に追記

---

## 更新履歴

- 2026-05-27 初版作成 (Phase 2-A)
