#requires -Version 5.1
# 毎朝07:55 - 全システム健全性チェック。問題があればDiscord通知。

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$today = (Get-Date).ToString("yyyy-MM-dd")
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$reportPath = Join-Path $brainRoot "wiki\_routines\health-$today.md"
$logPath = Join-Path $brainRoot "scripts\health.log"
$utf8 = [System.Text.UTF8Encoding]::new($false)

$issues = @()
$ok = @()

# 1. Ollama応答確認
try {
    $r = Invoke-RestMethod -Uri "http://localhost:11434/" -TimeoutSec 5
    $ok += "Ollama: 稼働中"
} catch {
    $issues += "Ollama: 応答なし（worker動かない可能性）"
}

# 2. スケジューラ稼働確認（主要タスクのみ）
$criticalTasks = @("BrainWorkerHeavy", "BrainWorkerLight", "BrainTaskBoard", "BrainMonitor", "BrainHarvest", "BrainHealth", "BrainDashboard", "DailyBrainOllama")
foreach ($t in $criticalTasks) {
    $info = schtasks /query /tn $t /fo LIST 2>$null | Select-String "Status"
    if ($info -match "Ready|Running") {
        $ok += "${t}: OK"
    } else {
        $issues += "${t}: 異常 or 未登録"
    }
}

# 3. ロックファイル古くないか（自動修復）
$autoFixed = @()
$lockFiles = Get-ChildItem (Join-Path $brainRoot "queue") -Filter ".worker*.lock" -Force -ErrorAction SilentlyContinue
foreach ($lockPath in $lockFiles) {
    $age = ((Get-Date) - $lockPath.LastWriteTime).TotalMinutes
    if ($age -gt 60) {
        # 自動削除
        Remove-Item $lockPath.FullName -Force
        $autoFixed += "$($lockPath.Name): $([int]$age)分古かったので削除"
    } else {
        $ok += "$($lockPath.Name): $([int]$age)分前（正常）"
    }
}

# 4. processing/ に古いタスクが詰まってないか（自動修復・inboxに戻す）
$processing = Get-ChildItem (Join-Path $brainRoot "queue\processing") -File -ErrorAction SilentlyContinue
$staleProcessing = $processing | Where-Object { ((Get-Date) - $_.LastWriteTime).TotalMinutes -gt 60 }
if ($staleProcessing) {
    foreach ($s in $staleProcessing) {
        $dest = Join-Path $brainRoot "queue\inbox" $s.Name
        try {
            Move-Item $s.FullName $dest -Force
            $autoFixed += "processing→inbox: $($s.Name) ($([int]((Get-Date) - $s.LastWriteTime).TotalMinutes)分stuck)"
        } catch {
            $issues += "processing/ stuck修復失敗: $($s.Name)"
        }
    }
} else {
    $ok += "processing/: $($processing.Count)件（stuck なし）"
}

# 5. failed/ に新規エラー
$failed = Get-ChildItem (Join-Path $brainRoot "queue\failed") -File -ErrorAction SilentlyContinue
if ($failed -and $failed.Count -gt 0) {
    $recentFailed = $failed | Where-Object { $_.LastWriteTime.Date -eq [DateTime]::Today }
    if ($recentFailed) {
        $issues += "failed/: 今日 $($recentFailed.Count)件 失敗"
    }
}

# 6. inbox/ にタスクが滞留しすぎてないか
$inbox = Get-ChildItem (Join-Path $brainRoot "queue\inbox") -File -ErrorAction SilentlyContinue
$inboxCount = if ($inbox) { $inbox.Count } else { 0 }
if ($inboxCount -gt 30) {
    $issues += "inbox/: $inboxCount件 滞留（処理が追いついてない）"
} else {
    $ok += "inbox/: $inboxCount件 待機中"
}

# 7. ディスク容量チェック
$drive = Get-PSDrive C
$freeGB = [Math]::Round($drive.Free / 1GB, 1)
if ($freeGB -lt 10) {
    $issues += "ディスク容量: 残${freeGB}GB（10GB未満・要注意）"
} else {
    $ok += "ディスク容量: ${freeGB}GB free"
}

# 8. 重要ファイル存在確認
$importantFiles = @(
    "scripts\worker.ps1",
    "scripts\dispatch.ps1",
    "scripts\monitor.ps1",
    "scripts\harvest.ps1",
    "scripts\task_board.ps1",
    "scripts\prompt-prefix.md",
    "wiki\hot.md",
    "wiki\index.md",
    "CLAUDE.md"
)
foreach ($f in $importantFiles) {
    $p = Join-Path $brainRoot $f
    if (-not (Test-Path $p)) {
        $issues += "重要ファイル欠損: $f"
    }
}

# 9. wiki/_inbox/ に滞留する成果物
$inboxResults = Get-ChildItem (Join-Path $brainRoot "wiki\_inbox") -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Directory.Name -ne "_archive" }
$staleResults = $inboxResults | Where-Object { ((Get-Date) - $_.LastWriteTime).TotalHours -gt 24 }
if ($staleResults) {
    $issues += "wiki/_inbox/: 24時間以上未レビュー $($staleResults.Count)件"
}

# レポート生成
$lines = @()
$lines += "---"
$lines += "type: health-check"
$lines += "date: $today"
$lines += "generated: $nowStamp"
$lines += "tags: [health, system]"
$lines += "---"
$lines += ""
$lines += "# システム健全性チェック [[$today]]"
$lines += ""
$lines += "## 総合判定"
if ($issues.Count -eq 0) {
    $lines += "**状態: 🟢 正常**（問題なし）"
} elseif ($issues.Count -le 2) {
    $lines += "**状態: 🟡 注意**（問題 $($issues.Count) 件）"
} else {
    $lines += "**状態: 🔴 異常**（問題 $($issues.Count) 件・要対処）"
}
$lines += ""

if ($autoFixed.Count -gt 0) {
    $lines += "## 🔧 自動修復"
    foreach ($f in $autoFixed) { $lines += "- $f" }
    $lines += ""
}

if ($issues.Count -gt 0) {
    $lines += "## ⚠️ 問題"
    foreach ($i in $issues) { $lines += "- $i" }
    $lines += ""
}

$lines += "## ✅ 正常項目"
foreach ($o in $ok) { $lines += "- $o" }
$lines += ""
$lines += "## 集計"
$lines += "- queue: inbox=$inboxCount / processing=$($processing.Count) / failed=$($failed.Count)"
$lines += "- ディスク残: ${freeGB}GB"
$lines += "- wiki/_inbox/ 未レビュー: $($inboxResults.Count) 件（うちstale: $($staleResults.Count)件）"

$report = $lines -join "`r`n"
[System.IO.File]::WriteAllText($reportPath, $report, $utf8)

# ログ追記
$logLine = "$nowStamp - issues=$($issues.Count) inbox=$inboxCount processing=$($processing.Count) failed=$($failed.Count)"
$logLine | Add-Content $logPath -Encoding UTF8

# Discord通知（自動修復ありの場合も通知）
if ($autoFixed.Count -gt 0) {
    $configPath = Join-Path $brainRoot "scripts\config.json"
    if (Test-Path $configPath) {
        try {
            $cfg = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($cfg.discord.webhook_url) {
                & "$brainRoot\scripts\notify.ps1" -From Health -Title "🔧 Brain Auto-Fix" -Body ($autoFixed -join "`n") -Color "orange"
            }
        } catch {}
    }
}

# Discord通知（webhook設定あり・問題ある場合のみ）
if ($issues.Count -gt 0) {
    $configPath = Join-Path $brainRoot "scripts\config.json"
    if (Test-Path $configPath) {
        try {
            $cfg = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($cfg.discord.webhook_url) {
                $notifyScript = Join-Path $brainRoot "scripts\discord_notify.ps1"
                $color = if ($issues.Count -gt 2) { "red" } else { "yellow" }
                $body = "問題 $($issues.Count) 件:`n" + ($issues -join "`n")
                & powershell.exe -NonInteractive -ExecutionPolicy Bypass -File $notifyScript -Title "Brain Health" -Body $body -Color $color
            }
        } catch {}
    }
}

Write-Host "Health check: $($issues.Count) issues / $($ok.Count) ok / report: $reportPath"
