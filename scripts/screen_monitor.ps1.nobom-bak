# 大井 PC スクリーンキャプチャ (30分毎)
# Scheduled Task: BrainScreenMonitor (30分毎)
# 保存先: _system/monitor/screens/YYYY-MM-DD/HHMM.png
# 重要: 大井の作業を Claude が把握するため + 後で「あの時何やってた?」を引けるため

param(
    [int]$QualityJpeg = 60,  # JPEG 圧縮率 (容量節約)
    [int]$MaxKeepDays = 7    # 7日以上前のスクショは削除
)

$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$brain = "C:\Users\Owner\business\brain"
$today = (Get-Date).ToString("yyyy-MM-dd")
$time = (Get-Date).ToString("HHmm")
$outDir = "$brain\_system\monitor\screens\$today"
$outPath = "$outDir\$time.jpg"

if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

# 全モニタを取得して合成キャプチャ
$screens = [System.Windows.Forms.Screen]::AllScreens
$totalBounds = [System.Drawing.Rectangle]::Empty
foreach ($s in $screens) {
    if ($totalBounds.IsEmpty) {
        $totalBounds = $s.Bounds
    } else {
        $totalBounds = [System.Drawing.Rectangle]::Union($totalBounds, $s.Bounds)
    }
}

$bmp = New-Object System.Drawing.Bitmap $totalBounds.Width, $totalBounds.Height
$gfx = [System.Drawing.Graphics]::FromImage($bmp)
$gfx.CopyFromScreen($totalBounds.X, $totalBounds.Y, 0, 0, $bmp.Size)

# JPEG で保存 (圧縮)
$encoders = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()
$jpegEncoder = $encoders | Where-Object { $_.FormatID -eq [System.Drawing.Imaging.ImageFormat]::Jpeg.Guid }
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters 1
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$QualityJpeg)
$bmp.Save($outPath, $jpegEncoder, $encoderParams)

$gfx.Dispose()
$bmp.Dispose()

# 古いスクショ削除 (容量管理)
$cutoff = (Get-Date).AddDays(-$MaxKeepDays)
Get-ChildItem "$brain\_system\monitor\screens" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $dirDate = [DateTime]::ParseExact($_.Name, "yyyy-MM-dd", $null)
        if ($dirDate -lt $cutoff) {
            Remove-Item $_.FullName -Recurse -Force
            Write-Host "古いスクショ削除: $($_.Name)"
        }
    } catch {}
}

Write-Host "[screen] saved: $outPath"
