---
type: concept
title: OpenMythos完全分析（Claude Mythos理論的再構成）
created: 2026-05-19
tags: [llm, architecture, recurrent-depth, transformer, moe, mla, analysis, ai-research]
related: [[entities/aipax]], [[entities/testall]], [[concepts/recurrent-depth-prompting]]
source: github.com/kyegomez/OpenMythos
status: analysis-complete
---

# OpenMythos — Claude Mythos理論的再構成 完全分析

> **大井指示**: 「話題になってたオープンミュトス、分析して最強にして」
> **結論**: AIエージェントフレームじゃない。LLMモデルアーキテクチャ研究実装。直接組み込みは非現実的だが、思想は事業に移植可能。

## 1. 基本情報

| 項目 | 値 |
|---|---|
| リポジトリ | https://github.com/kyegomez/OpenMythos |
| 作者 | Kye Gomez (@KyeGomezB) |
| ライセンス | MIT |
| ⭐スター | 13.3k |
| Fork | 3k |
| 公開日 | 2026-04頃（MarkTechPost記事から推定） |
| PyPI | `pip install open-mythos` |
| 言語 | Python 100% |
| メディア露出 | MarkTechPost / Decrypt / Awesome Agents / Trendshift |

## 2. プロジェクトの正体（一文）

**Anthropic Claude Mythosモデルのアーキテクチャを、公開研究文献から第一原理で理論的に再構成したPyTorch実装**。Anthropicとは無関係。学習済み重みなし。コードは「仮説の実装」。

## 3. 中核仮説（Central Hypothesis）

```
Claude Mythos = Recurrent-Depth Transformer (RDT)
              + Mixture-of-Experts (DeepSeekMoE)
              + Multi-Latent Attention (DeepSeek-V2)
              + LTI-Stable Injection (Parcae)
              + Adaptive Computation Time
```

つまり: **同じ重みを最大64回ループして「深い思考」をする**。各ループで隠れ状態が連続潜在空間で更新される。チェーン・オブ・ソートのようなトークン出力なしに「思考」が起きる。

## 4. アーキテクチャ図

```
Input (B, T) — token IDs
   ↓
[Embedding]
   ↓
[Prelude P]  — 2-6 standard TransformerBlocks (run once)
   ↓
   e = x (encoded input, frozen)
   ↓
[Recurrent Block R]  — looped T times (T = 16〜64)
   ↑___________↓
   h_{t+1} = A·h_t + B·e + Transformer(h_t, e)
   ↓ (ACT halting may exit early)
[Coda C]     — 2-6 standard TransformerBlocks (run once)
   ↓
[RMSNorm → LM head]
   ↓
Output logits (B, T, vocab_size)
```

## 5. 技術要素 8 つの解説

| # | 技術 | 役割 | 出典 |
|---|---|---|---|
| 1 | **Recurrent-Depth Transformer** | 同じ重みを T回ループ → 深さ拡張 | Loop, Think, & Generalize (2025) |
| 2 | **LTI Injection** | スペクトル半径 ρ(A)<1 で安定化 | Parcae (Prairie et al., 2026) |
| 3 | **Adaptive Computation Time** | 困難な問題に多く計算配分 | Graves (2016), Universal Transformer |
| 4 | **Multi-Latent Attention** | KVキャッシュ 10-20倍削減 | DeepSeek-V2 (2024) |
| 5 | **Grouped Query Attention** | KVヘッド数を減らして高速化 | Ainslie et al. (2023) |
| 6 | **DeepSeekMoE** | fine-grained experts + shared experts | Dai et al. (2024) |
| 7 | **Loop-index RoPE** | 各ループで異なる位相 → 機能分化 | RoPE変形・本実装独自 |
| 8 | **Depth-wise LoRA** | 各ループ微調整・パラメータ効率 | Relaxed Recursive Transformers (Bae et al., 2024) |

## 6. スケール変種

| Variant | dim | Experts | Expert dim | Loops | Context | Output |
|---|---|---|---|---|---|---|
| mythos_1b | 2048 | 64 | 2048 | 16 | 4k | 4k |
| mythos_3b | 3072 | 64 | 4096 | 16 | 4k | 4k |
| mythos_10b | 4096 | 128 | 5632 | 24 | 8k | 4k |
| mythos_50b | 6144 | 256 | 9728 | 32 | 8k | 4k |
| mythos_100b | 8192 | 256 | 13568 | 32 | **1M** | 128k |
| mythos_500b | 12288 | 512 | 23040 | 48 | **1M** | 128k |
| mythos_1t | 16384 | 512 | 34560 | **64** | **1M** | 128k |

## 7. 主要主張

### スケーリング則
**770M パラメータの RDT が 1.3B 標準 Transformer に同等性能**
→ ループ深度を増やせばパラメータ半分で同品質

### 学習効率
ループ型は通常Transformerより**2.5倍高速に収束**（Tiny Shakespeare実証）
- 1B: 10-15B tokens で十分（Chinchilla 20Bより少）
- 3B: 30-40B tokens
- 10B: 100-150B tokens

### 学習スタック
- Optimizer: AdamW
- Dataset: HuggingFaceFW/fineweb-edu（1.3T）+ OpenHermes 2.5 + OpenWebMath
- Tokenizer: openai/gpt-oss-20b
- Precision: bfloat16 (H100/A100) / float16 + GradScaler (旧GPU)
- Parallelism: PyTorch DDP via torchrun

## 8. なぜこれが Claude を説明するのか（4つの根拠）

### (1) Systematic Generalization
Vanilla Transformer は訓練中に見たことない組み合わせで失敗。**Looped Transformer は通る** → 3段階のグロッキング過程で創発的に獲得。

### (2) Depth Extrapolation
訓練時 5-hop reasoning chain → 推論時 10-hop も解ける。Vanilla TFは失敗。**ループ回数を増やせば深い問題が解ける**。

### (3) Latent Chain-of-Thought
**T回ループ ≈ T ステップの暗黙チェーン・オブ・ソート**。連続潜在空間なので「複数の次手を同時表現」可能 → breadth-first reasoning。

### (4) No Parameter Explosion
k層ループ L回 = kL層非ループモデルと同品質。**深い思考をパラメータ爆発なしで実現**。

## 9. 安定性問題と解法

**ループモデルは訓練が不安定**:
- Residual explosion（hidden state h_t が無限大に発散）
- Loss spike（スペクトルノルム大）

**Parcae の解法**:
1. A = continuous negative diagonal matrix
2. ZOH/Euler離散化: A_discrete = exp(Δt · A_continuous)
3. **ρ(A) < 1 が常に保証される by construction**
4. 学習率に対してロバスト・clean training

これが本実装の中核安定化メカニズム。

## 10. 重要な未解決問題

### 過剰思考（Overthinking）
ループ多すぎると「答えを通り越して」精度が落ちる → ACT halting で動的停止

### Memorization-Reasoning Tradeoff
ループは推論を強くするが、事実記憶が弱くなる傾向。Claude が「推論は神だが事実記憶は不安定」と感じる原因かも。

## 11. 批判・懐疑論

| 観点 | 内容 |
|---|---|
| **理論実装のみ** | Anthropic公式じゃない・学習済み重みなし。「仮説」 |
| **再現性リスク** | MoE + LTI + ACT + LoRA の同時統合は高難度 |
| **Mythos優位性疑問** | Vidoc Security が既存 GPT-5.4 / Opus 4.6 で同様の脆弱性発見再現 → Mythos の優位性は思ったより限定的かも |
| **Kye Gomez 評判** | リポジトリ数が多い反面、品質はバラバラと言われがち |

## 12. 学習コストの現実

| Scale | 必要GPU | 推定コスト | 期間 |
|---|---|---|---|
| 1B | H100 ×1 | 〜10万円 | 1-2週間 |
| 3B | H100 ×4 | 〜100万円 | 1-2週間 |
| 10B | H100 ×16 | 〜500万円 | 2-3週間 |
| 100B+ | H100 ×数百 | 億円規模 | 数ヶ月 |

→ 大井が「最強化」のために**学習する**のは非現実的。**思想を抽出して事業に組み込む方が圧倒的にROI高い**。

## 13. ライブラリ依存関係

```
torch >= 2.1.0
transformers >= 4.40.0
datasets >= 2.18.0
flash-attn >= 2.8.3 (optional, CUDA required)
```

## 14. 主要参考文献

### Twitter/X 議論
- @realsigridjin: なぜ Claude Mythos がすごいか - ループTF理論
- @hayden_prairie: Parcae スケーリング則
- @davidad: RoPE-like loop index embedding
- @ChrisHayduk: Looped Transformers Controversy

### 論文
- Loop, Think, & Generalize (2025): https://arxiv.org/pdf/2604.07822
- Parcae (Prairie et al., 2026): https://arxiv.org/abs/2604.12946
- Reasoning with Latent Thoughts (Saunshi et al., 2025): https://arxiv.org/abs/2502.17416
- DeepSeek-V2: https://arxiv.org/abs/2405.04434
- DeepSeekMoE: https://arxiv.org/abs/2401.06066
- Relaxed Recursive Transformers: https://arxiv.org/pdf/2410.20672
- Universal Transformers: https://arxiv.org/pdf/1807.03819
- COCONUT: https://arxiv.org/abs/2412.06769

## 15. 大井文脈での評価

| 観点 | スコア | コメント |
|---|---|---|
| 話題性 | ★★★★★ | 13.3kスター・Decrypt/MarkTechPost掲載 |
| 実用性（直接組み込み） | ★ | 学習コスト非現実・LLM API使う方が早い |
| 学習価値 | ★★★★ | モダンLLMアーキ理解材料・SFC AOテーマ「思考の外部化」直結 |
| **思想の移植価値** | ★★★★★ | **RDTのループ思想をプロンプト化して AIpaX/Testall に組み込める** |
| **解説者ブランディング** | ★★★★★ | **18歳が日本語で最初に解説 → AI界隈で名前売れる** |

→ 詳細は [[concepts/recurrent-depth-prompting]] を参照。

## 16. 「最強化」5段階プラン

### Phase 1: 即実行（今週・無料）
1. このページを Brain wiki に保存（完了）
2. **note記事「Claude Mythosとは何か？OpenMythos完全解説」を書く**
3. **X スレッド 5本**（RDT/MoE/MLA/ACT/Scaling Laws 各1本）
4. SFC AO 志望理由に追加：「OpenMythos読解で深層思考の構造を把握、AIによる思考外部化の極端形として研究」

### Phase 2: AIpaX 組み込み（1ヶ月・実装）
5. **RDT思想を「保存庫検索プロンプト」に移植**
   - 顧客質問 → Loop1 検索 → Loop2 矛盾チェック → Loop3 顧客別条件適用 → Loop4 確認事項抽出 → 最終回答
   - 既存4社にアップセル材料（v2機能）

### Phase 3: Testall 組み込み（1ヶ月・実装）
6. **Loop reasoning で診断精度向上**
   - テスト結果 → Loop1 弱点抽出 → Loop2 優先度 → Loop3 45分タスク生成 → Loop4 動機付け
   - 既存JUDGE 75点 → 80点台へ

### Phase 4: ビジコン武器化（2-3ヶ月）
7. **「RDT-prompting によるAI事業効率化」**を [[entities/business-contests-expanded]] のテック系コンテストネタに
8. 特に **U18 AIチャンピオンシップ（6/22）**、**SIH国際**、**Stanford e-Entrepreneurship** で技術深度アピール

### Phase 5: PoC 軽量学習（3-6ヶ月・1-2万円）
9. **Vast.ai で mythos_1b を Tiny Shakespeare 学習**
10. 「日本最年少 OpenMythos 学習成功者」ブランディング → 採用Web AIpa の権威性に直結

## 17. 関連
- [[concepts/recurrent-depth-prompting]] — RDT思想のプロンプト実装ガイド
- [[entities/aipax]] — 組み込み先1
- [[entities/testall]] — 組み込み先2
- [[entities/ooi-yuei]] — SFC AO志望テーマと連動
- [[entities/business-contests-expanded]] — 武器化先
- [[meta/execution-log]] — 実装証拠の記録先

---

*分析者: Claude (大井湧瑛 CEOモード) / 2026-05-19*
