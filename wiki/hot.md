---
type: hot-cache
updated: 2026-06-05 07:52
structure_version: 2
managed_by: Claude (must update every session)
---

# 🔥 hot.md — 直近コンテキスト & 先回りヒント貯蔵庫

> **このファイルは Claude が毎セッション読み・毎セッション更新する。**
> 単なる「直近の事実」ではなく「Claude が次に動くために必要な全情報」を集約。
> 詳細スナップショット (静的) → [[dashboards/business-snapshot]]
> 大井プロファイル入口 → [[meta/ooi-profile-index]]
> OpenClaw稼働状況 → [[dashboards/openclaw-activity]]

---

## 📅 This Week [[2026-W22]] (5/25-5/31) — 棚卸し完了

**主な動き** (詳細: [[_routines/weekly-2026-W22]]):
- 会社インフラ4種同日契約 (ドメイン+Google Workspace+Slack+Notion) + Phase 2 (9部署+大井ホーム) 物理化
- OpenClaw工場フル稼働: brain git 1067 commits, 4件昇格, 275件以上削除, 新規4案 (tobira-log/aisho-check/senbatsu-lp/大井塾)
- Almeo MVV「熱狂を、つくる。」確定 + 大井クローンv4 spec + コメダ事件 → 7.5h完全復帰プロトコル化
- AIpaX 80万提案書/クロージング想定問答15選 + EEMUS 夢AWARD骨子v3/ストーリー骨子 完備
- Digital AI補助金 第1次 (5/31) ロスト → 第2次 (8月末) 切替確定

## 📅 Next Week [[2026-W23]] (6/1-6/7)

1. 🔥 **攻める: 夢AWARD 応募骨子完成 → 提出** (6/7締切・残6日・叩き台2本揃い済み・大井30分肉付けのみ)
2. 🌱 **種まき: AIpaX 5社目クロージング接触** (想定問答15選+80万提案書完備・大井の連絡1本だけ・月収80万ギャップ最速手)
3. 🪦 **やめる/寝かす: AIpaX school を独立事業から外し AIpaX 教育コースとして統合判断** (来週中に確定)

---

## 🌅 Today（2026-06-05）— 振り返り完了

**結果**: 0/3（大井の着手ゼロ・5日連続）。PDCA昇格2件・OpenClaw 54件着弾。工場は動いた。
**詳細**: [[_routines/morning-20260605]] | [[_routines/midday-20260605]] | [[_routines/evening-20260605]]

---

## 🌅 Today（2026-06-06）— 振り返り完了

**結果**: 0/3（大井着手ゼロ・11日連続）。OpenClaw 41件完了・工場は動いた。
**詳細**: [[_routines/evening-20260606]]

---

## 🌅 Today（2026-06-07）— 締切日 🔥🔥

**絶対やる**: 夢AWARD フォーム送信（`brain/00_YUEI/夢AWARD-提出パッケージ-即コピペ用.md` → コピペ15〜30分で完了）
**フォーム**: https://ws.formzu.net/fgen/S49170529/ ← 今すぐ開く
**結果**: 0/3 未着手（13:xx Midday時点）

**Midday**: 昇格1件（EEMUS 60秒ピッチ台本）・削除3件（ハルシネ研究/ダミーCF/汎用プラン）

1. 🔥🔥 **夢AWARD フォーム提出（締切当日・今日で終わり）** — 提出パッケージ完成済み・個人情報+1文追記+送信だけ
2. 🌱 **AIpaX 5社目クロージング連絡1本** — アプローチメール草稿完備・1通送るだけ
3. ⏰ **Anthropic課金試算** — 残8日・overflow設定

---

## 🌅 Yesterday（2026-06-05） — 振り返り完了

**結果**: 0/3（朝計画全未着手）。OpenClaw 250+件完了・工場は回った。大井の着手ゼロ。
**詳細**: [[_routines/morning-20260604]] | [[_routines/midday-20260604]] | [[_routines/evening-20260604]]

---

## 📍 今ここ (Live State)

**Last session**: 2026-06-07 15:xx — **「昨日から動作悪い」の診断＆作業再開**(Claude/Opus4.8・ultracode)。原因は**Claudeセッションが3〜4分で落ちてた**こと(daily 6/6-6/7に多数の即死セッション)。**OpenClaw工場は健全・アイドル**(queue空・worker正常tick)と確認。
**判明**:
- queue/results 3450件 = **処理済み履歴**(harvestは results/{部署}/ のみ対象)。要対応ではない
- 真の未処理は **wiki/_inbox 約430件**(marketing177/newbiz156/corp34/research20/dev11)の未昇格ドラフト → 部署別トリアージ workflow 起動済み
- 夢AWARD締切=**本日6/7必着**で公式確認(時刻明記なし)
**Last touched files**:
- `brain/00_YUEI/TODAY.md` (6/7用に再生成・夢AWARD最優先化)
- `brain/wiki/hot.md` (このLiveState)

**現在の Mode**: 作業再開・工場inbox棚卸し中
**未完(大井判断待ち・本日)**: 🔥**夢AWARD提出(締切本日・11日連続未着手)** / AIpaX 5社目接触
**未完(Claude進行中)**: wiki/_inbox 430件トリアージ→優良昇格・ゴミ一掃(workflow完了待ち)
**⚠️ 懸念**: 夢AWARD **本日締切** / セッション即死の再発(原因未特定・harness側の可能性)

---

## 🚨 今日 (2026-05-27) 必ずやる

> 期限が近い / 大井の手が必要 / 放置すると損失。

| # | やること | 期限 | 担当 | 状態 |
|---|---|---|---|---|
| 1 | 夢AWARD骨子 (5日連続未着手) | 5/29 14時 (Calendar済) | 大井のみ | ❌ 持ち越し |
| 2 | AIpaX 5社目クロージング状況確認 | 5/28 (昨夜20時 Calendar) | 大井 | ⏳ 5/28へ |
| 3 | AIpa Web inbox 9件昇格判定 | ✅完了 | Claude | ✅ 完了 |
| 4 | SFC AO論点メモ | 5/28 19時 (Calendar済) | 大井+Claude | ⏳ ドラフト完成済み |
| 5 | queue/inbox 1521件滞留解消 | ✅完了 | Claude | ✅ 完了 (archive+AutoReview停止) |
| 6 | 会社インフラ確立 | ✅完了 | 大井 | ✅ 完了 (ドメイン+G Suite+Slack+Notion) |

---

## 💡 Claude からの先回り提案 (3案)

> 大井から指示が来てない時、Claude が「これやっとこ」と能動的に提案する候補。

### A. AIpa Web inbox 5件昇格判定 (推奨)
- 5/26 着弾済み: 商工会メール3パターン・静岡企業10社リスト・LP最適化3案・X広告コピー5案・月10万モニター契約書テンプレ
- Claude が `wiki/_inbox/_reviews/marketing/` か `newbiz/` を読んで PROMOTE/KEEP/ARCHIVE 判定 → 該当ファイルを `wiki/{正式パス}/` へ移動
- 効果: 5/26 の成果物が今日中に正式蓄積、AIpa Web の営業準備が一段進む
- 工数: 15-30分

### B. 大井プロファイル統合の品質チェック
- [[meta/ooi-profile-index]] を作ったが、各 ooi-* ファイル間の矛盾チェックは未実施
- ooi-deep-synthesis-2026-05-20 を最新マスターとして、矛盾点があれば旧文献に「過去の認識」タグ
- 効果: 大井クローン応答の精度向上

### C. シンコード/森岡素材のスキル化
- 5/26 取り込んだ森岡続編・AIコーディング教科書・シンコードraw が `_inbox/` 5件
- スキル化候補: 「明日使う1人」フレーム、「絶対に買う1人」フレーム、F1ストーリーテリング雛形等
- 効果: 営業文・LP・X投稿で常時呼び出せるテンプレ完成

---

## 今日の AI ニュース
*最終更新: 2026-06-07 07:53*

1. ★ **【6/15 締切・残8日】Anthropic サブスク経由のプログラム課金分離 — Pro $20 / Max5x $100 / Max20x $200/月クレジット制（繰越なし・API定価）、対象は Agent SDK・`claude -p`・GitHub Actions・OpenClaw 等の第三者アプリ** — **OpenClaw 24h自走に直撃の恐れ**。本日 TODO #3「Anthropic課金試算」を実施: ①メールでクレジット受領 ②overflow トグル設定 ③月間消費を API レートで試算。**要確認: OpenClaw が Agent SDK 認証か直接APIキーか**（後者なら影響なし）
2. ★ **【競合シグナル】OpenAI Education が国家規模で教育市場を制圧中 — 教員向けニュースレター「The Edu Prompt」創刊、ヨルダン100万生徒・エストニア2万生徒・カザフ8.4万教員に展開** — AIpaX school / Almeo の直接競合。世界規模の無料・国家戦略に対し「日本語×中小/個人塾×伴走型」で差別化必須。NPR 調査(6/5)では教師の 3/4「AI は過去技術超え」
3. ★ **【補助金 実数値確定】デジタル化・AI導入補助金2026 — 通常枠 補助率 1/2・上限 450 万、インボイス枠 最大 3/4・上限 350 万、生成AIツールを補助対象に明確化、4 次締切 8/25** — Almeo を「IT導入支援事業者」登録できれば補助金前提の SMB 提案で成約率が跳ねる（要：登録要件調査）

※継続フォロー: Claude Opus 4.8 既定化＋ultracode / GPT-4.5 退役 6/27・o3 退役 8/26 / Gemini Spark・Omni・3.5 Flash (I/O 2026) / Anthropic 評価額 $965B で OpenAI 逆転 / Cerebras IPO・SpaceX 6/8 ロードショー

詳細: brain/07_research/ai-news/2026-06-07.md

---

## 📥 新着インテリ (取り込み待ち)

> `.raw/` `_inbox/` に届いてるが未消化のもの。

- `wiki/_inbox/ingest/2026-05-27-0540-manifest.md` — `.raw/` 15件の取り込み manifest (新規生成)
- `wiki/_inbox/aipa-web/` (5/26時点で5件) — 契約書テンプレ・X広告・LP案・企業リスト・商工会メール
- ChatGPT 履歴系: notion-export-2026-05-19 (ファイル名 cp932 化け、対処要)

---

## 🎯 直近30日の太線 (shincoder-actions より)

- 期限: **2026-06-21** までに月収100万円 (残25日、現在 AIpaX 約20万/月)
- ギャップ: **80万/月**
- 主戦場: AIpaX 5社目クロージング + AIpa Web モニター獲得 + 中規模ビジコン入賞
- 詳細: [[meta/shincoder-actions-for-ooi-2026-05-25]]

---

## 🎚️ 認知プロファイル (Claude 対話で常に意識)

- 大井の WISC: 言語理解150・視空間140・流動性推理135 / WM110・処理速度115
- 「アイデア生成 >> 実装処理」 → 外部臓器 (Obsidian/Claude/相方) に流す方が早い
- 「努力不足」って感じる時は実は「処理キャパオーバー」。Claude は dispatch で受け止める
- 詳細: [[meta/ooi-deep-synthesis-2026-05-20]]

---

## 📂 入口リスト (Claude が引くべき主要ファイル)

| 用途 | 入口 |
|---|---|
| 全体地図 | [[index]] |
| 静的事業スナップショット | [[dashboards/business-snapshot]] |
| 大井プロファイル統合 | [[meta/ooi-profile-index]] |
| OpenClaw 稼働 | [[dashboards/openclaw-activity]] |
| 部署フロー | [[_routines/department-flow]] |
| 3本柱戦略 | [[meta/three-pillars]] |
| 直近の優先順位 (アクション) | [[meta/shincoder-actions-for-ooi-2026-05-25]] |

---

## 🛠️ hot.md 保守ルール (Claude へ)

1. セッション開始 = まず読む
2. 「今ここ」「今日必ずやる」「先回り提案」「新着インテリ」の4セクションは **動的**。毎セッションで更新する責任あり
3. 太線セクション (`認知プロファイル` 以降) は **準静的**。週1で見直す
4. ファイルが400行超えたら、過去情報を `dashboards/business-snapshot.md` に圧縮
5. 静的詳細は `dashboards/` か `meta/` に外出し
