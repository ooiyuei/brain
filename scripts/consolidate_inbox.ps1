#requires -Version 5.1
# Mechanical memory-consolidation for wiki/_inbox (ASCII-only source for PS5.1 safety).
# (1) dedup dated-version clusters -> keep newest only, archive the rest
# (2) quarantine tiny/error-stub files
# LLM-free, runs standalone via scheduler (no live Claude needed = true 24/7).
# Non-destructive: everything is moved under _archive. No -Apply = dry-run.
# 2026-06-07 PDCA cycle1: dream_consolidation only summarized; _inbox kept piling.
param([switch]$Apply)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$inbox = Join-Path $brain "wiki\_inbox"
$archRoot = Join-Path $inbox "_archive"
$junkRoot = Join-Path $archRoot "_junk"
$log = Join-Path $brain "scripts\consolidate_inbox.log"
$depts = @("research","newbiz","dev","marketing","corp","secretary","misc")
$errPatterns = @("Context overflow","just came online","prompt too large","just woke up","tmp-write","```$")
$mode = if ($Apply) { "APPLY" } else { "DRY-RUN" }

function ClusterKey([string]$name) {
    $k = $name -replace '\.md$',''
    # strip first date token (YYYYMMDD or YYYY-MM-DD) and everything after -> cluster name
    $k = [regex]::Replace($k, '([-_])?(\d{8}|\d{4}-\d{2}-\d{2})([-_].*)?$', '')
    return $k.Trim(@('-','_',' '))
}

if ($Apply -and -not (Test-Path $junkRoot)) { New-Item -ItemType Directory -Force -Path $junkRoot | Out-Null }

$movedDup = 0; $movedJunk = 0; $report = @()
foreach ($d in $depts) {
    $dir = Join-Path $inbox $d
    if (-not (Test-Path $dir)) { continue }

    # pass1: junk = tiny or error-stub
    $files = @(Get-ChildItem $dir -Filter *.md -File -ErrorAction SilentlyContinue)
    foreach ($f in $files) {
        $isJunk = $false; $why = ""
        if ($f.Length -lt 330) { $isJunk = $true; $why = ("tiny-" + $f.Length + "B") }
        else {
            $head = ((Get-Content $f.FullName -TotalCount 12 -ErrorAction SilentlyContinue) -join "`n")
            foreach ($p in $errPatterns) { if ($head -match $p) { $isJunk = $true; $why = ("errstub-" + $p); break } }
        }
        if ($isJunk) {
            $report += ("JUNK [" + $d + "] " + $f.Name + " (" + $why + ")")
            if ($Apply) { Move-Item $f.FullName (Join-Path $junkRoot $f.Name) -Force -ErrorAction SilentlyContinue }
            $movedJunk++
        }
    }

    # pass2: dated-version duplicates -> keep newest
    $files = @(Get-ChildItem $dir -Filter *.md -File -ErrorAction SilentlyContinue)
    $groups = $files | Group-Object { ClusterKey $_.Name }
    foreach ($g in $groups) {
        if ($g.Count -le 1) { continue }
        $keep = $g.Group | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $old = $g.Group | Where-Object { $_.FullName -ne $keep.FullName }
        $archDir = Join-Path $archRoot $d
        if ($Apply -and -not (Test-Path $archDir)) { New-Item -ItemType Directory -Force -Path $archDir | Out-Null }
        foreach ($o in $old) {
            $report += ("DUP  [" + $d + "] keep=" + $keep.Name + " | archive=" + $o.Name)
            if ($Apply) { Move-Item $o.FullName (Join-Path $archDir $o.Name) -Force -ErrorAction SilentlyContinue }
            $movedDup++
        }
    }
}

$stamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$summary = ($stamp + " [" + $mode + "] consolidate: dup=" + $movedDup + " junk=" + $movedJunk)
$summary | Add-Content $log -Encoding UTF8
Write-Host $summary
$report | ForEach-Object { Write-Host ("  " + $_) }
