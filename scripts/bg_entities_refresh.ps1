#requires -Version 5.1
# 毎日10:00 - wiki/entities/ の中で最も古いものを2件、OpenClawに更新依頼。
# 17ファイル÷2 = 約9日で全件更新

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$entitiesDir = Join-Path $brainRoot "wiki\entities"
$stateFile = Join-Path $brainRoot "scripts\.bg_entities_state.json"
$outDir = Join-Path $brainRoot "wiki\_inbox\newbiz"
$today = (Get-Date).ToString("yyyy-MM-dd")

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

# state: 既に今ラウンドで更新したentitiesのリスト
$state = @{ refreshed = @(); round = 1 }
if (Test-Path $stateFile) {
    try {
        $state = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $state = @{
            refreshed = @($state.refreshed)
            round = [int]$state.round
        }
    } catch {}
}

# まだ更新してない entities を取得（更新日時の古い順）
$allEntities = Get-ChildItem $entitiesDir -Filter "*.md" -File | Where-Object { $_.BaseName -ne "ooi-yuei" } | Sort-Object LastWriteTime
$pending = $allEntities | Where-Object { $state.refreshed -notcontains $_.BaseName }

if ($pending.Count -eq 0) {
    # 全件完了 → 次ラウンドへ（古いものから再度更新）
    $state.refreshed = @()
    $state.round = $state.round + 1
    $stateJson = $state | ConvertTo-Json
    [System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

    & "$brainRoot\scripts\notify.ps1" -From OpenClaw -Title "🦞 entities更新 ラウンド$($state.round - 1)完了" -Body "全17件×ラウンド$($state.round - 1) 完了。明日からラウンド$($state.round)開始。" -Color green
    exit 0
}

# 今日処理する2件
$today_targets = $pending | Select-Object -First 2

foreach ($entity in $today_targets) {
    $entitySlug = $entity.BaseName
    $entityPath = $entity.FullName

    $prompt = @"
# タスク: [[entities/$entitySlug]] のページを最新情報で更新する初稿

## 現状ファイル
worker.ps1が context_files で渡します。これを読んで、以下の観点で更新提案を作成：

## 更新観点
1. **直近の動き**: 状態（企画中/開発中/営業中など）に変化はあるか
2. **数字の更新**: 売上・ユーザー数・コスト等の最新値（不明なら「要確認」）
3. **競合状況の変化**: [[meta/competitive-intel]] と整合性チェック
4. **次のアクション**: 直近1ヶ月で大井がやるべき1-3項目
5. **リスク・ブロッカー**: 今のフェーズで詰まりやすいポイント

## 出力フォーマット
既存ファイルの構造を保ちつつ、以下を含む形で「**更新提案**」として出力：

```markdown
---
type: entity-refresh-proposal
entity: $entitySlug
date: $today
tags: [refresh, proposal]
---

# [[entities/$entitySlug]] 更新提案 $today

## 1. 状態変化チェック
- 現状: ...
- 推奨更新: ...

## 2. 数字最新化
| 項目 | 既存値 | 推奨更新 |
|---|---|---|
| ... | ... | ... |

## 3. 競合状況
- 既存記載: ...
- 最新動向: ...

## 4. 直近1ヶ月の推奨アクション
1. ...
2. ...
3. ...

## 5. リスク・ブロッカー
- ...

## 6. その他更新提案
- ...
```

## 重要
- 既存ファイルを書き換えない（あくまで提案）
- 推測には「推測:」プレフィックス、不明は「不明」と明記
- 約3000字以内
## 注: Claudeが後でこの提案を読んで、本ファイル[[entities/$entitySlug]]を更新する
"@

    & $dispatcher `
        -Department "newbiz" `
        -Title "[BG-Entities] $entitySlug 更新提案" `
        -Prompt $prompt `
        -ContextFiles @($entityPath) `
        -OutputPath "$outDir\refresh-$entitySlug-$today.md" `
        -Priority "low"

    $state.refreshed += $entitySlug
}

$stateJson = $state | ConvertTo-Json
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

Write-Host "BG-Entities: dispatched $($today_targets.Count) refresh tasks. Round $($state.round), refreshed $($state.refreshed.Count)/16"
