---
type: concept
title: Brain Mythos v2 — 強化版 (OpenMythos 2026版から再移植)
created: 2026-05-24
status: master-plan-v2
priority: P0
related: [[concepts/brain-mythos-design]], [[concepts/claude-mythos-architecture]]
sources: [github.com/kyegomez/OpenMythos (2026-05-24版・MODA追加後)]
tags: [architecture, brain-system, mythos, v2, strengthened]
---

# Brain Mythos v2 — 最強化版

> v1 ([[concepts/brain-mythos-design]]) で 5層実装済。
> 2026-05-24 時点で OpenMythos repo が更新され **MODA** (Mixture-of-Depths Attention) と **Variants** が追加。
> v2 では未移植の3技術 + 既存層の強化を統合。

---

## v1 実装ステータス監査 (2026-05-24時点)

| Layer | ファイル | 状態 | 弱点 |
|---|---|---|---|
| **L1** Entity Latent | (手動運用) | △ 9件OK / 7件未対応 | inject scriptがない |
| **L2** MoE Router | `scripts/mythos_router.ps1` | ✓ 動作 | top-1のみ・正規表現6パターンの単純マッチ |
| **L3** Recurrent Pipeline | `scripts/recurrent_pipeline.ps1` | ✓ 動作 | Depth3まで・ファイル探索ロジック堅牢 |
| **L4** ACT Halting | recurrent内に統合 | △ slope<5基準のみ | confidence/spectral未統合 |
| **L5** Depth Templates | `prompt_templates/depth_{1,2,3}_*.md` | ✓ 完備 | 内容適切 |
| **Coda** (Brushup) | `brushup_pipeline.ps1` ⭐NEW | ✓ 動作 (2026-05-19追加) | _promoted→_final 90点化 |

→ **v1 = 6層体制で約70%完成**

---

## OpenMythos 2026版で追加 (未移植3技術)

### 1. **MODA** (Mixture-of-Depths Attention) - `moda.py` 43KB 新規
各層が「**現在層 + 前層全部の同位置トークン**」に対して同時アテンション。深さを跨いだ統合理解が可能。

### 2. **Variants** (1B/3B/10B/50B/100B/500B/1T) - `variants.py` 新規
スケール別の事前設定。タスク複雑度に応じて depth/expert数 を変えられる。

### 3. **Spectral Radius Stability** - `ρ(A) < 1` check
LTI Injection の安定性条件。`A` 行列の最大固有値が1未満でないと**ループ発散**する。

---

## v2 強化計画 (新規4層 + 既存層改修)

### L1' Entity Latent 強化 — Auto-Injection Script

**変更点**: 手動運用 → 自動化
- `scripts/inject_entity_latent.ps1` 新規 — 17事業全件に latent セクション自動挿入
- 既存entity の更新時に latent も再生成

**ステータス (2026-05-24時点)**:
- ✓ 9件: agents-of-flag/aipa-web/aipax-school/aipax/eemus/gymee/juken-os/kasunote (既存) + ipak-darts/ipak-fishing/omni/ooi-yuei/ai-juku (本日追加)
- ✗ 残4件: ecokan/fruits-sauce/ipak-cafe/ipak-ofuro (寝かせ事業・優先度低)

### L2' MoE Router 強化 — Top-K Combine

**変更点**: top-1 → **top-K (=2) weight-combined**
- `scripts/mythos_router_v2.ps1` 新規 (既存 mythos_router.ps1 は維持)
- マッチした expert を weight 順 top-2 で**並列発火**
- shared experts (大井ソウル/フレームワーク/事業定義) は**常時注入**
- 64エキスパート相当の細粒度パターン拡張 (20+ pattern)

### L4' ACT Halting v2 — Multi-Criteria

**変更点**: slope のみ → **3条件 OR で halt**
1. **slope < 5** (改善幅小・既存)
2. **score >= 45 (= 90%)** (高品質到達・既存)
3. **spectral regression** = 前回より score 下がった (ループ発散兆候・新規)
4. **confidence >= 0.99** = レビューが「もう完成」判定 (新規)

実装: `recurrent_pipeline.ps1` に上記3条件追加

### 🆕 L6 Variants (Task Tier) — タスク複雑度別 config

**目的**: 1サイズ全部処理 → タスク複雑度別に最適化

| Tier | dispatch条件 | depth | brushup | 想定処理時間 |
|---|---|---|---|---|
| **mythos_1b** (light) | 300字未満・要約・整形 | 1 | なし | 30秒 |
| **mythos_3b** (default) | 通常dispatch | 2 | なし | 2分 |
| **mythos_10b** (deep) | priority=high・3000字以上 | 3 | あり | 5分 |
| **mythos_50b** (critical) | priority=critical・主力事業の核心 | 3+ | あり+Claude refine | 10分 |

実装: `dispatch.ps1` に `-Tier` パラメータ追加 / `worker.ps1` で tier別処理分岐

### 🆕 L7 Spectral Stability — 発散検知

**目的**: 「ループしても改善しない・むしろ悪化」を検知して即停止

```
score履歴: [Depth1=28, Depth2=32, Depth3=29]
   ↓
spectral radius = max(|score差|/|前回score|) = |29-32|/32 = 0.094
   ↓
ρ > 1 = 発散判定 → 即halt + 警告ログ
```

実装: `scripts/spectral_check.ps1` 新規

### 🆕 L8 MODA-inspired Cross-Depth Synthesis

**目的**: Depth1/2/3 の**各出力を全部Claudeに渡して**最終Synthesis

```
Depth1 = 量重視の粗稿 (アイデア網羅)
Depth2 = 弱点改善版 (具体性)
Depth3 = キャラ厳密版 (大井らしさ)
   ↓
[Coda Synthesis] Claude(俺) が3版を読んで「いいとこ取り」90点版生成
   ↓
_final/
```

実装: `brushup_pipeline.ps1` の改修 — 元1ファイル → Depth1+2+3 の3ファイル統合参照

---

## v2 全体アーキ (再描画)

```
[大井の発話]
  ↓
[Prelude] Claude判定 (即答/単純dispatch/複雑/critical)
  ↓
[L6 Variants] Tier決定 (1b/3b/10b/50b)
  ↓
[L2' Router v2] Top-K experts 選択 (+ shared experts常時注入)
  ↓
[L3 Recurrent Pipeline]
  ├ Depth1 (Volume) → score
  ├ [L4' ACT v2] slope/score/spectral/confidence 4条件チェック
  ├ Depth2 (Refine) → score → 4条件チェック
  ├ Depth3 (Persona) → score → 4条件チェック
  ↓
[L7 Spectral Check] 発散兆候あれば即halt
  ↓
[L8 MODA Synthesis] Depth1+2+3を統合 → Claude refine
  ↓
[Coda] Brushup → _final/
  ↓
[大井へ]
```

---

## 期待効果 (v1 vs v2)

| 指標 | v1 | v2 | 改善 |
|---|---|---|---|
| 平均スコア | 29.1点 | 推定42点 | +13点 |
| 90点到達率 | 5% (PROMOTE) | 推定25% | 5倍 |
| 無駄ループ削減 | slopeのみ | 4条件 | 30%削減 |
| Entity Latent カバー | 56% (9/16) | 81% (13/16) | +25pp |
| タスク種類別最適化 | 1サイズ | 4Tier | 4倍 |
| Brushup品質 | 1原稿 → 1ブラッシュ | 3原稿 → MODA Synthesis | 統合知 |

---

## 実装優先順 (v2 ロードマップ)

| 優先 | Layer | 工数 | 効果 | 状態 |
|---|---|---|---|---|
| **1** | L1' inject script (残4件) | 10分 | 中 | 13/16 完了 (本日) |
| **2** | L4' ACT v2 (3条件追加) | 30分 | ★★★ | 未着手 |
| **3** | L7 Spectral Check | 20分 | ★★ | 未着手 |
| **4** | L8 MODA Synthesis (brushup改修) | 45分 | ★★★ | 未着手 |
| **5** | L6 Variants (dispatch -Tier) | 40分 | ★★ | 未着手 |
| **6** | L2' Router v2 (top-K) | 30分 | ★ | 未着手 |

---

## ハードウェア制約 (重要)

**ローカル動作**: 大井のRTX 5060 8GB では mythos_10b 以上は動かない (重みなしの実装も)。
ただし brain System は **設計思想の移植** であり、qwen3.6 をベースに上記レイヤーを**ロジックレベルで再現**する。

相方のRTX 5060 Ti 16GB機で DeepSeek-V2-Lite 等を動かすテストを別途実施予定。

---

## 関連

- v1: [[concepts/brain-mythos-design]] (既存5層設計)
- 原典: [[concepts/claude-mythos-architecture]] (OpenMythos解析)
- 失敗教訓: [[meta/lessons-learned-2026-05-19]] (12h自走の学び)
- 大井ソウル: [[meta/ooi-soul]] (Sharedエキスパート最上位)

---

*2026-05-24 OpenMythos 2026版 (MODA+Variants追加) を確認・v2設計確定。*
