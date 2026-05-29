#requires -Version 5.1
# Morioka book OCR batch using tesseract (faster than easyocr)
# Output: C:\Users\Owner\business\brain\.local\morioka-ocr\page-NNNN.txt

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$tess = 'C:\Program Files\Tesseract-OCR\tesseract.exe'
$imgDir = 'C:\Users\Owner\Pictures\auto-screenshots-20260526-075018'
$outDir = 'C:\Users\Owner\business\brain\.local\morioka-ocr'
$logPath = "$outDir\_progress.log"

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory $outDir -Force | Out-Null }

$images = Get-ChildItem $imgDir -Filter '*.png' | Sort-Object Name
$total = $images.Count
Write-Host "Starting OCR: $total pages with tesseract jpn+eng"
"[$(Get-Date -Format 'HH:mm:ss')] start $total pages" | Add-Content $logPath -Encoding UTF8

$start = Get-Date
$skipped = 0
$processed = 0

for ($i = 0; $i -lt $total; $i++) {
    $img = $images[$i]
    $page = $img.BaseName
    $outBase = "$outDir\page-$page"
    $outTxt = "$outBase.txt"

    if (Test-Path $outTxt) {
        $skipped++
        continue
    }

    & $tess $img.FullName $outBase -l 'jpn+eng' 2>$null

    $processed++

    if (($i + 1) % 25 -eq 0) {
        $elapsed = (Get-Date) - $start
        $rate = if ($processed -gt 0) { $processed / $elapsed.TotalSeconds } else { 0 }
        $remain = $total - $i - 1
        $eta = if ($rate -gt 0) { [int]($remain / $rate) } else { 0 }
        $msg = "$(Get-Date -Format 'HH:mm:ss') progress $($i+1)/$total processed=$processed skipped=$skipped ETA=${eta}s"
        Write-Host $msg
        $msg | Add-Content $logPath -Encoding UTF8
    }
}

# Concatenate all into _all.txt
$allFile = "$outDir\_all.txt"
$sb = [System.Text.StringBuilder]::new()
Get-ChildItem $outDir -Filter 'page-*.txt' | Sort-Object Name | ForEach-Object {
    $null = $sb.AppendLine("`n`n===== $($_.BaseName.Substring(5)) =====`n")
    $null = $sb.AppendLine((Get-Content $_.FullName -Raw -Encoding UTF8))
}
[System.IO.File]::WriteAllText($allFile, $sb.ToString(), [System.Text.Encoding]::UTF8)

$elapsed = (Get-Date) - $start
$size = [int]((Get-Item $allFile).Length / 1KB)
Write-Host "DONE: $processed processed, $skipped skipped, ${size}KB total in $([int]$elapsed.TotalSeconds)s"
"$(Get-Date -Format 'HH:mm:ss') DONE processed=$processed skipped=$skipped size=${size}KB elapsed=$([int]$elapsed.TotalSeconds)s" | Add-Content $logPath -Encoding UTF8
