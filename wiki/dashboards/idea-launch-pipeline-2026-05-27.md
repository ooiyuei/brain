---
type: dashboard
title: アイデア→ローンチ パイプライン ダッシュボード
created: 2026-05-27
status: auto-updated
related: [[meta/idea-to-launch-flow-spec-2026-05-27]], [[scripts/idea_to_launch_loop.ps1]]
update_schedule: 毎時 (idea_to_launch_loop.ps1 実行時に末尾追記)
tags: [dashboard, pipeline, shincoder, state-machine]
---

# アイデア→ローンチ パイプライン ダッシュボード

> このファイルは `idea_to_launch_loop.ps1` が1時間ごとに末尾に自動追記する。
> 最新状態は最下部の `Auto-update:` ブロックを参照。

---

## アクティブ事業一覧 (初期値)

| 事業名 | Step | ステータス | 滞在日数 | 次アクション | リスクフラグ |
|---|---|---|---|---|---|
| AIpaX | S9:PMF判定 | active | - | PMF3軸記入 | - |
| Testall | S5:MVP開発 | active | - | dispatch済 | - |
| EEMUS | S3:広告投下 | active | - | CPA計測 | - |
| AIpa Web | S4:HOLD改善 | hold | - | LPコピー改善 | - |
| AIpaX school | S5:MVP開発 | active | - | dispatch済 | - |

---

## パイプライン可視化 (テキスト図)

```
シンコード11ステップ パイプライン (2026-05-27 現在)

S1:発掘 → S2:LP → S3:広告 ──GO──→ S5:MVP → S6:BIP → S7:β → S8:ファネル → S9:PMF → S10:UE → S11:スケール
                    │                                                           ↑
                    PIVOT(>=500)                                     (S8←→S9 改善ループ)
                    HOLD(300-500) → S4:LP改善 → (4日後) → S3再

現在地:
  AIpaX         ..............................................[S9]....................
  Testall       .......................[S5]...........................................
  EEMUS         .........[S3]..........................................................
  AIpa Web      ..........[S4 HOLD]....................................................
  AIpaX school  .......................[S5]...........................................
```

---

## ステート遷移ログ (自動追記エリア)

各行フォーマット: `[YYYY-MM-DD HH:MM] [ideaId] OLD_STEP -> NEW_STEP (理由)`

```
(ここに自動追記されます)
```

---

## 森岡レビュー スケジュール

| 事業名 | 次回レビュートリガー | 前回レビュー |
|---|---|---|
| AIpaX | Step 9 到達時 (未実施) | - |
| Testall | Step 6 到達時 (未) | - |
| EEMUS | Step 3 現在 → 即実施 | - |
| AIpa Web | Step 6 到達時 | - |
| AIpaX school | Step 6 到達時 | - |

---

## 判定ファイル最終更新

| ファイル種別 | 最終ファイル名 | 大井記入日 |
|---|---|---|
| CPA判定シート | (auto-detect from _final/decisions/) | - |
| PMF判定シート | (auto-detect from _final/decisions/) | - |
| ユニットエコノミクス | (auto-detect from _final/decisions/) | - |
| コンセプト診断 | (auto-detect from _final/decisions/) | - |

---

## 使い方 (大井向け)

### 数字を記入するだけでステートが進む

1. `shincoder_loop.ps1` が `wiki/_final/decisions/cpa-check-YYYY-MM-DD.md` を出力する
2. 大井が **実測CPA数値** を埋める
3. 1時間後に `idea_to_launch_loop.ps1` がファイルを読んでステートを自動更新
4. 次のステップのタスクが自動dispatch される

### 手動でステップを動かしたい場合

`.local/idea_states.json` を直接編集:

```json
{
  "ideas": {
    "testall": { "step": 7, "status": "active" }
  }
}
```

`step` を変更すると次回ループで新ステップのタスクがdispatchされる。

### 一時停止したい場合

```json
{
  "ideas": {
    "eemus": { "status": "paused" }
  }
}
```

---

## PIVOT 履歴

| 事業名 | PIVOT日 | PIVOT前CPA | 変更内容 | PIVOT後CPA |
|---|---|---|---|---|
| (自動追記) | | | | |

---
<!-- idea_to_launch_loop.ps1 の自動追記はこの行以降に入る -->
