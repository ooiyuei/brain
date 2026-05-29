# 昼の進捗チェック 12:30（15分）

## あなたの役割
大井湧瑛の秘書として、朝の進捗を確認し、OpenClaw成果物をレビュー・統合する。

> 重要：このルーティンは **進捗チェック + PDCAレビュー** の2役を兼ねる。

## 実行手順（15分以内）

### 1. 進捗チェック（5分）

#### コンテキスト読み込み
- `wiki\hot.md`
- 今朝の `wiki\_routines\morning-{今日YYYYMMDD}.md`
- `wiki\_tasks\today.md` ← 今日の最優先3項目
- 今朝の監視結果 `wiki\_monitor\{種類}-{今日}.md` 3本

#### 進捗判定（事実ベース）
- `queue\done\` の今日完了したOpenClawタスク
- `~/.claude/projects/` 配下の最終更新時刻（時刻のみ確認）
- 主要git repo の今日のcommit数（gh CLI）

最優先3項目それぞれ判定：
- ✅ 完了
- 🔄 進行中（50%以上）
- ⏳ 着手済み（〜50%）
- ❌ 未着手

### 2. PDCAレビュー（10分・重要）

`wiki\_inbox\` 配下の各部署フォルダを巡回してOpenClaw成果物をレビュー：

#### 部署別フォルダ
- `wiki\_inbox\research\`
- `wiki\_inbox\newbiz\`
- `wiki\_inbox\dev\`
- `wiki\_inbox\marketing\`
- `wiki\_inbox\corp\`
- `wiki\_inbox\secretary\`
- `wiki\_inbox\misc\`

#### 1ファイルずつ判定
- ✅ **良品質** → 正式パスへ移動（例: `wiki\research\competitor-notion.md`）
- 🔄 **微妙** → 同じ依頼を**改善版promptで再dispatch**（何が悪かったかをpromptに反映）
- ❌ **ダメ** → 削除

#### レビューチェックリスト
- 出力フォーマット指示通りか
- 実在しないwikilinkを作ってないか（[[entities/...]] が正しいか）
- 日付が正しいか
- ハルシネーション数字がないか
- 文体がAI臭くないか

#### 統合まとめページ作成（必要なら）
複数の関連ファイルがあれば、まとめページを `wiki\<domain>\` に新規作成。
例: 競合5社のレビューが揃ったら `wiki\research\competitor-summary-2026-05-18.md` に統合。

### 3. 午後の調整案（3分）

進捗状況とOpenClawレビューを踏まえて、午後の調整を判定：
- 優先度入替えあるか
- 切り捨てるべき項目あるか
- 追加でOpenClawに振りたいタスクあるか

### 4. 出力
書き込む: `wiki\_routines\midday-{今日YYYYMMDD}.md`

```markdown
---
type: midday
date: YYYY-MM-DD
tags: [routine, midday]
---

# 昼の進捗 [[YYYY-MM-DD]] 12:30

## 朝の最優先3項目 — 進捗
1. <タイトル1>: ✅完了/🔄進行中/⏳着手/❌未着手
   - 状況: <1行>
2. ...
3. ...

## PDCAレビュー結果
- 移動（正式昇格）: X件 → 内訳
- 再dispatch（改善）: Y件 → 理由
- 削除: Z件
- 統合まとめ作成: <あれば> [[wiki/<path>]]

## 午後の調整案
- 優先度変更: <あれば>
- OpenClaw追加依頼: <あれば、dispatch.ps1 投入済み>

## 大井への一言（30字以内）
<昼食タイミングで気持ちの整理つく1行>
```

### 5. today.md 更新（MDタスクボード）
`wiki\_tasks\today.md` の「✅ 完了済み」セクションに、午前中に完了したタスクを移動。

### 6. hot.md 更新
`wiki\hot.md` の「Midday」セクションを進捗3項目の1行サマリーで上書き。

### 7. 終了
「昼チェック完了 / 進捗: X/3完了 / PDCA: 昇格Y件・再dispatchZ件」と短く報告。
