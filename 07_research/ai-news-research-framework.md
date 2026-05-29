# AI 毎日リサーチフレームワーク

**担当:** Researcher Agent (OpenClaw)
**更新:** 2026-05-28
**保存先:** `C:\Users\Owner\business\brain\07_research\ai-news\YYYY-MM-DD.md`

---

## A. フレームワーク概要

毎朝 8:00 に OpenClaw が自律実行し、大井が朝のルーティン中に読める形で brain に蓄積する。
判断・意思決定は大井が行う。Researcher は情報収集・整形・保存のみを担当する。

### 実行主体

| タスク | 担当 | 手段 |
|---|---|---|
| Web 検索・収集 | OpenClaw (Researcher Agent) | WebSearch / WebFetch |
| Markdown 整形 | OpenClaw | テンプレートに従い出力 |
| brain 保存 | OpenClaw | Write ツール |
| 重要発表通知 | OpenClaw | Discord Webhook (blue embed) |
| 読む・判断する | 大井湧瑛 | 日報ルーティン内 |

---

## B. 情報源リスト (優先度順)

### Tier 1: 毎日必ずチェック（最重要）

| 情報源 | URL | チェック内容 |
|---|---|---|
| Anthropic ブログ | https://www.anthropic.com/news | Claude 新機能・API 変更・モデルリリース |
| Anthropic リリースノート | https://releasebot.io/updates/anthropic | 細かい機能追加 |
| OpenAI ニュース | https://openai.com/news/ | GPT 系モデル・ChatGPT 機能 |
| Google AI Blog | https://blog.google/technology/ai/ | Gemini 系・Google I/O 関連 |
| Gemini API リリースノート | https://ai.google.dev/gemini-api/docs/changelog | API 変更・新機能 |

### Tier 2: 週 3〜5 回（主要ニュース）

| 情報源 | URL | チェック内容 |
|---|---|---|
| TechCrunch AI | https://techcrunch.com/category/artificial-intelligence/ | スタートアップ・調達 |
| The Verge AI | https://www.theverge.com/ai-artificial-intelligence | 一般向けプロダクト動向 |
| MIT Technology Review AI | https://www.technologyreview.com/topic/artificial-intelligence/ | 技術的深掘り |
| Hugging Face Blog | https://huggingface.co/blog | OSS モデル・新技術 |
| arXiv cs.AI / cs.LG | https://arxiv.org/list/cs.AI/recent | 論文・技術トレンド |

### Tier 3: 週 2〜3 回（日本市場）

| 情報源 | URL | チェック内容 |
|---|---|---|
| ITmedia AI+ | https://www.itmedia.co.jp/aiplus/ | 国内 AI ニュース |
| ASCII.jp AI | https://ascii.jp/tag/ai/ | 国内動向 |
| Forbes Japan テクノロジー | https://forbesjapan.com/tags/technology | 起業家・投資視点 |
| 日本経済新聞 DX | https://www.nikkei.com/topic/dx/ | 中小企業 AI 動向 |

### Tier 4: 週 1〜2 回（個人発信・ツール）

| 情報源 | カテゴリ | チェック内容 |
|---|---|---|
| Andrej Karpathy (X/YouTube) | 研究者 | 技術解説・AI 所見 |
| Yann LeCun (Meta AI) | 研究者 | LLM 懐疑論・代替アーキテクチャ |
| 落合陽一 (X) | 日本オピニオン | 国内 AI 活用・社会変容 |
| 安宅和人 (X) | 日本オピニオン | データ・AI 戦略 |
| Simon Willison (simonwillison.net) | エンジニア | LLM 実装ネタ・技術解説 |
| Y Combinator | スタートアップ | AI スタートアップ採択傾向 |
| Cursor changelog | ツール | コーディング AI 最前線 |
| Lovable / Bolt / Replit | ツール | No-Code/Low-Code AI 動向 |
| Vellum changelog | ツール | LLM Ops・プロンプト管理 |

---

## C. 毎日の出力フォーマット

ファイル名: `C:\Users\Owner\business\brain\07_research\ai-news\YYYY-MM-DD.md`

```markdown
# AI ニュース YYYY-MM-DD

**収集:** OpenClaw Researcher Agent
**実行時刻:** HH:MM JST

---

## 今日のヘッドライン 3 つ

> 大井が 2 分で読んで判断できる形にまとめる。事業インパクト順に並べる。

1. **[タイトル]** — [1 文で意義を説明。Almeo/Testall 関連なら★マーク]
2. **[タイトル]** — [同上]
3. **[タイトル]** — [同上]

---

## 新機能・新製品リリース

### [製品名 / 企業名]
- **内容:** [具体的な機能・変更点]
- **対象:** [誰向け: Dev / Enterprise / 一般ユーザー]
- **料金変化:** [あれば記載]
- **API 変更:** [あれば記載 — 大井のコードに影響する可能性]
- **ソース:** [URL]
- **信頼度:** 高/中/低

---

## 技術トレンド (論文・実装)

### [論文タイトル / 技術名]
- **概要:** [3 行以内]
- **実用化の見通し:** [短期 / 中期 / 長期]
- **ソース:** [URL or arXiv ID]
- **信頼度:** 高/中/低

---

## 競合動向 (AI コンサル・AI 教育・AI SaaS)

| 企業/プロダクト | 動き | Almeo への示唆 |
|---|---|---|
| [名前] | [何をした] | [真似すべきか / 差別化ポイントか] |

---

## 投資・M&A・IPO ニュース

| 企業 | 金額 | ラウンド | 評価額 | 示唆 |
|---|---|---|---|---|
| [名前] | [金額] | [Series X / IPO] | [$XB] | [市場規模・競合の資金力] |

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
| [今日の情報] | [高/中/低 + 理由] | [今週 / 今月 / 将来] | [具体的に何をするか] |

---

## 未確認・要フォローアップ

- [ ] [気になるが情報が少ない件]
- [ ] [明日以降の発表を待つ件]
```

---

## D. 実装手順

### ステップ 1: ディレクトリ確認

```
C:\Users\Owner\business\brain\07_research\ai-news\
```

このディレクトリが存在することを確認。なければ作成。

### ステップ 2: OpenClaw Scheduled Task 設定

**推奨実行時刻: 毎朝 07:45 JST**
(大井がコメダに行く前・または朝ルーティン中に読める形にする)

Scheduled Task のプロンプト:

```
あなたは Researcher Agent です。
以下の手順で AI 最新情報リサーチを実行してください。

1. WebSearch で以下のクエリを実行 (並列実行):
   - "Anthropic Claude update [today's date]"
   - "OpenAI release announcement [today's date]"  
   - "Google Gemini update [today's date]"
   - "AI startup funding news [today's date]"
   - "AI Japan news [today's date]"

2. 重要なニュース記事は WebFetch で本文を取得して詳細確認

3. C:\Users\Owner\business\brain\07_research\ai-news\YYYY-MM-DD.md に
   フレームワーク C のフォーマットで保存

4. ヘッドライン 3 つを brain/wiki/hot.md の「今日のAIニュース」セクションに追記

5. Claude / Anthropic の重大発表があれば Discord に通知
   (webhook: brain の secrets に保存)

信頼度基準:
- 高: 公式発表・公式ブログ・1次ソース
- 中: TechCrunch / The Verge / MIT Tech Review 等の信頼メディア
- 低: 個人ブログ・未確認ソース
```

### ステップ 3: hot.md との連携

`C:\Users\Owner\business\brain\wiki\hot.md` に以下セクションを追加:

```markdown
## 今日の AI ニュース
*最終更新: YYYY-MM-DD HH:MM*

1. [ヘッドライン 1]
2. [ヘッドライン 2]  
3. [ヘッドライン 3]

詳細: brain/07_research/ai-news/YYYY-MM-DD.md
```

### ステップ 4: Discord 通知条件

以下のいずれかに該当する場合のみ通知 (spam 防止):
- Claude / Anthropic の新モデルリリース
- OpenAI / Google の新モデルリリース
- 日本の AI 規制・補助金の新発表
- Almeo 競合の $10M+ 調達
- API の破壊的変更 (大井のコードに影響)

---

## E. 価値判断基準 (ヘッドライン 3 つの選び方)

### 優先度マトリクス

| カテゴリ | 最優先 | 優先 | 通常 |
|---|---|---|---|
| モデルリリース | Claude / GPT 系の新主力モデル | Gemini / Grok 等 | OSS モデル |
| API 変更 | 破壊的変更・料金変更 | 新機能追加 | 細かい改善 |
| 競合 | AI 教育×日本市場の競合 | AI コンサル競合 | 海外のみの競合 |
| 規制 | 日本の AI 規制・補助金 | EU AI Act 影響 | 米国のみの規制 |
| 投資 | 教育×AI の $1B+ 調達 | AI SaaS の大型調達 | 海外技術系の調達 |
| ツール | 大井が今日使えるもの | 1 週間以内に使えるもの | 将来的に参考 |

### Almeo 事業軸でのフィルター

大井の事業 (AI コンサル / AI 教育 / Testall / AI×中小企業) に照らして:
- **直撃**: 「これは明日の提案に使える」レベル → 必ずヘッドライン入り
- **間接**: 「競合が使い始めたら差別化が必要」レベル → 技術トレンドセクションへ
- **参考**: 「5 年後に重要かも」レベル → 記録のみ

---

## F. 品質チェックリスト (毎日実行時)

- [ ] ソースが公式または信頼メディアか
- [ ] 昨日と同じニュースを再掲していないか
- [ ] 「おそらく」「たぶん」を根拠にしていないか
- [ ] Almeo への適用可能性が具体的か (「検討する」禁止)
- [ ] ファイルが正しいパスに保存されたか
- [ ] hot.md が更新されたか

---

## G. サンプル出力 (2026-05-28)

→ `C:\Users\Owner\business\brain\07_research\ai-news\2026-05-28.md` を参照
(本日分は本フレームワーク文書に続けて記載)

---

## H. 調査の限界

- Web 検索の地域バイアス: 英語圏の情報が多くなりやすい。日本語ソースは別途専用クエリが必要
- リアルタイム性: WebSearch のインデックス遅延で数時間遅れる場合あり
- 有料コンテンツ: WSJ / Nikkei 等の有料記事は本文取得不可 (タイトルのみ)
- SNS 速報: X (Twitter) の速報は WebSearch に反映されるまでタイムラグあり
- 論文の深度: arXiv 論文は概要のみ。実装の品質は別途検証が必要
