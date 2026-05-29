#requires -Version 5.1
# auto_review.ps1 が生成したレビュー結果（_reviews/）を解析して
# PROMOTE → wiki/_promoted/ / ARCHIVE → wiki/_inbox/_archive/ に自動移動
# PDCA最終ステップを閉じる

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$inboxDir = Join-Path $brainRoot "wiki\_inbox"
$reviewsDir = Join-Path $inboxDir "_reviews"
$promotedDir = Join-Path $brainRoot "wiki\_promoted"
$archiveDir = Join-Path $inboxDir "_archive"
$reviewedArchive = Join-Path $reviewsDir "_processed"
$logPath = Join-Path $brainRoot "scripts\auto_promote.log"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

@($promotedDir, $archiveDir, $reviewedArchive) | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

if (-not (Test-Path $reviewsDir)) {
    "$nowStamp - no reviews dir, exit" | Add-Content $logPath -Encoding UTF8
    exit 0
}

$promoted = 0; $archived = 0; $kept = 0; $skipped = 0

# _processed以外のreview ファイルを巡回
Get-ChildItem $reviewsDir -Directory | Where-Object { $_.Name -ne "_processed" } | ForEach-Object {
    $dept = $_.Name

    Get-ChildItem $_.FullName -File -Filter "*-review.md" -ErrorAction SilentlyContinue | ForEach-Object {
        $reviewFile = $_

        # 30分以上経過したものだけ処理（安定性確保）
        $age = ((Get-Date) - $reviewFile.LastWriteTime).TotalMinutes
        if ($age -lt 30) {
            $skipped++
            return
        }

        try {
            $content = [System.IO.File]::ReadAllText($reviewFile.FullName, [System.Text.Encoding]::UTF8)

            # SCORE と DECISION を正規表現抽出
            $scoreMatch = [regex]::Match($content, 'SCORE:\s*(\d+)\s*/\s*50')
            $decisionMatch = [regex]::Match($content, 'DECISION:\s*(PROMOTE|KEEP|ARCHIVE)')

            if (-not $decisionMatch.Success) {
                "$nowStamp - skip (no decision): $($reviewFile.Name)" | Add-Content $logPath -Encoding UTF8
                $skipped++
                return
            }

            $score = if ($scoreMatch.Success) { [int]$scoreMatch.Groups[1].Value } else { 0 }
            $decision = $decisionMatch.Groups[1].Value.ToUpper()

            # 元ファイル名を逆算
            $origName = $reviewFile.BaseName -replace '-review$', '.md'
            $origPath = Join-Path $inboxDir "$dept\$origName"

            # _inbox直下になければ拡張検索 (Recurrent Pipelineと同じパターン)
            if (-not (Test-Path $origPath)) {
                $searchPaths = @(
                    "$promotedDir\$dept\$origName",
                    "$archiveDir\$dept\$origName"
                )
                $found = $searchPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
                if ($found) {
                    "$nowStamp - already moved: $dept/$origName (at $(Split-Path $found -Parent | Split-Path -Leaf))" | Add-Content $logPath -Encoding UTF8
                    # review は _processed へ
                    $procDeptDir = Join-Path $reviewedArchive $dept
                    if (-not (Test-Path $procDeptDir)) { New-Item -ItemType Directory -Path $procDeptDir -Force | Out-Null }
                    Move-Item $reviewFile.FullName (Join-Path $procDeptDir $reviewFile.Name) -Force
                    $skipped++
                    return
                }
                # 再帰検索 fallback
                $hit = Get-ChildItem $inboxDir -Recurse -File -Filter $origName -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($hit) {
                    $origPath = $hit.FullName
                } else {
                    "$nowStamp - skip (original missing everywhere): $($reviewFile.Name)" | Add-Content $logPath -Encoding UTF8
                    $skipped++
                    return
                }
            }

            switch ($decision) {
                "PROMOTE" {
                    $destDir = Join-Path $promotedDir $dept
                    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                    Move-Item $origPath (Join-Path $destDir $origName) -Force
                    "$nowStamp - PROMOTE [$score]: $dept/$origName" | Add-Content $logPath -Encoding UTF8
                    $promoted++
                }
                "ARCHIVE" {
                    $destDir = Join-Path $archiveDir $dept
                    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                    Move-Item $origPath (Join-Path $destDir $origName) -Force
                    "$nowStamp - ARCHIVE [$score]: $dept/$origName" | Add-Content $logPath -Encoding UTF8
                    $archived++
                }
                "KEEP" {
                    "$nowStamp - KEEP [$score]: $dept/$origName" | Add-Content $logPath -Encoding UTF8
                    $kept++
                    # KEEPは元ファイルそのまま、reviewファイルだけ処理済みに移動
                }
            }

            # review ファイル自体を _processed/ に移動
            $procDeptDir = Join-Path $reviewedArchive $dept
            if (-not (Test-Path $procDeptDir)) { New-Item -ItemType Directory -Path $procDeptDir -Force | Out-Null }
            Move-Item $reviewFile.FullName (Join-Path $procDeptDir $reviewFile.Name) -Force

        } catch {
            "$nowStamp - ERROR processing $($reviewFile.Name): $($_.Exception.Message)" | Add-Content $logPath -Encoding UTF8
        }
    }
}

$summary = "promote=$promoted archive=$archived keep=$kept skip=$skipped"
"$nowStamp - SUMMARY $summary" | Add-Content $logPath -Encoding UTF8

# Discord通知（変動あった時のみ）
if (($promoted + $archived) -gt 0) {
    $body = "✅ PROMOTE: $promoted 件 (wiki/_promoted/ へ昇格)`n🗑 ARCHIVE: $archived 件 (廃棄)`n📌 KEEP: $kept 件 (要編集)"
    & "$brainRoot\scripts\notify.ps1" -From Claude -Title "🔄 PDCA 自動整理完了" -Body $body -Color green
}

Write-Host "auto_promote: $summary"
