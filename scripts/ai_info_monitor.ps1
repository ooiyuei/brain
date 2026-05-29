# AI 情報常時巡回スクリプト (毎朝 06:30 + 緊急時)
# Scheduled Task: BrainAIInfoMonitor
# 大井指示 (2026-05-28): GitHub いいね大量・X・AI情報サイト巡回 → 取り入れ
# 出力: 07_research/ai-info/YYYY-MM-DD.md

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$date = (Get-Date).ToString("yyyy-MM-dd")
$nowFull = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$outDir = "$brain\07_research\ai-info"
$outPath = "$outDir\$date.md"

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

# OpenClaw に依頼する形 (qwen3:8b で整形)
# 実際の WebSearch は dispatch 経由じゃなく researcher agent が良いが、
# 毎朝の定型処理は dispatch でテンプレ生成 → 朝の Claude が WebSearch で実データ補充
$prompt = @"
# AI 情報巡回テンプレ生成 $date

明朝 (大井起床時) に Claude が WebSearch で埋める前の、巡回先リストの構造を整形:

## 巡回先 (必須)
1. GitHub Trending (https://github.com/trending) - 言語 Python/TypeScript・Daily
2. GitHub Trending Repository AI/ML タグ
3. Hugging Face トレンドモデル (https://huggingface.co/models)
4. Anthropic news (https://anthropic.com/news)
5. OpenAI changelog (https://platform.openai.com/docs/changelog)
6. Google AI blog (https://blog.google/technology/ai/)
7. arxiv AI 新着 (https://arxiv.org/list/cs.AI/recent)
8. Hacker News AI 関連 (https://news.ycombinator.com/)
9. Reddit r/MachineLearning hot
10. X (旧Twitter) keyword: Claude / Anthropic / GPT5 / AI agent / MCP

## 巡回方針
- 最低 5サイト・最大10サイト
- 1リポジトリ/記事につき 100文字要約 + 大井事業 (Almeo/Testall/AIpaX School) への適用度 ★1-5
- 「今すぐ TTP すべき」と判断したらDiscord通知 (purple)

## 出力フォーマット
- ヘッドライン Top3 (大井向け即実行可能)
- GitHub 新着リポ Top5 (★4-5)
- 新ツール・新ライブラリ Top3
- プロンプトパターン (拾えたら)
- Anthropic/OpenAI/Google 重大変更 (あれば)

今は枠だけ生成・実データは Claude が朝に補充。
"@

# 朝のテンプレ枠を作る
$body = @"
---
type: ai-info-daily
date: $date
generated_at: $nowFull JST
status: template-only (Claude WebSearch で実データ補充待ち)
tags: [ai-info, daily, github-trending, webwatch]
---

# AI 情報巡回 $date

> **このファイルは ai_info_monitor.ps1 が朝06:30 にテンプレ生成。**
> 朝の Claude セッションで WebSearch + WebFetch で実データ補充する。
> 「アンテナ常時」=大井指示 (2026-05-28)

## 🎯 ヘッドライン Top3 (Claude 補充待ち)

1. [Claude WebSearch で埋める]
2. [Claude WebSearch で埋める]
3. [Claude WebSearch で埋める]

## 📦 GitHub Trending リポ Top5 (Claude 補充待ち)

(各リポ: URL / Star数 / 一行説明 / 大井事業適用度★1-5 / TTP できる要素)

## 🛠 新ツール・新ライブラリ Top3 (Claude 補充待ち)

## 🎨 プロンプトパターン (拾えたら・Claude 補充待ち)

## 🚨 Anthropic / OpenAI / Google 重大変更 (あれば・Claude 補充待ち)

## 💼 Almeo / Testall / AIpaX School への適用案

## 🗞 情報源
- https://github.com/trending
- https://github.com/trending?since=daily&spoken_language_code=
- https://huggingface.co/models?sort=trending
- https://anthropic.com/news
- https://platform.openai.com/docs/changelog
- https://blog.google/technology/ai/
- https://arxiv.org/list/cs.AI/recent
- https://news.ycombinator.com/
- https://x.com/search?q=Claude%20Anthropic&f=live
- https://x.com/search?q=AI%20agent%20MCP&f=live

---
## 関連
- [[07_research/ai-news-research-framework]]
- [[01_ceo/daily-operations-protocol]]
"@

$utf8 = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($outPath, $body, $utf8)
Write-Host "[ai_info_monitor] template saved: $outPath"

# Discord 通知 (gray・低圧)
$titleText = "[AI Info] template ready " + (Get-Date).ToString('HH:mm')
& "$brain\scripts\discord_notify.ps1" -Title $titleText -Body "AI 情報巡回テンプレ生成: 07_research/ai-info/$date.md / 朝の Claude が WebSearch で補充" -Color "gray" -From "Monitor"
