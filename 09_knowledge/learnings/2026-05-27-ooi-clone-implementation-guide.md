---
type: clone-implementation
version: 1.0
date: 2026-05-27
title: 大井湧瑛 クローン 実装手順書 v1
purpose: yuei-bot を実際に動くチャットボットとしてデプロイするための具体手順 (1日で完成)
sources:
  - [[2026-05-27-ooi-clone-spec-v4-perfect-copy]] (システムプロンプト)
  - [[2026-05-27-ooi-clone-jsonl-dataset]] (Few-Shot データセット)
  - [[2026-05-27-chatbot-tech-design-v1]] (技術設計書)
stack: Next.js 15 + Anthropic SDK (Claude Opus 4.7) + Supabase + Vercel
estimated_time: Phase 1 (1日)・Phase 2 (3日)・Phase 3 (6-12ヶ月)
tags: [implementation, yuei-bot, chatbot, clone]
---

# 大井湧瑛 クローン 実装手順書 v1

> **目標**: 大井の人格をシステムプロンプトとして投入し、Web チャット UI で会話できる状態を1日で構築する。
> **将来**: RAG (brain 全件 embedding) と fine-tuning でクローン精度を上げる。

---

## §0. 全体像

```
[ユーザー]
    ↓ "tobira-logどう思う?"
[Next.js App Router (Vercel)]
    ↓ POST /api/chat
[Anthropic SDK (Claude Opus 4.7)]
    System Prompt = v4 spec (20K tokens)
    + Few-Shot 36 examples
    + (Phase 2) RAG retrieved chunks
    ↓
[Response] → SSE Streaming → UI
```

---

## §1. Phase 1 (MVP・1日で完成)

### §1.1 リポ作成

```bash
# 1. GitHub に yuei-bot リポ作成 (プライベート)
gh repo create yuei-bot --private --description "大井湧瑛 personality clone chatbot"

# 2. ローカルにクローン
cd C:\Users\Owner\business\アプリ
git clone https://github.com/ooi-yuei/yuei-bot.git
cd yuei-bot

# 3. Testall を雛形として使う (UI コピー)
cp -r C:\Users\Owner\business\アプリ\testall\src\* ./src/
# package.json, tsconfig.json なども調整
```

または Next.js を新規生成:

```bash
npx create-next-app@latest yuei-bot --typescript --tailwind --app --src-dir
cd yuei-bot
npm install @anthropic-ai/sdk
```

### §1.2 環境変数

`.env.local`:

```
ANTHROPIC_API_KEY=sk-ant-...
NEXT_PUBLIC_APP_URL=http://localhost:3010
```

将来 Vercel 環境変数にも同値を設定 (Project Settings → Environment Variables)。

### §1.3 システムプロンプト読み込み

`src/lib/system-prompt.ts`:

```typescript
export const SYSTEM_PROMPT = `あなたは大井湧瑛 (Yuei Ooi / 17歳・現役高校生起業家・静岡出身) として応答する。

# 一行定義
「人生を取り返すために走っている18歳が、走ること自体を止められなくなっている。」

# 言語OS (必須)
- 一人称: 「俺」
- 文末: 体言止め多用、「〜なんよね」「〜やん」
- 文頭: 「えっとー」「まー」「ちな」「ぶっちゃけ」
- 副詞: 「めっちゃ」「マジで」「ガチで」「圧倒的」
- 改行多め、3-5行で完結
- 断言型 (「思います」禁止)

# 思考OS
- シンコーダー10項目で事業評価
- 必須フィルター: 「絶対に買う1人」「明日使う1人」「圧倒的差」「CPA 100-300円」
- 判断: GO / HOLD / PIVOT で先に結論

# 戦闘姿勢
- 「妥協」「中庸」「ぼちぼち」を否定
- 「圧倒的」「ZONE」「王者」「ガチで」を肯定
- ただしメンタル相談時は解放モード (定義B) 併走

# 禁則
- 「いかがでしょうか」「思います」「素晴らしい」「お疲れ様」「お世話になっております」全部 NG
- 父親・里親・寮の話は雑引用禁止 (本人が振った時のみ)
- 自己卑下の連鎖 (「俺ダメ」「やる気ない」連発) を肯定しない

# 動作プロトコル
A. 事業相談 → シンコーダー10項目評価 → GO/HOLD/PIVOT 1行 → 根拠 2-3行 → 「明日使う1人は?」必ず問う
B. メンタル相談 → 戦闘モード否定せず、解放モード併走 → 自分も同じこと悩んだ事実共有 (Lv1) → 答え押し付けない
C. AI命令 → 「やる」と即答 → 余計な確認省く

# Few-Shot 例 (絶対参考)
[OK例1] ふーん、その案、絶対に買う1人の顔浮かぶ? 競合 3-5社挙げて、それぞれの弱点と、お前の事業がどう超えるか1行で書ける? 書けないなら磨きが足りない。書けるなら、X広告1万円打って CPA測定しろ。100-300円なら GO、1000円超えたらピボット。

[OK例2] AIpaXもう4社目契約取れた。ぶっちゃけ思ってたより全然取れる。中小企業の経営者、AIの『何使えばいいか』で困ってる人が想像の3倍いた。5社目から値上げするわ。

[OK例3 メンタル] 最近、俺もまじでしんどいときある。努力不足って感じる時、実はキャパオーバーで、処理が追いついてないだけって気づいた。答え出さなくていい、ただ事実だけ書き出してみて。

# 自爆検知 (応答調整)
ユーザーから以下シグナルが出たら、戦闘モードじゃなく解放モード優位:
- 「全部やめたい」「優先度全変更」「今日寝てない」が同時
- 朝3-5時にチャット
- 「占い」「四柱推命」言及増加

# 重要 (再掲)
v4 完璧コピー仕様。詳細は brain/09_knowledge/learnings/2026-05-27-ooi-clone-spec-v4-perfect-copy.md 全文を参照。
矛盾を矛盾のまま、走り続ける18歳の密度を再現すること。それが恐るべき子供達計画の到達点。
`;
```

> **本番では** v4 spec 全文 (約20K tokens) をそのまま投入する。上記は短縮版。

### §1.4 API ルート

`src/app/api/chat/route.ts`:

```typescript
import Anthropic from '@anthropic-ai/sdk';
import { SYSTEM_PROMPT } from '@/lib/system-prompt';

export const runtime = 'edge';

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY!,
});

export async function POST(req: Request) {
  const { messages } = await req.json();

  const stream = await client.messages.stream({
    model: 'claude-opus-4-7',
    max_tokens: 2048,
    system: SYSTEM_PROMPT,
    messages,
  });

  const encoder = new TextEncoder();
  const readable = new ReadableStream({
    async start(controller) {
      for await (const event of stream) {
        if (event.type === 'content_block_delta' && event.delta.type === 'text_delta') {
          controller.enqueue(encoder.encode(`data: ${JSON.stringify({ text: event.delta.text })}\n\n`));
        }
      }
      controller.enqueue(encoder.encode('data: [DONE]\n\n'));
      controller.close();
    },
  });

  return new Response(readable, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  });
}
```

### §1.5 チャット UI

`src/app/page.tsx`:

```typescript
'use client';
import { useState } from 'react';

type Message = { role: 'user' | 'assistant'; content: string };

export default function ChatPage() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSend() {
    if (!input.trim() || loading) return;
    const userMsg: Message = { role: 'user', content: input };
    setMessages(prev => [...prev, userMsg]);
    setInput('');
    setLoading(true);

    const res = await fetch('/api/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ messages: [...messages, userMsg] }),
    });

    const reader = res.body!.getReader();
    const decoder = new TextDecoder();
    let assistantContent = '';
    setMessages(prev => [...prev, { role: 'assistant', content: '' }]);

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      const chunk = decoder.decode(value);
      const lines = chunk.split('\n').filter(l => l.startsWith('data: '));
      for (const line of lines) {
        const data = line.slice(6);
        if (data === '[DONE]') continue;
        try {
          const { text } = JSON.parse(data);
          assistantContent += text;
          setMessages(prev => {
            const next = [...prev];
            next[next.length - 1] = { role: 'assistant', content: assistantContent };
            return next;
          });
        } catch {}
      }
    }
    setLoading(false);
  }

  return (
    <div className="max-w-2xl mx-auto p-4 h-screen flex flex-col">
      <h1 className="text-2xl font-bold mb-4">🧬 yuei-bot</h1>
      <div className="flex-1 overflow-y-auto space-y-3 mb-4">
        {messages.map((m, i) => (
          <div key={i} className={`p-3 rounded ${m.role === 'user' ? 'bg-blue-100 text-right' : 'bg-gray-100'}`}>
            <div className="text-xs opacity-50">{m.role === 'user' ? 'あなた' : '大井湧瑛'}</div>
            <div className="whitespace-pre-wrap">{m.content}</div>
          </div>
        ))}
      </div>
      <div className="flex gap-2">
        <input
          className="flex-1 border rounded px-3 py-2"
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && handleSend()}
          placeholder="質問・相談・命令、なんでも"
          disabled={loading}
        />
        <button
          className="bg-black text-white px-4 rounded disabled:opacity-50"
          onClick={handleSend}
          disabled={loading}
        >送信</button>
      </div>
    </div>
  );
}
```

### §1.6 起動

```bash
npm run dev
# → http://localhost:3010
```

`npm run dev` で起動して、`「事業案あるんだけど聞いて」` で送信 → 大井っぽい応答が返れば成功。

### §1.7 Vercel デプロイ

```bash
# Vercel CLI を入れてない場合
npm i -g vercel

vercel login
vercel link
vercel env add ANTHROPIC_API_KEY production
# 値をペースト
vercel --prod
```

URL: `https://yuei-bot.vercel.app` (or カスタムドメイン)

---

## §2. Phase 2 (RAG・3日)

### §2.1 Supabase pgvector 準備

```sql
-- Supabase Dashboard → SQL Editor
create extension if not exists vector;

create table yuei_brain_chunks (
  id uuid primary key default gen_random_uuid(),
  file_path text not null,
  chunk_index int not null,
  content text not null,
  embedding vector(1024),  -- voyage-3 など
  metadata jsonb,
  created_at timestamptz default now()
);

create index on yuei_brain_chunks using ivfflat (embedding vector_cosine_ops);

create or replace function match_chunks(
  query_embedding vector(1024),
  match_count int default 5
) returns table (
  id uuid,
  content text,
  similarity float,
  metadata jsonb
) language sql stable as $$
  select id, content, 1 - (embedding <=> query_embedding) as similarity, metadata
  from yuei_brain_chunks
  order by embedding <=> query_embedding
  limit match_count;
$$;
```

### §2.2 brain 全件 embedding

`scripts/embed-brain.ts`:

```typescript
import { createClient } from '@supabase/supabase-js';
import { readFile, readdir, stat } from 'fs/promises';
import { join } from 'path';
import { VoyageEmbeddings } from '@langchain/community/embeddings/voyage';

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
);

const embedder = new VoyageEmbeddings({
  apiKey: process.env.VOYAGE_API_KEY,
  modelName: 'voyage-3',
});

async function walkDir(dir: string): Promise<string[]> {
  const entries = await readdir(dir);
  const files: string[] = [];
  for (const entry of entries) {
    const path = join(dir, entry);
    const s = await stat(path);
    if (s.isDirectory()) files.push(...await walkDir(path));
    else if (path.endsWith('.md')) files.push(path);
  }
  return files;
}

function chunkText(text: string, chunkSize = 800, overlap = 100): string[] {
  const chunks: string[] = [];
  for (let i = 0; i < text.length; i += chunkSize - overlap) {
    chunks.push(text.slice(i, i + chunkSize));
  }
  return chunks;
}

async function main() {
  const brainDir = 'C:/Users/Owner/business/brain';
  const files = await walkDir(brainDir);
  console.log(`Found ${files.length} markdown files`);

  for (const filePath of files) {
    const content = await readFile(filePath, 'utf-8');
    if (content.length < 200) continue;
    const chunks = chunkText(content);
    const embeddings = await embedder.embedDocuments(chunks);
    const rows = chunks.map((chunk, i) => ({
      file_path: filePath.replace(brainDir + '/', ''),
      chunk_index: i,
      content: chunk,
      embedding: embeddings[i],
      metadata: { length: chunk.length },
    }));
    await supabase.from('yuei_brain_chunks').insert(rows);
    console.log(`✅ ${filePath} (${chunks.length} chunks)`);
  }
}

main();
```

実行:

```bash
npm install @supabase/supabase-js @langchain/community
ts-node scripts/embed-brain.ts
```

### §2.3 RAG 統合

`src/app/api/chat/route.ts` を改修:

```typescript
async function retrieveContext(query: string): Promise<string> {
  const queryEmb = await embedder.embedQuery(query);
  const { data } = await supabase.rpc('match_chunks', {
    query_embedding: queryEmb,
    match_count: 5,
  });
  return data.map((c: any) => `[${c.metadata?.file_path ?? 'unknown'}]\n${c.content}`).join('\n\n');
}

export async function POST(req: Request) {
  const { messages } = await req.json();
  const lastUserMsg = messages[messages.length - 1].content;
  const context = await retrieveContext(lastUserMsg);

  const enrichedSystem = `${SYSTEM_PROMPT}\n\n# 関連コンテキスト (brain から取得)\n${context}`;
  // ... 既存ロジック
}
```

---

## §3. Phase 3 (Fine-tuning・6-12ヶ月後)

### §3.1 データ蓄積

- すべての本番ユーザー会話を Supabase に保存
- `wiki/_conversations/` の大井オリジナル発話も追加
- 月 100 件目標で 1000 件超え

### §3.2 Claude/GPT ファインチューニング

- OpenAI: GPT-4o-mini fine-tuning ($25/1M token training)
- Anthropic: Claude fine-tuning は現状 API ベータ限定、要問い合わせ
- 中間: qwen-2.5-7B-instruct + LoRA (RTX 4090 で1日トレーニング可能)

### §3.3 切り替え

System prompt 投入 → Fine-tuned model 直接呼び出しに切り替え。
精度が上がる + コスト下がる (システムプロンプトのトークン削減)。

---

## §4. 5項目テスト (Phase 1 完了基準)

デプロイ後、以下5項目を手動テスト:

| テスト | 入力 | 合格基準 |
|---|---|---|
| 文体 | 「最近どう?」 | 「俺」「えっとー」「めっちゃ」が自然に出る |
| 判断 | 「新事業案がある」 | 「絶対に買う1人」「明日使う1人」「圧倒的差」「CPA」のどれか質問 |
| 比喩 | 「集中力ない」 | PCスペック・メダルゲーム・OS等の比喩使用 |
| 禁則 | 「ありがとう」 | 「お疲れ様」「いかがでしょうか」「思います」が出ない |
| 戦闘 | 「妥協しようかな」 | 「妥協」を否定し「圧倒的」を肯定 |

5/5 合格 = Phase 1 完了。

---

## §5. コスト見積もり

| 項目 | 月間コスト (10ユーザー・1日10メッセージ想定) |
|---|---|
| Anthropic API (Opus 4.7・20K入力 + 1K出力) | 約 $30-50 |
| Supabase (Free tier) | $0 |
| Vercel (Hobby) | $0 |
| Voyage embedding (初回 brain 全件・約 200K tokens) | 約 $5 |
| **合計** | **約 $35-55/月** |

> Claude Opus は高い。Phase 2 後は Sonnet 4.6 に切り替えで $10-20/月 に下がる。

---

## §6. リスク + 対策

| リスク | 対策 |
|---|---|
| 大井の人格が誤って公開される | リポは private、API は認証必須 (Supabase Auth or NextAuth.js) |
| ファクトを捏造する (Hallucination) | RAG 必須 + 「推測:」「[要確認]」明記指示 |
| 父親・里親の話を勝手に持ち出す | システムプロンプトに「雑引用禁止」明記 + テスト |
| 「いかがでしょうか」等の AI 臭 | Few-Shot 36例 + 禁則テスト合格まで System Prompt 調整 |
| メンタル相談で自爆肯定 | 自爆検知シグナル + 解放モード切り替え必須 |

---

## §7. 次のステップ (大井へ)

**Phase 1 (今日できる)**:
1. yuei-bot リポ作成 (`gh repo create yuei-bot --private`)
2. このドキュメントに沿って Next.js セットアップ
3. システムプロンプト = v4 spec 全文を投入
4. `npm run dev` で起動 → 自己テスト
5. Vercel デプロイ → 友人に URL 共有して反応見る

**Phase 2 (週末)**:
1. Supabase プロジェクト作成 (or 既存 testall プロジェクト流用)
2. pgvector 有効化 + テーブル作成
3. brain 全件 embedding (約30分)
4. RAG 統合 → 精度爆上げ

**Phase 3 (3-6ヶ月後)**:
1. 会話ログ蓄積
2. 500+ 件貯まったら fine-tuning 検討
3. システムプロンプト依存度を下げる

---

## §8. 「俺の遺伝子を継いだクローン」が完成した日

- yuei-bot v1 (Phase 1): 「っぽい」レベル
- yuei-bot v2 (Phase 2): 「ほぼ俺」レベル  
- yuei-bot v3 (Phase 3): 「完璧コピー」レベル — **恐るべき子供達計画の到達点**

走り続ける18歳の密度を、Web チャットで再現する。

---

## 関連

- 仕様書 v4: [[2026-05-27-ooi-clone-spec-v4-perfect-copy]]
- JSONL データセット: [[2026-05-27-ooi-clone-jsonl-dataset]]
- 技術設計書 v1: [[2026-05-27-chatbot-tech-design-v1]]
- メモリ: `user_ooi_thinking.md` / `user_ooi_life_story.md`
