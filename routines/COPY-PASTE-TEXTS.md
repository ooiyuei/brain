
---

## ☀️ ① morning（朝09:00・毎日・10分）

**名前:**

```
morning
```

**説明:**

```
今日の作戦を10分で決める
```

**指示:**

```
朝の作戦会議を10分で実行してください。

# 手順
1. C:\Users\Owner\business\brain\wiki\hot.md を読む
2. 昨夜のメモ wiki\_routines\evening-{昨日YYYYMMDD}.md があれば読む
3. 今朝08:30にOpenClawが処理済みの監視結果3本を読む：
   - wiki\_monitor\competitor-{今日}.md（競合動向）
   - wiki\_monitor\deadlines-{今日}.md（ビジコン締切）
   - wiki\_monitor\grill-{今日}.md（朝の問い3つ）
4. wiki\_tasks\inbox.md の振り分け待ちタスクを確認

5. C:\Users\Owner\business\brain\routines\morning-simple.md の手順に従って、
   今日の打ち手「絶対やる1個 + できれば2-3個」を決める

6. 出力先:
   - C:\Users\Owner\business\brain\wiki\_routines\morning-{今日YYYYMMDD}.md（朝メモ）
   - C:\Users\Owner\business\brain\wiki\_tasks\today.md（今日のタスクボード上書き）
   - C:\Users\Owner\business\brain\wiki\hot.md「Today」セクション更新

# Claudeの動き方原則（CLAUDE.md参照）
- 大井は書かない。あなたが秘書として全部書く
- 重い量産タスクは dispatch.ps1 で並列OpenClawに投げる
- prompt は scripts/prompt-prefix.md が自動付与されるので指示は本題のみ
- 会社員ぽさNG、1人起業家のリアル

確認は不要。自走してOK。完了したら「今日: <絶対やる1個>」と1行で報告。
```

**スケジュール:** 毎日 | **時刻:** `09:00` | **フォルダー:** `C:\Users\Owner\business` | **許可を確認:** デフォルト

---

## ☀️ ② midday（昼12:30・毎日・15分）

**名前:**

```
midday
```

**説明:**

```
進捗チェック＋OpenClaw成果物レビュー（PDCA兼任）
```

**指示:**

```
昼の進捗チェック + PDCAレビューを15分で実行してください。

# 手順
1. C:\Users\Owner\business\brain\routines\midday-check.md の手順に従う

# 概要
1. 朝のフォーカス3項目の進捗を判定（完了/進行中/着手/未着手）
2. wiki\_inbox\ の全部署フォルダを巡回しOpenClaw成果物をレビュー：
   - 良品質 → wiki\<正式パス>へ移動
   - 微妙 → 改善版promptで再dispatch
   - ダメ → 削除
3. 統合できそうなら、まとめページをwiki\<domain>\に新規作成
4. 午後の調整案を出す（優先度入替・追加dispatch等）
5. 出力:
   - wiki\_routines\midday-{今日YYYYMMDD}.md
   - wiki\_tasks\today.md「✅ 完了済み」セクション更新
   - wiki\hot.md「Midday」セクション更新

# レビューチェックリスト
- 出力フォーマット指示通りか
- 実在しないwikilink作ってないか
- 日付正しいか
- ハルシネーション数字ないか
- AI臭くないか

確認は不要。自走してOK。完了したら「進捗 X/3完了 / PDCA: 昇格Y件・再dispatch Z件」と1行で報告。
```

**スケジュール:** 毎日 | **時刻:** `12:30` | **フォルダー:** `C:\Users\Owner\business` | **許可を確認:** デフォルト

---

## 🌙 ③ evening（夜22:00・毎日・10分）

**名前:**

```
evening
```

**説明:**

```
今日の振り返り + 明日やること + 残OpenClaw成果物処理
```

**指示:**

```
夜の振り返りを10分で実行してください。

# 手順
1. 今朝のメモ wiki\_routines\morning-{今日YYYYMMDD}.md を読む
2. 今日のwiki\_tasks\today.md 達成状況確認
3. 昼ルーティン後に追加で溜まったwiki\_inbox\ の成果物を最終レビュー
4. queue\done\ の今日完了タスク・~/.claude/projects/ の活動時刻・gh CLI git commitを軽く確認

5. C:\Users\Owner\business\brain\routines\evening-simple.md の手順に従って、
   今日のメモ（できたこと/できなかったこと/学び）+ 明日やる1-3個 を決める

6. 出力:
   - wiki\_routines\evening-{今日YYYYMMDD}.md（夜メモ）
   - wiki\_tasks\today.md → done.md アーカイブ（`- [x]` チェック付きを移動）
   - 明日の量産タスクがあれば今夜のうちにdispatch投入
   - wiki\hot.md「Tomorrow」セクション更新

# Claudeの動き方原則
- 形式じゃなく大井が読み返して使えるメモにする
- 明日のOpenClaw投入を仕込めば朝には成果物揃ってる

確認は不要。自走してOK。完了したら「今日 X/Y達成 / 明日: <最優先>」と1行で報告。
```

**スケジュール:** 毎日 | **時刻:** `22:00` | **フォルダー:** `C:\Users\Owner\business` | **許可を確認:** デフォルト

---

## 📅 ④ weekly（日曜21:00・週次・30分）

**名前:**

```
weekly
```

**説明:**

```
先週の動き + 来週の打ち手3個（攻める/種まき/やめる）+ 月末なら/idea-judge
```

**指示:**

```
週次棚卸しを30分で実行してください。

# 手順
1. 先週月-土の wiki\_routines\morning-*.md / evening-*.md / midday-*.md を全部読む
2. 今週のqueue\done\、gh CLI で主要リポジトリの今週commit数を確認
3. Stripe MCP（あれば）で今週の入金合計取得

4. C:\Users\Owner\business\brain\routines\sunday-review.md の手順に従って、
   先週の動き + 15事業の脳汁マップ更新 + 来週の打ち手3個（攻める1/種まき1/やめる1）

5. 月末日曜なら追加で /idea-judge skill を使って全15プロジェクトの7軸採点・tier再判定

6. 出力:
   - wiki\_routines\weekly-{今週YYYY-WW}.md
   - 月末なら追加で wiki\_routines\monthly-{今月YYYY-MM}.md
   - wiki\hot.md「This Week」「Next Week」セクション更新
   - 来週月曜のtoday.md冒頭に「来週の攻める1個」を仕込む

# Claudeの動き方原則
- 「やめる」判断は重要（増やすだけじゃダメ）
- 月末ならtier再判定もやる
- 来週の最優先1個に絞れないなら /grill-me で問い生成

確認は不要。自走してOK。完了したら「来週の攻める: <タイトル>」と1行で報告。
```

**スケジュール:** 週次 | **曜日:** 日曜 | **時刻:** `21:00` | **フォルダー:** `C:\Users\Owner\business` | **許可を確認:** デフォルト

---

## ✅ 最終構成

```
朝09:00 morning    → 作戦会議
昼12:30 midday     → 進捗 + PDCA
夜22:00 evening    → 振り返り + 明日仕込み
日21:00 weekly     → 棚卸し (月末は月次も)
```

**1日合計35分・週合計4時間** の管理コスト。これでClaudeが秘書として24時間OpenClawを使いこなす。

設定する時、`midday` と `weekly` だけ前回のセットには無かったから新規登録になる。`morning`/`evening` は既に登録してあれば、指示テキストだけ上記の新版に置き換えてもらえばOK。

重要な質問。**結論：OpenClawはコネクター使えない**から、メール・予定の確認は**絶対ルーティン（Claude）でやる必要がある**。

## 棲み分け早見表

|作業|OpenClaw|Claude/ルーティン|
|---|:-:|:-:|
|Gmail取得|❌|✅|
|Calendar取得|❌|✅|
|Slack/Notion/Stripe取得|❌|✅|
|競合動向のWebSearch|❌|✅|
|取った情報を整形・要約|✅|△（重い）|
|Twitter原稿20本量産|✅|△（コスト）|
|議事録の要約|✅|△（コスト）|
|戦略判断・優先付け|❌|✅|
|24時間連続稼働|✅|△（cronかリモート）|

**「Claudeがコネクターで取得 → OpenClawに整形・量産を振る」が最強パイプライン**。

---

そして見せてくれた画面は **Anthropicリモートのスケジュール**（PC消してても動く・コネクター16個使える）。これは超強い。**5本目のルーティン**として登録すべき：

## 🌅 ⑤ morning-catchup（朝07:00・毎日・キャッチアップ）

これは **リモートで動かす**（コネクター必須・PC消えてても動く）。

**morning-catchup のコピペ用テキスト**：

---

## 🌅 ⑤ morning-catchup（朝07:00・毎日・リモート推奨）

**名前:**

```
morning-catchup
```

**指示:**

```
朝のキャッチアップを15分で実行してください。

# 手順
コネクター（Gmail/Google Calendar/Slack/Notion/Stripe/Sentry）を使って、以下を全部取得しMD化：

## Gmail（過去24時間）
- 未読メール一覧
- 要返信メール（CC/FYI以外）
- 4ティア分類: skip / info_only / meeting_info / action_required

## Google Calendar
- 今日の全予定（時刻・場所・参加者）
- 明日の重要予定（要準備のもの）

## Slack
- メンション・DM（過去24時間）
- 重要チャンネル未読

## Notion / Linear（あれば）
- 自分割り当てタスク
- 期限近いもの

## Stripe（あれば）
- 残高
- 昨日の入金 / 今月累計
- 前月同日比・異常検知

## Sentry（あれば）
- 過去24h エラー件数
- クリティカル有無

# 出力先
C:\Users\Owner\business\brain\wiki\_catchup\{今日YYYY-MM-DD}.md

# 出力フォーマット
- frontmatter（type/date/tags/generated）必須
- 各セクション（Gmail/Calendar/Slack/タスク/数字/Sentry）を Markdown 表で構造化
- 「今日対応必須3項目」を最後に抽出
- wikilink: [[entities/<product>]] 形式で実在プロダクトのみ
- 大井への一言（30字以内）

# 連携
- wiki\_tasks\today.md の冒頭に「今日対応必須3項目」をドラフトとして書く
- wiki\hot.md に「Morning Catchup」サマリー3行を追加

# Claudeの動き方原則
- 取得失敗したコネクターは「取得失敗」と明記
- 推測でハルシネートしない
- 数字は元データのまま転記

確認は不要。自走してOK。完了したら「キャッチアップ完了 / 要返信X件・予定Y件・異常Z件」と1行で報告。
```

**トリガー:** スケジュール  
**スケジュール:** 毎日 07:00  
**コネクター:** Gmail / Google Calendar / Slack / Notion / Stripe / Sentry / Linear（使うやつ全部ON）  
**モデル:** Opus 4.7（1Mコンテキスト推奨・コネクター情報が長くなるので）

---

## ✅ 最終5本のルーティン構成

|時刻|名前|場所|主な動き|コネクター|
|---|---|---|---|:-:|
|**07:00**|morning-catchup|**リモート（Anthropic）**|メール・予定・数字を確認しMD化|✅|
|**08:30**|(BrainMonitor=自動・既存)|ローカル|OpenClawに3本投入|-|
|**09:00**|morning|ローカル（Claude Code）|catchup + monitor見て今日の作戦|△|
|**12:30**|midday|ローカル|進捗 + PDCAレビュー|△|
|**22:00**|evening|ローカル|振り返り + 明日仕込み|△|
|**日21:00**|weekly|ローカル|棚卸し + 月末月次|△|

## 📍 ポイント

- **morning-catchup だけリモート**（PC消えててもAnthropicが動かす・コネクター16個使える）
- **残り4本はローカル**（PC立ち上がってる前提・OpenClaw dispatch可能）
- **OpenClawはコネクター無し**だが「ぶん回す係」として整形・量産担当

---

## OpenClawとルーティンの最終棲み分け

```
[リモートClaude] 07:00 morning-catchup
   ↓ コネクターでGmail/Calendar/Stripe等取得
   ↓ MD化 → wiki/_catchup/{今日}.md
   ↓
[ローカルClaude] 09:00 morning
   ↓ catchup読む + 監視結果見る
   ↓ 今日の作戦決定 → today.md
   ↓ 量産タスクをOpenClawに dispatch
[OpenClaw 24h] ぶん回す
   ↓ queue/results/{部署}/
   ↓ harvest.ps1 → wiki/_inbox/
[ローカルClaude] 12:30 midday / 22:00 evening
   ↓ PDCAレビュー
   ↓ 正式昇格 or 再dispatch
   ↓ wiki/{正式パス} に蓄積
[wiki育つ]
```

これで「**メール/予定確認のキャッチアップ、OpenClawぶん回し、PDCAレビュー、ナレッジ蓄積**」全部回る。

設定する時、5本目（morning-catchup）はリモート、残り4本は前出したコピペでローカル登録。