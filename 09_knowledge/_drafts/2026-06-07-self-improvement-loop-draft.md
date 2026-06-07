---
type: system-design
status: draft
date: 2026-06-07
author: Claude (Opus 4.8)
owner: 大井湧瑛
title: 自走自己改善ループ (Self-Improvement Loop) 設計
tags: [self-improvement, autonomy, consolidation, fidelity, github-harvest, guardrails, openclaw]
related:
  - "[[09_knowledge/README]]"
  - "[[09_knowledge/failures/2026-06-03-openclaw-24h-自走-根本原因と恒久対策]]"
  - "[[scripts/dream_consolidation]]"
  - "[[scripts/self_review]]"
  - "[[scripts/quality_score]]"
  - "[[scripts/dispatch]]"
  - "[[scripts/queue_guard]]"
---

# 自走自己改善ループ — Self-Improvement Loop 設計

> 大井の要求: この有機体 (brain + OpenClaw工場 + Claudeクローン) が **「自走して改善し続ける」**。
> 設計原則: **新規スクリプトを最小化し、既存の証明済みインフラ (scheduler / Claude /loop / dispatch関所 / dream / self_review / quality_score) の上に薄く載せる。** 既に動いているものを再利用する (DRY)。

---

## 0. 既存資産の棚卸し (この設計が乗る土台)

| 資産 | 種別 | 役割 | この設計での使い道 |
|---|---|---|---|
| `log-session.py` (Claude hook) | capture | 全 user prompt を `_conversations/` に **逐語保存** + `conversations.jsonl` | §4 capture-everything の入口 (既に稼働) |
| `dream_consolidation.ps1` (23:00 / BrainDreamConsolidation) | consolidate | 1日の brain 差分 + queue done/failed を集計 → `learnings/` | §1 の Consolidate フェーズの実体 |
| `self_review.ps1` (日曜22:00 / BrainSelfReview) | evaluate | worker.log / failed / inbox滞留を分析→改善提案 | §1 Evaluate + §3 提案配管の足場 |
| `quality_score.ps1` (40点満点・4次元) | evaluate | OpenClaw出力をAI臭/数字誠実/実用価値で採点 | §2 fidelity harness の採点エンジンを流用 |
| `auto_review.ps1` → `auto_promote.ps1` | evolve | レビュー→PROMOTE/ARCHIVE で PDCA を閉じる | §1 Evolve の昇格パス |
| `dispatch.ps1` (inbox≥150 backpressure + 12h dedup) | guardrail | **唯一の投入関所** | §5 ガードレールの中核 (既に存在) |
| `queue_guard.ps1` (10分毎・膨張/孤児/Ollama復活) | guardrail | 安全弁・自己修復 | §5 ガードレール |
| `game_guard.ps1` (BrainGameGuard 2分毎) | guardrail | ゲーム検知→VRAM解放 | §5 リソース保護 |
| Claude `/loop` skill | scheduler | Claudeセッション内の定間隔再実行 | §1 の Observe/有人判断ループ |
| `schedule` skill / Windows ScheduledTask (Brain*) | scheduler | OS級 cron | 新規ジョブ登録先 |

**結論: 自己改善ループの 8割は既に部品として存在する。本設計は「それらを観察→統合→評価→進化の1本の輪に接続し、欠けている3部品 (fidelity harness / GitHub harvest / 自己改善ガード) を足す」。**

---

## 1. 継続改善サイクル (Observe → Consolidate → Evaluate → Evolve)

### 1.1 全体図

```
        ┌─────────────────────────────────────────────────────────┐
        │                  THE LOOP (1日単位で1周)                  │
        │                                                           │
   (A) OBSERVE  ──→  (B) CONSOLIDATE  ──→  (C) EVALUATE  ──→  (D) EVOLVE
   何が起きたか        episodic→knowledge      良し悪し採点         構造を更新
   を集める            に圧縮                   ドリフト検知         提案→承認→適用
        ↑                                                           │
        └───────────────── 適用された変更が次のOBSERVE対象になる ────┘
                          (= フィードバックが閉じる)
```

各フェーズは **別のリズム** で回る (全部を毎日やらない=過負荷回避):

| フェーズ | リズム | 実行主体 | 既存/新規 |
|---|---|---|---|
| A. Observe | 常時 (hook) + 毎時 (harvest) | log-session.py / harvest.ps1 | 既存 |
| B. Consolidate | 毎日 23:00 | dream_consolidation.ps1 (拡張) | 既存+拡張 |
| C. Evaluate | 毎日 (品質) + 毎週日曜 (システム) | quality_score / self_review (拡張) | 既存+拡張 |
| D. Evolve | 毎週 (提案) + 有人承認時 (適用) | self_review + Claude /loop | 既存+拡張 |

### 1.2 各フェーズの定義

**(A) OBSERVE — 何が起きたか集める**
- 入力源: ① Claude会話 (`_conversations/`, `conversations.jsonl`) ② OpenClaw出力 (`queue/done`, `queue/results`) ③ brain編集差分 (md mtime) ④ 大井の決定 (日報 evening-*.md, hot.md更新, TODAY/TOMORROW) ⑤ システムテレメトリ (worker.log, failed/, inbox滞留, Ollama死活)。
- すべて **既に書き出されている**。Observeは「新規収集」ではなく「散在ソースの索引付け」。
- 追加するもの: `09_knowledge/_log.md` の機械追記 (dream が日次1行サマリを append)。

**(B) CONSOLIDATE — episodic を knowledge に圧縮 (= 夢)**
- `dream_consolidation.ps1` を主体に。現状は「差分の集計」止まり。**拡張: 差分を `learnings/` に圧縮する際、新パターン候補を抽出**。
  - 同一テーマが直近で N回 (≥3) 出たら → スキル化候補として `09_knowledge/_promote_candidates/` に1ファイル。
  - 大井の決定 (採用/却下/方針転換) は必ず `learnings/decisions/YYYY-MM-DD-{slug}.md` に1事例として固定 (§4)。
- 出力は **追記型・冪等**。同じ日を再実行しても重複生成しない (ファイル名に日付固定)。

**(C) EVALUATE — 良し悪しを測る**
- 2系統:
  1. **出力品質** (毎日): `quality_score.ps1` を `harvest` 直後にバッチ適用。24点未満は `_inbox/_low_quality/` に隔離して昇格させない (源流フィルタ)。
  2. **システム健全性** (毎週): `self_review.ps1` が worker稼働率・失敗率・滞留・**昇格率 (= 価値転換率)** を集計。
- **最重要KPI: 昇格率 (promoted / generated)**。2026-06-03の教訓「生成は回っていたが価値を生んでいなかった (81%重複)」を二度と起こさないため、**「動いた量」ではなく「育った量」を主指標にする**。

**(D) EVOLVE — 構造を更新する**
- self_review が「改善提案」を `wiki/meta/self-review-*.md` に生成 → Claude /loop または朝セッションが読み、**3カテゴリに振り分け**:
  - 自動適用可 (低リスク・可逆): 設定値調整 (filler レート, dedup窓, しきい値) → Claudeが直接編集 + git commit。
  - 要承認 (中リスク): 新スクリプト追加, ScheduledTask 追加/変更, モデル/プロンプト変更 → §3/§5の承認ゲートへ。
  - 要大井判断 (高リスク): 方向性, 予算, リリースGo → hot.md/INBOX.md に上申。
- 適用された変更は §5 のガードを通り、次の Observe で効果測定される (輪が閉じる)。

### 1.3 配線 (誰がいつ叩くか)

```
23:00  BrainDreamConsolidation     → Consolidate (+パターン抽出)
23:30  [新] BrainFidelityHarness    → Evaluate (週次・日曜のみ実体動作, §2)
日曜22:00 BrainSelfReview (拡張)     → Evaluate+Evolve提案
毎時   BrainHarvest → [新] quality_score バッチ → Evaluate (品質ゲート)
朝/任意 Claude /loop "self-improve"  → Evolve提案の振り分け・自動適用・上申
週1   [新] BrainGithubHarvest        → §3 (土曜深夜)
```

---

## 2. Fidelity Regression Harness (クローン忠実度の週次回帰テスト)

### 2.1 目的
大井クローン (v4) が、**新しく溜まった本物の大井発話に対しても忠実か**を毎週自動で再採点し、**ドリフト (劣化/乖離) を自動フラグ**する。回帰テストのクローン版。

### 2.2 ゴールデンセット (真実の蓄積)
- ソース: `_conversations/` の **逐語 user prompt** (= 圧縮前の真実, log-session.py が保存済み)。
- `09_knowledge/fidelity/golden/` に **評価ペア** を蓄積:
  - `prompt`: 大井が実際に投げた発話/状況
  - `actual`: その時の大井の実際の意思決定・反応・言い回し (日報・決定ログから紐付け)
  - `tags`: 領域 (事業判断 / 言い回し / 優先順位 / リスク感度 / トーン)
- ゴールデンは **append-only・人手承認制**。毎週 dream が「今週の高シグナル発話」を `golden/_candidates/` に提案 → 大井 or Claude が承認したものだけ正式 golden 化 (汚染防止)。

### 2.3 週次スコアリング (新規 `fidelity_harness.ps1` + Claude採点)
毎週日曜23:30 / `BrainFidelityHarness`:
1. golden セット全件について、クローン (Claudeに大井ペルソナ + brain context を与えた構成) に **same prompt** を再投入し回答生成。
2. 各回答を **5次元×10点=50点** で採点 (quality_score のエンジンを拡張):
   - D1 意思決定の一致 (実際の大井判断と同方向か)
   - D2 優先順位感覚 (攻める/種まき/やめる の振り分けが大井的か)
   - D3 リスク感度 (撤退条件・捏造回避・誇大回避)
   - D4 言い回し/トーン (AI臭ゼロ・大井語彙)
   - D5 価値観整合 (MVV「熱狂を、つくる。」/ 物語的背景と矛盾しないか)
3. 採点は **Claude (Opus) が rubric 採点** (qwen下書き→Opus採点の既存分業を流用)。
4. 結果を `09_knowledge/fidelity/scores/YYYY-Www.md` に時系列保存。

### 2.4 ドリフト検知と自動フラグ
- **基準線**: 直近4週の移動平均。
- フラグ条件:
  - 総合スコアが基準線 **-5点以上低下** → `[DRIFT]` フラグ。
  - いずれか1次元が **-3点** → `[DIM-DRIFT:Dn]` フラグ。
  - 連続2週低下 → `[DRIFT-TREND]` (エスカレーション)。
- フラグ時のアクション (自動・低リスク側):
  1. `wiki/meta/fidelity-drift-YYYY-Www.md` に **どの次元が・どの golden で・なぜ** 乖離したかを Claude が言語化。
  2. hot.md の「先回りヒント」に1行上申 (朝の大井が気づく)。
  3. 原因が「brain context の古さ」なら → entity refresh / consolidation 再実行を提案 (自動)。
  4. 原因が「ペルソナ定義の欠落」なら → クローン spec 更新案を `_promote_candidates/` に (要承認)。
- **重要: harness は採点と提案までで止める。クローン定義の自動書き換えはしない (暴走防止, §5)。**

---

## 3. GitHub Harvest → Upgrade Proposal Pipeline (大井のアイデア)

### 3.1 目的
高スター agent/AI リポジトリを定期収集し、パターンを抽出して、**この有機体自身へのアップグレードを提案**する。外界の進化を自分に取り込む器官。

### 3.2 パイプライン (search → score → extract → propose → human-approve)

```
[1 SEARCH]  gh search repos / gh search code (週1・土曜深夜)
   クエリ: "ai agent" "autonomous agent" "memory consolidation" "self-improving"
           "llm orchestration" "agentic workflow" 等 (クエリ表は config 化)
   フィルタ: stars>=500, pushed:>last-90d, language 不問
        │
[2 SCORE]  各リポを 5軸で採点 (新規 github_harvest.ps1 が gh API でメタ取得)
   ① 関連性 (我々の課題=自走/記憶/品質/オーケストレーションに合致するか)
   ② 勢い (star伸び率・直近コミット頻度)
   ③ 採用容易性 (ローカル8GB GPU制約・管理者権限なし・PS5.1/Claude環境で動くか)
   ④ ライセンス安全性 (MIT/Apache優先, GPL注意)
   ⑤ 新規性 (既に我々が持っているパターンと重複しないか)
   → 上位 N=5 のみ次工程へ (洪水防止)
        │
[3 EXTRACT]  Claude が各リポの README/構造/主要パターンを読み
   "このリポの核となる仕組み" を1段落 + "我々への転用案" を抽出
   出力: 09_knowledge/excavation/github/YYYY-MM-DD-{repo}.md (原文リンク+要約)
        │
[4 PROPOSE]  転用案を「具体的変更提案」に変換
   形式: 対象ファイル / 変更内容 / 期待効果 / リスク / 可逆性 / 工数 / GPU影響
   出力: wiki/_inbox/_promote_candidates/upgrade-{slug}.md
        │
[5 HUMAN-APPROVE]  承認ゲート (必須・全件)
   - 低リスク&可逆 → Claudeが PoC ブランチで試作 → quality比較 → 承認後マージ
   - 中/高リスク → hot.md/INBOX.md に上申, 大井 or CEO skill が Go/No-Go
   - 却下も learnings/decisions/ に記録 (なぜ採らなかったか=資産)
```

### 3.3 配線
- `BrainGithubHarvest` (新規 ScheduledTask, 土曜02:00, 週1)。
- レート: **1回の収穫で最大5リポ・最大5提案** (ハードキャップ)。`dispatch` 経由で投入し backpressure に従う。
- **絶対に「面白そうな全リポを一気に試す」をしない** (2026-06-03 の overproduction 再来防止)。1週1テーマ集中。

### 3.4 安全特記
- harvest は **読み取り + 提案のみ**。コード自動実行・自動マージは禁止。
- 外部コードは必ず PoC worktree (`EnterWorktree`) で隔離試行 → 本体に触れない。
- 依存追加は管理者不要・ローカルGPU制約 (qwen3:8b/8GB) を破らないことを score④で事前排除。

---

## 4. Capture-Everything (発話・決定 → episodic → consolidated)

### 4.1 二層記憶モデル
```
[EPISODIC 記憶 = 生ログ・逐語・冪等]
  _conversations/YYYY-MM-DD/*.md      ← 全 user prompt 逐語 (log-session.py, 稼働中)
  _log/conversations.jsonl            ← 索引 (稼働中)
  queue/done/*.json, results/*.md     ← OpenClaw 全出力
  _routines/evening-*.md              ← 日次の決定スナップショット
        │  (毎日23:00 dream が圧縮)
        ▼
[CONSOLIDATED 知識 = 圧縮・概念化・参照可能]
  09_knowledge/learnings/             ← 概念・パターン
  09_knowledge/learnings/decisions/   ← [新] 大井の決定1件=1ファイル
  09_knowledge/successes/ , failures/ ← 事例
  09_knowledge/frameworks/ , skills/  ← 3回再現→昇格
```

### 4.2 「決定」を取りこぼさない仕組み (新規・最小)
現状 prompt は全部保存されるが、**決定 (大井が "これで行く/却下/方針変える" と言った瞬間)** が知識に昇格していない。これが資産化の穴。
- dream_consolidation 拡張: 当日 `_conversations/` から **決定シグナル** を抽出 (regex + Claude判定):
  - "で行く" "決定" "却下" "やめる" "やっぱり" "方針" "GO" "No-Go" "承認" 等。
- 抽出した決定を `learnings/decisions/YYYY-MM-DD-{slug}.md` に固定 (what / why / 代替案 / 撤退条件)。
- この decisions/ が **§2 fidelity harness のゴールデンソース** にもなる (決定=最高品質の真実)。

### 4.3 ライフサイクル (既存フローを正式化)
```
発話/決定 → episodic (逐語保存) → 23:00 consolidate → learnings/
 → 3回再現 → frameworks/ → boilerplate付き skills/ → 横展開 (部署 handoff)
```
- 冪等性: 全ステップ append-only or 日付固定ファイル名。再実行で重複しない。
- 文字化け対策: 日本語を含む全 .ps1 は **BOM付きUTF-8** (2026-06-03教訓4)。prompt は `-PromptFile` 経由で渡す (`powershell -Command` で日本語引数を渡さない)。

---

## 5. ガードレール (自己改善が暴走/過剰生産しないために)

> 設計の魂。2026-06-03 の「24h自走が空回り (生成>価値, inbox 1336滞留, 81%重複, OOMクラッシュ27回)」を **構造的に二度と起こさない**。自己改善ループは自分自身を変更できるので、guardrail が無いと最も危険。

### 5.1 既存ガードを必ず通す (再発明しない)
| ガード | 場所 | 自己改善ループでの役割 |
|---|---|---|
| **投入関所 backpressure** | dispatch.ps1 (inbox≥150 skip) | harvest/提案/consolidate由来の全タスクはここを通す。super以外は飽和時に自動停止 |
| **12h dedup** | dispatch.ps1 | 同テーマ提案の二重投入を阻止 |
| **膨張/孤児ガード** | queue_guard.ps1 (10分毎) | 万一溢れても自己修復 |
| **品質ゲート** | quality_score.ps1 (24点未満隔離) | 低品質な自動生成物を昇格させない |
| **ゲーム/リソース保護** | game_guard.ps1, num_ctx=8192, NUM_PARALLEL=1 | GPU 8GB を超えない |

### 5.2 自己改善 専用の追加ガード (新規)
1. **変更レート制限**: 自己改善ループが1日に自動適用できる変更は **最大3件**・1週で **最大10件**。超過分はキューで翌日へ。(filler 暴走の構造的再来防止)
2. **可逆性ゲート**: 自動適用は **git管理下 + 1コミット=1変更 + 即revert可能** なものに限る。ScheduledTask 追加/削除, モデル変更, 外部コード実行は **必ず有人承認**。
3. **リスク三分類の強制**: すべての提案は自動適用可 / 要承認 / 要大井判断 のラベル必須。未分類は適用しない (デフォルト拒否)。
4. **「動いた量」を成功指標にしない**: KPIは **昇格率 (価値転換率)** と **fidelityスコア**。生成数の増加は成功と見なさない (2026-06-03 の最大教訓)。
5. **サーキットブレーカー**: 以下のいずれかで自己改善ループを **自動 pause** し hot.md/INBOX に警告:
   - failed/ が 50件超 (異常生産)
   - inbox 滞留が48hで減らない (価値転換停止)
   - fidelity が `[DRIFT-TREND]` (2週連続劣化)
   - quality 平均が前週比 -10点
   - Ollama unreachable が直近1hで3回超 (環境不安定)
6. **自己改変の二重ロック**: ループが **自分の guardrail / dispatch関所 / quality_score の閾値** を変更する提案は、**常に「要大井判断」** に固定 (自分で自分のブレーキを緩められない)。
7. **PoC隔離**: 外部由来 (GitHub harvest) のコードは worktree で隔離試行のみ。本体マージは有人。
8. **冪等 & 日付固定**: 全自動生成は再実行で重複しない設計 (重複1061件アーカイブの再来防止)。

### 5.3 「壊れたら自分で気づいて止まる」原則
- self_review (週次) + サーキットブレーカー (常時) + fidelity drift (週次) の3層で **自分の劣化を自分で検知**。
- 検知したら **加速ではなく減速** (pause/上申)。自走の本質は「止まらないこと」ではなく「壊れたら正しく止まり、復帰すること」(2026-06-05 queue_guard 孤児.paused自動解除の思想と同じ)。

---

## 6. 実装ロードマップ (最小新規・既存拡張優先)

| 順 | 作るもの | 種別 | 依存 | リスク |
|---|---|---|---|---|
| 1 | `dream_consolidation.ps1` に **決定抽出 + パターン候補抽出** を追加 | 拡張 | 既存稼働中 | 低 (append only) |
| 2 | `self_review.ps1` に **昇格率KPI + サーキットブレーカー判定** を追加 | 拡張 | 既存稼働中 | 低 |
| 3 | `fidelity_harness.ps1` + `BrainFidelityHarness` (日曜23:30) + golden承認フロー | 新規 | quality_score流用 | 中 (採点コスト) |
| 4 | `github_harvest.ps1` + `BrainGithubHarvest` (土曜02:00) | 新規 | gh CLI, dispatch関所 | 中 (外部依存→PoC隔離で緩和) |
| 5 | `quality_score` を harvest直後に **バッチ自動適用** (品質ゲート) | 配線 | 既存 | 低 |
| 6 | Claude `/loop "self-improve"` の **Evolve振り分けプレイブック** を skill化 | 新規skill | 上記出力 | 低 |

---

## 7. これで満たされる大井の要求

- **自走**: scheduler (OS cron) + Claude /loop が無人で Observe→Consolidate→Evaluate→Evolve を回す。
- **改善し続ける**: 毎週 fidelity 回帰 + GitHub harvest + self_review が「今より良く」を生成し続ける。
- **暴走しない**: dispatch関所 + 変更レート制限 + 可逆性ゲート + サーキットブレーカー + 自己改変二重ロックで、2026-06-03型の overproduction/runaway を構造的に封鎖。
- **取りこぼさない**: 逐語capture (稼働中) → 決定抽出 (新) → consolidate → skill化 の二層記憶で全発話・全決定が資産化。
