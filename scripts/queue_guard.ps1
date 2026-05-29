#requires -Version 5.1
# Queue Guard - 10分毎・queue膨張/古いタスク放置の自動防止
# 2026-05-25 新規: 過去にinbox 1215件膨張 → 処理詰まりの再発防止
# - inbox > 200件で古い normal(5-) を24h以上前のものから順に overflow へ移動
# - failed > 50件で全部 overflow に隔離
# - workers 死亡時に自動復活 (heavy/light 各1基保証)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$queue = "$brain\queue"
if (Test-Path "$queue\.paused") { exit 0 }

$logPath = "$brain\scripts\queue_guard.log"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

$inboxCount = (Get-ChildItem "$queue\inbox" -File -Filter "*.json" -ErrorAction SilentlyContinue).Count
$failedCount = (Get-ChildItem "$queue\failed" -File -ErrorAction SilentlyContinue).Count
$overflowDir = "$queue\inbox\_overflow_archive"
if (-not (Test-Path $overflowDir)) { New-Item -ItemType Directory -Path $overflowDir -Force | Out-Null }

$movedOld = 0
$movedFailed = 0
$workersRestarted = 0

# 1. inbox膨張ガード (200件超で古いnormalを整理)
if ($inboxCount -gt 200) {
    Get-ChildItem "$queue\inbox\5-*.json" -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddHours(-24) } | ForEach-Object {
        Move-Item $_.FullName "$overflowDir\$($_.Name)" -Force -ErrorAction SilentlyContinue
        $movedOld++
    }
}

# 2. failed膨張ガード (50件超で隔離)
if ($failedCount -gt 50) {
    Get-ChildItem "$queue\failed" -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddHours(-6) } | ForEach-Object {
        Move-Item $_.FullName "$overflowDir\$($_.Name)" -Force -ErrorAction SilentlyContinue
        $movedFailed++
    }
}

# 3. worker健全性 (heavy + light 各最低1基保証)
$workers = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like '*\worker.ps1*' })
$hasHeavy = $false
$hasLight = $false
foreach ($w in $workers) {
    if ($w.CommandLine -match '\bheavy\b') { $hasHeavy = $true }
    if ($w.CommandLine -match '\blight\b') { $hasLight = $true }
}
$vbs = "$brain\scripts\silent_runner.vbs"
if (-not $hasHeavy) {
    Remove-Item "$queue\.worker-heavy.lock" -Force -ErrorAction SilentlyContinue
    Start-Process wscript -ArgumentList "//nologo `"$vbs`" `"$brain\scripts\worker.ps1`" heavy" -WindowStyle Hidden
    $workersRestarted++
}
if (-not $hasLight) {
    Remove-Item "$queue\.worker-light.lock" -Force -ErrorAction SilentlyContinue
    Start-Process wscript -ArgumentList "//nologo `"$vbs`" `"$brain\scripts\worker.ps1`" light" -WindowStyle Hidden
    $workersRestarted++
}

# 4. .paused 怪奇現象対策 (過去にscheduler triggerで勝手にpaused復活)
# 大井が手動でpauseしたい時は dashboard ボタン or pause_brain.ps1
# .paused が古い (1h以上前で) + 全schedulers有効 = 怪奇復活 → 削除
if (Test-Path "$queue\.paused") {
    $pAge = ((Get-Date) - (Get-Item "$queue\.paused").LastWriteTime).TotalHours
    $enabledSchedulers = @(Get-ScheduledTask | Where-Object { $_.TaskName -match '^BrainWorker' -and $_.State -ne 'Disabled' }).Count
    if ($pAge -gt 1 -and $enabledSchedulers -gt 0) {
        Remove-Item "$queue\.paused" -Force -ErrorAction SilentlyContinue
        "$nowStamp - 怪奇.paused削除 (age=$([math]::Round($pAge,1))h・schedulers有効)" | Add-Content $logPath -Encoding UTF8
    }
}

$summary = "inbox=$inboxCount oldMoved=$movedOld failed=$failedCount failedMoved=$movedFailed workers=$($workers.Count) restarted=$workersRestarted"
"$nowStamp - $summary" | Add-Content $logPath -Encoding UTF8
Write-Host "queue_guard: $summary"
