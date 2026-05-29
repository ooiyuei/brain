#requires -Version 5.1
# 1分おきに wiki/live-status.md を更新（Obsidianで見える状態）

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$outPath = Join-Path $brainRoot "wiki\live-status.md"
$now = Get-Date
$utf8 = [System.Text.UTF8Encoding]::new($false)

# 同じ情報を取得（status.ps1から流用）
$ollamaOk = $false
$loadedModels = @()
try {
    $r = Invoke-RestMethod -Uri "http://localhost:11434/api/ps" -TimeoutSec 3
    $ollamaOk = $true
    $loadedModels = $r.models
} catch {}

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

$inbox = Get-ChildItem (Join-Path $brainRoot "queue\inbox") -File -ErrorAction SilentlyContinue
$processing = Get-ChildItem (Join-Path $brainRoot "queue\processing") -File -ErrorAction SilentlyContinue
$todayDone = (Get-ChildItem (Join-Path $brainRoot "queue\done") -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime.Date -eq [DateTime]::Today }).Count

$heavyLock = Test-Path (Join-Path $brainRoot "queue\.worker-heavy.lock")
$lightLock = Test-Path (Join-Path $brainRoot "queue\.worker-light.lock")

$memInfo = Get-CimInstance Win32_OperatingSystem
$memUsedPct = [Math]::Round(($memInfo.TotalVisibleMemorySize - $memInfo.FreePhysicalMemory) / $memInfo.TotalVisibleMemorySize * 100, 1)
$memUsedGB = [Math]::Round(($memInfo.TotalVisibleMemorySize - $memInfo.FreePhysicalMemory) / 1MB, 1)
$memTotalGB = [Math]::Round($memInfo.TotalVisibleMemorySize / 1MB, 1)

$isBusy = ($processing.Count -gt 0) -or ($loadedModels.Count -gt 0) -or $heavyLock -or $lightLock
$statusEmoji = if ($isBusy) { "🔥" } else { "💤" }
$statusText = if ($isBusy) { "稼働中" } else { "アイドル" }

# === MD出力 ===
$lines = @()
$lines += "---"
$lines += "type: live-status"
$lines += "updated: $($now.ToString('yyyy-MM-dd HH:mm:ss'))"
$lines += "tags: [live, status, monitoring]"
$lines += "---"
$lines += ""
$lines += "# $statusEmoji Brain Live Status"
$lines += ""
$lines += "**$($now.ToString('HH:mm:ss'))** | $statusEmoji **$statusText**"
$lines += ""
$lines += "## 🦙 Ollama"
$lines += ""
if ($ollamaOk) {
    $lines += "- 状態: 🟢 稼働中"
    $lines += "- ロード済みモデル: $($loadedModels.Count)"
    if ($loadedModels.Count -gt 0) {
        $lines += ""
        $lines += "| モデル | サイズ | VRAM | 残時間 |"
        $lines += "|---|---|---|---|"
        foreach ($m in $loadedModels) {
            $sizeGB = [Math]::Round($m.size / 1GB, 1)
            $vramGB = if ($m.size_vram) { [Math]::Round($m.size_vram / 1GB, 1) } else { 0 }
            $until = if ($m.expires_at) {
                $expTime = [DateTime]::Parse($m.expires_at)
                $remMin = [int]($expTime - $now).TotalMinutes
                "残${remMin}分"
            } else { "-" }
            $lines += "| $($m.name) | ${sizeGB}GB | ${vramGB}GB | $until |"
        }
    }
} else {
    $lines += "- 状態: 🔴 応答なし"
}
$lines += ""

# GPU
if ($gpu) {
    $lines += "## 🎮 GPU"
    $lines += ""
    $lines += "- **$($gpu.Name)**"
    $lines += "- 使用率: **$($gpu.Util)%**"
    $lines += "- VRAM: $($gpu.MemUsed)MB / $($gpu.MemTotal)MB (**$([Math]::Round($gpu.MemUsed / $gpu.MemTotal * 100, 1))%**)"
    $lines += ""
}

# Memory
$lines += "## 💾 RAM"
$lines += ""
$lines += "- 使用率: **${memUsedPct}%** (${memUsedGB}GB / ${memTotalGB}GB)"
if ($memUsedPct -lt 50) {
    $lines += "- ⚠️ 余裕あり（タスク投入したら効率UP）"
} elseif ($memUsedPct -gt 90) {
    $lines += "- 🔴 高負荷"
} else {
    $lines += "- ✅ 適正"
}
$lines += ""

# Workers
$lines += "## ⚙️ Workers"
$lines += ""
$lines += "- Heavy (qwen3.6:latest): " + $(if ($heavyLock) { "🟢 **稼働中**" } else { "⚪ idle" })
$lines += "- Light (qwen3:8b): " + $(if ($lightLock) { "🟢 **稼働中**" } else { "⚪ idle" })
$lines += ""

# Queue
$lines += "## 📦 Queue"
$lines += ""
$lines += "| 状態 | 件数 |"
$lines += "|---|---|"
$lines += "| 📥 inbox | $($inbox.Count) |"
$lines += "| ⚙️ processing | $($processing.Count) |"
$lines += "| ✅ 今日完了 | $todayDone |"
$lines += ""

# 処理中タスク
if ($processing.Count -gt 0) {
    $lines += "## 🔄 処理中タスク"
    $lines += ""
    foreach ($p in $processing) {
        try {
            $j = Get-Content $p.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            $age = [int]((Get-Date) - $p.LastWriteTime).TotalSeconds
            $lines += "- ⚡ [$age 秒経過] **$($j.title)**"
        } catch {}
    }
    $lines += ""
}

# inbox上位
if ($inbox.Count -gt 0) {
    $lines += "## 📥 待機タスク (上位5)"
    $lines += ""
    $inbox | Sort-Object Name | Select-Object -First 5 | ForEach-Object {
        try {
            $j = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            $lines += "- [$($j.priority)] $($j.title)"
        } catch {}
    }
    $lines += ""
}

$lines += "## 🎯 判定"
$lines += ""
if ($isBusy) {
    $lines += "🔥 **OpenClaw稼働中** — タスク処理してます"
} else {
    if ($inbox.Count -eq 0) {
        $lines += "💤 **アイドル** — タスク無し。idle_filler.ps1 が次のタスクを補充予定"
    } else {
        $lines += "⏳ **再開待ち** — inbox に $($inbox.Count) 件、次のworker起動で処理開始"
    }
}
$lines += ""

$lines += "---"
$lines += ""
$lines += "_このページは1分おきに自動更新（BrainLiveStatus）。最新を見るには Obsidian を再読み込み_"
$lines += ""
$lines += "**ターミナルで連続表示**: ``& C:\Users\Owner\business\brain\scripts\status_live.ps1``"

$content = $lines -join "`r`n"
[System.IO.File]::WriteAllText($outPath, $content, $utf8)
