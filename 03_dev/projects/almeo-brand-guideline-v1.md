---
type: dev-design
project: almeo-brand
version: 1.0
date: 2026-05-27
title: Almeo ブランドガイドライン v1
purpose: ロゴ・カラー・タイポ・トーンを一元定義し、Web・名刺・ピッチ資料・SNS で一貫させる
applies_to: 株式会社 Almeo / Almeo (旧 AIpaX) 全アセット
tags: [brand, design, guideline, almeo, logo, color]
---

# Almeo ブランドガイドライン v1

> **ベース**: 森岡フレームのブランドエクイティ設計図 + architect Web 設計 (MUJI × Apple ハイブリッド推奨)
> **目的**: ロゴ・色・タイポ・トーンを統一して「品ある若さ + 地方密着 + AI」を全アセットで表現

---

## §1. ブランド一行ステートメント

> **「静岡の中小企業と、一緒に走る。」**

森岡フレームで確定 (15字以内・覚えやすい)。
- Web ヘッダー、メール署名、ピッチ資料表紙、X bio に全部入れる

---

## §2. ブランドパーソナリティ (5形容詞)

> 全アセットの判断基準。「Almeo っぽい?」と迷ったらこの5つに照らす。

1. **誠実 (Sincere)** — 嘘・誇張・盛り NG。事実ベースで魅せる
2. **静か (Quiet)** — 派手な装飾より余白の品。MUJI 系
3. **本気 (Serious)** — 「ぼちぼち」感を消す。コミットメント明示
4. **若い (Young)** — 17歳発を活かす。エネルギーと挑戦の象徴
5. **地に足 (Grounded)** — 静岡の土地感・お茶・自然・職人の系譜

---

## §3. カラーシステム

### §3.1 メインパレット

```css
:root {
  /* Primary - 静かな主役 */
  --almeo-black:    #1a1a1a;   /* 文字・主要 UI (almost-black) */
  --almeo-white:    #ffffff;   /* 背景・空気 */

  /* Secondary - 静岡の体温 */
  --almeo-beige:    #f5f1ea;   /* 背景アクセント (warm beige・お茶・障子) */
  --almeo-cream:    #fdfbf6;   /* セクション分離 (off-white) */

  /* Accent - 信頼の森 */
  --almeo-forest:   #2d5f3f;   /* CTA・リンク・主要強調 (静岡の自然) */
  --almeo-mountain: #4a6b5c;   /* hover・副次強調 */

  /* Neutral - 文字階層 */
  --almeo-ink-1:    #1a1a1a;   /* 見出し */
  --almeo-ink-2:    #4a4a4a;   /* 本文 */
  --almeo-ink-3:    #8a8a8a;   /* キャプション */
  --almeo-ink-4:    #d4d4d4;   /* 区切り線 */

  /* Status (utility) */
  --almeo-success:  #2d5f3f;   /* メインカラーと同じ (信頼の森) */
  --almeo-warning:  #c47a2c;   /* お茶の濃い色 */
  --almeo-error:    #8b3a3a;   /* 落ち着いた朱色 */
}
```

### §3.2 使用ルール

| 色 | 使う場所 | 使わない場所 |
|---|---|---|
| `--almeo-black` | 見出し・主要文字・ロゴ | 大面積 (圧迫) |
| `--almeo-white` | メイン背景 | アクセント |
| `--almeo-beige` | セクション区切り背景・カード背景 | 文字 |
| `--almeo-cream` | サブセクション分離 | 大面積 |
| `--almeo-forest` | CTA ボタン・リンク・強調 | 本文 |
| `--almeo-mountain` | hover state | 通常 |

### §3.3 アクセシビリティ

- `--almeo-black` × `--almeo-white` = コントラスト比 18.7:1 (AAA)
- `--almeo-forest` × `--almeo-white` = 6.8:1 (AAA Large Text)
- `--almeo-ink-2` × `--almeo-beige` = 7.5:1 (AAA)

→ Lighthouse Accessibility 100 達成可能。

### §3.4 NG カラー (絶対使わない)

- **ネオン・蛍光色**: 静かさを壊す
- **グラデーション**: 過剰演出・MUJI 哲学に反する (1箇所のヒーローのみ例外)
- **彩度高すぎる赤・青**: 17歳のチープさが出る

---

## §4. タイポグラフィ

### §4.1 フォント選定

| 用途 | 和文 | 欧文 | ウェイト |
|---|---|---|---|
| 見出し (H1-H3) | **Noto Sans JP** | **Inter** | 700 (Bold) |
| 本文 | **Noto Sans JP** | **Inter** | 400 (Regular) |
| キャプション | **Noto Sans JP** | **Inter** | 500 (Medium) |
| 数字・コード | - | **JetBrains Mono** | 400 |

**理由**:
- Noto Sans JP = Google 公式・無料・全 OS 対応・variable font
- Inter = 海外スタートアップ標準・読みやすい・無料
- JetBrains Mono = 数字・コード強調 (案件実績など)

### §4.2 サイズスケール

```css
/* Tailwind v4 @theme で定義 */
--font-size-display-1: 4.5rem;   /* 72px - Hero (デスクトップ) */
--font-size-display-2: 3rem;     /* 48px - Section title */
--font-size-h1:        2.25rem;  /* 36px */
--font-size-h2:        1.875rem; /* 30px */
--font-size-h3:        1.5rem;   /* 24px */
--font-size-h4:        1.25rem;  /* 20px */
--font-size-body:      1rem;     /* 16px */
--font-size-small:     0.875rem; /* 14px */
--font-size-caption:   0.75rem;  /* 12px */
```

### §4.3 日本語特有の調整

```css
.font-jp {
  font-family: 'Noto Sans JP', 'Inter', sans-serif;
  line-height: 1.8;           /* 日本語は広め */
  letter-spacing: 0.04em;     /* 字間広め */
  word-break: keep-all;       /* 禁則処理 */
  font-feature-settings: 'palt' 1;  /* プロポーショナル和文 */
}
```

---

## §5. ロゴ仕様

### §5.1 ロゴタイプ (Wordmark)

**「ALMEO」** のシンプルなワードマーク。

**理由**:
- アイコンマーク (シンボル) より、3年は **ワードマーク優先**
- ブランド認知度ゼロ → シンボル単独使用は早すぎる
- 「ALMEO」の5文字が美しいプロポーション

### §5.2 推奨フォント (ロゴ専用)

候補3つ:

#### 案1: **Inter Display Bold** ⭐ 推奨
- モダン・シャープ・国際標準
- ALMEO の5文字が緊密にまとまる
- Apple 系の品

#### 案2: **DM Sans Bold**
- 案1より少し柔らかい
- 「若さ」が出る

#### 案3: **Manrope ExtraBold**
- 角がやや丸い
- 「親しみ」が出る

→ Day 1 は **案1 (Inter Display Bold)** で実装。後で再評価。

### §5.3 ロゴ構造

```
┌─────────────────────────────────────┐
│                                     │
│           ALMEO                     │
│           ─────                     │
│                                     │
└─────────────────────────────────────┘

オプション要素 (拡張時):
- 下線: 「進む」「下から支える」イメージ (アンダーライン)
- A の三角形を「山」「テント」モチーフに (静岡の山並み)
```

### §5.4 タグライン (ロゴ下)

```
ALMEO
─────
静岡の中小企業と、一緒に走る。
```

### §5.5 ロゴカラー

| 用途 | 色 |
|---|---|
| 通常 | `--almeo-black` (#1a1a1a) on white |
| ダーク背景 | `--almeo-white` (#ffffff) on `--almeo-black` |
| アクセント版 | `--almeo-forest` (#2d5f3f) on `--almeo-cream` |
| モノクロ印刷 | `#000000` on white (フォールバック) |

### §5.6 ロゴサイズ・余白

- 最小サイズ: 80px (デジタル) / 20mm (印刷)
- 余白: ロゴの高さ × 0.5 を全周に確保
- 縦横比: 維持必須、変形 NG

### §5.7 ロゴ NG

- ❌ 影・グラデーション
- ❌ 単独シンボル化 (3年は早い)
- ❌ 色変更 (上記5バリアント以外)
- ❌ 傾斜・回転
- ❌ 解像度低い使用

---

## §6. レイアウト原則

### §6.1 グリッド (MUJI × Apple)

- **12カラム** (デスクトップ)
- **6カラム** (タブレット)
- **4カラム** (モバイル)
- ガター: 24px (デスクトップ) / 16px (モバイル)
- マックス幅: 1280px (本文は 720-840px の読みやすい幅)

### §6.2 余白 (MUJI 哲学)

- セクション間: **120-160px** (デスクトップ・余白多め)
- 要素間: **24-48px**
- カード内 padding: **32-40px**

> 「足したい」と思ったら、3つ削れ。MUJI ルール。

### §6.3 角丸

- カード: 8-12px (柔らかいが、Material 風になりすぎない)
- ボタン: 6-8px
- 画像: 0 or 4px (基本シャープ)

### §6.4 影

- 通常: なし or 極小 (`shadow-sm`)
- hover: `shadow-md` 程度
- モーダル: `shadow-xl` (用途限定)

---

## §7. 写真・画像

### §7.1 写真トーン

- **自然光** (蛍光灯避ける)
- **静岡の風景** (お茶畑・山・川・地方都市の街並み)
- **モノ・空間** (人物の代わりに、机・本・道具・自然)
- **モノクロ気味** or 暖色寄り

### §7.2 NG 写真

- ❌ ストックフォト感満載 (笑顔の外国人など)
- ❌ ビビッドな色彩
- ❌ AI 生成丸わかりの背景
- ❌ 加工しすぎ (彩度ガン上げ)

### §7.3 推奨 (Day 1 用ヒーロー画像)

候補:
1. 静岡の早朝・お茶畑にうっすら霧
2. 浜松の街並み (空気感ある)
3. 大井湧瑛のシルエット (静かな後ろ姿・モノクロ)
4. ローカルな喫茶店・古い机・ノートPC

→ Day 1 は **#1 or #2** (人物なし) で開始。Phase 2 で大井のプロフィール撮影。

### §7.4 アイコン

- `lucide-react` 統一 (Apple HIG 風)
- ストロークウィッスト: 1.5px
- カラー: `--almeo-ink-2`

---

## §8. ボイス & トーン (文章トーン)

### §8.1 基本ルール

| ✅ やる | ❌ やらない |
|---|---|
| 体言止め多用 | 「いかがでしょうか」 |
| 短文・改行多め | 長文・改行少 |
| 数字で示す | 「多数」「様々」 |
| 「俺」(大井発信時)・「私たち」(法人発信時) | 「弊社」「拙者」 |
| 断言 | 「思います」「と存じます」 |
| 静岡・浜松の具体地名 | 「全国・首都圏」 |

### §8.2 媒体別トーン

| 媒体 | 一人称 | 文体 |
|---|---|---|
| Web (Almeo.jp) | 「私たち」 | 端正だが熱量保つ |
| X (旧 Twitter) | 「俺」 | 大井クローン v4 全開 |
| note 記事 | 「俺」「私」(使い分け) | ストーリー優先 |
| ピッチ資料 | 「Almeo」「弊社」 | フォーマル |
| お問い合わせ返信 | 「Almeo (大井)」 | 端正・親身 |
| 契約書・請求書 | 「当社」 | 法的フォーマル |

### §8.3 NG 表現リスト

- 「いかがでしょうか」 → 「どうですか」「ぜひ」
- 「思います」 → (削除) or 「断言する」「確信する」
- 「素晴らしい」 → 「圧倒的」「ガチで効く」
- 「お疲れ様」 → (削除) or 「ありがとうございます」
- 「お世話になっております」 → 「いつもありがとうございます」
- 「とても重要」「様々な」 → (削除) or 数字で代替
- 「と言えるでしょう」 → 断言

---

## §9. CTA (Call to Action)

### §9.1 主要 CTA 文言

| 場面 | 文言 |
|---|---|
| Web Hero | **「30分の相談で、何ができるか見せる」** |
| Service Page | 「Almeo を試す (初月無料)」 |
| Case Study | 「同じことを、うちでもやる」 |
| Blog 記事末尾 | 「個別相談する」 |

### §9.2 ボタン仕様

```css
.btn-primary {
  background: var(--almeo-forest);
  color: var(--almeo-white);
  padding: 12px 32px;
  border-radius: 6px;
  font-weight: 600;
  font-size: 16px;
  transition: background 0.2s;
}
.btn-primary:hover {
  background: var(--almeo-mountain);
}
```

---

## §10. メール署名 (会社統一)

```
─────────────────────────────────
大井湧瑛 / Yuei Ooi
代表取締役・株式会社 Almeo
Almeo - 静岡の中小企業と、一緒に走る。

✉ yuei.oi@almeo.jp
🌐 https://almeo.jp
📞 [電話番号・要記入]
📍 静岡県浜松市 [住所]

X: @[要確認] | note: @[要確認]
─────────────────────────────────
```

---

## §11. 名刺デザイン (将来)

### §11.1 表面 (シンプル)

```
[ALMEO ロゴ・左上]

大井湧瑛
代表取締役

株式会社 Almeo
Almeo

[右下]
yuei.oi@almeo.jp
almeo.jp
```

### §11.2 裏面 (バックストーリー)

```
「静岡の中小企業と、一緒に走る。」

私たち Almeo は、AI で
静岡の中小企業の
業務を変える伴走者です。

──────────────────
2026年法人化 / 4社契約中
浜松市 / 17歳起業家
```

---

## §12. ピッチ資料テンプレ (将来)

- 16:9 比
- 1スライド = 1メッセージ
- 余白 60% (本文40%)
- カバー: ロゴ + タグライン + 「2026 法人化 / 17 yo / 静岡」
- フッター: 「ALMEO」ロゴ小さく + ページ番号

---

## §13. SNS プロフィール統一

| プラットフォーム | プロフィール |
|---|---|
| X (旧 Twitter) | 「Almeo / 大井湧瑛 (17) / 静岡 浜松 / 中小企業 × AI / 4社契約中 / 2026法人化」 |
| LinkedIn | 同上 + 「代表取締役・株式会社 Almeo」追加 |
| note | 「Almeo @ 静岡浜松。17歳の AI コンサル。地方の中小企業に伴走中。」 |
| Instagram | 「Almeo - 静岡の中小企業と、一緒に走る。@yuei_oi」 |

---

## §14. ロゴ実装手順 (Day 1 用)

### §14.1 即席ロゴ (Day 1 で公開できる版)

```tsx
// components/ui/Logo.tsx
export function Logo() {
  return (
    <div className="flex items-center gap-2">
      <span 
        className="font-bold tracking-tight text-2xl"
        style={{ fontFamily: "'Inter', sans-serif" }}
      >
        ALMEO
      </span>
    </div>
  );
}
```

これでも十分。

### §14.2 SVG ロゴ (Week 1 で作成)

- Figma で 1時間
- バリエーション: 横/縦/シンボルのみ
- ファイル: `public/logo.svg` `logo-white.svg` `logo-square.svg`

---

## §15. ガイドライン管理

### §15.1 バージョン管理
- v1.0 (2026-05-27): 初版
- 変更時は v1.1, v2.0 と上げて履歴を残す

### §15.2 関連リソース (将来作成)
- `public/brand/` フォルダに全アセット格納
  - `logo.svg`, `logo-white.svg`, `logo-square.svg`
  - `favicon.ico`, `apple-touch-icon.png`
  - `og-default.png`
  - `color-palette.png`
- Figma の Almeo Brand ファイル (大井管理)

---

## §16. 関連

- ブランドエクイティ: [[04_sales_mkt_cs/lp/almeo/2026-05-27-almeo-brand-equity-blueprint]]
- Web アーキ: [[03_dev/projects/almeo-website-architecture-v1]]
- LP コピー: [[04_sales_mkt_cs/lp/almeo/2026-05-27-almeo-lp-copy-3patterns]]
- ロゴ コンセプト: [[03_dev/projects/almeo-logo-concepts-v1]]
- Almeo entity: [[entities/almeo]]
