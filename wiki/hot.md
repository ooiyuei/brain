---
type: hot-cache
updated: 2026-06-02 07:53
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

## 🌅 Today（2026-06-01 結果）

**絶対やる1個**: 夢AWARD応募骨子 ❌ 未着手（6日連続）
**サブ①**: AIpaX 5社目クロージング ❌ 未着手
**サブ②**: Digital AI補助金確認 ❌ 未着手（最低優先）
**Claude完了**: 昼PDCA（1件昇格・10件削除・qwen3:8bバグ検出）

## ☀️ Midday（12:30 昼チェック）

**日付**: 2026-06-01
**進捗**: 夢AWARD骨子 ❌未着手（残5日・叩き台2本あり・今日30分で完成できる） / AIpaX5社目クロージング ❌未着手（大井の連絡1本のみ） / Digital AI補助金 ❌未着手（最低優先）
**PDCA**: 1件昇格（AIpa Web静岡企業リスト→research/）・10件削除（qwen3:8bバグ3+重複7）⚠️ qwen3:8b worker が ooi-yuei.md を出力するバグ確認
**午後**: ①夢AWARD骨子v3（`_promoted/newbiz/eemus-dream-award-骨子v3-2026-05-27.md`）を開いて30分肉付け → 今日完成 ②AIpaX 5社目クロージング連絡
**詳細**: [[_routines/midday-20260601]]

## 🌙 Tomorrow（2026-06-02）

**最優先**: **夢AWARD応募骨子を完成・提出** — 6/7締切・残**5日**。6日連続未着手。叩き台2本（`_promoted/newbiz/eemus-dream-award-骨子v3-2026-05-27.md`・`eemus-dream-award-story-2026-05-31.md`）はある。朝一番・他を全部閉じて30分だけ向き合う。明日やらないと手遅れ。
**サブ①**: **AIpaX 5社目クロージング接触** — 想定問答15選完成済み。大井の連絡1本のみ。月収80万ギャップの最速手。
**サブ②**: **qwen3:8bバグ対処** — BG-Entities系context_files設定修正。ooi-yuei.mdを除外するかqwen3.6:latestに切替。
**詳細**: [[_routines/evening-20260601]]

---

## 📍 今ここ (Live State)

**Last session**: 2026-06-01 夜 — 夜ルーティン (evening-20260601生成/done.mdアーカイブ/hot.md更新)
**Last touched files**:
- `brain/wiki/_routines/evening-20260601.md` (夜メモ生成)
- `brain/wiki/_tasks/done.md` (6/1完了タスクアーカイブ)
- `brain/wiki/hot.md` (Tomorrow 6/2更新)

**現在の Mode**: 夜ルーティン完了
**完了**: 昼PDCA（1件昇格/10件削除）・qwen3:8bバグ検出
**未完**: 夢AWARD骨子（大井の肉付け30分・残5日・6日連続未着手）/ AIpaX 5社目接触（大井アクション1本のみ）
**⚠️ 懸念**: qwen3:8b が context_files 末尾を出力するバグ → BG-Entities系3件破損

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
*最終更新: 2026-06-02 07:53*

1. ★ デジタル化・AI導入補助金2026 の **2 次締切が 6/15**（残13日）— 補助率 1/2〜4/5・上限450万円、生成AIツールも対象（登録済みのみ）。Almeo の中小企業 AI 導入支援の提案窓。今が動くタイミング
2. Anthropic が **$65B 調達・評価額 $965B**（Series H、Altimeter/Sequoia 主導）— Q1 2026 は VC の AI 投資が世界全体の80%。Claude 基盤の長期安定性↑＝OpenClaw を Claude に張る判断を補強
3. Google が **Gemini CLI を 6/18 に Antigravity CLI へ統合**（Pro/Ultra/無料枠は提供停止、CLI 利用者は移行必須）— エージェント実行の計量化が業界トレンドに（Anthropic 6/15 と同方向）

※継続フォロー: Anthropic 6/15 Agent SDK 従量課金化（OpenClaw 自動化に直撃・要 opt-in＋プロンプトキャッシュ）/ OpenAI GPT-4.5 は 6/27 廃止

詳細: brain/07_research/ai-news/2026-06-02.md

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
