---
type: harvest-proposal
domain: openclaw-self-improvement
date: 2026-06-07
cycle: PDCA cycle5 (GitHub harvest)
sources:
  - TransformerOptimus/SuperAGI
  - win4r/UltraMemory
  - ZSeven-W/agent-memory-desktop
  - jakops88-hub/Long-Term-Memory-API (MemVault)
status: proposal (awaiting 大井 Go on the #1 first-cycle pick)
---

# GitHub Harvest 提案 — OpenClaw 強化パターン (2026-06-07)

> 大井の指示: 高star AI/agentリポを収集 -> 解析 -> パターン抽出 -> システム強化提案 -> 人間承認。
> 4リポを実ソース読みで解析済み。**どれもクローンしない** (TS/Postgres/Electron stack はPS5.1+Obsidian+8GB-qwen と不一致)。**アイデアだけ移植**する。
> 全提案は制約準拠: 8GB VRAM上限 (追加モデル無し)・PS5.1 ASCII script・runaway/flood 禁止。

## スコアリング方針

各パターンを feasibility x value (各0-100) で全件ランク。OpenClawの現状 (PDCA cycle1-4 完了: 止まらない/溜まらない/磨いて昇格 が稼働中) に対する**限界増分**で価値を判定。
flood履歴 (398件事故) が最大の既知リスクなので、**anti-runaway系を最優先**で上に置く。

### 全パターン ランク表 (feasibility x value 降順)

| # | パターン | 出典 | feas | val | 積 | 判定 |
|---|---|---|---|---|---|---|
| 1 | Cost Guard / 日次カウンタ circuit-breaker | MemVault | 97 | 90 | 8730 | **採用** |
| 2 | Iteration-limit + stale-run guard | SuperAGI | 95 | 90 | 8550 | **採用 (#1と統合)** |
| 3 | Sleep Cycle consolidation (episodic->semantic 昇格) | MemVault | 90 | 92 | 8280 | **採用** |
| 4 | Importance+recency 半減期 decay re-rank | MemVault | 95 | 85 | 8075 | **採用** |
| 5 | RRF rank-fusion (Vector + BM25) | UltraMemory | 90 | 85 | 7650 | 採用 (#4とrank_wiki束) |
| 6 | Per-call telemetry -> 集計 scoreboard (APM) | SuperAGI | 90 | 85 | 7650 | **採用** |
| 7 | Dry-run forgetting (preview-before-delete) | agent-memory-desktop | 95 | 85 | 7575 | 既存に近い (下記skip理由) |
| 8 | MMR diversity de-dup | UltraMemory | 80 | 90 | 7200 | 採用 (rank_wiki束) |
| 9 | Adaptive retrieval gate + access-reinforced decay | UltraMemory | 85 | 80 | 6800 | 採用 (#4へ吸収) |
| 10 | Vector->keyword fallback chain | agent-memory-desktop | 85 | 75 | 6375 | skip (低リスク・小) |
| 11 | Resource summary (raw再注入の代わり) | SuperAGI | 80 | 80 | 6400 | skip (#3と重複) |
| 12 | Entity/Relationship graph (GraphRAG-lite) | MemVault | 78 | 80 | 6240 | skip (将来) |
| 13 | Local cosine rerank fallback | UltraMemory | 95 | 70 | 6650 | 部分採用 (rank_wiki) |
| 14 | Token-budget-aware completion sizing | SuperAGI | 85 | 70 | 5950 | skip (qwen自前ctx) |
| 15 | Pinned + (age x importance) decay rule | agent-memory-desktop | 90 | 70 | 6300 | 採用 (#3/#4のfrontmatter) |
| 16 | Forgetting timeline 30日 projection | agent-memory-desktop | 80 | 65 | 5200 | skip (cosmetic) |

---

## (1) 推奨採用 TOP 5

### A. Cost Guard / 日次カウンタ circuit-breaker  ★最重要 = #1 first cycle
- **出典**: MemVault `hybridCostGuard.ts` + SuperAGI `agent_executor.py` (iteration-limit / stale-run guard) を統合。
- **なぜ効くか**: OpenClawの**根本病は flood/idle 振動**。398件事故は「生成側に上限が無い」ことが原因。現状 `priority_filler.ps1` は dedup と consolidation で後始末はするが、**produce前のハードゲートが無い**。これを入れると flood が構造的に起こせなくなる。
- **実装スケッチ (我々の stack)**: 新規 `scripts/guard.ps1` (ASCII)。日次カウンタファイル `scripts/.guard_YYYYMMDD.txt` を読み、`priority_filler.ps1` と `consolidate_inbox.ps1` の先頭で `& guard.ps1 -Producer priority_filler` を呼ぶ。ゲート: (a) **MAX_PER_DAY** (例 40) を超えたら exit 1 で dispatch を止める、(b) SuperAGI流に `today_priorities.generated` が >24h のタスクは個別 skip、(c) consolidation 側は **MIN_NEW_NOTES** (例 5) 未満なら no-op・**MAX_BATCH** (例 30) で1回処理量を上限。各 dispatch 成功でカウンタを +1。状態 (今日の生成数 / 上限 / 残り) を `hot.md` の `## OpenClaw guard` セクションに1行で書く。`priority_filler.ps1` の既存 `Test-Path "$brain\queue\.paused"` exit パターンをそのまま流用するので改修は数行。
- **feasibility 97 / value 90**。
- **runaway-guard note**: これ自体が runaway-guard。**カウンタの reset は日付ロールのみ** (手動 reset は `-Apply` 同様に明示フラグ要)。MAX_PER_DAY を低め (40) で開始し、scoreboard (項目E) を見て大井判断で調整。

### B. Sleep Cycle consolidation (episodic -> semantic 昇格)
- **出典**: MemVault `consolidationService.ts`。
- **なぜ効くか**: 現 `dream_consolidation.ps1` は「要約のみで育たない」と PDCA に明記済み。raw な `_conversations` (episodic) を qwen で「entity に紐づく core fact」に変換し**昇格後フラグで二度処理しない**ことで、初めて brain が semantic 層に**蓄積**する。brain-as-human-brain の本丸。GPU負荷は consolidate のバッチ実行時のみで 8GB に収まる (qwen3:8b は既存稼働モデル)。
- **実装スケッチ**: `consolidate_inbox.ps1` (既にスケジュール済) に phase3 追加。`isConsolidated` frontmatter 無しの `_conversations` から直近24h分を集め、**MAX_BATCH件まで** (guard準拠) を1プロンプトにまとめ qwen3:8b へ strict-JSON system prompt (`[{entityName,entityType,fact,confidence}]`) で投げる。各 fact を `10_projects/entities/<name>.md` (semantic) へ追記マージ (重複は (name,type) で dedup)、元ノートに `consolidated: true` を stamp。LLM呼び出しを伴うため**この phase だけ guard ゲート (MIN_NEW_NOTES) の後ろに置く**。
- **feasibility 90 / value 92**。
- **runaway-guard note**: バッチ上限 (MAX_BATCH) と「consolidated済みは skip」で再処理ループを禁止。**confidence < 0.5 の fact は entity へ書かず `_inbox/_lowconf/` へ回し Opus polish 行きにする** (qwen の捏造耐性。PDCA cycle3 で qwen平均33点・捏造ありと実測済みなので必須)。**《大井判断》: entity を qwen が自動編集することの是非** — 初期は dry-run (書込みせず提案のみ hot.md) で1週運用し、品質確認後に -Apply 自動化。

### C. Importance + recency 半減期 decay re-rank (+ RRF + MMR)
- **出典**: MemVault `scoring.ts` (decay) + UltraMemory `retriever.ts` (RRF fusion / MMR de-dup / access-reinforced decay)。
- **なぜ効くか**: 現 `search_wiki.ps1` は**生コサインのみ**で並べる。古い・重複・低重要のチャンクが上位を占めうる。decay+importance で「人間的な想起」、RRF でキーワード一致も融合、**MMR が近似重複を上位から排除** = flood 履歴と同じ「似たもの大量」問題を retrieval 層でも潰す。RAG が改善すれば auto-polish と priority_filler が見る文脈が良くなり、全体の質が底上げされる。
- **実装スケッチ**: 新規 `scripts/rank_wiki.ps1` (ASCII)。`search_wiki.ps1` の `Get-CosineSimilarity` をそのまま再利用 (追加モデル0)。(1) コサイン rank と `Select-String` 語頻度 rank を **RRF** `0.7/(60+vrank)+0.3/(60+brank)` で融合。(2) top~20 のみ再コサインして `final = 0.7*fused + 0.3*cos`。(3) `final *= 0.5+0.5*exp(-ageDays/halfLife)` (frontmatter `created` から age、`importance` 1-5 と `access_count` で halfLife を伸縮 = use-it-or-lose-it)。(4) **MMR**: 既選択ノートとのコサインが高い候補を greedy にスキップして top-k 確定。再現時 frontmatter の `access_count` を +1 stamp。`embed_wiki.ps1` が既にキャッシュ済みの `.wiki_vectors.jsonl` を読むだけなので **GPU追加コスト 0** (クエリ埋め込み1回のみ、既存と同じ)。
- **feasibility 90 / value 87** (decay/RRF/MMR の統合スコア)。
- **runaway-guard note**: 読み取り専用なので runaway リスク無し。frontmatter `access_count` 書込みは 1ノート1整数で安全。

### D. Per-call telemetry -> 集計 scoreboard (APM)
- **出典**: SuperAGI `apm/call_log_helper.py` + `apm/analytics_helper.py`。
- **なぜ効くか**: 「self-improving」を名乗るのに**測定層が無い**のが現状最大の穴 (PDCA は手記録)。qwen draft と Opus polish の各回を append-only ログに1行残し、週次で集計すれば「60->90 lift の実値・runaway発生回数・採択1件あたりコスト」が出る。PDCA の Check を**自動化**し、guard の MAX_PER_DAY 等を**データで**調整できる。
- **実装スケッチ**: `dispatch.ps1` と auto-polish workflow の出口に1行 append: `wiki/_telemetry/calls.jsonl` へ `{ts, model, dept, task, draft_score, final_score, tokens_est, seconds}`。`consolidate_inbox.ps1` の週次パスで集計し `hot.md` に scoreboard を書く (avg lift / today生成数 / dup率 / lowconf率)。tokens_est は `chars/4` 概算で十分。
- **feasibility 90 / value 85**。
- **runaway-guard note**: append-only なので肥大に注意 — **週次で `calls.jsonl` を `calls-YYYYWW.jsonl` にローテート**し集計後は raw を `_archive` へ。

### E. Pinned + (age x importance) frontmatter スキーマ (B/C/Dの共通基盤)
- **出典**: agent-memory-desktop (pinned/importance decay rule) + MemVault。
- **なぜ効くか**: B・C・D が全て frontmatter (`pinned, importance, created, access_count, consolidated`) を前提とする。これを**最初に1本化**しておくと後続が乗るだけで済む。`pinned:true` は consolidation/forgetting/decay すべてで「絶対に消さない/沈めない」を保証 = 大事なノートの誤喪失を防ぐ安全装置。
- **実装スケッチ**: `_templates` に標準 frontmatter ブロックを定義し、`dispatch.ps1` が新規ノート生成時に `created` と `importance` (qwen が 1-5 を1回出力) を stamp。既存ノートへの遡及付与は `consolidate_inbox.ps1` の dry-run パスで「frontmatter欠落ノート一覧」を hot.md に出すだけに留め、**一括書込みはしない** (PS5.1 でのBOM/文字化けリスク回避、PDCA の encoding 教訓)。
- **feasibility 90 / value 70**。
- **runaway-guard note**: スキーマ追加のみ。書込みは新規ノート時の数フィールドに限定。

---

## (2) Skip リスト (関連そうだが今は割に合わない)

| パターン | 出典 | skip 理由 |
|---|---|---|
| Dry-run forgetting (preview-before-delete) | agent-memory-desktop | **我々は既に持っている**。`consolidate_inbox.ps1` は `-Apply` 無し = dry-run がデフォルトで、まさにこのガード。新規採用ではなく「既存パターンの妥当性確認」。forgetting timeline (#16) も cosmetic なので skip。 |
| Vector->keyword fallback chain | agent-memory-desktop | 低リスクだが価値小。Ollama/nomic-embed は同一マシン常駐で落ちる頻度が低く、落ちる時はqwen生成自体も止まる。rank_wiki の RRF が既にキーワードpassを内包するので、fallback は**その副産物として無料で得られる** (別途実装不要)。 |
| Resource summary (raw再注入の代替) | SuperAGI | #3 Sleep Cycle consolidation と機能重複。episodic->semantic 昇格が走れば「要約を注入」は自動的に満たされる。二重実装は避ける。 |
| Token-budget-aware completion sizing | SuperAGI | qwen3:8b は ctx が固定で Ollama 側が切り詰める。8GBで14b/qwen3.6 は使わない方針が確定済みなので OOM 主因はモデルサイズで、ctx超過ではない。`chars/4` で `num_predict` を粗く絞る程度で十分、専用機構は過剰。**ただし RAG注入が長文化したら #3 の要約注入で自然に短くなる**ので不要。 |
| Entity/Relationship graph (GraphRAG-lite) | MemVault | 価値は高い (80) が、Obsidian wikilink+predicate の運用設計と consolidation 側の関係抽出が要り、cycle5 の射程外。**#3 で entity ノード化が進んだ後の cycle6+ 候補**として保留。 |
| SuperAGI / UltraMemory / MemVault 本体クローン | 全リポ | TS/FastAPI/Celery/Postgres/Redis/Electron/Prisma/Stripe いずれも PS5.1+Obsidian+8GB に不一致・no-admin非対応。**コードでなくアルゴリズムのみ移植**が全リポ共通の結論。 |

---

## (3) 最初に回す ONE (= 次の PDCA cycle5)

**A. Cost Guard / 日次カウンタ circuit-breaker (`guard.ps1`)** を最初に実装する。

理由:
1. **積スコア最高 (97x90)** かつ OpenClaw の**根本病 (flood/idle) を直接叩く**唯一の anti-runaway 基盤。
2. 他の採用 (B Sleep Cycle, C rank, D telemetry) は**いずれも追加の生成/LLM呼び出しを増やす**ので、**先に上限ゲートを置いてから**でないと flood リスクを上げる。guard が土台。
3. 改修が小さい (既存 `.paused` exit パターン流用・新規1ファイル+2箇所の先頭呼び出し)、ASCII で完結、効果が hot.md scoreboard で即可視。

PDCA cycle5 の形:
- **Plan**: guard.ps1 設計 (MAX_PER_DAY=40 / MIN_NEW_NOTES=5 / MAX_BATCH=30 を初期値、根拠は398事故/24h)。
- **Do**: `guard.ps1` 作成 + `priority_filler.ps1` / `consolidate_inbox.ps1` 先頭にゲート呼び出し追加。
- **Check**: dry-run で「もし今日40件超なら止まる」を擬似カウンタで検証、hot.md に guard 行が出るか確認。
- **Act**: 1日運用後カウンタ挙動を確認し、次 cycle6 で **D telemetry** (測定層) -> **B Sleep Cycle** -> **C rank_wiki** の順に積む。

---

## 《大井の判断が要る項目》

1. **guard 初期上限値**: MAX_PER_DAY=40 / MIN_NEW_NOTES=5 / MAX_BATCH=30 で開始してよいか (低めから始め scoreboard で調整する想定)。
2. **qwen による entity 自動編集の許可** (#3 B): 初期は dry-run (提案のみ hot.md)、品質OK後に -Apply 自動化 — この段階的解禁でよいか。それとも entity 書込みは恒久的に Opus polish 経由のみにするか。
3. **採用順の承認**: cycle5=guard 単独でまず1サイクル回す方針でよいか (B/C/D を待たせる)。
