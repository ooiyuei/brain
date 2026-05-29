---
type: concept
title: Brain Mythos 設計 (OpenMythosアーキを brain System に移植)
created: 2026-05-19
status: master-plan
priority: P0
related: [[concepts/claude-mythos-architecture]], [[concepts/ai-economy-2026-structure]]
tags: [architecture, brain-system, mythos, master-design]
---

# Brain Mythos — OpenMythos の brain System 完全移植

> ローカル実装はGPUクラスター必要で非現実的。
> でも**設計思想** は brain System の質を爆上げできる。死ぬ気で組み込む。

## マッピング (Mythos → brain System)

| Mythos技術 | 役割 | brain System 移植先 |
|---|---|---|
| **MLA Attention** | KV cache圧縮 | **Entity Latent層** — entities/に「30秒サマリー」追加・ContextFilesに渡すサイズ最小化 |
| **Sparse MoE 64×top-4** | タスクに応じてエキスパート選択 | **Router + Filler Pool** — タスク内容から最適 filler/agent を動的選択 |
| **Recurrent-Depth (16loop)** | 深く考えるループ | **Recurrent Pipeline** — 1タスクを最大3回ループしてブラッシュアップ |
| **ACT Halting (0.99)** | もう答え出せそうと判定 | **Score Slope Halt** — スコア伸び率<5で自動停止・無駄ループ防止 |
| **DepthLoRA (rank16)** | 深度別の微調整 | **Depth Templates** — ループ1/2/3で違うプロンプト使う |
| **Prelude/Coda 2層** | 標準transformer | **Pre-process / Post-process** — dispatch前後の固定処理 (prefix・review) |
| **LTI Injection** | ループ初期化 | **Initial Context Injection** — 各タスク開始時に大井ソウル+entitiesを注入 |

---

## 全体アーキ (Brain Mythos)

```
[大井の発話・思いつき]
  ↓
[Prelude] Claude(俺) が判定: 即答 / 単純dispatch / 複雑 → recurrent pipeline
  ↓
[Router] (MoE) タスク内容から最適 filler 選択 (router.ps1)
  ↓
[Recurrent Block] (最大3ループ・ACT halting)
  ├ Depth1: 粗く量産 (qwen3.6 + entity latent)
  │   ↓ score算出
  │   ↓ slope < 5 ? STOP : 続行
  ├ Depth2: 改善点特化プロンプト (Depth2 template)
  │   ↓ score算出
  │   ↓ slope判定
  └ Depth3: 大井キャラ厳密化+wikilink注入 (Depth3 template)
  ↓
[Coda] Claude(俺) が最終ブラッシュアップ → _final/
  ↓
[大井へ配信]
```

---

## 5層実装 (この順番で組む)

### Layer 1: Entity Latent (MLA相当)
**目的**: ContextFilesに渡すサイズを最小化しつつ核心情報を保つ
- 各 `entities/xxx.md` の冒頭に "## 30秒サマリー (Entity Latent)" を追加
- 3行で「何を誰に売って、価格・契約状況」を圧縮
- ContextFiles注入時はこの latent だけ参照 (フル本文は必要時のみ)

実装: `scripts/inject_entity_latent.ps1` — 主要15事業に latent セクションを生成

### Layer 2: MoE Router
**目的**: タスク内容から **どの filler / agent を呼ぶか動的選択**
- 入力: タスクの題目+概要
- 出力: 最適なfillerスクリプト名 + 優先度
- ルール: 「営業文 → sales_filler」「LP → writing_filler」「事業案 → biz_filler」「教材 → school_content_filler」
- shared experts = 大井ソウル + 良い事業の定義 (全タスクに常時注入)

実装: `scripts/mythos_router.ps1` — 1タスク投入時の前段ルーター

### Layer 3: Recurrent Pipeline (核心)
**目的**: 1タスクを最大3回ループしてブラッシュアップ
- Depth1: qwen3.6で粗稿
- auto_review でスコア算出
- Depth2: スコア+改善ポイントを渡して再生成
- auto_review でスコア再算出 (ACT halting判定)
- Depth3: 大井キャラ厳密化+wikilink注入の最終版
- Claude(俺)が最後にブラッシュアップ → _final/

実装: `scripts/recurrent_pipeline.ps1`

### Layer 4: ACT Halting
**目的**: スコア伸び率<5で自動停止 (無駄ループ削減)
- Depth1 score → Depth2 score の差分計算
- 差分 < 5 → halt (Depth3 スキップ)
- 差分 >= 5 → 続行
- 累積スコアが90+ なら無条件 halt

実装: `auto_review.ps1` の改修 + `act_halting.ps1` 新規

### Layer 5: Depth Templates
**目的**: ループ段階ごとに違うプロンプトテンプレ使う
- `prompt_templates/depth_1_volume.md` (粗稿用・量重視)
- `prompt_templates/depth_2_refine.md` (改善ポイント特化)
- `prompt_templates/depth_3_persona.md` (大井キャラ厳密化+wikilink注入)

実装: 3本のテンプレ作成 + recurrent_pipeline で使い分け

---

## 期待効果

### 現状 (Mythos前)
- filler が固定poolからランダム → 70点止まり
- ContextFiles 全文注入で重い・無駄
- 1回dispatch で終わり = 1回の精度がそのまま品質
- Claude(俺)起動時にしかブラッシュアップ進まない

### Mythos後 (予測)
- **Router**でタスク最適化 = 適材適所
- **Entity Latent**で軽量・速い (10倍速)
- **Recurrent Depth**で1タスクを3回磨く = 70→90点に自動到達
- **ACT Halting**で無駄ループ削減 = コスト1/3
- **Depth Templates**で段階別最適化 = 大井キャラ確実反映

→ **OpenClaw単体で qwen3.6 が 「Claude 4.5に近い」品質**を出せるようになる

---

## 実装順 (優先度)

| Layer | 工数 | 効果 | 優先 |
|---|---|---|---|
| L3 Recurrent Pipeline | 30分 | ★★★ 最大 | **1** |
| L1 Entity Latent | 20分 | ★★ 大 | **2** |
| L5 Depth Templates | 15分 | ★★ 大 | **3** |
| L4 ACT Halting | 15分 | ★ 中 | **4** |
| L2 MoE Router | 30分 | ★ 中 | **5** |

---

## 関連
- [[concepts/claude-mythos-architecture]] — 原典 (OpenMythos解析)
- [[concepts/ai-economy-2026-structure]] — AI経済全体
- [[meta/lessons-learned-2026-05-19]] — 12h自走の学び
