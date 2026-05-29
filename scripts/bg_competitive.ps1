#requires -Version 5.1
# 毎日11:00 - 競合5社/日 動向チェック。
# meta/competitive-intel.md に登録された競合リストを5社ずつ深掘り。

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$intelPath = Join-Path $brainRoot "wiki\meta\competitive-intel.md"
$stateFile = Join-Path $brainRoot "scripts\.bg_competitive_state.json"
$outDir = Join-Path $brainRoot "wiki\research\competitors"
$today = (Get-Date).ToString("yyyy-MM-dd")

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

# 監視対象 主要競合（実在）
$competitors = @(
    @{ Name = "Studyplus Planning"; Product = "testall"; Category = "EdTech" },
    @{ Name = "atama+"; Product = "testall"; Category = "EdTech" },
    @{ Name = "Notion AI"; Product = "aipax"; Category = "Productivity" },
    @{ Name = "Sansan"; Product = "aipax"; Category = "Business" },
    @{ Name = "engage"; Product = "aipa-web"; Category = "HR-Tech" },
    @{ Name = "採用ピックアップ"; Product = "aipa-web"; Category = "HR-Tech" },
    @{ Name = "Wantedly"; Product = "aipa-web"; Category = "HR-Tech" },
    @{ Name = "Studyplus"; Product = "testall"; Category = "EdTech" },
    @{ Name = "BizReach"; Product = "aipa-web"; Category = "HR-Tech" },
    @{ Name = "Indeed"; Product = "aipa-web"; Category = "HR-Tech" },
    @{ Name = "ChatGPT Team"; Product = "aipax"; Category = "AI-SaaS" },
    @{ Name = "Microsoft Copilot"; Product = "aipax"; Category = "AI-SaaS" },
    @{ Name = "Salesforce Einstein"; Product = "aipax"; Category = "AI-CRM" },
    @{ Name = "Gusto"; Product = "aipa-web"; Category = "HR-Tech" },
    @{ Name = "Manebi"; Product = "aipax-school"; Category = "EdTech" }
)

# state: { current_idx: 0 }
$state = @{ current_idx = 0 }
if (Test-Path $stateFile) {
    try {
        $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $state = @{ current_idx = [int]$loaded.current_idx }
    } catch {}
}

# 1周完了チェック
if ($state.current_idx -ge $competitors.Count) {
    $state.current_idx = 0
    & "$brainRoot\scripts\notify.ps1" -From OpenClaw -Title "🦞 競合動向監視 1サイクル完了" -Body "15社の動向チェック完了。明日から次サイクル。" -Color green
}

# 今日処理する5社（または残り）
$batchSize = 5
$batch = @()
for ($i = 0; $i -lt $batchSize; $i++) {
    $idx = $state.current_idx + $i
    if ($idx -lt $competitors.Count) {
        $batch += $competitors[$idx]
    }
}

if ($batch.Count -eq 0) {
    Write-Host "No competitors to process"
    exit 0
}

# 各社別に dispatch（並列）
foreach ($comp in $batch) {
    $slug = $comp.Name -replace "[\s/]+", "-" -replace "[^a-zA-Z0-9\-]", ""

    $prompt = @"
# タスク: 競合「$($comp.Name)」の動向深掘り

## 監視対象
- 競合: **$($comp.Name)**
- カテゴリ: $($comp.Category)
- 大井プロダクトの競合先: [[entities/$($comp.Product)]]

## 調べる視点
1. **直近の動き**: 公開情報の範囲で（知らないなら「公開情報範囲では特記事項なし」と明記）
2. **強み**: ターゲット/価格/技術/ブランド/ネットワーク
3. **弱み・隙**: [[entities/$($comp.Product)]] が突けるポイント
4. **大井事業への影響**: 短期/中期/長期
5. **対抗戦略**: 大井が取るべき差別化軸

## 出力フォーマット
\`\`\`markdown
---
type: competitor-watch
competitor: $($comp.Name)
target_product: $($comp.Product)
category: $($comp.Category)
date: $today
tags: [bg-competitive, $($comp.Category.ToLower())]
---

# 競合動向: $($comp.Name) ($today)

## 1行サマリー
（30字以内）

## 直近の動き
- ...

## 強み
- ...

## 弱み・隙
- ...

## [[entities/$($comp.Product)]] への影響
- 短期: ...
- 中期: ...
- 長期: ...

## 大井の対抗戦略
- 差別化軸:
- 取るべきアクション:

## 注意レベル
高/中/低 — 理由: ...
\`\`\`

## ルール
- 約2500字以内
- 推測には「推測:」プレフィックス
- 不明な数字は「不明」
- AI臭NG
"@

    & $dispatcher `
        -Department "research" `
        -Title "[BG-Competitive] $($comp.Name)" `
        -Prompt $prompt `
        -OutputPath "$outDir\$slug-$today.md" `
        -Priority "low"
}

# state進める
$state.current_idx += $batchSize
$stateJson = $state | ConvertTo-Json
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

Write-Host "BG-Competitive: dispatched $($batch.Count) competitors. Next idx: $($state.current_idx)"
