---
type: dev-architecture
project: almeo-website
version: 1.0
date: 2026-05-27
created_by: architect agent
status: ready-to-implement
stack: Next.js 16 + React 19 + Tailwind v4 + Vercel + Resend
target_publish: 2026-05-28 (Day 1 - 4.5h で公開可能)
tags: [almeo, website, architecture, nextjs, vercel]
---

# Almeo 公式 Web サイト アーキテクチャ設計書 v1

> **作成**: 2026-05-27 / architect agent
> **対象**: 株式会社 Almeo = Almeo (旧 AIpaX)
> **目標**: almeo.jp を 4.5時間 (Day 1) で公開可能な状態に設計

---

## §0. エグゼクティブサマリー

Almeo (旧 AIpaX) 公式 Web は「静岡の中小企業オーナーが、3秒で『これは信用できる若手AI会社だ』と判断できる」ことに全リソースを集中させる **静的サイト**。

設計の根幹:
1. **Testall と同じ技術スタック** (Next.js 16 / React 19 / Tailwind v4 / Vercel) — 大井の習熟資産を最大流用
2. **Content as Code** (`/content/**/*.mdx`) — 初期コンテンツは Git 管理、CMS 不採用
3. **静的優先 + 限定的 ISR** — Lighthouse 95+ と LCP <1.5s を構造的に達成
4. **17歳代表というレバレッジを正面から使う** — 隠さず「品ある若さ + 4社実績 + 静岡密着」三位一体で「不安要素」を「希少性」に転換

**Day 1 (4-6h) で公開可能な最小構成**: トップ / 会社概要 / 問合せ / 法務3点 (privacy/tos/tokutei) + Resend メール送信。
**最短公開ルート見積**: **4.5時間**。

---

## §1. 技術スタック

### 1-1. コア技術選定

| レイヤー | 採用技術 | バージョン | 採用理由 |
|---|---|---|---|
| フレームワーク | **Next.js App Router** | 16.x | Testall と同一。SSG/ISR/RSC 同居可、コーポレートサイト最適 |
| UI ランタイム | React | 19.x | RSC, useFormStatus, useOptimistic を Contact フォームで活用 |
| 言語 | TypeScript | 5.x | Strict mode、`zod` でフォーム型安全 |
| スタイル | **Tailwind CSS v4** | 4.x | Testall と同じ。`@theme` で和文 token を CSS-first 定義 |
| ホスティング | **Vercel** | - | 大井既存契約、Edge Network、ISR/OG ゼロ設定 |
| フォント | **Noto Sans JP + Inter** | next/font/google | Variable font + subset 自動最適化、CLS ゼロ |
| アイコン | `lucide-react` | 1.x | Tree-shake 効く |
| クラス合成 | `clsx` + `tailwind-merge` | - | Testall と同パターン |
| 監視 | Vercel Analytics + GA4 | - | RUM + マーケ用 |
| エラー監視 | Sentry (Phase 2) | - | Testall ノウハウ流用 |

### 1-2. コンテンツ管理戦略

**決定: Markdown/MDX in repo** (CMS 不採用)

理由:
- 月数本更新ペースで CMS の月額は ROI に合わない
- Claude Code 経由で `content/blog/*.mdx` 直接編集 = ノーコード以上の体験
- 将来 CMS 移行も MDX → Sanity は移行スクリプト1本で済む

コンテンツ配置:
```
content/
├── blog/                       # ISR 対象
├── cases/                      # 導入事例 (4社、匿名化済)
└── company/{history,founder}.mdx
```

### 1-3. お問い合わせフォーム

**決定: 自前 `app/api/contact/route.ts` + Resend** (Formspree 不採用)

- 月3000通までの送信が Resend 無料枠で十分
- 大井宛 + 自動返信 (ユーザー宛) を Server Action で完結
- データ永続化は Phase 2 で Supabase `contact_submissions` 追加

---

## §2. サイトマップ

### Phase 1 (Day 1 公開・P0)
- `/` (ヒーロー + サービス3本 + 事例ティーザー + CTA)
- `/company` (法人実在・代表者・所在地・沿革)
- `/contact` (問合せフォーム = 最大コンバージョン点)
- `/(legal)/privacy` `/tos` `/tokutei`

### Phase 2 (Week 1-2)
- `/service/almeo` `/almeo-web` (AI コンサル + 採用サイト)
- `/case` (導入事例 + 個別ページ)
- `/blog` (お知らせ + ブログ、ISR)

### Phase 3 (Month 2-3)
- `/service/almeo-school`
- `/recruit` `/recruit/[role]`
- `/portal` (Supabase Auth 必須)

---

## §3. App Router 構造

```
app/
├── (marketing)/                  # 公開ページ群
│   ├── layout.tsx
│   ├── page.tsx                  # /
│   ├── company/page.tsx
│   ├── service/{almeo,almeo-web,almeo-school}/page.tsx
│   ├── case/{page.tsx,[slug]/page.tsx}
│   ├── blog/{page.tsx,[slug]/page.tsx}
│   └── contact/{page.tsx,actions.ts}
├── (legal)/
│   └── {privacy,tos,tokutei}/page.tsx
├── (portal)/                     # Phase 3
│   └── dashboard/page.tsx
├── api/og/route.ts               # 動的 OGP 画像
├── sitemap.ts                    # 動的 sitemap.xml
├── robots.ts
├── opengraph-image.tsx           # デフォルト OGP
└── layout.tsx
```

---

## §4. パフォーマンス目標

| 指標 | 目標 | 達成戦略 |
|---|---|---|
| Lighthouse Performance | 95+ | SSG + 画像最適化 + フォント subset |
| LCP | < 1.5s | ヒーロー `priority` + AVIF |
| INP | < 200ms | RSC で JS 削減 |
| CLS | < 0.05 | font-display:swap + width/height 明示 |

---

## §5. デザイン方針 (第一推奨)

**MUJI × Apple ハイブリッド** ⭐

- 構造: Apple (余白広く、コピーで魅せる、写真大きく)
- 質感: 標準 (薄影 + 1px border)
- 雰囲気: MUJI 寄り (静岡的「土地に根ざした品」、過剰演出なし)

**ブランドカラー案**:
```css
--primary:   #1a1a1a   /* almost-black (Apple) */
--secondary: #f5f1ea   /* warm beige (MUJI、静岡の柔らかさ) */
--accent:    #2d5f3f   /* forest green (静岡の自然 + 信頼) */
```

詳細: [[brand-guideline-v1]] 参照。

---

## §6. Day 1 で確実に公開できる最小構成 + 最短ルート

### 公開最小構成
- `/` `/company` `/contact` `/(legal)/{privacy,tos,tokutei}`
- Resend 問合せ送信 (大井宛 + 自動返信)
- sitemap.xml / robots.txt 自動生成
- 固定 OG 画像1枚
- Vercel Analytics + GA4

### 4.5時間ルート

| 区間 | 作業 | 時間 |
|---|---|---|
| 0:00-0:20 | `npx create-next-app` + Vercel + DNS 設定 | 20分 |
| 0:20-0:50 | Testall から流用 + フォント + ブランドカラー | 30分 |
| 0:50-1:20 | レイアウト (Header/Footer) | 30分 |
| 1:20-2:10 | `/` ページ実装 | 50分 |
| 2:10-2:30 | `/company` 実装 | 20分 |
| 2:30-3:30 | `/contact` + Server Action + Resend | 60分 |
| 3:30-3:50 | 法務3ページ (テンプレ流用) | 20分 |
| 3:50-4:10 | metadata, sitemap, robots, OG画像 | 20分 |
| 4:10-4:30 | Lighthouse 計測 + Production deploy | 20分 |

**= 4時間30分で公開可能**

### 大井が事前に用意するもの
1. **Resend API key** (resend.com で5分)
2. **DNS 設定権限** (Google Workspace 管理画面)
3. **会社情報文字列**: 社名 / 所在地 / 設立日 / 連絡先メール `contact@almeo.jp`
4. **ヒーローコピー (3行)**: 30字 × 3行
5. **OG 画像1枚** (Figma 15分 or Day 1 中に Claude 代替)

---

## §7. 17歳代表の反転戦略

**直視: 隠したら逆効果。正面突破で希少性に転換**

戦略:
1. **ファクト全公開**: 法人登記情報 / 既存契約4社 / 月額売上 / 商工会経由 / 代表略歴
2. **「サポート体制」強調**: 「株式会社 Almeo」「秘書室・営業・開発の各部署体制」
3. **「年齢ではなく、起業の本気度」見せる**: 「2024年から事業活動、現在17歳。法人化 2026-06。本気で 10 年以上やる」のストーリー
4. **メディア・受賞歴の社会的証明**
5. **「年齢で判断したくない方へ」の覚悟ページ** (オプション・率直に書く)

サイト上の構造:
- `/` ヒーロー直下「2026-06 法人化・既存契約4社・浜松密着」3点
- `/company` 「ライフストーリー → 起業動機 → 現在体制 → 将来計画」順
- `/case` 4社の現場感 (匿名でも属性は出す)

---

## §8. セキュリティ多層防御

| 層 | 実装 | Phase |
|---|---|---|
| 1. Honeypot field | `<input name="website" tabindex="-1" />` | Day 1 |
| 2. Server-side zod 検証 | 全項目 validate | Day 1 |
| 3. Rate limit | IP ベース 1分3回 (Upstash) | Phase 1.5 |
| 4. Cloudflare Turnstile | reCAPTCHA より UX 良 | Phase 1.5 |
| 5. Headers | CSP / HSTS / X-Frame-Options | Day 1 |

---

## §9. 公開後の運用 SLA

| 項目 | SLA |
|---|---|
| お問い合わせ返信 | 24時間以内 (Resend webhook → Slack 通知) |
| お知らせ追加 | 月 2-4 本 |
| 長尺ブログ | 月 1-2 本 |
| セキュリティ patch | Critical CVE 24時間以内 |

---

## §10. ADR (アーキテクチャ決定記録)

| ADR | 決定 | 理由 |
|---|---|---|
| ADR-001 | Next.js 16 App Router | Testall と同一、習熟資産 |
| ADR-002 | MDX in repo | CMS は過剰投資 |
| ADR-003 | Resend + Server Action | 完全制御 + 無料枠 |
| ADR-004 | Phase 1 で Supabase 接続なし | Day 1 公開最速化 |
| ADR-005 | MUJI × Apple デザイン | 「品ある若さ + 地方密着」 |
| ADR-006 | 17歳代表を隠さず正面突破 | 隠す方が逆効果 |
| ADR-007 | 多言語は Phase 2 以降 | Day 1 は日本語のみ |

---

## §11. 関連

- ブランドエクイティ設計図: [[04_sales_mkt_cs/lp/almeo/2026-05-27-almeo-brand-equity-blueprint]]
- LP コピー 3案: [[04_sales_mkt_cs/lp/almeo/2026-05-27-almeo-lp-copy-3patterns]]
- ブランドガイドライン: [[03_dev/projects/almeo-brand-guideline-v1]]
- ロゴコンセプト案: [[03_dev/projects/almeo-logo-concepts-v1]]
- 既存 Testall アーキ参照: `apps/testall/`
- Almeo entity: [[entities/almeo]]
