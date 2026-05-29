---
type: source-raw
title: 動画02 NEXT.JS 14 + Supabase + react-hook-form 掲示板チュートリアル
created: 2026-05-26
status: permanent-archive
video_no: 02
tags: [shincoder, raw, nextjs, supabase, tutorial]
---

# NEXT.JS 14 + Supabase + react-hook-form 掲示板チュートリアル

## 📊 サマリー
- 技術チュートリアル (Web開発教材)
- NEXT.JS 14 App Router 基礎
- Supabase バックエンド as a Service
- Prisma ORM 設定
- react-hook-form + Zod バリデーション
- shadcn/ui コンポーネント
- サーバーアクション (NEXT.JS 14 新機能)

## 🔥 構築する完成形
- 掲示板アプリ (ホーム + 詳細 + 作成)
- レスポンシブ
- フォームバリデーション
- データベース永続化
- API Route + サーバーアクション両方

## 技術スタック
- **NEXT.JS 14** (App Router, TypeScript)
- **Tailwind CSS** + **shadcn/ui** (UI ライブラリ)
- **Supabase** (Postgres DB + Auth)
- **Prisma ORM** (DB クエリ抽象化)
- **react-hook-form** + **zod** (フォーム + バリデーション)

## 主要セクション

### 1. プロジェクト作成
```bash
npx create-next-app@latest
# TypeScript: yes
# ESLint: yes
# Tailwind CSS: yes
# src/: no
# App Router: yes
# Import Alias: yes
```

### 2. ヘッダー作成
- layout.tsx に共通ヘッダー配置
- メタデータ設定 (タイトル/デスクリプション)
- v0.dev で AI 自動生成も可

### 3. 掲示板リスト (BBS Card List)
- shadcn/ui の Card コンポーネント
- グリッドレイアウト (3列)
- Tailwind CSS で配置

### 4. Supabase + Prisma セットアップ
- supabase.com で プロジェクト作成
- .env.local に DATABASE_URL
- Prisma schema 定義
  - id (Int, AutoIncrement)
  - userName (String)
  - title (String)
  - content (String)
  - createdAt (DateTime)
- マイグレーション → テーブル作成
- RLS (Row Level Security) 設定

### 5. API Route (Get/Post)
- app/api/post/route.ts
- GET: 全件取得 (findMany)
- POST: 作成 (create)
- TypeScript 型定義 (interface BBSData)

### 6. 詳細ページ (動的ルーティング)
- app/post/[bbsId]/page.tsx
- [bbsId] = 動的パラメーター
- API: app/api/post/[bbsId]/route.ts
- findUnique で ID 取得

### 7. SSR vs SSG vs CSR vs ISR
- 掲示板 = SSR (no-store) 最適
- 課金ページ等 = SSG
- 投稿頻繁 = SSR か CSR

### 8. フォーム + バリデーション
- shadcn/ui Form
- react-hook-form 統合
- zod schema (フォームスキーマ)
- 文字数バリデーション (2字以上タイトル・10-140字本文)
- onSubmit ハンドラ

### 9. サーバーアクション (NEXT.JS 14)
- app/actions/post.ts に "use server"
- API Route 不要・直接 DB クエリ
- revalidatePath でキャッシュ更新
- redirect でリダイレクト
- フォームと統合

## 🎯 大井応用
- Testall 受験生プラン作成フォーム
- AIpaX 営業フォーム
- AIpa Web 採用LPフォーム
- 各事業の最新NEXT.JS構造に活用
- 「初めての NEXT.JS」書籍 (2026年4月発売予定) 入門書として

## 全文字起こし

[ユーザー提供transcript - 30000字]
