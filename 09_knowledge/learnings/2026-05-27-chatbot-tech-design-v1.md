---
type: tech-design
date: 2026-05-27
title: 大井湧瑛 チャットボット 技術設計書 v1
target: 「大井湧瑛として応答するエージェント」を MVP→v3 段階的に実装
related:
  - [[09_knowledge/learnings/2026-05-27-ooi-clone-spec-v3]] (システムプロンプト本体)
  - [[wiki/entities/testall]] (Anthropic SDK 実装事例)
tags: [chatbot, technical, claude-api, rag, fine-tuning, infra]
---

# 大井湧瑛 チャットボット 技術設計書 v1

> 「俺という人格をデータで再現してほしい・ゆくゆくはチャットボットにしたい」(大井 2026-05-27 指示) を実現する技術設計書。3段階 (MVP / v2 / v3) で実装可能。

---

## エグゼクティブサマリー

### 目的
- 大井湧瑛として応答するチャットボットを構築
- 用途: 大井の不在時の代理応答 / X 自動返信 / 営業ドラフト生成 / 思考整理アシスタント / フォロワーとの対話

### 実装3段階
1. **MVP (1日)**: システムプロンプト方式 + Claude API + Vercel/Next.js
2. **v2 (1週間)**: RAG (brain 全件 vector化) + 直近会話履歴学習
3. **v3 (1ヶ月+)**: ファインチューニング (大量データ蓄積後)

### 推奨着手順
- 今すぐ着手可能: **MVP (1日で動く・¥0 初期費用)**
- 既存資産活用: Testall のコードベース (Next.js + Anthropic SDK + Vercel) を fork
- 完成後: X 自動返信 / 大井不在時の対応 Bot として公開も可能

---

## Phase 1: MVP (システムプロンプト方式) — 1日で完成

### アーキテクチャ
```
[User Web UI]
    ↓ (POST /api/chat)
[Next.js API Route on Vercel]
    ↓ (Anthropic SDK)
[Claude API (claude-sonnet-4-6 推奨、深い応答時は opus 4-7)]
    ↑ (System Prompt: ooi-clone-spec-v3 全文 ≈ 8K tokens)
    ↓ (Streaming response)
[User]
```

### 技術スタック
- **Frontend**: Next.js 16 + Tailwind + shadcn/ui (Testall 流用)
- **Backend**: Next.js API Route (`/api/chat`)
- **LLM**: Claude API (claude-sonnet-4-6, fallback opus-4-7)
- **Deploy**: Vercel (Testall と同じ team_3HJIyzwuV3Jou9KUAwoi5W2B)
- **認証**: Supabase Auth (Google OAuth、Testall 流用)
- **データベース**: Supabase Postgres (会話履歴保存・分析用)
- **コスト**: Claude API のみ ($3-15/月、低頻度なら)

### プロジェクト名
- 推奨: `yuei-bot` or `ooi-clone` or `ooi-cco` (Chief Clone Officer)
- ドメイン: `yuei.ai` / `yuei.chat` 等で取得可

### 実装手順 (1日)
1. **0-1h**: Testall リポを fork → `yuei-bot` リポ作成
2. **1-2h**: システムプロンプト = ooi-clone-spec-v3 全文を `src/lib/system-prompt.ts` に投入
3. **2-4h**: `/api/chat` を Anthropic SDK で実装 (streaming)
4. **4-6h**: フロントUI (シンプルなチャット画面、shadcn/ui)
5. **6-7h**: Vercel deploy + 動作確認
6. **7-8h**: X で先行公開「俺のクローン作った、聞いてみて」(バイラル狙い)

### システムプロンプト構造
```typescript
const SYSTEM_PROMPT = `
<ooi-clone-spec-v3 全文 (約8000 tokens)>

# ユーザーとの会話開始指示
- 必ず大井湧瑛として応答する
- 1人称「俺」、文体・トーンは仕様書通り
- 質問タイプ別の動作プロトコルに従う
- 不明な事実は「推測:」「[要確認]」明記
- 内部情報 (Stripe売上等) は答えない
`;
```

### 制限
- システムプロンプト方式の限界: 8K-200K tokens (Claude の context window 内)
- 大井の直近 1日分の発話 (`wiki/_conversations/`) は **Few-Shot として5-10本含める** とリアリティ増す
- 完全な人格再現は不可能 (会話の機微・新しい情報への反応は限界あり)

---

## Phase 2: RAG (Retrieval-Augmented Generation) — 1週間で完成

### 追加アーキテクチャ
```
[User Query]
    ↓
[Embedding (text-embedding-3-large or Voyage AI)]
    ↓
[Vector Search on Supabase pgvector]
    ↑ (brain 全件 を chunked & embedded)
    ↓ (top-5 関連 chunks)
[Claude API with System Prompt + Retrieved Context]
    ↓
[Response]
```

### RAG データセット (brain 全件)
- **wiki/meta/ooi-*.md** (12ファイル ≈ 130KB) — 大井プロファイル
- **wiki/entities/*.md** (24ファイル ≈ 200KB) — 各事業詳細
- **wiki/sources/*.md** (取り込み素材) — 森岡・シンコーダー・AIコーディング教科書等
- **09_knowledge/learnings/*.md** — 直近の学び
- **wiki/_conversations/YYYY-MM-DD/*.md** — 過去の発話原文 (UserPromptSubmit hook 保存分・継続増加)
- **daily/*.md** — 日報

合計: 約 1-3MB のテキスト → 500-1500 chunks (各 ~1000 tokens)

### Embedding 戦略
- モデル: `text-embedding-3-large` (1536次元) or `voyage-large-2`
- Chunk size: 1000 tokens, overlap 200
- Metadata: ファイルパス・更新日・タグ
- 更新頻度: 日次バッチ (brain の hook で自動)

### Retrieval ロジック
1. ユーザー query → embedding
2. Supabase pgvector で similarity search (top-10)
3. Re-ranking (Claude で関連度判定 → top-5 絞り込み)
4. System Prompt に Retrieved chunks を挿入

### コスト試算 (v2)
- Embedding (1回): $0.50-2 (1MB のテキスト)
- 月次更新: $1-5
- Claude API: $5-30/月 (利用量による)
- Supabase: 既存プロジェクト無料枠で十分

### 実装手順 (1週間)
- **Day 1-2**: pgvector 設定 + Embedding パイプライン作成
- **Day 3-4**: brain 全件を chunked → embedded → 投入
- **Day 5**: Retrieval API 実装
- **Day 6**: re-ranking 実装
- **Day 7**: A/B テスト (MVP vs v2)、品質確認

---

## Phase 3: ファインチューニング — 1-3ヶ月

### 前提
- 大井の発話データが **1000-10000件** 蓄積された後 (UserPromptSubmit hook の `_conversations/`)
- 現状 (5/27 時点) は約 50-100 件、まだ早い

### 方式 A: Anthropic ファインチューニング (公式・推奨)
- Claude のファインチューニングが正式リリースされたら採用
- 大井発話 + AI応答ペアを train dataset 化
- コスト: $1,000-10,000 (一括) + 推論コストは通常

### 方式 B: OpenAI ファインチューニング (代替)
- GPT-4o-mini で fine-tune
- 大井発話を assistant 側に、入力 prompt を user 側に
- コスト: $100-1000 (低コスト)
- 性能: Claude より文体再現が劣る可能性

### 方式 C: ローカル LLM (qwen3.6 等) + LoRA
- OpenClaw インフラ流用 (Ollama)
- LoRA で軽量ファインチューニング
- メリット: コスト ¥0 (電気代のみ)
- デメリット: 文体再現の精度限界

### 推奨タイミング
- 大井発話 1000+ 件蓄積 = 約 6-12ヶ月後
- それまでは Phase 2 (RAG) で十分

---

## チャットボットの公開戦略

### 用途別 UI

#### 1. プライベート (大井専用・思考整理アシスタント)
- URL: `yuei.ai/me` (Supabase Auth でログイン)
- 機能: brain 全件への自然言語問い合わせ・思考メモから事業案抽出・自分の過去発言検索

#### 2. パブリック (フォロワー向け・X バイラル狙い)
- URL: `yuei.ai/chat` (認証不要・rate limit あり)
- 機能: 「大井に聞いてみる」コーナー
- 訴求: 17歳起業家のリアル知見にアクセス可能
- バイラル: X で 「俺のクローンに事業案聞いてみたら〇〇って言われた」スクショ拡散

#### 3. B2B (アクセラ受講生向け・大井塾の教材)
- URL: `yuei.ai/coach` (受講生限定)
- 機能: アクセラ生が事業相談・大井不在時の壁打ち相手
- 価格: 大井塾本科の特典として無料 / 単体 月額9,800円
- 大井塾の差別化要素として最強 (「大井に24時間アクセス」)

#### 4. 営業ドラフト生成 Bot
- 用途: 大井宛の問い合わせメールに対して「大井ならこう返す」ドラフト生成
- 統合: Gmail 連携で下書き自動作成
- 既存の Gmail MCP draft 機能を強化

---

## 倫理・リスク

### 大井の人格を扱う上で
- **本人 (大井) の承認必須** で公開
- 「これはAIです、本人ではありません」の明示 (混同回避)
- ハラスメント・差別等の応答を出さないガードレール (Anthropic のContent Policy 準拠)

### 自伝・センシティブ情報
- 父親・里親・寮の話は **絶対に bot から発話しない** (システムプロンプトに禁則明記済)
- 「英徳」の名前を勝手に出さない
- EXPACT 等の批判は内部のみ・対外発信時カット

### コピー・なりすまし対策
- bot とのやりとりを大井公式アカウント (X) で発信する時は、「bot 経由」と明示
- 大井本人の発言と区別

### 知的財産
- システムプロンプトは大井の人格データ = **大井の所有物**
- 第三者がコピーして勝手に運用しないよう、ライセンス明示
- brain も同様 (private repo + 暗号化バックアップ)

---

## 開発ロードマップ

### 即実行 (今週中)
- [ ] Day 1: yuei-bot リポ作成 (Testall fork)
- [ ] Day 1: システムプロンプト投入 (ooi-clone-spec-v3 全文)
- [ ] Day 2: フロントUI + Vercel deploy
- [ ] Day 2: 大井が動作確認 → 「俺っぽい?」フィードバック
- [ ] Day 3: 微調整 (Few-Shot 強化、口調補正)

### 1週間以内 (Phase 2 着手)
- [ ] Supabase pgvector 設定
- [ ] brain Embedding パイプライン
- [ ] RAG 動作確認

### 1ヶ月以内 (公開準備)
- [ ] パブリック UI で「大井に聞いてみる」公開
- [ ] X バイラル投稿 (3本)
- [ ] フィードバック収集 (大井 + フォロワー)

### 3ヶ月以内 (大井塾本科への統合)
- [ ] B2B 版 (アクセラ受講生向け) 公開
- [ ] 月額9,800円プラン設定 (大井塾本科特典 or 単体)

### 6-12ヶ月以内 (Phase 3 検討)
- [ ] 発話データ蓄積 1000+ 件確認
- [ ] ファインチューニング着手判断

---

## コスト試算 (年間)

| 項目 | MVP (Phase1) | + RAG (Phase2) | + Fine-tune (Phase3) |
|---|---|---|---|
| Claude API | $60-360/年 | $120-600/年 | $120-600/年 |
| Embedding | - | $24/年 | $24/年 |
| ファインチューニング | - | - | $1,000-10,000 (一括) |
| Vercel | $0 (Hobby) | $0 | $20/月 (Pro 必要) |
| Supabase | $0 (Free) | $0 (Free) | $25/月 (Pro 必要) |
| ドメイン (yuei.ai 等) | $50-200/年 | - | - |
| **合計** | **$110-560/年** | **$144-624/年** | **$1,640-10,824/年** |

→ MVP は **月3000-50000円**で運営可能。フォロワー 1000人いれば即元取れる。

---

## 既存資産との接続

### 流用元
- **Testall** (apps/testall) — Anthropic SDK 実装事例、Next.js 16 構成、Supabase Auth
- **kasunote** — Vercel deploy パターン
- **brain/wiki/meta/ooi-*** — システムプロンプト本体
- **brain/scripts/dispatch.ps1** — OpenClaw 経由でローカル LLM 試作も可能

### 横展開先
- **AIpaX** との連携: 大井クローンを社内コンサル代行として顧客に提供 (B2B加価値)
- **AIpaX school** との連携: 受講生の質問に大井クローンが答える教材化
- **大井塾本科** との連携: アクセラの 24/7 メンター機能
- **Testall** との連携: 受験生の悩みに大井クローンが答える機能 (差別化要素)

---

## 大井がやるべきこと (時系列)

### 今日中 (5/27)
- このドキュメントを確認 → MVPの方向で合意か判断
- 既存 ooi-clone-spec-v3 を読んで「俺っぽいか」感想

### 今週中
- yuei-bot リポ作成 (Testall fork)
- システムプロンプト投入 → ローカル動作確認

### 来週
- Vercel deploy
- X で MVP 公開
- フィードバック収集

### 1-3ヶ月
- RAG 拡張
- 大井塾本科への統合検討

---

## 関連

- システムプロンプト本体: [[09_knowledge/learnings/2026-05-27-ooi-clone-spec-v3]]
- 母親会話 (データポイントD): [[wiki/sources/2026-05-27-mother-line-conversation]]
- 戦闘姿勢: [[09_knowledge/learnings/2026-05-27-ooi-fighting-spirit]]
- 3年ビジョン: [[09_knowledge/learnings/2026-05-27-3year-vision-2029]]
- Testall (実装事例): [[10_projects/Testall]]
- 大井塾 (B2B 活用先): [[02_newbiz/ideas/2026-05-27-ooi-juku-accelerator]]
