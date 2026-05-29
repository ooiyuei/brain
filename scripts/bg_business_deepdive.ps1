#requires -Version 5.1
# 毎日10:30 - 全15事業のうち、3日に1事業ずつ深掘り。45日で全事業×4視点完了。
# 4視点 = 現状診断 / 深掘り / 企画書初稿 / 次の一手

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$entitiesDir = Join-Path $brainRoot "wiki\entities"
$stateFile = Join-Path $brainRoot "scripts\.bg_business_state.json"
$outBaseDir = Join-Path $brainRoot "wiki\_inbox\newbiz"
$today = (Get-Date).ToString("yyyy-MM-dd")

if (-not (Test-Path $outBaseDir)) { New-Item -ItemType Directory -Path $outBaseDir -Force | Out-Null }

# 対象15事業
$businesses = @(
    "testall", "gymee", "agents-of-flag", "aipax", "aipa-web",
    "aipax-school", "eemus", "omni", "ipak-cafe", "ipak-ofuro",
    "ipak-darts", "ipak-fishing", "ecokan", "fruits-sauce", "wa-kouchai"
)

$viewpoints = @(
    @{ Slug = "current"; Title = "現状診断"; Prompt = "現状の事業フェーズ・進捗・数字・直近の動き・ボトルネックを整理する" },
    @{ Slug = "deepdive"; Title = "深掘り"; Prompt = "市場規模・ターゲット顧客プロファイル・競合・差別化・収益モデルを深く分析する" },
    @{ Slug = "proposal"; Title = "企画書初稿"; Prompt = "投資家・パートナー向け企画書として、課題/解決策/市場/モデル/チーム/ロードマップを書く" },
    @{ Slug = "next"; Title = "次の一手"; Prompt = "直近1ヶ月で大井がやるべき3項目を、優先度と所要時間付きで提案する" }
)

# state: { current_idx: 0, current_viewpoint: 0 }
$state = @{ current_idx = 0; current_viewpoint = 0 }
if (Test-Path $stateFile) {
    try {
        $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $state = @{
            current_idx = [int]$loaded.current_idx
            current_viewpoint = [int]$loaded.current_viewpoint
        }
    } catch {}
}

# 全件完了チェック
if ($state.current_idx -ge $businesses.Count) {
    # 1サイクル完了 → リセット（次サイクル）
    $state.current_idx = 0
    $state.current_viewpoint = 0
    & "$brainRoot\scripts\notify.ps1" -From OpenClaw -Title "🦞 全事業深掘り 1サイクル完了" -Body "15事業×4視点 完了。明日から次サイクル開始（同じ事業を最新情報で再深掘り）。" -Color green
}

$biz = $businesses[$state.current_idx]
$vp = $viewpoints[$state.current_viewpoint]
$entityPath = Join-Path $entitiesDir "$biz.md"

if (-not (Test-Path $entityPath)) {
    Write-Host "Skip: $biz (entity file not found)"
    # 次へ
    $state.current_viewpoint = ($state.current_viewpoint + 1) % 4
    if ($state.current_viewpoint -eq 0) { $state.current_idx++ }
    $stateJson = $state | ConvertTo-Json
    [System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))
    exit 0
}

$prompt = @"
# タスク: [[entities/$biz]] の $($vp.Title)

## 視点
$($vp.Prompt)

## 入力ファイル
worker.ps1 が context_files で [[entities/$biz]] を渡します。これを読み込んで分析してください。

## 出力フォーマット
\`\`\`markdown
---
type: business-$($vp.Slug)
business: $biz
date: $today
viewpoint: $($vp.Title)
tags: [bg-business, $($vp.Slug), $biz]
---

# [[entities/$biz]] $($vp.Title) ($today)

（ここから本文。指示の視点に基づき構造化Markdownで書く）

## ...セクション1
...

## ...セクション2
...

## 不明点・要確認
- ...

## 関連
- [[entities/$biz]] (本体ページ)
- [[meta/competitive-intel]]
\`\`\`

## ルール
- 約3000字以内
- 推測には「推測:」プレフィックス
- 不明な数字は「不明」「要確認」と明記
- 大井の脳汁駆動・OS化思考に響く構造で
"@

& $dispatcher `
    -Department "newbiz" `
    -Title "[BG-Business] $biz $($vp.Title)" `
    -Prompt $prompt `
    -ContextFiles @($entityPath) `
    -OutputPath "$outBaseDir\bg-business-$biz-$($vp.Slug)-$today.md" `
    -Priority "low"

# state進める
$state.current_viewpoint = ($state.current_viewpoint + 1) % 4
if ($state.current_viewpoint -eq 0) { $state.current_idx++ }

$stateJson = $state | ConvertTo-Json
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

Write-Host "BG-Business: dispatched $biz / $($vp.Title) (idx $($state.current_idx), vp $($state.current_viewpoint))"
