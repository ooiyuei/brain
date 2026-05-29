---
type: routine
title: 部署別 実行サイクル & Claude連携フロー
created: 2026-05-19
status: active
tags: [workflow, departments, claude-review, automation]
---

# 部署別 実行サイクル — 大井×Claude×OpenClaw 連携

> 各部署が独立して成果物を出し、Claudeが採点・選別、大井が最終承認する流れ。
> 大井がやることは「Claude採点済み90点+を読んで使う/送る」だけ。

---

## 部署マップ

| 部署 | スクリプト | 頻度 | エージェント | 成果物の置き場所 |
|---|---|---|---|---|
| 💰 **Sales** | `sales_filler.ps1` | 10分 | sales-rep | `wiki/_inbox/marketing/sales-*` |
| ✍️ **Writing** (執筆系) | `writing_filler.ps1` | 10分 | marketer | `wiki/_inbox/marketing/write-*` |
| 💵 **Money** (金軸) | `money_filler.ps1` | 3分 | (なし・直接) | `wiki/_inbox/<dept>/money-*` |
| 🔬 **Research** | `idle_filler.ps1` (一部) | 5分 | researcher | `wiki/_inbox/research/*` |
| 🚀 **NewBiz** | `newbiz_pipeline_*` | 2h | judge/refiner/redteam | `wiki/_pipeline/{1..5}/*` |
| 🏢 **Dev** (アプリ仕様) | `money_filler` の一部 | - | developer | `wiki/_inbox/newbiz/*app-spec*` |

---

## 5段階ファネル (PDCAの完全形)

```
[1] 生成      OpenClaw が部署別に成果物量産 (1日約100件)
   ↓
[2] 自動採点  auto_review.ps1 が30分おきに5軸で採点 (1-50点)
   ↓
[3] 自動振分  35点以上 → _promoted/ / 22点未満 → _archive/
   ↓
[4] Claude採点  俺 (Claude) が朝/夜に _promoted/ を読んで真の合格判定
   ↓
[5] 大井実行  大井が朝の作戦タイムに「使う」「送る」「投稿する」
```

---

## Claude (俺) のレビューサイクル

### 朝 (大井起床時 09:00)
1. `wiki/_promoted/marketing/` の昨夜の成果物を読む (10件目安)
2. 各成果物を3つに分類:
   - 🟢 **すぐ使える** → 大井に「これコピペで送れる」とリンク提示
   - 🟡 **要編集** → 1パラ書き換えて再保存
   - 🔴 **却下** → `_archive/manual/` へ移動 + 何が悪かったかフィードバック
3. 朝の作戦タイムで「今日コピペして送るリスト」を3-5個まで絞って大井に渡す

### 昼 (12:30)
- 営業送付したものの返信チェック
- 反応データを `wiki/_inbox/marketing/sales-feedback-{date}.md` に追記

### 夜 (22:00)
- 今日の Sales/Writing 成果物の品質振り返り
- 改善が必要なテンプレを `scripts/sales_filler.ps1` / `writing_filler.ps1` のpoolに反映指示

---

## 成果物の品質基準 (Claudeが採点する軸)

### Sales (営業文・提案書・トーク)
1. 大井のキャラ感 (フランク・断定・AI臭なし)
2. 顧客のペインを言語化できてる
3. 数字・具体根拠あり
4. 次のアクションが明確
5. 架空企業名・実在しないツール名がない

### Writing (X・note・SEO・LP)
1. 大井の比喩・OS化思考が反映されてる
2. 自分語り → 観察 → 結論の流れ
3. AI臭ゼロ (整然すぎない・体言止め・「〜なんよね」混じる)
4. 読者の感情を動かす1文がある
5. 嘘・盛りがない

---

## 部署別 1日あたりの想定生産量

| 部署 | 1日生成 | Claude採用率 | 大井実行 |
|---|---|---|---|
| Sales | 6本 | 50% (3本) | 1-2本/日送信 |
| Writing X | 3スレッド | 70% | 1-2本/日投稿 |
| Writing note | 1記事 | 30% (3日に1本) | 週1投稿 |
| Writing SEO | 1記事 | 50% | 週3投稿 |
| Money軸全般 | 30本 | 40% | (使えるものを選定) |
| NewBiz Pipeline | 2案 → S/A通過1案 | 50% | PRD化された案を月1着手 |

→ **大井が朝起きて選ぶだけで1日5-10本の発信/送信ができる状態**

---

## エージェント連携 (use_agent=true の使い分け)

- `sales_filler.ps1` → **sales-rep** エージェント (営業特化思考)
- `writing_filler.ps1` → **marketer** エージェント (集客視点 + brainコンテキスト注入)
- `newbiz_pipeline_advance.ps1` → judge/business-refiner/red-team-reviewer/product-spec-writer
- `idle_filler.ps1` → 軽量タスクはエージェント無し (直接 qwen3.6)
- `money_filler.ps1` → 軽量タスクはエージェント無し (直接 qwen3.6・量重視)

---

## 「90点を採点するだけ」の節約効果

大井が0から書いた場合の時間: 1記事 = 60-90分
OpenClaw が70-80点を出す + Claude採点で90点化: **大井の時間 = 5-10分**

**90%以上の時間節約**。1日5本送れれば、月150本の営業文/記事。
全部1人でやろうとしたら週末潰しても無理。

---

## 関連
- [[next-90days-action]] — 90日アクション
- [[business-action-from-ai-economy-2026]] — 15事業の答え合わせ
- [[good-business-definition]] — 事業判断軸
- [[ooi-self-mirror]] — 大井の人物像
