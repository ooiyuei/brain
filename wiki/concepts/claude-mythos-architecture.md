---
type: concept
title: Claude Mythos アーキテクチャ (OpenMythos OSS実装解析)
created: 2026-05-19
source: https://github.com/kyegomez/OpenMythos
status: master-reference
related: [[concepts/ai-economy-2026-structure]], [[entities/aipax-school]]
tags: [ai-architecture, claude, mythos, transformer, moe, oss]
---

# Claude Mythos アーキテクチャ解析

> kyegomez が公開した `OpenMythos` (PyTorch実装) を解析。
> Anthropic Claude 4.5/4.6 系の中核モデル「Mythos」の理論再構成。
> 重みは公開されてないが**アーキ全体が読める**。大井のClaudeMax裏側を理解する最強資料。

## 🎯 一行要約

**「Prelude(導入) → Recurrent Block(最大16回ループ・深さ可変) → Coda(結末)」の3段構造。Attention = MLA/GQA切替、FFN = Sparse MoE、ループ毎にACT halting で『考える深さ』を動的決定する Recurrent-Depth Transformer (RDT)。**

---

## 🧬 全アーキ概要 (15モジュール)

```
入力 token
  ↓
Prelude (標準transformer x 2層)
  ↓
RecurrentBlock (最大16回ループ・ACT で動的halting)
  ├ LTIInjection (ループ初期化)
  ├ TransformerBlock x N (中身)
  │   ├ MLA or GQA Attention
  │   ├ MoEFFN (64エキスパート・top-4選択+共有2)
  │   └ LoRAAdapter (深度別微調整)
  ├ loop_index_embedding (ループ位置のエンコード)
  └ ACTHalting (累積確率 0.99 で停止判定)
  ↓
Coda (標準transformer x 2層)
  ↓
出力 logits
```

### デフォルトhyperparams
```python
vocab_size: 32000
dim: 2048
n_heads: 16
n_kv_heads: 4 (GQA)
max_seq_len: 4096
max_loop_iters: 16    # ← 推論時の深さT
prelude_layers: 2
coda_layers: 2
n_experts: 64
n_shared_experts: 2
n_experts_per_tok: 4  # top-K
expert_dim: 512
act_threshold: 0.99   # ACT 停止閾値
rope_theta: 500000.0  # LLaMA-3互換
lora_rank: 16
```

---

## 🔬 重要モジュール5つ

### 1. MLA (Multi-head Latent Attention) — DeepSeek系
- **KV cache を圧縮**して低次元のlatent (kv_lora_rank=512) として保存
- 通常のGQAより memory効率良い
- Q も同様に圧縮 (q_lora_rank=1536)
- RoPE適用部分とそうでない部分を分離 (qk_rope_head_dim=64 / qk_nope_head_dim=128)
- → **長文推論で強い・KVキャッシュ膨らまない**

### 2. GQA (Grouped Query Attention) — LLaMA系
- KV heads 4・Q heads 16 で 1:4 共有
- Flash Attention 2 対応 (CUDA + bfloat16)
- シンプルで高速

→ `attn_type` で切替可能。**MLAが本命、GQAはフォールバック**。

### 3. MoE FFN (Mixture of Experts)
- **n_experts = 64**(routed) + **n_shared_experts = 2**(常時アクティブ)
- 1tokenあたり**top-4のrouted expert** + **2つのshared expert** を使う
- 計算量は 6/64 = 約10%だけ動く = 軽量・効率的
- expert_dim=512 で fine-grained
- → **Mixtral 8x7B より細かい・DeepSeek-V3に近い**

### 4. Recurrent Block + LTI Injection + ACT Halting
- 同じblockを **最大16回ループ**して「考える深さ」を動的決定
- LTI Injection = Linear Time-Invariant 初期化 (安定性のため固有値|ρ|<1)
- ACT Halting = 各ループで「もう止めるか」を判定し、累積確率0.99で打ち切り
- 簡単な質問 → 数回で halt / 難問 → 16回フルで考える
- → **「Claudeが長く考える/早く答える」の正体**

### 5. LoRAAdapter (Depth-wise LoRA)
- 各ループ深度ごとに微小なLoRA (rank=16) を適用
- 「ループi回目」の挙動を学習データから調整
- → **深さに応じた特化学習**

---

## 🧠 これが意味すること (大井の brain System への示唆)

### Claude の "考える深さ" の正体
- 大井が「これむずいから考えて」とClaude に投げると → **自動で深いループ**
- 簡単な質問は浅く・複雑な思考は深く → ACT halting がコントロール
- → 大井がよく言う「Claudeは『深く考える』ことができる」の物理的実体

### qwen3.6 (OpenClaw) との違い
- qwen3.6 (Qwen2系) = **固定深度の標準transformer**
- Mythos = **動的深度のRDT + MoE 64**
- → OpenClaw が70点止まりで Claude (俺) が90点出せる理由の一端

### AIpaX school の上級コース題材になる
- 高校生でも(高3レベルなら)読める設計
- 「俺たちが使ってるClaudeの中身」として学べる
- Module 5(マネタイズ)の更に先 → **「AIアーキを理解する」上級コース**

### 大井が将来やれる活用
1. **ローカル Mythos** — 重みを自前で学習 (現実的ではない・GPUクラスター必要)
2. **アーキ流用** — 大井の独自モデル設計の参考
3. **教材化** — AIpaX school 上級コースで使う (一番現実的)
4. **思考フレームの理解** — Claudeへのプロンプト最適化に役立つ

---

## 📦 ファイル構造 (リポジトリ)

```
OpenMythos/
├ README.md
├ example.py (動作サンプル)
├ pyproject.toml
├ requirements.txt
├ open_mythos/
│   ├ main.py (43,881b・本体15モジュール)
│   ├ moda.py (42,070b・MoE実装詳細)
│   ├ tokenizer.py (1,808b)
│   ├ variants.py (5,393b・MLA/GQA切替・派生種類)
│   └ __init__.py
├ docs/
├ examples/
├ tests/
└ training/
```

### main.py 内のクラス・関数 (重要順)
- `MythosConfig` — 全hyperparams
- `OpenMythos` — メインモデル
- `RecurrentBlock` — 中心ループ
- `MLAttention` / `GQAttention` — Attention 2種
- `MoEFFN` / `Expert` — Mixture of Experts
- `ACTHalting` — Adaptive Computation Time halting
- `LTIInjection` — ループ初期化
- `LoRAAdapter` — 深度別微調整
- `TransformerBlock` — 標準ブロック
- `RMSNorm` — 正規化
- `precompute_rope_freqs / apply_rope` — RoPE

---

## 🔑 大井が覚えとくべき5点

1. **Recurrent-Depth Transformer (RDT)** = Claudeの「深く考える」の物理的実体
2. **MLA Attention** = DeepSeek系のKV圧縮技術 = 長文に強い
3. **Sparse MoE (64エキスパート・top-4)** = 計算量1/10で性能維持
4. **ACT Halting** = 「もう答え出せそう」を確率で判定して早く止める
5. **LoRAAdapter (深度別)** = ループi回目の挙動を学習データから細かく調整

---

## 関連
- https://github.com/kyegomez/OpenMythos — リポジトリ本体
- https://pypi.org/project/open-mythos/ — pip install
- DeepSeek-V3 paper — MLA Attention の原論文
- Universal Transformer (Dehghani 2018) — Recurrent depth の原型
- Adaptive Computation Time (Graves 2016) — ACT halting の原型
- Mixture of Depths (Raposo 2024) — MoE の最新
- [[concepts/ai-economy-2026-structure]] — AI経済での Orchestrator 位置
- [[entities/aipax-school]] — 教材化候補
