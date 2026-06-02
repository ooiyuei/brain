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

## 🌅 Today（2026-06-02）

**絶対やる1個**: **夢AWARD応募骨子 完成・提出準備** — 残5日（6/7締切）・7日連続未着手・朝一番30分
**サブ①**: AIpaX 5社目クロージング接触（大井の連絡1本のみ）
**サブ②**: qwen3:8bバグ対処（BG-Entities系 context_files修正・Claudeがやる）
**⚠️ 注意**: 監視ファイル（competitor/deadlines/grill）本日未生成（BrainMonitor遅延？）

## ☀️ Midday（12:30 昼チェック）

**日付**: 2026-06-02
**進捗**: 夢AWARD骨子 ❌未着手（残4日・今日中にやらないと詰む） / AIpaX5社目クロージング ❌未着手（想定問答inboxにあり・大井の連絡1本のみ） / qwen3:8bバグ ❌未着手（設定修正が必要）
**PDCA**: 1件昇格（AIpa Web静岡企業候補リスト→research/aipa-web-shizuoka-companies-2026-06-02.md）・10件削除（Stripe qwen3:8b×4+重複×6）
**午後**: ①今から30分で夢AWARD骨子仕上げ（叩き台2本+inbox骨子あり）②AIpaX5社目に連絡 ③夜にqwen3:8b設定修正
**詳細**: [[_routines/midday-20260602]]

## 🌙 Tomorrow（2026-06-03）

**最優先**: **夢AWARD応募骨子を完成・提出** — 6/7締切・残**4日**。**9日連続未着手**。骨子v3（`_promoted/newbiz/eemus-dream-award-骨子v3-2026-05-27.md`）は揃ってる。朝起きてすぐ・スマホ開く前に骨子v3を開く・30分で仕上げる。明日がラスト。
**サブ①**: **AIpaX 5社目クロージング接触** — 想定問答15選完成済み。大井の連絡1本のみ。月収80万ギャップの最速手。
**サブ②**: **qwen3:8bバグ対処** — BG-Entities系context_filesからooi-yuei.md除外。Claudeが設定ファイルを直接修正。
**詳細**: [[_routines/evening-20260602]]

---

## 📍 今ここ (Live State)

**Last session**: 2026-06-03 深夜 — **OpenClaw 24h自走の根治オーバーホール**(Claude/Opus4.8・全権委任)。「ぶん回しが止まる」の根本原因(qwen3.6 OOM/レーン飢餓/num_ctx/プロデューサ過多)を13件恒久修正・実証完了。
**Last touched files**:
- `brain/scripts/worker.ps1` `dispatch.ps1` `queue_guard.ps1` `daily_brain.ps1` (修正)
- `~/.openclaw/openclaw.json` + `agents/*/models.json` (qwen3:8b統一)
- `~/.claude/settings.json` (会話ログhook復旧)
- `brain/09_knowledge/failures/2026-06-03-openclaw-24h-自走-根本原因と恒久対策.md` (恒久記録)
- `brain/00_YUEI/REPORT.md` (朝レポート)

**現在の Mode**: インフラ最強化 完了・実証済み
**完了**: qwen3.6削除/agent経路一本化/num_ctx8192/レーン修正/一元バックプレッシャ/BOM修正11本/会話ログ復旧。キュー排出 8→48件/時、Ollamaクラッシュ0
**未完(大井判断待ち)**: 文字化け568件の隔離可否 / inbox1336昇格パイプライン / filler優先度の質転換 / GPU増設
**未完(事業)**: 夢AWARD骨子(残4日・**10日連続未着手**) / AIpaX 5社目接触
**⚠️ 懸念**: 夢AWARD 6/7締切 / openclaw mainセッションsticky qwen3.6(VSCode ACP使うなら/reset)

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
*最終更新: 2026-06-03 07:53*

1. ★ Anthropic が **IPO 申請 → 翌日（6/2）Claude 全面障害** — OpenClaw は 100% Claude 依存＝**単一障害点が現実化**。Claude 不通時に qwen3:8b へ退避する最小フォールバックを worker.ps1 に検討
2. ★ **Claude Opus 4.8 ベンチ判明**（大井が今動かしてる基盤）— agentic coding 64.3→**69.2%**、fast mode が **2.5x 速・1/3 コスト**、コーディングは高 effort デフォルト。OpenClaw を fast mode 固定＋キャッシュ化で 6/15 課金変更に先回り
3. **3 大ラボが「常駐自律エージェント」へ収束** — GPT-5.6（6月予定）/ Gemini Spark（24/7 常駐）/ Opus dynamic workflows。**OpenClaw 24h 自走の方向性は業界本流**。差別化は「日本 SMB 業務文脈への張り付き」

※継続フォロー: 補助金 2次締切 **6/15**（残12日・Almeo の提案窓）/ 6/15 Agent SDK 従量課金化＋Sonnet4/Opus4 API 退役 / GPT-4.5 は 6/27 廃止

詳細: brain/07_research/ai-news/2026-06-03.md

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
