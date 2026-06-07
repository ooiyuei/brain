---
type: sleep-consolidation
date: 2026-06-07
source: episodic
consolidated_by: Claude (sleep cycle / hippocampal->neocortical)
inputs:
  - wiki/daily/2026-06-07.md
  - 08_openclaw/PDCA-environment-log.md (Cycle 1-6)
  - wiki/_conversations/2026-06-07/ (8 utterances)
  - 00_YUEI/NOTES.md
  - wiki/hot.md
related: [[08_openclaw/PDCA-environment-log]] [[09_knowledge/frameworks/2026-06-07-self-improvement-loop]] [[09_knowledge/frameworks/2026-06-07-brain-cognitive-architecture]] [[02_newbiz/eemus]]
---

# 2026-06-07 睡眠consolidation — OpenClaw環境「ちゃんと動く」達成日

> 今日の本筋: 大井「PCがフル回ってない・もったいない・24h自走しろ・PDCAで回し続けろ」→ 1日6サイクルのPDCAでOpenClaw環境を「ちゃんと動く」状態まで構築。価値の本体は量(GPU100%)でなく「Opus polish + 昇格」だと再確認。並行して夢AWARD締切・法人知識の壁打ち依頼が発生。

---

## 1. 決定 (decisions) — 最高グレード知識

### D1. OpenClaw「ちゃんと動く」= 3機構の定義を確定
「止まる/溜まる」の振動を終わらせる定義を固めた。**「止まらない(生成) + 溜まらない(整理) + 磨いて昇格する(価値変換)」** の3機構が同時に回ることを"ちゃんと動く"と定義。GPU100%稼働それ自体は目的ではない(junk化するため)。
- 止まらない: `priority_filler`(hourly, durable) + BG*日次研究
- 溜まらない: `consolidate_inbox`(hourly, **Claude非依存**)
- 磨いて昇格: `auto-polish`(named workflow, 自走discovery) → `_polished/_READY` → 大井《要記入》→ canonical

### D2. ローカルqwenは「60点の量産」止まり — 価値レバーはOpus polish (再確認・確定)
大井の発話「60点くらい出してそっからClaudeで90点まで磨けばいい」が今日の設計思想の核。qwen実測スコア**平均~33点**(投資家ピッチは12点=大井を投資ファンドと誤認し全数字捏造)。**Opus磨きで平均~89点**に到達。よってbase modelの差し替えではなく polish step が本物の価値レバー。これを `/loop` の標準ACTステップに昇格。

### D3. モデル戦略 — qwen3:8b 一本で確定 (LATE/別モデル検討を却下)
大井「latedみたいなモデルなかったっけ?ほかはどう?」に対し再評価。結論は **GPU 8GB制約で qwen3:8b(6GB/100%GPU) が上限**。14b=遅すぎ(1文5分)、qwen3.6=23GBでOOM(6/3削除・**二度と入れない**を再確認)。モデル探索より「タスク粒度を細かく + Opus polish」で精度を上げる方針に確定。

### D4. Cost Guard 導入 — flood を構造的に不可能化 (harvest #1採用)
`dispatch.ps1`(全producer唯一のchokepoint)に日次レート上限を実装。`$guardMax=60/日`(暫定・super bypass)。実enqueue成功時のみカウント。**三重防御完成**: backpressure(溜まり過ぎ=在庫150) / dedup(同一12h) / cost-guard(日次出し過ぎ)。437件/晩のfloodは二度と起きない。

### D5. priority_filler を durable 化 (stale silent-skip の根治)
GPUアイドルの根本原因 = セッション死→priorities >48h stale→filler が **silent skip**→生成停止。3分岐に改修: <48h=通常 / 48-168h=last-known-good継続投入 / >168h=abandoned停止。

### D6. consolidate_inbox を Claude非依存スケジューラ化
398件の_inbox事故の機械的対策。日付違い重複クラスタ→最新1本残し旧版archive、極小(<330B)/errstub→junk隔離。全てmove(非破壊)。`schtasks BrainConsolidateInbox` hourly登録。LLM判断不要部分をスケジューラ単独化=Claude不在でも24/7整理。

### D7. auto-polish を named workflow 化
`~/.claude/workflows/auto-polish.js` に保存。2 phase(Discover=_inbox glob − _polished差分 + entity自動マップ / Polish=Opus並列90点化)。今後の `/loop` tickは `Workflow({name:"auto-polish"})` を呼ぶだけで新着を自動昇格。idempotent。手組み不要の反復ループ確立。

---

## 2. 新事実 (facts) — 確立した durable な事実

- **F1. 6サイクルのPDCAを1日でship**: Cycle1機械consolidation → 2 filler durability → 3 自動polish → 4 polish自動discovery → 5 GitHub harvest → 6 Cost Guard。すべて本番検証済み(exit0/encoding破損なし)。
- **F2. qwenの典型的故障モード**(polish時に実検出): 価格捏造/誤り(aipa-web 月10-15万→3プラン化が必要)、メタ指示混入(月次レポートにqwenの自己指示が漏出)、bold反復5-12回、架空facts捏造(Studyplus等)→《要記入》化、投資家ピッチでの相手属性の取り違え。
- **F3. dispatched=N は「呼んだ数」であって実投入数ではない**: dedupで実投入0が多く、refresh期間中はfillerは実質no-op。連続価値の本体はBG*日次研究(新規) + Opus polish + Claude refresh。
- **F4. 「動作悪い」の真因はOpenClaw工場ではなくClaudeセッションの即死**(3-4分で落ちる、daily 6/6-6/7に多数)。工場は健全・アイドルだった。queue/results 3450件は処理済み履歴(harvestはresults/{部署}/のみ対象)。真の未処理はwiki/_inbox ~430件。
- **F5. GitHub harvest方針**: 高star AI/agentリポは「アルゴリズムだけ移植、TS/Postgres/Electronはcloneしない」判定。推奨5パターン: A Cost Guard / B Sleep Cycle(episodic→semantic、**まさに本consolidation**) / C RRF+MMR re-rank / D telemetry scoreboard / E frontmatter schema。skip: dry-run forgetting(既存)・token budget(8GBにoverkill)。
- **F6. 並行コンテキスト(事業側)**: 夢AWARD締切=本日6/7必着(提出パッケージ完成済・大井のみ提出可)。大井から「会社としての立ち回り(合併/業務提携/子会社等の法人知識)を教えて」の壁打ち依頼が発生(相方からのリクエスト経由)。

---

## 3. 学び (learnings) — 再利用可能なパターン/教訓

- **L1. volume ≠ value**: GPUを100%にすること自体は目的でない。filler全開→junk洪水(398件)、filler停止→GPUアイドル。間に「value-gated定常生成 + 自動consolidation」が無いと振動する。"溜まる/止まる"の両極は同じ病。
- **L2. Opus-polish-dominates**: base modelを上げるより、安いモデルで骨(60点)を量産し高いモデルで仕上げ(90点)る方が費用対効果が高い。33点→89点の段差は polish step が生む。
- **L3. PS5.1 ASCII rule**: Writeツールはno-BOMで出力→PS5.1がShift-JIS誤読→文字化け→parse error。**新規.ps1はASCIIで書く**(処理対象の日本語ファイル名は実行時OK)。Editツールは既存encodingを保持する(BOM保持を実証済)→既存.ps1への追記はEdit。
- **L4. 単一chokepointに防御を集約する**: 全producerが通る`dispatch.ps1`一箇所にrate guardを置くことで、producer個別実装なしに全体の上限を保証。カウントは「実行の意図」でなく「実際の副作用(enqueue成功)」で取る。
- **L5. 機械的にできる整理はLLMから剥がす**: dedup/stub隔離はregexで足りる→スケジューラ単独化でClaude不在でも回る。LLM判断が要るのは salience/promote判定のみ。
- **L6. durabilityは「沈黙して止まる」を疑え**: stale時のsilent skipが最も発見しにくい停止モード。「何もしない」を明示的に3分岐(継続/last-known-good/abandoned)で設計する。
- **L7. 現在地確認の罠**: 「動作悪い」の訴えで工場(OpenClaw)を疑ったが真因はharness側のセッション即死。"何が動いていないか"を機構別に切り分けてから手を打つ。

---

## 4. 未解決 (open threads) — pending / 大井判断待ち

- **OT1. 🔥 夢AWARD 提出** — 本日6/7締切・提出パッケージ完成済(`00_YUEI/夢AWARD-提出パッケージ-即コピペ用.md`)・**大井のみ提出可**。11日連続未着手。consolidation時点で結果0/3。
- **OT2. AIpaX 5社目クロージング連絡1本** — メール草稿完備・大井が1通送るだけ。月収80万ギャップの最速手。
- **OT3. Anthropic課金試算** — 6/15締切(クレジット制移行)。**要確認: OpenClawがAgent SDK認証か直接APIキーか**(後者なら影響なし)。24h自走に直撃の恐れ。
- **OT4. 大井判断: Cost Guard上限値** — `$guardMax=60/日`は暫定。tune可(dispatch.ps1冒頭)。
- **OT5. 大井判断: pattern B (Sleep Cycle) でqwenにentity自動編集を許すか** — 現状は大井未承認のため auto-edit禁止(本consolidationも既存ノート非編集・additiveのみ)。
- **OT6. _polished/_READY の《要記入》箇所** — 13本+αが87-90点で大井最終化待ち(価格・実factsの確認が必要な箇所)。
- **OT7. 法人知識の壁打ち未回答** — 「合併/業務提携/子会社等の法人としての立ち回り」を大井に教える依頼が15:36に発生。本日のセッション流れではOpenClaw環境構築に吸収され未対応。
- **OT8. 次サイクル候補** — cycle7 = B Sleep Cycle consolidation(本件で着手) or D telemetry(guard/throughput可視化) or C RRF+MMR re-rank / cycle: harvest.ps1 intake-gate / fidelity harness。
- **OT9. セッション即死の根因** — harness側の可能性。未特定。再発リスクあり。

---

## consolidation メタ
- 本ファイルは additive。既存 entity/concept ノートは編集していない(大井のauto-edit承認待ち=OT5)。
- 本consolidation自体が GitHub harvest 推奨パターン B「Sleep Cycle(episodic→semantic)」の初稼働。
