---
type: department-readme
dept_code: 08_openclaw
dept_name: OpenClaw社員 (qwen3.6:latest)
director: (none - dispatch経由)
openclaw_tag: (all)
updated: 2026-05-27
---

# 08_openclaw — OpenClaw社員エリア

## 責務
ローカル ollama (qwen3.6:latest / qwen3:8b / phi3:mini) で量産・整形・要約・調査を実行。各部署部長からの dispatch を待ち、worker.ps1 が処理。

## 注意 (qwen3.6 の特性)
- **指示が長いと暴走** → 1タスク = 1アウトプット、約3000字以内、ステップ分解
- **日付認識が弱い** → 今日の日付を必ず明示
- **ハルシネーション傾向** → 「不明」「推測:」「[要確認]」マーカー必須
- **ゆっくり・細かく・タスク分け** が品質の鍵 (大井の方針 2026-05-27)

## 主要スクリプト (Phase 2-C で `_system/scripts/` に移動予定)
- `dispatch.ps1` / `dispatch.py` — タスク投入 (Win から / Mac から)
- `worker.ps1` (-Lane light/heavy/any) — queue 処理エンジン
- `harvest.ps1` — 1時間毎に results → `_inbox/{部署}` 配送
- `discord_notify.ps1` — 重要結果を Discord 通知

## このフォルダの構成
- `README.md` — このファイル
- `_log.md` — OpenClaw 全体ログ (worker.ps1 のログとは別の意味ログ)
- `queue/` — Phase 2-C で `brain/queue/` から移動 (現在 inbox 0 / processing 0 / done 885 / archive 1521)
- `prompts/` — プロンプトテンプレ
  - `_common.md` — 全共通プレフィックス (現 `scripts/prompt-prefix.md`)
  - `newbiz.md` / `marketing.md` / `corp.md` / `secretary.md` / `research.md` / `dev.md` — Phase 2-D で部署別追加プレフィックス作成
- `outputs/` — worker.ps1 の results を部署別整理
- `templates/` — 既存 `scripts/templates/` を移動

## レーン分離
- **Light レーン**: `BrainWorkerLight` (qwen3:8b、priority=low or プロンプト短い)
- **Heavy レーン**: `BrainWorkerHeavy` (qwen3.6:latest、use_agent or 長文 or priority=high)
- 並列に動作、互いに独立

## 部署タグ ↔ 部長 ↔ 出力先

| OpenClaw タグ | 部長 | 出力先 (Phase 2-C 後) |
|---|---|---|
| `newbiz` | `venture-director` | `02_newbiz/inbox/` |
| `dev` | `architect` | `03_dev/inbox/` |
| `marketing` | `marketer` | `04_sales_mkt_cs/inbox/` |
| `corp` | `cfo` | `05_corp/inbox/` |
| `secretary` | `secretary` | `06_secretary/inbox/` |
| `research` | `researcher` | `07_research/inbox/` |
| `misc` | (CEO レビュー) | `08_openclaw/outputs/misc/` |

## 失敗対策
- 3連続失敗 → Discord red 通知 + `01_ceo/escalations.md` に追記
- BrainAutoReview は **Disabled 維持** (5/25 に1500件一気投入の事故、自動投入禁止)

## 関連
- 全体運用ルール: `brain/CLAUDE.md` の「OpenClawエンジン」「dispatchするときの鉄則」セクション
- ハーネス設定: `~/.claude/settings.local.json` の hook 群
