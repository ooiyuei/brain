#requires -Version 5.1
<#
.SYNOPSIS
  脳の「consolidation(海馬→新皮質の整理)」のうち機械的にできる部分。
  wiki/_inbox/{部署}/ の (1)日付違い重複クラスタ=最新1本だけ残す (2)エラースタブ/極小ファイル を _archive へ退避。
  LLM判断不要・スケジューラ単独で動く(Claudeセッション不要=真の24/7)。
  破壊なし: 全て move(_archive 配下)。-Apply 無しは dry-run。
.NOTES
  2026-06-07 PDCA cycle1: dream_consolidationが要約しかせず_inboxが溜まる問題への機械的対策。
#>
param([switch]$Apply)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$inbox = Join-Path $brain "wiki\_inbox"
$archRoot = Join-Path $inbox "_archive"
$junkRoot = Join-Path $archRoot "_junk"
$log = Join-Path $brain "scripts\consolidate_inbox.log"
$depts = @("research","newbiz","dev","marketing","corp","secretary","misc")
$errPatterns = @("Context overflow","just came online","I just came online","資料を読み込みました","整理する準備","ちょっと混雑","として整理します。$")
$mode = if ($Apply) { "APPLY" } else { "DRY-RUN" }

function ClusterKey([string]$name) {
    $k = $name -replace '\.md$',''
    # 最初の日付トークン(YYYYMMDD or YYYY-MM-DD)以降を除去してクラスタ名にする
    $k = [regex]::Replace($k, '([-_])?(\d{8}|\d{4}-\d{2}-\d{2})([-_].*)?$', '')
    return $k.Trim(@('-','_',' '))
}

if ($Apply) {
    if (-not (Test-Path $junkRoot)) { New-Item -ItemType Directory -Force -Path $junkRoot | Out-Null }
}

$movedDup = 0; $movedJunk = 0; $report = @()
foreach ($d in $depts) {
    $dir = Join-Path $inbox $d
    if (-not (Test-Path $dir)) { continue }

    # --- pass1: junk(極小 or エラースタブ) ---
    $files = @(Get-ChildItem $dir -Filter *.md -File -ErrorAction SilentlyContinue)
    foreach ($f in $files) {
        $isJunk = $false; $why = ""
        if ($f.Length -lt 330) { $isJunk = $true; $why = "tiny($($f.Length)B)" }
        else {
            $head = (Get-Content $f.FullName -TotalCount 12 -Raw -ErrorAction SilentlyContinue)
            foreach ($p in $errPatterns) { if ($head -match $p) { $isJunk = $true; $why = "errstub:$p"; break } }
        }
        if ($isJunk) {
            $report += "JUNK [$d] $($f.Name) ($why)"
            if ($Apply) { Move-Item $f.FullName (Join-Path $junkRoot $f.Name) -Force -ErrorAction SilentlyContinue }
            $movedJunk++
        }
    }

    # --- pass2: 日付違い重複クラスタ → 最新だけ残す ---
    $files = @(Get-ChildItem $dir -Filter *.md -File -ErrorAction SilentlyContinue)
    $groups = $files | Group-Object { ClusterKey $_.Name }
    foreach ($g in $groups) {
        if ($g.Count -le 1) { continue }
        $keep = $g.Group | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $old = $g.Group | Where-Object { $_.FullName -ne $keep.FullName }
        $archDir = Join-Path $archRoot $d
        if ($Apply -and -not (Test-Path $archDir)) { New-Item -ItemType Directory -Force -Path $archDir | Out-Null }
        foreach ($o in $old) {
            $report += "DUP  [$d] keep='$($keep.Name)' archive='$($o.Name)'"
            if ($Apply) { Move-Item $o.FullName (Join-Path $archDir $o.Name) -Force -ErrorAction SilentlyContinue }
            $movedDup++
        }
    }
}

$stamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$summary = "$stamp [$mode] consolidate: dup=$movedDup junk=$movedJunk"
$summary | Add-Content $log -Encoding UTF8
Write-Host $summary
$report | ForEach-Object { Write-Host "  $_" }
