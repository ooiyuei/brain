#requires -Version 5.1
<#
.SYNOPSIS
    OpenClawが生成した results/{部署}/*.md を wiki/_inbox/{部署}/ に整理流し込み。
    Claudeエージェントが定期的にレビューし、正式ページへ昇格させる前段階。

.DESCRIPTION
    1時間に1回スケジューラから実行される想定。
    既に output_path 指定で直接書かれているものはここでは触らない。
    output_path未指定の results/{部署}/*.md だけが対象。
#>

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$resultsRoot = Join-Path $brainRoot "queue\results"
$wikiInbox = Join-Path $brainRoot "wiki\_inbox"
$archiveRoot = Join-Path $brainRoot "queue\results\_archive"
$logPath = Join-Path $brainRoot "scripts\harvest.log"

function Write-HarvestLog {
    param([string]$msg)
    $stamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$stamp $msg" | Add-Content $logPath -Encoding UTF8
}

$departments = @("research","newbiz","dev","marketing","corp","secretary","misc")
$totalMoved = 0

foreach ($dep in $departments) {
    $srcDir = Join-Path $resultsRoot $dep
    if (-not (Test-Path $srcDir)) { continue }

    $dstDir = Join-Path $wikiInbox $dep
    $archDir = Join-Path $archiveRoot $dep
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
    if (-not (Test-Path $archDir)) { New-Item -ItemType Directory -Force -Path $archDir | Out-Null }

    $files = Get-ChildItem $srcDir -Filter "*.md" -File -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        try {
            $dstPath = Join-Path $dstDir $f.Name
            $archPath = Join-Path $archDir $f.Name

            Copy-Item $f.FullName $dstPath -Force
            Move-Item $f.FullName $archPath -Force

            $totalMoved++
            Write-HarvestLog "Moved: $dep/$($f.Name)"
        } catch {
            Write-HarvestLog "Error: $dep/$($f.Name) - $($_.Exception.Message)"
        }
    }
}

Write-HarvestLog "Harvest complete: $totalMoved files moved"
