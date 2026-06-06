---
ts: 2026-06-07T07:52:11+09:00
session_id: e646db9e-124d-4e98-8e0c-2c4f23a35b1b
cwd: C:\Users\Owner\business
host: 大井
event: UserPromptSubmit
chars: 2984
tags: [conversation, raw-prompt]
---

# 発話 2026-06-07 07:52

```
<scheduled-task name="daily-ai-news-research" file="C:\Users\Owner\.claude\scheduled-tasks\daily-ai-news-research\SKILL.md">
This is an automated run of a scheduled task. The user is not present to answer questions. For implementation details, execute autonomously without asking clarifying questions — make reasonable choices and note them in your output. "write" actions (e.g. MCP tools that send, post, create, update, or delete), only take them if the task file asks for that specific action. When in doubt, producing a report of what you found is the correct output.

あなたは Researcher Agent です。大井湧瑛 (株式会社 Almeo 代表) のために AI 最新情報の日次リサーチを実行してください。

## 実行手順

### ステップ 1: 今日の日付を取得
今日の日付を YYYY-MM-DD 形式で確認する。

### ステップ 2: WebSearch で情報収集 (以下を並列実行)
1. "Anthropic Claude update [today's date in format like May 2026]"
2. "OpenAI GPT release announcement [month year]"
3. "Google Gemini AI update [month year]"
4. "AI startup funding investment news [month year]"
5. "AI Japan SMB subsidy regulation news [month year]"
6. "AI education tools news [month year]"

### ステップ 3: 重要記事は WebFetch で本文取得
ヘッドライン候補になりそうな記事は WebFetch で詳細を確認する。

### ステップ 4: 以下のフォーマットで Markdown ファイルを作成・保存

保存先: C:\Users\Owner\business\brain\07_research\ai-news\[YYYY-MM-DD].md

フォーマット:
```
# AI ニュース YYYY-MM-DD

**収集:** OpenClaw Researcher Agent
**実行時刻:** HH:MM JST

---

## 今日のヘッドライン 3 つ

> 大井が 2 分で読んで判断できる形。事業インパクト順。Almeo/Testall 関連は ★ マーク。

1. **[タイトル]** — [1 文で意義を説明]
2. **[タイトル]** — [同上]
3. **[タイトル]** — [同上]

---

## 新機能・新製品リリース

### [製品名 / 企業名]
- **内容:** [具体的な機能・変更点]
- **対象:** [誰向け]
- **料金変化:** [あれば記載]
- **API 変更:** [あれば記載]
- **ソース:** [URL]
- **信頼度:** 高/中/低

---

## 技術トレンド (論文・実装)

### [技術名 / 論文名]
- **概要:** [3 行以内]
- **実用化の見通し:** [短期/中期/長期]
- **ソース:** [URL]
- **信頼度:** 高/中/低

---

## 競合動向 (AI コンサル・AI 教育・AI SaaS)

| 企業/プロダクト | 動き | Almeo への示唆 |
|---|---|---|

---

## 投資・M&A・IPO ニュース

| 企業 | 金額 | ラウンド | 評価額 | 示唆 |
|---|---|---|---|---|

---

## 大井が今すぐ試すべきツール 1 つ

**ツール名:** [名前]
**URL:** [URL]
**何ができる:** [1 文]
**Almeo/Testall での活用案:** [具体的シナリオ 1 つ]
**試すのに何分かかる:** [X 分]

---

## Almeo / Testall への適用可能性

| 発見 | 事業への影響 | 優先度 | アクション案 |
|---|---|---|---|

---

## 未確認・要フォローアップ

- [ ] [気になるが情報が少ない件]

---

*ソース一覧*
- [URL1]
- [URL2]
```

### ステップ 5: brain/wiki/hot.md を更新

C:\Users\Owner\business\brain\wiki\hot.md を読み込み、「今日の AI ニュース」セクションを以下の形式で更新 (なければ追加):

```
## 今日の AI ニュース
*最終更新: YYYY-MM-DD HH:MM*

1. [ヘッドライン 1]
2. [ヘッドライン 2]
3. [ヘッドライン 3]

詳細: brain/07_research/ai-news/YYYY-MM-DD.md
```

## 品質基準

- 信頼度「高」: 公式発表・公式ブログ・1 次ソース
- 信頼度「中」: TechCrunch / The Verge / MIT Tech Review 等の信頼メディア
- 信頼度「低」: 個人ブログ・未確認ソース → 「未検証」と明記
- 「おそらく」「たぶん」を根拠にしない
- ソースなしの断定をしない

## ヘッドライン選定の優先基準

以下の順に重み付けする:
1. Claude / OpenAI / Gemini の新モデル・重大 API 変更
2. 日本の AI 規制・補助金の新発表 (中小企業向けが最優先)
3. Almeo の競合 (AI 教育×日本市場) の動き
4. 大型調達 ($1B+) またはIPO動向
5. 大井が今日使えるツール・機能

## 注意事項

- 昨日と同じニュースを再掲しない
- ディレクトリ C:\Users\Owner\business\brain\07_research\ai-news\ が存在しない場合は作成する
- 保存完了後「本日の AI ニュースを保存しました: [ファイルパス]」と出力する
</scheduled-task>
```
