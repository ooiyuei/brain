#requires -Version 5.1
# 毎朝07:00 - AI最新情報をRSS/APIから取り込みOpenClawに要約させる
# ソース: Hacker News (AI関連) / arXiv (cs.AI) / Anthropic blog RSS

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$outDir = Join-Path $brainRoot "wiki\_monitor"
$today = (Get-Date).ToString("yyyy-MM-dd")

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

# ========== 1. Hacker News から AI関連トップ取得 ==========
$hnItems = @()
try {
    $topIds = Invoke-RestMethod -Uri "https://hacker-news.firebaseio.com/v0/topstories.json" -TimeoutSec 10
    $count = 0
    foreach ($id in $topIds[0..49]) {
        if ($count -ge 10) { break }
        try {
            $story = Invoke-RestMethod -Uri "https://hacker-news.firebaseio.com/v0/item/$id.json" -TimeoutSec 5
            if ($story.title -match "(?i)AI|LLM|GPT|Claude|Anthropic|OpenAI|Llama|Gemini|agent|RAG|fine.?tun") {
                $hnItems += [PSCustomObject]@{
                    Title = $story.title
                    URL = $story.url
                    Score = $story.score
                    Comments = $story.descendants
                }
                $count++
            }
        } catch {}
    }
} catch {
    Write-Host "Hacker News fetch failed: $($_.Exception.Message)"
}

# ========== 2. arXiv cs.AI 直近 10件 ==========
$arxivItems = @()
try {
    $xml = Invoke-RestMethod -Uri "http://export.arxiv.org/api/query?search_query=cat:cs.AI&max_results=10&sortBy=submittedDate&sortOrder=descending" -TimeoutSec 15
    foreach ($entry in $xml.feed.entry) {
        $arxivItems += [PSCustomObject]@{
            Title = ($entry.title -replace "`n", " " -replace "\s+", " ").Trim()
            Summary = ($entry.summary -replace "`n", " " -replace "\s+", " ").Trim().Substring(0, [Math]::Min(300, ($entry.summary -replace "`n", " ").Length))
            Link = ($entry.id.ToString())
            Published = $entry.published
        }
    }
} catch {
    Write-Host "arXiv fetch failed: $($_.Exception.Message)"
}

# ========== 3. Anthropic Blog RSS ==========
$anthropicItems = @()
try {
    $xml = [xml](Invoke-WebRequest -Uri "https://www.anthropic.com/news/rss.xml" -TimeoutSec 10 -UseBasicParsing).Content
    $count = 0
    foreach ($item in $xml.rss.channel.item) {
        if ($count -ge 5) { break }
        $anthropicItems += [PSCustomObject]@{
            Title = $item.title
            Link = $item.link
            PubDate = $item.pubDate
            Description = ($item.description -replace "<[^>]+>", "").Substring(0, [Math]::Min(200, ($item.description -replace "<[^>]+>", "").Length))
        }
        $count++
    }
} catch {
    Write-Host "Anthropic RSS fetch failed: $($_.Exception.Message)"
}

# ========== 4. データをまとめて OpenClawに整形依頼 ==========
$dataBlock = "## Hacker News (AI関連 直近)`n"
if ($hnItems.Count -gt 0) {
    foreach ($i in $hnItems) {
        $dataBlock += "- $($i.Title) (Score: $($i.Score), Comments: $($i.Comments))`n  URL: $($i.URL)`n"
    }
} else {
    $dataBlock += "(取得失敗)`n"
}

$dataBlock += "`n## arXiv cs.AI (直近10件)`n"
if ($arxivItems.Count -gt 0) {
    foreach ($i in $arxivItems) {
        $dataBlock += "- **$($i.Title)**`n  Abstract: $($i.Summary)`n  Link: $($i.Link)`n"
    }
} else {
    $dataBlock += "(取得失敗)`n"
}

$dataBlock += "`n## Anthropic Blog (直近5件)`n"
if ($anthropicItems.Count -gt 0) {
    foreach ($i in $anthropicItems) {
        $dataBlock += "- **$($i.Title)** ($($i.PubDate))`n  $($i.Description)`n  Link: $($i.Link)`n"
    }
} else {
    $dataBlock += "(取得失敗)`n"
}

# OpenClawに整形依頼
$prompt = @"
# タスク: 大井湧瑛向けに今日のAI業界ニュースサマリーを作成

## 入力データ（自動取得）
以下は今日（$today）自動取得した最新AI情報です。これを整形してください。

$dataBlock

## 出力フォーマット
\`\`\`markdown
---
type: ai-news-daily
date: $today
tags: [ai-news, daily, monitor]
---

# AI業界ニュース $today

## 大井に響く Top3（重要度順）
1. **<タイトル>** — <なぜ大井に関係あるか1行>
2. ...
3. ...

## カテゴリ別

### 🆕 新しいモデル・製品リリース
- ...

### 🧠 注目研究（arXiv）
- **<研究タイトル>**: 1行で何がすごいか
- ...

### 🏢 企業の動き（資金調達・戦略・買収）
- ...

### 🛠 開発者向けツール・SDK
- ...

## 大井プロダクトへの示唆
- [[entities/aipax]] / [[entities/aipa-web]] / [[entities/testall]] に関係あるニュースがあれば1行で
- 既存戦略変更が必要か

## 大井への一言（30字以内）
<起きて最初に見て情報感度上がる1行>
\`\`\`

## ルール
- 入力データに無い情報は推測しない
- 重要度判定は「大井の事業に直接影響あるか」軸
- 約3000字以内
- AI臭NG（「とても」「様々」禁止）
"@

& $dispatcher `
    -Department "research" `
    -Title "[BG-AINews] AI業界ニュース $today" `
    -Prompt $prompt `
    -OutputPath "$outDir\ai-news-$today.md" `
    -Priority "normal"

Write-Host "BG-AINews: HN=$($hnItems.Count) arXiv=$($arxivItems.Count) Anthropic=$($anthropicItems.Count) → dispatched"
