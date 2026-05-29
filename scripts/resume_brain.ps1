#requires -Version 5.1
# Brain System Smart Resume
# - Snapshot を照合・同じ品質で復帰
# - Ollama service 生存確認 → 死んでたら自動起動
# - 全コンポーネント健全性チェック

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$queue = "$brain\queue"
$paused = "$queue\.paused"
$snapshot = "$queue\.pause_snapshot.json"

Write-Host "=== Brain Resume (Smart) ===" -ForegroundColor Cyan

# 1. Pause flag 削除
Remove-Item $paused -Force -ErrorAction SilentlyContinue
Write-Host "[1/9] Pause flag cleared"

# 2. Snapshot 読み込み
$snap = $null
if (Test-Path $snapshot) {
    try { $snap = Get-Content $snapshot -Raw -Encoding UTF8 | ConvertFrom-Json; Write-Host "[2/9] Snapshot loaded (paused @ $($snap.paused_at))" }
    catch { Write-Host "[2/9] Snapshot read error" }
} else {
    Write-Host "[2/9] No snapshot (cold resume)"
}

# 3. Ollama service 生存確認 → 死んでたら起動
$ollamaUp = $false
try {
    $r = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
    if ($r.StatusCode -eq 200) { $ollamaUp = $true }
} catch {}
if (-not $ollamaUp) {
    $ollamaApp = "$env:LOCALAPPDATA\Programs\Ollama\ollama app.exe"
    if (Test-Path $ollamaApp) {
        Start-Process $ollamaApp -WindowStyle Hidden
    } else {
        Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
    }
    Start-Sleep 5
    try {
        $r = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -UseBasicParsing -TimeoutSec 5
        if ($r.StatusCode -eq 200) { $ollamaUp = $true }
    } catch {}
}
Write-Host "[3/9] Ollama: $(if ($ollamaUp) {'UP'} else {'FAIL'})"
if (-not $ollamaUp) { Write-Host "  ⚠ Ollama 起動失敗。手動で 'ollama serve' を実行してください" -ForegroundColor Red }

# 4. Lock files 削除
@(".worker-heavy.lock", ".worker-light.lock", ".worker-any.lock") | ForEach-Object {
    Remove-Item "$queue\$_" -Force -ErrorAction SilentlyContinue
}
Write-Host "[4/9] Locks cleared"

# 5. Brain* scheduler を Enable
# 除外リスト (デフォルトで止めるべきもの)
$keepDisabled = @(
    "BrainNewbizSeed",     # 新規事業開拓は終了
    "BrainNewbizAdvance",
    "BrainIdleFiller",     # 主力5に絞ったので不要
    "BrainDevFiller",      # 現状不要
    "BrainCorpFiller",     # 現状不要
    "BrainCSFiller"        # 現状不要
)
$enabledCount = 0
Get-ScheduledTask | Where-Object { $_.TaskName -match '^Brain' } | ForEach-Object {
    if ($_.TaskName -in $keepDisabled) {
        Disable-ScheduledTask -TaskName $_.TaskName -ErrorAction SilentlyContinue | Out-Null
    } else {
        if ($_.State -eq 'Disabled') {
            try { Enable-ScheduledTask -TaskName $_.TaskName -ErrorAction SilentlyContinue | Out-Null; $enabledCount++ } catch {}
        }
    }
}
Write-Host "[5/9] Schedulers enabled ($enabledCount activated)"

# 6. Dashboard 起動確認
$dashUp = $false
try {
    $r = Invoke-WebRequest -Uri "http://localhost:7777/api/status" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
    if ($r.StatusCode -eq 200) { $dashUp = $true }
} catch {}
if (-not $dashUp) {
    $old = Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*dashboard_server*" }
    if ($old) { Stop-Process -Id $old.ProcessId -Force -ErrorAction SilentlyContinue; Start-Sleep 2 }
    Start-Process node -ArgumentList "$brain\scripts\dashboard_server.js" -WindowStyle Hidden
    Start-Sleep 3
    try {
        $r = Invoke-WebRequest -Uri "http://localhost:7777/api/status" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($r.StatusCode -eq 200) { $dashUp = $true }
    } catch {}
}
Write-Host "[6/9] Dashboard: $(if ($dashUp) {'UP @ http://localhost:7777'} else {'starting...'})"

# 7. Worker kick (両レーン)
if ($ollamaUp) {
    $vbs = "$brain\scripts\silent_runner.vbs"
    Start-Process wscript -ArgumentList "//nologo `"$vbs`" `"$brain\scripts\worker.ps1`" heavy" -WindowStyle Hidden
    Start-Sleep 1
    Start-Process wscript -ArgumentList "//nologo `"$vbs`" `"$brain\scripts\worker.ps1`" light" -WindowStyle Hidden
    Write-Host "[7/9] Workers kicked (heavy + light)"
} else {
    Write-Host "[7/9] Worker kick skipped (Ollama down)"
}

# 8. 健全性チェック
Start-Sleep 5
$inbox = (Get-ChildItem "$queue\inbox" -File -Filter "*.json" -ErrorAction SilentlyContinue).Count
$proc = (Get-ChildItem "$queue\processing" -File -ErrorAction SilentlyContinue).Count
$vram = (nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>$null).Trim()
$readySched = (Get-ScheduledTask | Where-Object { $_.TaskName -match '^Brain' -and $_.State -eq 'Ready' }).Count

# Snapshot 照合
$diff = ""
if ($snap) {
    $inboxDiff = $inbox - $snap.inbox_count
    $diff = " (snapshot差分: inbox$(if ($inboxDiff -ge 0) {'+'} else {''})$inboxDiff)"
}

Write-Host "[8/9] Health check"
Write-Host "  inbox=$inbox processing=$proc VRAM=${vram}MB schedulers=$readySched$diff"

# 9. 完了
Write-Host "[9/9] Resume complete" -ForegroundColor Green
Write-Host ""
Write-Host "→ Dashboard: http://localhost:7777" -ForegroundColor Cyan
Write-Host "→ Pause: scripts\pause_brain.ps1"

# Snapshotは保持 (次のpauseで上書きされる)
