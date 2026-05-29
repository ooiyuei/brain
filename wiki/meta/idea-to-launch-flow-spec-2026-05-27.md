---
type: spec
title: アイデア→ローンチ ステートマシン 設計仕様
created: 2026-05-27
status: active
related: [[concepts/solopreneur-11steps]], [[_routines/shincoder-decision-templates]], [[_routines/morioka-decision-templates]]
tags: [spec, state-machine, shincoder, morioka, automation]
---

# アイデア→ローンチ ステートマシン 設計仕様

## 概要

`idea_to_launch_loop.ps1` が管理するステートマシンの完全仕様。
シンコード11ステップを各事業の「現在地」として追跡し、自動でタスクをdispatchする。
既存の `shincoder_loop.ps1` は廃止せず並走させる (後者はランダムdispatch・前者はステート駆動)。

---

## 1. 状態図 (11ステート + 遷移)

```
[S1: 発掘]
  └─ LP草案ファイル検出 ──────────────────────→ [S2: LP草案]
       └─ 大井確認後 (手動) ─────────────────→ [S3: 広告投下]

[S3: 広告投下]
  ├─ CPA <= 300円 (GO) ────────────────────→ [S5: MVP開発]
  ├─ CPA 300-500円 (HOLD) ─────────────────→ [S4: HOLD改善]
  └─ CPA >= 500円 (PIVOT) ─────────────────→ [S3: 再広告] ← pivotCount++

[S4: HOLD改善]
  └─ 4日経過 ─────────────────────────────→ [S3: 再広告]

[S5: MVP開発]
  └─ 開発完了 (手動) ──────────────────────→ [S6: ビルドインパブリック]

[S6: ビルドインパブリック]
  └─ βリリース (手動) ────────────────────→ [S7: βリリース]

[S7: βリリース]
  └─ 初回課金確認 (手動) ─────────────────→ [S8: ファネル分析]

[S8: ファネル分析]
  └─ 改善サイクル1周 (手動) ──────────────→ [S9: PMF判定]

[S9: PMF判定]
  ├─ pmf-judge ファイルに "PMF達成" ──────→ [S10: ユニットエコノミクス]
  └─ pmf-judge ファイルに "未達" ─────────→ [S8: ファネル分析] (継続)

[S10: ユニットエコノミクス]
  └─ unit-economics ファイルに "スケールGO" → [S11: スケール]

[S11: スケール]
  └─ 終端 (バイアウト or 継続拡大)
```

**全ての状態は** `.local/idea_states.json` に永続化される。

---

## 2. 自動進行ルール (ファイル存在トリガー)

| 遷移 | トリガー条件 | 判定ファイル |
|---|---|---|
| S1 → S2 | `wiki/_inbox/` 配下に `*lp*{idea_id}*` ファイルが存在 | 自動検出 |
| S3 → S5 | `_final/decisions/cpa-check-*.md` の該当事業行に数値 <= 300 | CPA判定シート |
| S3 → S4 | 同シートの数値 300-500 | CPA判定シート |
| S3 → S3 (PIVOT) | 同シートの数値 >= 500 | CPA判定シート (pivotCount++) |
| S4 → S3 | S4滞在4日以上 (タイマー) | 自動タイマー |
| S9 → S10 | `_final/decisions/pmf-judge-*.md` 該当行に "PMF達成" | PMF判定シート |
| S10 → S11 | `_final/decisions/unit-economics-*.md` に "スケールGO宣言" | UE計算シート |

**手動トリガー** (大井が `idea_states.json` の step フィールドを直接書き換え):
- S2 → S3: LP草案を確認・OK判断後
- S5 → S6: MVP開発完了
- S6 → S7: βリリース実行後
- S7 → S8: 初回課金確認
- S8 → S9: ファネル改善1サイクル完了

---

## 3. 手動オーバーライドフック

大井が `.local/idea_states.json` を直接編集することで任意ステートへ強制移動できる。

```jsonc
{
  "ideas": {
    "testall": {
      "step": 7,          // ← 直接書き換えでステップ移動
      "status": "active", // active / hold / pivot / pmf / scale / paused
      "notes": "β開始" // 備考メモ
    }
  }
}
```

**status 一覧**:
- `active` : 通常進行中
- `hold`   : CPA 300-500円・LP改善待ち
- `pivot`  : CPA >= 500円・方向転換中 (pivotCount が増える)
- `pmf`    : PMF達成・Step10以降
- `scale`  : スケールフェーズ
- `paused` : 一時停止 (タスク発行しない)

---

## 4. 森岡式 9軸レビュー 統合ルール

シンコード数字判定 (CPA/PMF/LTV) に対して、森岡式概念診断を3ステップごとに並走させる。

| タイミング | トリガー条件 | 生成タスク |
|---|---|---|
| Step 3 到達 | 前回レビューから21日以上 | concept-diagnosis (WHO/WHAT/HOW 確認) |
| Step 6 到達 | 同上 | concept-diagnosis (ブランドエクイティ確認) |
| Step 9 到達 | 同上 | concept-diagnosis (PMF直前コンセプト強度確認) |

**統合の意図**: シンコードが「数字で判定」しPIVOT回数を減らすのと並行し、
森岡式が「コンセプトの強度」を概念レベルで診断する。
数字はOKでもコンセプトが弱いと広告停止後に売上が消えるため、両方クリアを条件とする。

**出力先**: `wiki/_final/decisions/concept-diagnosis-{idea_id}-{date}.md`

---

## 5. クールダウンルール (スパム防止)

| ルール | 設定値 |
|---|---|
| 同一事業への再dispatch | 6時間空ける |
| 同一ステップのタスク | 冷却時間内は再発行しない |
| 森岡レビュー最小間隔 | 21日 |
| PIVOT後の再広告 | S4滞在4日後に自動解除 |
| 全体inbox上限 | 280件超でスキップ |

---

## 6. Discord通知ルール

| イベント | 通知 | 色 |
|---|---|---|
| CPA >= 500 (PIVOT) | `PIVOT検出 N件` | orange |
| PMF達成 | `PMF達成` | purple |
| スケールGO | `スケールGO` | green |
| pivotCount >= 3 | `多重PIVOT警告` | red |

---

## 7. 既存スケジューラとの共存

| スクリプト | 役割 | 周期 | 共存方針 |
|---|---|---|---|
| `shincoder_loop.ps1` | ランダムdispatch (ステップ無視) | 1h | **廃止しない** (バックフィル的に動く) |
| `idea_to_launch_loop.ps1` | ステートマシン駆動dispatch | 1h | **新規追加** (本スクリプト) |
| `newbiz_pipeline_advance.ps1` | 新規アイデアseed→PRD | 2h | 別ライン (対象が異なる) |

`shincoder_loop.ps1` は既存スケジューラ `BrainShincoderLoop` が動かしているため、
`idea_to_launch_loop.ps1` 用に新スケジューラ `BrainIdeaToLaunch` を別途登録する。

---

## 8. スケジューラ登録コマンド (参考)

```powershell
# BrainIdeaToLaunch - 毎時0分発火
$action  = New-ScheduledTaskAction -Execute "wscript.exe" `
    -Argument "C:\Users\Owner\business\brain\scripts\silent_runner.vbs `"C:\Users\Owner\business\brain\scripts\idea_to_launch_loop.ps1`""
$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Hours 1) -Once -At "00:00"
Register-ScheduledTask -TaskName "BrainIdeaToLaunch" -Action $action -Trigger $trigger `
    -RunLevel Highest -Force
```

既存 `BrainShincoderLoop` と完全に独立して動く。

---

## 9. ステートファイル構造

`C:\Users\Owner\business\brain\.local\idea_states.json`

```jsonc
{
  "lastUpdated": "2026-05-27T09:00:00+09:00",
  "ideas": {
    "aipax": {
      "id": "aipax",
      "name": "AIpaX",
      "step": 9,
      "status": "active",
      "lastDispatch": "2026-05-27T08:00:00+09:00",
      "lastAdvance": "2026-05-26T00:00:00+09:00",
      "daysInStep": 0,
      "stepEnteredAt": "2026-05-27",
      "pivotCount": 0,
      "moriokaReviewAt": "",
      "notes": ""
    },
    "testall": { "step": 5, "status": "active", ... },
    "eemus":   { "step": 3, "status": "active", ... },
    "aipa-web":{ "step": 4, "status": "active", ... },
    "aipax-school": { "step": 5, "status": "active", ... }
  }
}
```

---

## 10. 受け入れ条件

- [ ] `.local/idea_states.json` が初回実行で5事業分生成される
- [ ] 各事業が現在のステップに対応したタスクをdispatchする
- [ ] `_final/decisions/cpa-check-*.md` に >= 500 の数値がある事業が status=pivot になる
- [ ] `_final/decisions/pmf-judge-*.md` に "PMF達成" がある事業が step=10 になる
- [ ] 6時間以内の同一事業への重複dispatchがない
- [ ] Step 3/6/9 到達時に森岡レビュータスクが発行される
- [ ] PIVOT/PMF/スケールGO 各イベントで Discord 通知が飛ぶ
- [ ] `shincoder_loop.ps1` のスケジューラが停止しない
- [ ] ダッシュボードファイルに Auto-update スタンプが追記される

---

## 関連

- スクリプト: `scripts/idea_to_launch_loop.ps1`
- ダッシュボード: `wiki/dashboards/idea-launch-pipeline-2026-05-27.md`
- シンコードテンプレ: `wiki/_routines/shincoder-decision-templates.md`
- 森岡テンプレ: `wiki/_routines/morioka-decision-templates.md`
- 元フレームワーク: `concepts/solopreneur-11steps.md`
