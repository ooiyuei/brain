---
type: dev-design
project: almeo-logo
version: 2.0
date: 2026-05-27
title: Almeo ロゴ コンセプト v2 — 「Al = AI」「arm = 右腕」を視覚化
supersedes: 2026-05-27-almeo-logo-concepts-v1 (大井確定情報で再設計)
source_of_truth: 大井湧瑛 2026-05-27 発話「AL が AI に見える / arm 右腕イメージ / 理由は後付けでもいい」
audience: 大井湧瑛 (Figma で実装する人)
tags: [logo, branding, design-concept, v2, almeo]
---

# Almeo ロゴ コンセプト v2

> **v1 (装飾の方向性論) を破棄、v2 (大井の意図) で再構築**
> Al = AI に見える / arm = 右腕 / 意味は後付け を視覚化
> Figma / Canva / 外注 のための実装指示書

---

## §1. 設計の3軸 (v2 必達)

### 軸1: **「AL」が「AI」に読めるよう仕掛ける**
- `al` と `ai` は小文字でほぼ同形
- L の serif (足) を小さく / I 寄りにする
- 二重符号化 = ブランドの隠し意味

### 軸2: **「arm = 右腕」を感じさせる**
- アンダーライン / 矢印 / 腕モチーフ で「下から支える」「伸びる」
- 角張った形 (= 強さ・骨格) より、わずかにラウンド (= 親しみ・腕の曲線)

### 軸3: **意味は後付け、形は記号として強い**
- 何の意味か説明されなくても「読みやすく」「覚えやすい」
- 解釈の余地 (Easter egg 的楽しみ) を入れる

---

## §2. v2 ロゴ案 5本

### 🥇 v2-1. **小文字 `almeo`** ⭐ Day 1 推奨

#### コンセプト
- 大文字 `ALMEO` → 小文字 `almeo` に変える
- `al` と `ai` がほぼ同型 = 「AI を内包」が一目で分かる仕掛け
- MUJI / Airbnb / spotify / netflix と同じ「現代的・親近感」の系譜
- 17歳代表の「肩の力抜き」とマッチ

#### 視覚仕様
```
┌──────────────────────────┐
│                          │
│   almeo                  │
│                          │
└──────────────────────────┘

フォント: Inter Display Bold (or DM Sans Bold)
ウェイト: 700 (Bold)
字間: -0.02em (緊密)
カラー: #1a1a1a on #ffffff
特殊処理: 
  - 'l' を 'i' に視覚的に近づける (細く・点を上に追加するオプション)
  - 'al' を意図的に密接 (字間を更に狭く) → 'ai' と読ませる
```

#### 強み
- ✅ Day 1 で即実装 (CSS のみで完成)
- ✅ AI 隠し要素が即起動 (説明不要)
- ✅ 親近感 + モダン
- ✅ favicon 32px でも読める
- ✅ 全媒体で違和感ゼロ

#### 弱み
- ⚠ フォーマルな印象は薄れる (商工会フォーマル提案時、別バージョン併用)

#### 適性
- **Day 1 公開時のメインロゴ**
- 17歳代表のフェーズに完璧マッチ
- Phase 2 で大文字版を「フォーマル提案用」に並走

---

### 🥈 v2-2. **`almeo` + アンダーライン矢印** (動的版)

#### コンセプト
- v2-1 をベースに、下に細い線を引く
- 線の右端を **矢印** にして「右腕が伸びる」「進む」を表現
- arm = 右腕 の意味付けが視覚に乗る

#### 視覚仕様
```
┌──────────────────────────┐
│                          │
│   almeo                  │
│   ──────→                │
│                          │
└──────────────────────────┘

ベース: v2-1
アンダーライン:
  - 太さ: 1.5px
  - 色: #2d5f3f (forest green - アクセント)
  - 開始: a の左端
  - 終了: o の右端 + 矢印
  - 矢印: 細い三角形 (▶ より細く)
余白: ロゴと矢印の間 6px
```

#### バリエーション
- 矢印あり版: アクセント用 (Hero / 名刺裏)
- 矢印なし版: シック用 (フォーマル提案 / 法的書類)
- 線のみ版: 中間 (Web ヘッダー)

#### 強み
- ✅ 「右腕が伸びる」の物語性
- ✅ 静岡の「進む」感
- ✅ MUJI × Apple × 動的要素 = バランス◎
- ✅ Figma で30分実装可能

#### 弱み
- ⚠ favicon サイズでは矢印が消える → favicon は v2-1 ベース推奨

#### 適性
- **Week 1 で本実装する正式版**
- Web ヘッダー・名刺・ピッチ表紙

---

### 🥉 v2-3. **`almeo` + AI Easter egg**

#### コンセプト
- 通常は `almeo`
- 拡大すると `al` の部分が `AI` に変身する (or 反転)
- 隠し要素

#### 視覚仕様
```
┌──────────────────────────┐
│                          │
│   almeo                  │
│   ↑↑                     │
│   AI (small caps の埋め込み)│
│                          │
└──────────────────────────┘

通常版: almeo (小文字)
拡大版 (Hero / OG画像): AImeo (AI を small caps で強調)
  - A: bold
  - I: bold (L の代わり)
  - meo: regular
```

#### バリエーション
- 通常: `almeo`
- 強調版: `AImeo` (AI を強調)
- 完全展開: `AI almeo` (AI = arm + 説明)

#### 強み
- ✅ Easter egg の楽しみ
- ✅ AI 訴求が直接的
- ✅ メディアタイトルで強い (note 記事「AImeo の話」)

#### 弱み
- ⚠ 切り替えが「凝りすぎ」感
- ⚠ Day 1 不向き (本実装時に検討)
- ⚠ ブランド一貫性が崩れる可能性

#### 適性
- **Phase 2 (Month 2 以降)** のチャレンジ版
- 特定キャンペーン・限定使用

---

### v2-4. **`ai` シンボル (favicon 専用)**

#### コンセプト
- フルマーク = `almeo`
- 短縮シンボル = `ai` (Almeo の隠れ意味そのもの)
- favicon / アプリアイコン / SNS プロフィール画像

#### 視覚仕様
```
┌──────────────────────────┐
│                          │
│   ┌──┐                   │
│   │ai│                   │
│   └──┘                   │
│                          │
└──────────────────────────┘

形状: 角丸正方形 (radius 8px)
背景: #1a1a1a
文字: #ffffff / 小文字 `ai`
フォント: Inter Display Bold
サイズ: 32px〜1024px 対応
```

#### バリエーション
- 通常: 黒地白文字
- インバース: 白地黒文字 (ライトモード)
- アクセント版: 黒地 + #2d5f3f 文字

#### 強み
- ✅ favicon 32px で完璧に読める
- ✅ AI 訴求が一発
- ✅ 「Almeo の隠れ意味そのもの」の物語
- ✅ X / LinkedIn プロフィール画像で強い

#### 弱み
- ⚠ ALMEO ロゴと別物に見える可能性 (デザイン統一感に注意)
- ⚠ 「ai」だけだと AI Inc. と被るリスク

#### 適性
- **favicon / アプリアイコン / SNS プロフィール画像専用**
- v2-1 or v2-2 フルマークの **補完シンボル**

---

### v2-5. **`almeo` 文字内に「腕」モチーフ**

#### コンセプト
- `a` の右下、または `o` の右辺に「伸びる腕」を visualize
- arm = 右腕 の意味を直球で

#### 視覚仕様
```
┌──────────────────────────┐
│                          │
│   almeo→                 │
│       ╲                   │
│        ➜  ← o の右から伸びる線│
│                          │
└──────────────────────────┘

ベース: almeo (小文字)
腕モチーフ:
  - o の右下から線が斜め下に伸びる
  - 線の長さ: ロゴ高さの 1.5倍
  - 線の太さ: 1.5px
  - 終点: 三角形 (腕の先 → 矢印)
  - 色: #2d5f3f
```

#### バリエーション
- v2-2 のアンダーラインを変更して、`o` の右からだけ伸ばす
- 線を曲げて「肘から伸びた腕」風に
- 腕モチーフを完全に省略 → v2-1 と統一

#### 強み
- ✅ arm = 右腕 を最強に伝える
- ✅ 動的・進行感
- ✅ 印象に残る

#### 弱み
- ⚠ 装飾過多のリスク
- ⚠ favicon サイズでは消える
- ⚠ 「腕?」と読み取られない可能性

#### 適性
- **Phase 2 のキャンペーン版** (Day 1 不採用)
- バナー・OG画像・ピッチ表紙

---

## §3. ロードマップ (v2 確定版)

### Day 1 (今夜〜明日朝)
- **v2-1 (小文字 `almeo`)** を CSS で実装
- favicon は **v2-4 (`ai` 角丸)** を SVG で
- ヒーローで `almeo` を大きく + 下にタグライン「AI を、中小企業の右腕に。」

### Week 1 (Day 2-7)
- **v2-2 (`almeo` + アンダーライン矢印)** を Figma で正式版に
- 名刺デザインも v2-2 ベース
- 法務書類・契約書ヘッダーは v2-1 (シンプル) 採用 (フォーマル)

### Month 2-3
- **v2-3 (AI Easter egg)** を試作 → メディア露出時のビジュアル強化
- **v2-5 (腕モチーフ)** を試作 → キャンペーンビジュアル

### 保留・破棄
- v1 の「A の山モチーフ」「走る人モチーフ」は v2 で破棄
- 「静岡らしさ」は色 (forest green) + 写真で表現する方向

---

## §4. 即席ロゴ実装 (Day 1 用コード)

### React コンポーネント

```tsx
// components/ui/Logo.tsx
import { cn } from '@/lib/utils/cn';

interface LogoProps {
  variant?: 'default' | 'inverse' | 'accent';
  size?: 'sm' | 'md' | 'lg';
  showTagline?: boolean;
  className?: string;
}

export function Logo({ 
  variant = 'default', 
  size = 'md',
  showTagline = false,
  className 
}: LogoProps) {
  const colorClass = {
    default: 'text-[#1a1a1a]',
    inverse: 'text-white',
    accent: 'text-[#2d5f3f]',
  }[variant];

  const sizeClass = {
    sm: 'text-xl',
    md: 'text-3xl',
    lg: 'text-5xl md:text-6xl',
  }[size];

  return (
    <div className={cn('flex flex-col', className)}>
      <span 
        className={cn(
          'font-bold tracking-tight leading-none',
          colorClass,
          sizeClass,
        )}
        style={{ 
          fontFamily: "'Inter Display', 'Inter', sans-serif",
          letterSpacing: '-0.02em',
        }}
      >
        almeo
      </span>
      {showTagline && (
        <span className={cn('text-sm mt-2 opacity-70', colorClass)}>
          AI を、中小企業の右腕に。
        </span>
      )}
    </div>
  );
}
```

### 使い方

```tsx
// Hero
<Logo size="lg" showTagline />

// Header
<Logo size="md" />

// Footer (inverse)
<Logo size="sm" variant="inverse" />

// 強調 (CTA 近く)
<Logo size="md" variant="accent" />
```

### favicon (v2-4)

```html
<!-- public/favicon.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="6" fill="#1a1a1a"/>
  <text x="50%" y="50%" 
        font-family="Inter, sans-serif" 
        font-weight="700" 
        font-size="18"
        fill="white"
        text-anchor="middle" 
        dominant-baseline="central">
    ai
  </text>
</svg>
```

---

## §5. ロゴ各案の比較マトリクス

| 案 | 実装難度 | AI 訴求 | arm 訴求 | Day 1 | Week 1 | Month 2+ |
|---|---|---|---|---|---|---|
| **v2-1** 小文字 almeo | 易 | ⭐⭐⭐ | ⭐ | ✅ | - | - |
| **v2-2** + アンダー矢印 | 中 | ⭐⭐⭐ | ⭐⭐⭐ | - | ✅ | - |
| v2-3 AI Easter egg | 難 | ⭐⭐⭐⭐ | ⭐ | - | - | ✅ |
| **v2-4** ai シンボル | 易 | ⭐⭐⭐⭐ | - | ✅ favicon | - | - |
| v2-5 腕モチーフ | 中 | ⭐ | ⭐⭐⭐⭐ | - | - | ✅ |

---

## §6. 大井判断ポイント

1. ✅ Day 1 = **v2-1 (小文字 almeo) + v2-4 (ai シンボル favicon)** で OK?
2. ✅ Week 1 正式版 = **v2-2 (アンダーライン矢印)** で OK?
3. ✅ AI Easter egg (v2-3) は Month 2+ で OK?
4. ✅ 腕モチーフ (v2-5) はキャンペーン限定で OK?

---

## §7. 関連

- ブランド物語 v2: [[04_sales_mkt_cs/lp/almeo/2026-05-27-almeo-brand-narrative-v2]]
- ブランドガイドライン: [[03_dev/projects/almeo-brand-guideline-v1]] (Logo セクションを v2 に更新予定)
- Web アーキ: [[03_dev/projects/almeo-website-architecture-v1]]
- v1 ロゴコンセプト (破棄): [[03_dev/projects/almeo-logo-concepts-v1]] (歴史保存)
