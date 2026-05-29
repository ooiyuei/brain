---
type: system-readme
updated: 2026-05-27
visibility: 大井は普段見ない。Claude が運用する
---

# _system — システムエリア (大井は普段開かない)

## 責務
大井 (YUEI) のホーム (`00_YUEI/`) や各部署 (`01_..09_`) ではない、**Claude と スクリプトが運用するための内部ファイル**。

## サブフォルダ (Phase 2-C で旧パスから移動予定)

| サブフォルダ | 旧パス | 内容 |
|---|---|---|
| `log/` | `wiki/_log/` | 機械ログ (sessions.jsonl, operations.jsonl, conversations.jsonl, openclaw-snapshots.jsonl) |
| `dashboards/` | `wiki/dashboards/` | 自動生成ダッシュボード (business-snapshot, openclaw-activity, 5businesses-* 等) |
| `meta/` | `wiki/meta/` | 大井プロファイル (ooi-profile-index, ooi-deep-synthesis, ooi-clone-spec)、戦略フレーム、long-term targets |
| `routines/` | `wiki/_routines/` + `brain/routines/` | 朝/夜/週ルーティン (重複統合) |
| `conversations/` | `wiki/_conversations/` | 大井発話の原文保存 (UserPromptSubmit hook 出力) |
| `scripts/` | `brain/scripts/` | .ps1 / .py / .js 実行可能スクリプト全部 |
| `archive/` | (新規) | Phase 2-C 完了後の旧構造保全、`inbox-purge-2026-05-27/` 等 |

## 移動タイミング
- Phase 2-A/B: 空フォルダのみ作成 (このセッション)
- Phase 2-C: 物理移動 + hook/script のパス更新 (別セッション・1日確保)

## 注意
- `_system/` は大井が直接編集することはない (`NOTES.md` だけは `00_YUEI/` に置いてある)
- `_system/log/` の機械ログは hook が自動で書く → 編集禁止
- `_system/scripts/` を編集する場合は Windows Task Scheduler の登録パスも同時更新

## 関連
- ハーネス設定: `~/.claude/settings.local.json`
- Task Scheduler: `BrainWorkerLight/Heavy/Monitor/Harvest/TaskBoard/QueueGuard/...`
