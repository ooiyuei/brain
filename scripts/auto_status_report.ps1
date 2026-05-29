# 大井外出中の自動状況レポート (90分毎)
# Scheduled Task: BrainAutoStatusReport
# 大井に「ぶん回し継続」を Discord で報告

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"

# 1. ollama 稼働確認
$ollamaAlive = $false
$ollamaModel = "DOWN"
$ollamaGPU = "?"
try {
    $r = Invoke-WebRequest -Uri "http://127.0.0.1:11434/api/tags" -TimeoutSec 5 -ErrorAction Stop
    $ollamaAlive = $true
    $psOut = & "C:\Users\Owner\AppData\Local\Programs\Ollama\ollama.exe" ps 2>&1 | Out-String
    if ($psOut -match "^(qwen\S+)\s+\S+\s+\S+GB\s+(\S+)") {
        $ollamaModel = $Matches[1]
        $ollamaGPU = $Matches[2]
    }
} catch { }

# 2. Queue 状態
$inbox = (Get-ChildItem "$brain\queue\inbox" -File -Filter '*.json' -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer }).Count
$processing = (Get-ChildItem "$brain\queue\processing" -File -Filter '*.json' -ErrorAction SilentlyContinue).Count
$done = (Get-ChildItem "$brain\queue\done" -File -Filter '*.json' -ErrorAction SilentlyContinue).Count
$failed = (Get-ChildItem "$brain\queue\failed" -File -Filter '*.json' -ErrorAction SilentlyContinue).Count

# 3. Worker 直近稼働
$workers = Get-ScheduledTask -TaskName 'BrainWorker*' -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Ready' }
$workerLine = ""
foreach ($w in $workers) {
    $info = $w | Get-ScheduledTaskInfo
    $workerLine += "$($w.TaskName)=$($info.LastRunTime.ToString('HH:mm')) "
}

# 4. 直近30分の完了タスク
$cutoff = (Get-Date).AddMinutes(-30)
$recentDone = (Get-ChildItem "$brain\queue\done" -File -Filter '*.json' -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -ge $cutoff }).Count

# 5. 直近1時間の失敗
$cutoffH = (Get-Date).AddHours(-1)
$recentFailed = Get-ChildItem "$brain\queue\failed" -File -Filter '*.json' -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -ge $cutoffH }

# 6. brain 編集 (今日)
$today = (Get-Date).Date
$todayEdited = (Get-ChildItem $brain -Filter "*.md" -Recurse -ErrorAction SilentlyContinue | Where-Object {
    $_.LastWriteTime -ge $today -and
    $_.FullName -notlike "*\queue\*" -and $_.FullName -notlike "*\_archive\*"
}).Count

# 7. Disk usage
$drive = Get-PSDrive C
$diskFreeGB = [Math]::Round($drive.Free / 1GB, 1)

# 8. メモリ
$os = Get-CimInstance Win32_OperatingSystem
$memUsedPct = [Math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) * 100 / $os.TotalVisibleMemorySize, 0)

# 9. Discord通知 body
$timestamp = (Get-Date).ToString("HH:mm")
$ollamaStatus = if ($ollamaAlive) { "✅ $ollamaModel ($ollamaGPU)" } else { "❌ DOWN" }
$alertLevel = "blue"
$alerts = @()
if (-not $ollamaAlive) { $alerts += "ollama DOWN"; $alertLevel = "red" }
if ($inbox -gt 80) { $alerts += "inbox溜まり($inbox)"; $alertLevel = "orange" }
if ($recentFailed.Count -gt 3) { $alerts += "直近1h failed $($recentFailed.Count)件"; $alertLevel = "orange" }
if ($recentDone -eq 0 -and $inbox -gt 5) { $alerts += "worker詰まり?"; $alertLevel = "yellow" }
if ($diskFreeGB -lt 10) { $alerts += "Disk空き<10GB"; $alertLevel = "orange" }
if ($memUsedPct -gt 92) { $alerts += "RAM>$memUsedPct%"; $alertLevel = "yellow" }

$alertText = if ($alerts.Count -gt 0) { "`n⚠ " + ($alerts -join " / ") } else { "" }

$body = @"
$timestamp 自動状況レポート (90分毎)

🤖 ollama: $ollamaStatus
📋 queue: inbox=$inbox / processing=$processing / done(total)=$done / failed=$failed
⚙ worker: $workerLine
✅ 直近30分の完了: $recentDone 件
📝 今日のbrain編集: $todayEdited ファイル
💾 Disk空: ${diskFreeGB}GB / RAM: ${memUsedPct}%$alertText
"@

$titleText = "[Auto] Status " + (Get-Date).ToString('HH:mm')
& "$brain\scripts\discord_notify.ps1" -Title $titleText -Body $body -Color $alertLevel -From "Monitor"
