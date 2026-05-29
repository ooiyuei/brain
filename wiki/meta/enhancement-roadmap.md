---
type: meta-roadmap
title: Brain System 強化ロードマップ
tags: [meta, roadmap, enhancement]
created: 2026-05-18
updated: 2026-05-18
---

# Brain System 強化ロードマップ

> 「ローカルLLM × OpenClaw × Claude の最強環境」を継続的に強化するためのロードマップ。
> 大井が「強化して」と言ったらここを参照。週次 BrainSelfReview が自動更新する設計。

## 達成済み ✅

### Tier S（基盤）
- **S1: 2レーン並列化** ✅ 2026-05-18
  - BrainWorkerHeavy (qwen3.6:latest) + BrainWorkerLight (qwen3:8b)
  - 並列処理で処理能力倍化
  - 自動レーン振り分け（プロンプト長・use_agent で判定）
- **S2: 追加モデル** ✅ 2026-05-18
  - qwen3.6:latest（23GB・重い思考）
  - qwen3:8b（5.2GB・中程度量産）
  - phi3:mini（2.2GB・超軽量・応答速い）
  - nomic-embed-text（274MB・RAG用）
- **S3: RAG基盤** ✅ 2026-05-18
  - `scripts/embed_wiki.ps1` でwiki全文をベクトル化
  - `scripts/search_wiki.ps1` でクエリ→上位K件取得
  - 長期記憶として活用可能

### Tier A（自己進化）
- **A1: self_review.ps1** ✅ 2026-05-18
  - 毎週日曜22:00 BrainSelfReview スケジューラ
  - worker.log / failed/ / wiki/_inbox/ を集計
  - OpenClawに改善提案を依頼 → wiki/meta/self-review-proposals-{日付}.md
- **A2: Whisper準備** ⚠ 2026-05-18 設計済
  - WHISPER-SETUP.md にインストール手順
  - バイナリDLが必要なので大井対応待ち

## 保留・将来 🔜

- ~A3: Anthropic API直叩き~ ❌ API代かかるため廃止
- ~B1: OpenClaw Discord双方向~ 🔜 Bot Token取得後
- B2: Stable Diffusion等（画像生成） 🔜 ディスク空き次第
- B3: コーディングエージェント常駐（ACP） 🔜 Gateway要

## 自動強化サイクル

```
毎週日曜22:00
   ↓
BrainSelfReview 実行
   ↓
過去1週間のworker.log分析
   ↓
エラーパターン / 滞留 / 失敗 を集計
   ↓
OpenClawが改善提案3つ生成
   ↓
wiki/meta/self-review-proposals-{日付}.md
   ↓
Claude が月曜朝のmorningルーティンで読む
   ↓
重要なら即実装、保留なら inbox.md に記録
```

## 大井からの強化指示の処理ルール

大井が「強化して」「最強にして」と言ったら、Claudeは：

1. このファイルを読む
2. **未実装の高優先項目を1-3個選ぶ**
3. 即実装（自走）
4. このファイルの「達成済み」セクションに追記
5. 完了通知を Discord に送る

## 強化候補リスト（思いつき）

新しいアイデアがあればここに追加：

- [ ] OllamaのGPU設定最適化（num_gpu / num_ctx チューニング）
- [ ] wiki検索結果をmorningルーティンで参照する仕組み
- [ ] 大井のChatGPT過去ログ全件取り込み（RAG対象拡張）
- [ ] OpenClaw mainエージェントの system prompt カスタマイズ
- [ ] Linear / Notion MCP 連携の深掘り
- [ ] BrainHealth の自動修復機能（lock削除・worker再起動）
- [ ] processing/ 詰まりの自動回復

## 関連
- [[CLAUDE]] — Claude動き方原則
- [[_routines/_MOC]] — ルーティン索引
- 設計図: [[meta/system-architecture]] （要作成）
