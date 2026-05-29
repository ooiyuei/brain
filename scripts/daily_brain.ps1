$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$today = Get-Date -Format "yyyy-MM-dd"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")
$brainDir = "C:\Users\Owner\business\brain"
$dailyPath = Join-Path $brainDir "wiki\daily\$today.md"
$logPath = Join-Path $brainDir "scripts\daily_brain.log"
$ollamaUrl = "http://localhost:11434/api/generate"
$ollamaModel = "qwen3.6:latest"

function Write-Log { param([string]$msg); "$([DateTime]::Now.ToString("HH:mm:ss")) $msg" | Add-Content $logPath -Encoding UTF8 }
Write-Log "=== Start $today ==="

$health = Invoke-RestMethod -Uri "http://localhost:11434/" -TimeoutSec 5
Write-Log "Ollama OK"

$sessionRoot = "$env:USERPROFILE\.claude\projects"
$todayLogs = Get-ChildItem -Path $sessionRoot -Filter "*.jsonl" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime.Date -eq [DateTime]::Today }

if (-not $todayLogs) {
    Write-Log "No logs today"
    "# 日報 $today`n`nセッションなし" | Set-Content $dailyPath -Encoding UTF8
    exit 0
}

$lines = [System.Collections.Generic.List[string]]::new()
foreach ($log in $todayLogs) {
    $raw = Get-Content $log.FullName -Encoding UTF8
    foreach ($line in $raw) {
        $obj = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
        if (-not $obj) { continue }
        if ($obj.type -ne "user" -and $obj.type -ne "assistant") { continue }
        $text = ""
        if ($obj.message.content -is [string]) {
            $text = $obj.message.content
        } else {
            $parts = $obj.message.content | Where-Object { $_.type -eq "text" } | Select-Object -ExpandProperty text
            $text = $parts -join " "
        }
        if ($text.Length -lt 5) { continue }
        if ($text -match "^<system") { continue }
        $short = $text.Substring(0, [Math]::Min($text.Length, 800))
        $lines.Add("[$($obj.type)] $short")
    }
}

Write-Log "$($lines.Count) messages extracted"

if ($lines.Count -eq 0) {
    "# 日報 $today`n`n抽出失敗" | Set-Content $dailyPath -Encoding UTF8
    exit 0
}

$joined = $lines -join "`n`n"
$transcript = $joined.Substring(0, [Math]::Min($joined.Length, 40000))

$prompt = "以下は${today}の大井湧瑛のAI作業ログです。日本語で日報にまとめてください。今日やったこと・意思決定・残課題を箇条書きで。`n`n$transcript"

$bodyObj = [ordered]@{
    model = $ollamaModel
    prompt = $prompt
    stream = $false
    think = $false
    options = [ordered]@{ temperature = 0.3; num_predict = 4000 }
}
$bodyJson = $bodyObj | ConvertTo-Json -Depth 5

Write-Log "Calling Ollama..."
$resp = Invoke-RestMethod -Uri $ollamaUrl -Method Post -Body $bodyJson -ContentType "application/json; charset=utf-8" -TimeoutSec 300
$summary = $resp.response
Write-Log "Got $($summary.Length) chars"

$header = "---`ntype: daily`ndate: $today`ncreated: $nowStamp`n---`n`n# 日報 $today`n`n"
($header + $summary) | Set-Content $dailyPath -Encoding UTF8
Write-Log "Saved: $dailyPath"
Write-Log "=== Done ==="