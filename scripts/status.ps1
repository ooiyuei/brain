#requires -Version 5.1
# Brain System リアルタイム状態表示
# 使い方: & scripts\status.ps1
# 連続更新: & scripts\status_live.ps1

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$now = Get-Date

# ===== Ollama情報 =====
$ollamaOk = $false
$loadedModels = @()
try {
    $r = Invoke-RestMethod -Uri "http://localhost:11434/api/ps" -TimeoutSec 3
    $ollamaOk = $true
    $loadedModels = $r.models
} catch {}

# ===== GPU情報 =====
$gpu = $null
try {
    $nvidia = nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>$null
    if ($nvidia) {
        $parts = $nvidia -split ","
        $gpu = @{
            Name = $parts[0].Trim()
            Util = [int]$parts[1].Trim()
            MemUsed = [int]$parts[2].Trim()
            MemTotal = [int]$parts[3].Trim()
        }
    }
} catch {}

# ===== Queue状況 =====
$inbox = Get-ChildItem (Join-Path $brainRoot "queue\inbox") -File -ErrorAction SilentlyContinue
$processing = Get-ChildItem (Join-Path $brainRoot "queue\processing") -File -ErrorAction SilentlyContinue
$todayDone = (Get-ChildItem (Join-Path $brainRoot "queue\done") -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime.Date -eq [DateTime]::Today }).Count
$failed = (Get-ChildItem (Join-Path $brainRoot "queue\failed") -File -ErrorAction SilentlyContinue).Count

# ===== Worker稼働中？ =====
$heavyLock = Test-Path (Join-Path $brainRoot "queue\.worker-heavy.lock")
$lightLock = Test-Path (Join-Path $brainRoot "queue\.worker-light.lock")
$anyLock = Test-Path (Join-Path $brainRoot "queue\.worker-any.lock")

# ===== メモリ使用率 =====
$memInfo = Get-CimInstance Win32_OperatingSystem
$memUsedPct = [Math]::Round(($memInfo.TotalVisibleMemorySize - $memInfo.FreePhysicalMemory) / $memInfo.TotalVisibleMemorySize * 100, 1)
$memUsedGB = [Math]::Round(($memInfo.TotalVisibleMemorySize - $memInfo.FreePhysicalMemory) / 1MB, 1)
$memTotalGB = [Math]::Round($memInfo.TotalVisibleMemorySize / 1MB, 1)

# ===== 直近のworker.log（heavy/light両方） =====
$lastLogLines = @()
@("worker-heavy.log", "worker-light.log", "worker-any.log") | ForEach-Object {
    $lp = Join-Path $brainRoot "queue\logs\$_"
    if (Test-Path $lp) {
        $lastLine = Get-Content $lp -Tail 1 -Encoding UTF8
        if ($lastLine) { $lastLogLines += "$_ : $lastLine" }
    }
}

# ===== 出力 =====
Clear-Host
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🧠 Brain System Status  [$(($now).ToString('HH:mm:ss'))]" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Ollama & loaded models
$ollamaStatus = if ($ollamaOk) { "🟢" } else { "🔴" }
Write-Host "🦙 Ollama: $ollamaStatus" -NoNewline
if ($loadedModels.Count -gt 0) {
    Write-Host " | Loaded models: $($loadedModels.Count)" -ForegroundColor Yellow
    foreach ($m in $loadedModels) {
        $sizeGB = [Math]::Round($m.size / 1GB, 1)
        $vramGB = if ($m.size_vram) { [Math]::Round($m.size_vram / 1GB, 1) } else { 0 }
        $until = if ($m.expires_at) {
            $expTime = [DateTime]::Parse($m.expires_at)
            $remMin = [int]($expTime - $now).TotalMinutes
            "expires ${remMin}min"
        } else { "" }
        Write-Host "  └ $($m.name) | ${sizeGB}GB total / ${vramGB}GB VRAM | $until" -ForegroundColor Green
    }
} else {
    Write-Host " | (no models loaded)" -ForegroundColor DarkGray
}
Write-Host ""

# GPU
if ($gpu) {
    $gpuBar = "█" * [int]($gpu.Util / 5) + "▒" * (20 - [int]($gpu.Util / 5))
    Write-Host "🎮 GPU ($($gpu.Name))" -ForegroundColor Magenta
    Write-Host "  Util: $gpuBar $($gpu.Util)%" -ForegroundColor Magenta
    Write-Host "  VRAM: $($gpu.MemUsed)MB / $($gpu.MemTotal)MB ($([Math]::Round($gpu.MemUsed / $gpu.MemTotal * 100, 1))%)" -ForegroundColor Magenta
    Write-Host ""
}

# Memory
$memBar = "█" * [int]($memUsedPct / 5) + "▒" * (20 - [int]($memUsedPct / 5))
Write-Host "💾 RAM: $memBar ${memUsedPct}% (${memUsedGB}GB / ${memTotalGB}GB)" -ForegroundColor Yellow
Write-Host ""

# Worker稼働状態
Write-Host "⚙️  Workers:" -ForegroundColor Cyan
$heavyStatus = if ($heavyLock) { "🟢 RUNNING" } else { "⚪ idle" }
$lightStatus = if ($lightLock) { "🟢 RUNNING" } else { "⚪ idle" }
Write-Host "  Heavy ($("qwen3.6:latest")): $heavyStatus"
Write-Host "  Light ($("qwen3:8b")):       $lightStatus"
Write-Host ""

# Queue
Write-Host "📦 Queue:" -ForegroundColor Cyan
Write-Host "  📥 inbox:      $($inbox.Count) 件"
Write-Host "  ⚙️  processing: $($processing.Count) 件"
Write-Host "  ✅ 今日完了:   $todayDone 件"
Write-Host "  ❌ failed:     $failed 件"
Write-Host ""

# 処理中タスク詳細
if ($processing.Count -gt 0) {
    Write-Host "🔄 処理中:" -ForegroundColor Yellow
    foreach ($p in $processing) {
        try {
            $j = Get-Content $p.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            $age = [int]((Get-Date) - $p.LastWriteTime).TotalSeconds
            Write-Host "  ⚡ [$age 秒] $($j.title)" -ForegroundColor Yellow
        } catch {}
    }
    Write-Host ""
}

# 直近のworker活動
if ($lastLogLines.Count -gt 0) {
    Write-Host "📜 直近ログ:" -ForegroundColor DarkCyan
    foreach ($l in $lastLogLines) {
        Write-Host "  $l" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# 稼働判定
$isBusy = ($processing.Count -gt 0) -or ($loadedModels.Count -gt 0) -or $heavyLock -or $lightLock
if ($isBusy) {
    Write-Host "🔥 状態: 稼働中" -ForegroundColor Green
} else {
    Write-Host "💤 状態: アイドル（タスク投入待ち）" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  更新: $(($now).ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor DarkGray
