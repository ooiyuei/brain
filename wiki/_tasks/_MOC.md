---
type: moc
title: Tasks MOC
tags: [moc, tasks]
updated: 2026-05-18
---

# Tasks MOC — タスク管理索引

> **大井は書かない前提。Claudeが秘書として全部書く。**
> 大井はObsidianで見るだけ。タップしてチェック付けるだけ。

## ファイル構成

| ファイル | 用途 | 書き手 |
|---|---|---|
| [[_tasks/inbox|inbox.md]] | Claudeが「後で振り分け予定」のタスクを溜める箱 | Claude |
| [[_tasks/today|today.md]] | 今日やる（自動更新あり） | Claude（朝ルーティン）+ task_board.ps1 |
| [[_tasks/done|done.md]] | 完了アーカイブ | Claude（夜ルーティン） |

## 大井の使い方

1. **朝起きて today.md を開く** → 今日やることが書いてある
2. **やったタスクは `- [x]` でチェック**（または「終わったよ」とClaudeに言うだけ）
3. **思いついたらClaudeに話す** → Claudeが inbox.md か today.md に書く + 必要なら即OpenClaw dispatch
4. **夜・寝る前に today.md 見る** → 完了したものは done.md に自動移動済み

## Claudeの動き方

### 大井の発話を受けたら
1. **緊急/今日中**: today.md の「🔥 絶対やる」に追記 + 即OpenClaw dispatch
2. **重要だが余裕あり**: today.md の「🌱 できれば」に追記
3. **いつか/思いつき**: inbox.md に追記 + `#openclaw` タグ付ければ自動でOpenClaw処理（task_board.ps1）

### dispatch時のルール
- 1タスク=1アウトプット
- prompt は scripts/prompt-prefix.md が自動付与される（実在entities・日付・出力ルール）
- 詳細指示は[[CLAUDE]]参照

## 関連
- [[CLAUDE|Vault運用原則]]
- [[_routines/_MOC|Routines MOC]]
- [[index|Wiki Index]]
- [[hot|Hot Cache]]
