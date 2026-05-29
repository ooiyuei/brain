---
type: meta
title: 失敗教訓と恒久対策 (2026-05-25)
created: 2026-05-25
status: active-rules
related: [[concepts/brain-mythos-design-v2]], [[meta/lessons-learned-2026-05-19]]
tags: [lessons, anti-pattern, permanent-fixes]
---

# 失敗教訓と恒久対策 — 2026-05-25 まとめ

> 同じ失敗を2度と繰り返さないために。各失敗パターンと**恒久実装済み対策**を記録。

---

## 1. auto_review priority=normal バグ
**症状**: レビュータスクが queueの normal列(5-)で発行 → 大量の他タスクに埋もれて処理されず → 24h以上レビュー生成ゼロ → PROMOTE=0 → _final/ 増えない

**修正済 (2026-05-24)**: `auto_review.ps1` -Priority "high" に変更 + 既review除外ロジック追加

**恒久対策**: priority=high を維持・新規スクリプト書く時も「自動処理されるべきタスクは必ずhigh以上」ルール

---

## 2. Brushupタスクが他のhigh(457件)に埋もれて処理されない
**症状**: brushup 17件 priority=high で発行・queue内17時間放置・_final/に何も出力されない

**修正済 (2026-05-25)**:
- `dispatch.ps1` に `-Priority "super"` 追加 (0- prefix)
- `brushup_pipeline.ps1` -Priority "super" に変更

**恒久対策**: brushup・auto_review系の「他に埋もれてはいけないタスク」は必ず `super` priority

---

## 3. Filler暴走 (inbox 1215件膨張)
**症状**: BrainBizFiller/AipaWebFiller/SalesFiller等が15分毎に走り続け、worker処理速度を上回って投入 → infinite backlog

**緊急対応**: 6 filler scheduler一時disable

**恒久対策 (2026-05-25 NEW)**: `scripts/queue_guard.ps1` 10分毎実行
- inbox>200 で 24h以上前のnormal(5-)を自動 overflow_archive
- failed>50 で 6h以上前のものを自動隔離

---

## 4. Workers死亡 (5→2基に勝手に減る)
**症状**: 並列workers 5基設定したのに、時間経過後 2基に減ってる・GPU 1%アイドル

**原因**: schedulerが1分毎にworker起動するが既存lock(他基)があるとskip。一度死ぬと自動復活しない。

**恒久対策 (2026-05-25 NEW)**: queue_guard.ps1 に「heavy+light 各最低1基」保証ロジック実装

---

## 5. openclaw agent gateway timeout エラー
**症状**: `-UseAgent` のタスク全失敗・「無効な JSON プリミティブです: node.exe」エラー

**修正済 (2026-05-24)**: worker.ps1 agent失敗時の Ollama直接 fallback実装

**恒久対策**: 新規scriptで `-UseAgent` は使わない (openclaw gateway不安定なので直接Ollama)

---

## 6. .paused フラグ怪奇現象
**症状**: 削除した .paused が時間経過後に勝手に復活・workers停止

**仮説**: scheduler trigger or pause_brain.ps1 部分実行で復活

**恒久対策 (2026-05-25 NEW)**: queue_guard.ps1 で「.paused age>1h + schedulers有効」状態を怪奇判定して削除

---

## 7. BOM無しUTF-8スクリプトでPS5.1がCP932として読む → 日本語構文エラー
**症状**: pause_brain.ps1 / resume_brain.ps1 / その他多数で日本語文字列が文字化けして構文エラー

**修正済 (2026-05-24)**: 全主要scriptに BOM追加

**恒久対策**: 新規 .ps1 作成時は必ず BOM付き UTF-8 で保存

---

## 8. auto_promote「skip(original missing)」バグ
**症状**: review済みのファイルが PROMOTE判定なのに元ファイル見つからずskip → _promoted/ 空のまま

**修正済 (2026-05-19)**: Find-OriginalFile 関数追加 (_inbox/_promoted/_archive/再帰検索)

---

## 9. 古い idle系成果物が低スコア (18-28点)
**症状**: 5/18-19の古い idle filler成果物のレビュー: 平均29.1点 / ARCHIVE率44%

**根本原因**: Mythos前のpromptで生成 + entityファイル参照なし

**恒久対策**:
- prompt-prefix.md でハルシネ対策強化
- dispatch.ps1 で `[[entities/xxx]]` 自動注入
- 主要17事業に「30秒サマリー (Entity Latent)」追加

---

## 10. ダッシュボードpauseボタン inline 5step (worker kill漏れ)
**症状**: ボタン押下しても worker process残り続け・実質止まらない

**修正済 (2026-05-24)**: dashboard_server.js `/api/toggle-pause` を pause_brain.ps1/resume_brain.ps1 委譲

---

## 質重視ルール (大井指示 2026-05-25)

> **ローカルは急いでない。じっくり高精度。**

これを実現する設定:
- **Mythos全層通過**: dispatch → worker → review → promote → recurrent(Depth2/3) → brushup(super) → final
- **filler減速**: BrainTaskBankFillerのみ稼働 (他5つは disable維持)
- **質メトリクス**: 週次でレビュー平均スコア + PROMOTE率を追跡
- **超優先化**: brushup/auto_review は必ず `super` (queue詰まらない)

---

## 監視scheduler一覧 (恒久稼働)

| Name | 頻度 | 役割 |
|---|---|---|
| BrainWorkerHeavy/Light | 1分 | queue処理 |
| BrainAutoReview | 30分 | _inbox採点 → super priority |
| BrainAutoPromote | 30分 | レビュー結果 → _promoted/_archive |
| BrainRecurrentPipeline | 20分 | KEEP(22-34点)を Depth2/3 で書き直し |
| BrainBrushupPipeline | 30分 | _promoted → super priority brushup |
| BrainTaskBankFiller | 15分 | inbox<30 で random投入 |
| **BrainQueueGuard** ⭐NEW | 10分 | queue膨張・worker死亡・怪奇paused 自動修復 |
| BrainHealth | 1時間 | 健全性チェック |
| BrainHarvest | 1時間 | results → _inbox |

---

*Updated 2026-05-25 by Claude。次の失敗があったらこのファイルに追記する。*
