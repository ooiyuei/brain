#requires -Version 5.1
# Continuous supply engine (ASCII-only for PS5.1). Keeps the GPU genuinely busy with VARIED real work.
# If queue (inbox+processing) < Target, dispatch Batch tasks from standing_tasks.json via a rotating pointer.
# Safe by construction: every dispatch passes dispatch.ps1 -> backpressure(150) + dedup(12h) + cost-guard(daily cap).
# Priority=late (light lane, never blocks priority work). 2026-06-07 PDCA cycle8: fix "GPU idle for hours" (sparse generation).
param([int]$Target = 4, [int]$Batch = 4)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
if (Test-Path "$brain\queue\.paused") { exit 0 }
$log = "$brain\scripts\queue_keeper.log"
$stamp0 = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

$inbox = @(Get-ChildItem "$brain\queue\inbox" -Filter *.json -File -ErrorAction SilentlyContinue).Count
$proc  = @(Get-ChildItem "$brain\queue\processing" -Filter *.json -File -ErrorAction SilentlyContinue).Count
if (($inbox + $proc) -ge $Target) {
    "$stamp0 keeper: queue=$($inbox+$proc) >= target $Target -> skip" | Add-Content $log -Encoding UTF8
    exit 0
}

$bankFile = "$brain\scripts\standing_tasks.json"
if (-not (Test-Path $bankFile)) { "$stamp0 keeper: no standing_tasks.json" | Add-Content $log -Encoding UTF8; exit 0 }
$bank = Get-Content $bankFile -Raw -Encoding UTF8 | ConvertFrom-Json
$tasks = @($bank.tasks)
if ($tasks.Count -eq 0) { exit 0 }

$ptrFile = "$brain\scripts\.keeper_ptr.txt"
$ptr = 0
if (Test-Path $ptrFile) { try { $ptr = [int]((Get-Content $ptrFile -Raw).Trim()) } catch { $ptr = 0 } }

$dispatcher = "$brain\scripts\dispatch.ps1"
$n = 0
for ($i = 0; $i -lt $Batch; $i++) {
    $t = $tasks[(($ptr + $i) % $tasks.Count)]
    $stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
    $sid = [guid]::NewGuid().ToString().Substring(0, 4)
    $slug = ($t.title -replace '[^\w]', '-').ToLower(); if ($slug.Length -gt 40) { $slug = $slug.Substring(0, 40) }
    $out = "$brain\wiki\_inbox\$($t.department)\keep-$slug-$stamp-$sid.md"
    & $dispatcher -Department $t.department -Title $t.title -Prompt $t.prompt -Model "qwen3:8b" -OutputPath $out -Priority "late" 2>&1 | Out-Null
    $n++
}
$newptr = (($ptr + $Batch) % $tasks.Count)
[System.IO.File]::WriteAllText($ptrFile, [string]$newptr)
"$stamp0 keeper: queue=$($inbox+$proc) dispatched=$n ptr=$ptr->$newptr (guard/dedup may skip some)" | Add-Content $log -Encoding UTF8
Write-Host "queue_keeper: dispatched=$n ptr=$ptr->$newptr"
