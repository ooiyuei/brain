#requires -Version 5.1
# 週次自動改善ループ - 毎週日曜22:00
# worker.log / failed/ / wiki/_inbox の状況を分析、改善提案を生成

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$today = (Get-Date).ToString("yyyy-MM-dd")
$weekStart = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
$outPath = Join-Path $brainRoot "wiki\meta\self-review-$today.md"
$utf8 = [System.Text.UTF8Encoding]::new($false)

# 1. worker.log 集計
$workerLogs = Get-ChildItem (Join-Path $brainRoot "queue\logs") -Filter "worker*.log" -ErrorAction SilentlyContinue
$totalRuns = 0
$totalErrors = 0
$totalSeconds = 0
$errorPatterns = @{}

foreach ($lg in $workerLogs) {
    Get-Content $lg.FullName -Encoding UTF8 | ForEach-Object {
        if ($_ -match "Started:") { $totalRuns++ }
        if ($_ -match "ERROR:") {
            $totalErrors++
            $errMsg = ($_ -split "ERROR:")[1].Trim()
            $errKey = $errMsg.Substring(0, [Math]::Min(60, $errMsg.Length))
            if ($errorPatterns.ContainsKey($errKey)) {
                $errorPatterns[$errKey]++
            } else {
                $errorPatterns[$errKey] = 1
            }
        }
        if ($_ -match "Got response: (\d+) chars") {
            # 成功
        }
    }
}

# 2. failed/ の件数とエラー種別
$failedTasks = Get-ChildItem (Join-Path $brainRoot "queue\failed") -File -ErrorAction SilentlyContinue
$failedCount = if ($failedTasks) { $failedTasks.Count } else { 0 }

# 3. wiki/_inbox/ の滞留件数（24時間以上未処理）
$inboxStale = 0
if (Test-Path (Join-Path $brainRoot "wiki\_inbox")) {
    $allInbox = Get-ChildItem (Join-Path $brainRoot "wiki\_inbox") -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue |
        Where-Object { $_.Directory.Name -ne "_archive" }
    $inboxStale = ($allInbox | Where-Object { ((Get-Date) - $_.LastWriteTime).TotalHours -gt 24 }).Count
}

# 4. 平均レスポンス字数
$responses = @()
foreach ($lg in $workerLogs) {
    Get-Content $lg.FullName -Encoding UTF8 | ForEach-Object {
        if ($_ -match "Got response: (\d+) chars") {
            $responses += [int]$matches[1]
        }
        if ($_ -match "Agent ok: ([\d.]+) sec, (\d+) chars") {
            $responses += [int]$matches[2]
        }
    }
}
$avgResponse = if ($responses.Count -gt 0) { [int]($responses | Measure-Object -Average).Average } else { 0 }
$totalCompleted = $responses.Count

# 5. レポート出力
$lines = @()
$lines += "---"
$lines += "type: self-review"
$lines += "date: $today"
$lines += "period: $weekStart - $today"
$lines += "tags: [self-review, meta, weekly]"
$lines += "---"
$lines += ""
$lines += "# Brain System 週次自己レビュー [[$today]]"
$lines += ""
$lines += "## サマリー数字"
$lines += ""
$lines += "| 指標 | 値 |"
$lines += "|---|---|"
$lines += "| 総処理タスク | $totalRuns 件 |"
$lines += "| 完了 | $totalCompleted 件 |"
$lines += "| 失敗 | $failedCount 件 |"
$lines += "| エラー回数 | $totalErrors 回 |"
$lines += "| 成功率 | $(if ($totalRuns -gt 0) { [Math]::Round(($totalCompleted / $totalRuns) * 100, 1) } else { 0 })% |"
$lines += "| 平均出力字数 | $avgResponse 字 |"
$lines += "| 未レビュー滞留 (>24h) | $inboxStale 件 |"
$lines += ""

if ($errorPatterns.Count -gt 0) {
    $lines += "## エラーパターン Top5"
    $lines += ""
    $sorted = $errorPatterns.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 5
    foreach ($e in $sorted) {
        $lines += "- ($($e.Value)回) ``$($e.Key)``"
    }
    $lines += ""
}

# 6. OpenClawに改善提案を依頼
$reviewData = $lines -join "`r`n"

$proposalPrompt = @"
# タスク: Brain System の週次自己改善提案

## 入力データ（過去1週間の運用統計）
$reviewData

## 提案すべき改善
以下の観点で 3つの改善アクション を箇条書きで提案：

1. **エラー減少**: 上位エラーパターンを減らす施策
2. **品質向上**: 平均出力字数や成功率を上げる施策
3. **処理速度**: 滞留・遅延を改善する施策

各提案について：
- 何を変えるか（具体的ファイルパス・スクリプト名）
- なぜ効くか（理由）
- 想定インパクト（小/中/大）

## 出力フォーマット
``````markdown
## 改善提案 1: <タイトル>
- 対象ファイル: ``scripts/<file>`` or 設定変更
- 変更内容: <具体的に>
- 期待効果: <数値で>
- インパクト: 小/中/大

## 改善提案 2: ...

## 改善提案 3: ...

## 次週の優先実装
- どの提案を最優先で実装すべきか1つ選んで根拠
``````

約2000字以内、推測には「推測:」プレフィックス。
"@

# 既存内容を保存
[System.IO.File]::WriteAllText($outPath, $reviewData, $utf8)

# OpenClawに分析→提案依頼
& $dispatcher `
    -Department "research" `
    -Title "[Self-Review] Brain System 週次改善提案 $today" `
    -Prompt $proposalPrompt `
    -OutputPath (Join-Path $brainRoot "wiki\meta\self-review-proposals-$today.md") `
    -Priority "high"

# Discord通知
& "$brainRoot\scripts\notify.ps1" `
    -From Health `
    -Title "🩺 週次自己レビュー実行" `
    -Body "処理: $totalRuns 件 / 失敗: $failedCount 件 / 滞留: $inboxStale 件`n`n改善提案をOpenClawに依頼中。完了後 wiki/meta/self-review-proposals-$today.md を確認。" `
    -Color blue

Write-Host "Self-review done: $outPath"
Write-Host "Proposal dispatched, will appear at wiki/meta/self-review-proposals-$today.md"
