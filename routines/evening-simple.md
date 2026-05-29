# 夜の振り返り 22:00（10分）

## あなたの役割
大井湧瑛の右腕として、今日10分で「今日できたこと + 明日やること」を整理する。

> 形式的レポート不要。脳の整理用。

## 実行手順（10分以内）

### 1. 今日の事実収集（3分）
読む：
- 今朝の `wiki\_routines\morning-{今日YYYYMMDD}.md`
- 今日の `wiki\_tasks\today.md` — 達成状況確認
- 今日の `~/.claude/projects/` 配下の最終更新時刻（時刻のみ確認）
- `queue\done\` の今日完了タスク（OpenClaw成果物）
- `wiki\_inbox/` に新規追加された成果物（harvest.ps1が運んできたもの）
- 今日のgit commit（gh CLI）: 主要リポジトリの今日のcommit確認

#### 議事録自動取得（Fireflies/Zoom MCP）
今日の商談・MTGがあれば：
- Fireflies MCP: 今日の transcripts 取得
- Zoom MCP: 今日の recordings 一覧

各議事録について OpenClaw に要約dispatch：
```powershell
& "C:\Users\Owner\business\brain\scripts\dispatch.ps1" `
    -Department "secretary" `
    -Title "[Evening] 議事録要約: <タイトル>" `
    -Prompt "以下の議事録を構造化要約: <transcript本文>" `
    -OutputPath "wiki\_inbox\secretary\meeting-{ID}-{今日}.md" `
    -Priority "normal"
```
要約はOpenClaw が処理し、翌日のmiddayでレビュー昇格。

### 2. 今日の評価（Sonnet判定）
朝決めた打ち手と実績の対比：
- 「絶対やる1個」やれたか？
- 想定外で動いた事は何か？
- 何が予定通りいかなかったか？

正直に書く。形式じゃなく**大井自身が読み返して使える**メモにする。

### 3. 明日のメモ（3分）
明日に持ち越すべきこと：
- 今日やり残し
- 今日気づいた次の打ち手
- 期限が迫る案件（ビジコン応募・商談など）

### 4. OpenClaw依頼（あれば）
明日の量産タスク（草稿・調査）を今夜のうちに dispatch すれば、朝起きた時に成果物揃ってる：
```powershell
& "C:\Users\Owner\business\brain\scripts\dispatch.ps1" `
    -Department <部署> -Title "..." -Prompt "..." -Priority normal
```

### 5. 出力
書き込む: `wiki\_routines\evening-{今日YYYYMMDD}.md`

```markdown
---
type: evening
date: YYYY-MM-DD
tags: [routine, evening]
---

# 今日のメモ [[YYYY-MM-DD]]

## 今日できたこと（3個以内）
- ...
- ...
- ...

## できなかったこと
- <朝決めたのに>: 理由 <なんでやれなかったか>

## 想定外で動いたこと
- <あれば。良い意味でも悪い意味でも>

## 学び / 気づき（あれば）
- ...

## 数字の変化
- <今日数値が動いたプロジェクトがあれば>

## 明日やる（1-3個）
1. **<タイトル>** — [[entities/<product>]]
   - <なぜ明日: 1行>
2. ...
3. ...

## 寝る前に大井に一言（30字以内）
<明日朝に見て元気出るやつ・脳汁系・たまに辛口>

## OpenClaw夜投入（明日朝までに完了予定）
- ...

## 関連リンク
- 今朝の作戦: [[_routines/morning-{今日}]]
- ホットキャッシュ: [[hot]]
```

### 6. wiki/_inbox/ 最終レビュー（午後分）
昼ルーティンでレビュー漏れた成果物があればここで処理：
- `wiki\_inbox\` 各部署フォルダを巡回
- 良ければ正式パスへ昇格、微妙なら再dispatch、ダメなら削除

### 7. today.md → done.md アーカイブ（MDタスクボード）
`wiki\_tasks\today.md` で `- [x]` チェック付きの完了タスクを抽出し、
`wiki\_tasks\done.md` の「### 今日YYYY-MM-DD」セクションに追加。

未完了 `- [ ]` で `#today` タグついてるものは inbox.md の冒頭に戻して「明日以降」扱い。

### 8. hot.md 更新
`wiki\hot.md` の「Tomorrow」セクション（明日やる1-3個）を上書き。

### 9. 終了
「夜の振り返り完了 / 今日: X/Y 達成・PDCA: 昇格N件・明日: <最優先タイトル>」と1行で報告。
