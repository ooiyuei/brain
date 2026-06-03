#requires -Version 5.1
# Brain System Graceful Pause
# - Mythos state を保存
# - Ollama service は残す (再開高速化)
# - VRAM 完全解放
# - 再開時に同じ品質で復帰できる状態を作る

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$queue = "$brain\queue"
$paused = "$queue\.paused"
$snapshot = "$queue\.pause_snapshot.json"
$now = (Get-Date).ToString("o")

Write-Host "=== Brain Pause (Graceful) ===" -ForegroundColor Yellow

# 1. .paused flag (filler/workerが起動時にチェックする)
Set-Content -Path $paused -Value $now -Force
Write-Host "[1/8] Pause flag set"

# 2. 状態スナップショット保存 (再開時に照合)
$snap = @{
    paused_at = $now
    inbox_count = (Get-ChildItem "$queue\inbox" -File -Filter "*.json" -ErrorAction SilentlyContinue).Count
    processing_count = (Get-ChildItem "$queue\processing" -File -ErrorAction SilentlyContinue).Count
    done_count = (Get-ChildItem "$queue\done" -File -ErrorAction SilentlyContinue).Count
    overflow_count = (Get-ChildItem "$queue\inbox\_overflow_archive" -File -ErrorAction SilentlyContinue).Count
    ollama_was_up = $false
    active_schedulers = @()
}
try {
    $r = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
    if ($r.StatusCode -eq 200) { $snap.ollama_was_up = $true }
} catch {}
$snap.active_schedulers = @(Get-ScheduledTask | Where-Object { $_.TaskName -match '^Brain' -and $_.State -ne 'Disabled' } | ForEach-Object { $_.TaskName })
$snap | ConvertTo-Json -Depth 5 | Set-Content -Path $snapshot -Encoding UTF8
Write-Host "[2/8] Snapshot saved (inbox=$($snap.inbox_count), schedulers=$($snap.active_schedulers.Count))"

# 3. 全Brain* scheduler を Disable
$disabledCount = 0
Get-ScheduledTask | Where-Object { $_.TaskName -match '^Brain' } | ForEach-Object {
    if ($_.State -ne 'Disabled') {
        try { Disable-ScheduledTask -TaskName $_.TaskName -ErrorAction SilentlyContinue | Out-Null; $disabledCount++ } catch {}
    }
}
Write-Host "[3/8] Disabled $disabledCount schedulers"

# 4. Ollama モデルを unload (keep_alive:0) - serviceは残す
try {
    $ps = (Invoke-WebRequest -Uri "http://localhost:11434/api/ps" -UseBasicParsing -TimeoutSec 3).Content | ConvertFrom-Json
    foreach ($m in $ps.models) {
        $body = @{ model = $m.name; keep_alive = 0 } | ConvertTo-Json
        try { Invoke-WebRequest -Uri "http://localhost:11434/api/generate" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue | Out-Null } catch {}
    }
    Write-Host "[4/8] Models unloaded ($($ps.models.Count) models)"
} catch {
    Write-Host "[4/8] Ollama already idle"
}

# 5. ollama_llama_server だけkill (VRAM解放) - ollama service本体は残す
Get-Process ollama_llama_server -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "[5/8] ollama_llama_server killed (VRAM freed)"

# 6. Worker / filler / pipeline / loop プロセス kill (自プロセス $PID は除外)
$killed = 0
try {
    Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessId -ne $PID -and (
        $_.CommandLine -like '*worker.ps1*' -or
        $_.CommandLine -like '*_filler.ps1*' -or
        $_.CommandLine -like '*pipeline.ps1*' -or
        $_.CommandLine -like '*_loop.ps1*' -or
        $_.CommandLine -like '*auto_review*' -or
        $_.CommandLine -like '*auto_promote*')
    } | ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        $killed++
    }
    Get-Process wscript -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
} catch {}
Write-Host "[6/8] Workers killed ($killed processes)"

# 7. Lock files 削除 + processing → inbox
@(".worker-heavy.lock", ".worker-light.lock", ".worker-any.lock") | ForEach-Object {
    Remove-Item "$queue\$_" -Force -ErrorAction SilentlyContinue
}
$moved = 0
Get-ChildItem "$queue\processing" -File -ErrorAction SilentlyContinue | ForEach-Object {
    Move-Item $_.FullName "$queue\inbox\$($_.Name)" -Force -ErrorAction SilentlyContinue
    $moved++
}
Write-Host "[7/8] Locks cleared, $moved processing→inbox"

# 8. 確認
Start-Sleep 2
$vram = "?"
try { $vram = (nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>$null | Select-Object -First 1).Trim() } catch {}
Write-Host "[8/8] Done. VRAM: ${vram}MB" -ForegroundColor Green
Write-Host ""
Write-Host "→ Resume: scripts\resume_brain.ps1 で完全復帰" -ForegroundColor Cyan
Write-Host "→ Dashboard のボタンでも同じ動作"
exit 0
