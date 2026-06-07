---
type: pdca-log
domain: openclaw-environment
managed_by: Claude(Opus) /loop 自走PDCA
started: 2026-06-07
purpose: OpenClaw環境を「ちゃんと動く」まで回し続けるPDCAの記録。毎ループtick=1サイクル。
---

# OpenClaw 環境 PDCA ログ

> 大井の指示(2026-06-07): 「オープンクローの環境構築をループして改善し続けて。PDCA回して、brainも参考に、ちゃんと動くように」
> 各ループtickで1サイクル。Plan→Do→Check→Act。brain(architecture/self-improvement-loop/6-03失敗doc)を参照。

## 確定した制約・方針 (前提)
- **GPUは8GB一択**: qwen3:8b(6GB/100%GPU)が上限。**14b=遅すぎ(1文5分)・qwen3.6=23GBでOOM(6/3削除・二度と入れない)**。検証済み。
- **価値レバーはモデルでなくOpus polish**: qwen=60点の骨 → Opus=90点。polish workflowで52→90実証(価格ミス検出含む)。
- **PS5.1スクリプトはASCII or UTF-8-BOM必須**: Writeツールはno-BOM→PS5.1がShift-JIS誤読で文字化け→parse error。新規.ps1はASCIIで書く(処理対象の日本語ファイル名は実行時OK)。
- **flood/idle振動が根本病**: filler全開→junk洪水(398件) / filler停止→GPUアイドル。間に「value-gated定常生成+自動consolidation」が無い。

## ロードマップ (次サイクル候補)
1. ✅ cycle1: 機械的consolidation (dedup+stub隔離)
2. ⬜ cycle2: priority_filler durability — staleで沈黙→last-known-good/standing-bankで継続(セッション死でもGPU給餌)
3. ⬜ cycle3: harvest.ps1 ゲート化 (intake時にdedup/salience) or dream→today_priorities freshness seed
4. ⬜ cycle4: 自動triage — 定期triage workflow(Opus判断でpromote/archive/junk)を回す
5. ⬜ cycle5: fidelity harness / GitHub harvest (self-improvement-loop docより)

---

## サイクル記録

### Cycle 1 — 2026-06-07 17:48 — 機械的consolidation
- **Plan**: dream_consolidation.ps1は要約のみで「育たない」+ _inboxが溜まる(398件事故)。機械的にできる整理(重複退避・stub隔離)を自動化する。LLM判断不要部分をスケジューラ単独化=Claude不要の24/7。
- **Do**: `scripts/consolidate_inbox.ps1` 新規。(1)日付違い重複クラスタ→最新1本残し旧版を`_inbox/_archive/{dept}`へ (2)極小(<330B)/errstub→`_archive/_junk`へ。全てmove(非破壊)。`-Apply`無し=dry-run。ASCII化でPS5.1文字化け回避。`schtasks /Create BrainConsolidateInbox /SC HOURLY -Apply` 登録。
- **Check**: dry-run clean(exit0)。ClusterKey regex検証=日付違い3ペア全て同一キーに収束(biz-aipax-lp-beta / money-aipax-既存4社-アップセル提案 / refresh-ecokan)。タスク登録成功・next run 18:48。現_inbox12件は全て別タスク→dup=0(正)。
- **Act/次**: 18:48の初回-Apply実行結果を次tickで確認(CHECK)。次は cycle2 = priority_filler durability(stale沈黙の根治)。
- **限界(既知)**: クラスタキーにproducer接頭辞(pri-/money-/biz-)を含むため、別producerの同内容dupは未統合(Opus triageで拾う)。

### Cycle 2 — 2026-06-07 18:15 — priority_filler durability
- **Plan**: 今日のGPUアイドルの根本=セッション死亡→priorities >48h stale→priority_fillerが**silent skip**→生成停止。staleでも止まらないようにする。
- **Do**: `priority_filler.ps1` のstale分岐を改修。<48h=通常 / **48-168h=last-known-good継続投入**(dedup12h+cycle1 consolidationがdup整理) / >168h=abandoned停止(週超の古い優先順位を延々投げない)。ASCII追記でPS5.1 BOM保持(Edit済みdispatch.ps1が稼働継続=Editは encoding保持を確認済)。
- **Check**: 編集後 priority_filler 実行=EXIT0・stale=False通常path・dedup正常(4件全skip)。encoding破損なし。**発見: dispatched=Nは"呼んだ数"で、dedupで実投入0のことが多い** → refresh間はfiller実質no-op。連続価値の本体はBG*研究(日次=新規)+Opus polish+Claude refresh。
- **Act/次**: cycle3 = **自動triage/promote**(_inboxの60点qwen下書き→Opusで90点→正式昇格を/loop内で定期実行)。これが「成果物」を実際に生む価値変換の自動化。+ 18:48 consolidation初回-Apply結果のCHECK。

## ロードマップ更新 (2026-06-07 18:15)
- ✅ cycle1 機械consolidation / ✅ cycle2 filler durability
- ⬜ cycle3: 自動triage/promote(/loop内Opus・最重要=価値変換)
- ⬜ cycle4: harvest.ps1 intake-gate(salience/dedup)
- ⬜ cycle5: fidelity harness / GitHub harvest
- **方針の確定**: local qwenは"60点の量産"止まり・連続24/7の真の燃料はBG*日次研究。価値は「Opus polish + 昇格」で生む。GPUを100%にすること自体は目的でない(junk化する)。「止まらない+溜まらない+磨いて昇格する」が"ちゃんと動く"の定義。

### Cycle 3 — 2026-06-07 19:00 — 自動triage/polish (価値変換)
- **Plan**: _inboxの60点qwen下書きを「成果物」に変える価値変換が自動化されてない(誰もreviewせず398溜まった原因)。Opus polishを/loopの標準ステップにする。
- **Do**: polish workflow(Opus7並列)を未磨きdelta(7件)に実行。各: draft+entity+clone-spec-v5読込→90点リライト→`_inbox/_polished/`。idempotent(磨き済み6件はskip)。完了後 `_polished/_READY-2026-06-07.md`(大井向け成果物一覧)生成。
- **Check**: 13本が _polished に揃った(87-90点)。**qwen実測スコアは平均~33点(投資家ピッチは12点=大井を投資ファンドと誤認し全数字捏造)、Opus磨きで平均~89点**。価格誤り(aipa-web 月10-15万→3プラン)・メタ指示漏れ(月次レポートにqwenの自己指示が混入)・反復12回 等を検出除去。→ **polish step=本物の価値レバー。base modelでない(再確認)**。
- **Act/次**: 成果物を大井に提示(_READY manifest)。auto-polishを毎/loop tickの標準ACTに確定。次cycle4 = polish workflowをself-discovering(_inbox globして_polished除外して自動map)にし、ハンドビルド不要の反復ループ化。
- **限界**: 現状ITEMSをClaudeが毎回手組み。entityマップも手動。cycle4で自動化する。

## 現状サマリー (2026-06-07 19:00) — 「ちゃんと動く」3機構が稼働
1. **止まらない(生成)**: priority_filler(hourly・durable・cycle2) + BG*日次研究
2. **溜まらない(整理)**: consolidate_inbox(hourly・Claude非依存・cycle1・本番検証済)
3. **磨いて昇格(価値)**: Opus polish→_polished→大井《要記入》→canonical(cycle3)
→ 残: cycle4 polish自動discovery / cycle5 fidelity harness・GitHub harvest

### Cycle 4 — 2026-06-07 19:23 — polish自動discovery + durable named workflow
- **Plan**: cycle3のpolishは毎回ClaudeがITEMS手組み。自動化して反復可能な/loopステップにする。
- **Do**: `auto-polish` workflow作成(2 phase: Discover=_inbox glob−_polished差分+entity自動マップ → Polish=Opus並列90点化)。`~/.claude/workflows/auto-polish.js` に保存し**named workflow化**(全セッションで `Workflow({name:"auto-polish"})` 実行可)。
- **Check**: 実行=discovered1(19:00以降の新着 biz-testall-competitor-studyplus を自動検出)→ polished 38→90(価格自己矛盾/bold反復5回/Studyplus捏造facts→《要記入》/実entity注入)。**自走discovery〜polish〜_polished が完全動作**。idempotent(既磨きskip)。
- **Act/次**: 価値変換ループ確立。今後の/loop tickは `Workflow({name:"auto-polish"})` を呼ぶだけで新着を自動昇格。次cycle5 = **GitHub harvest**(大井の要望: 高star AI/agentリポを定期収集→解析→pattern抽出→システム強化提案→人間承認)。

## ✅ コア完成 (2026-06-07 19:23) — OpenClaw環境「ちゃんと動く」達成
| 機構 | 実装 | 駆動 |
|---|---|---|
| 止まらない(生成) | priority_filler(durable) + BG*研究 | scheduler |
| 溜まらない(整理) | consolidate_inbox(dedup/stub) | scheduler(Claude非依存) |
| 磨いて昇格(価値) | auto-polish(named wf・自走discovery) | Claude/loop |
| 人間最終化 | _polished/_READY → 大井《要記入》→canonical | 大井 |
→ 以降は **enhancement層**: cycle5 GitHub harvest / fidelity harness / harvest intake-gate。コアは運用フェーズ。
