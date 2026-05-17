# daily_brain.ps1
# 大井湧瑛のブレイン日報自動生成スクリプト
# Windowsタスクスケジューラから毎日23:00に呼ばれる
# Claude Code CLI を非対話モード (-p) で呼び出して要約

$ErrorActionPreference = "Continue"
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$today = Get-Date -Format "yyyy-MM-dd"
$nowStamp = (Get-Date).ToString('yyyy-MM-dd HH:mm')
$brainDir = "C:\Users\Owner\business\brain"
$dailyPath = Join-Path $brainDir "wiki\daily\$today.md"
$logPath = Join-Path $brainDir "scripts\daily_brain.log"
$claudeExe = "$env:APPDATA\Claude\claude-code\2.1.142\claude.exe"

function Write-Log {
    param([string]$msg)
    "$([DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss')) $msg" | Add-Content -Path $logPath -Encoding UTF8
}

Write-Log "=== Daily Brain Start ($today) ==="

if (-not (Test-Path $claudeExe)) {
    Write-Log "ERROR: Claude CLI not found at $claudeExe. Searching..."
    $claudeExe = (Get-ChildItem -Path "$env:APPDATA\Claude\claude-code" -Filter "claude.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
    if (-not $claudeExe) {
        Write-Log "FATAL: Claude CLI not found anywhere. Aborting."
        exit 1
    }
    Write-Log "Found Claude CLI at $claudeExe"
}

# 1. 今日のセッションログを集める
$sessionRoot = "$env:USERPROFILE\.claude\projects"
$todayLogs = Get-ChildItem -Path $sessionRoot -Filter "*.jsonl" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime.Date -eq [DateTime]::Today }

if (-not $todayLogs) {
    Write-Log "No session logs today. Writing empty daily."
    $emptyContent = @"
---
type: daily
date: $today
sessions: 0件
created: $nowStamp
---

# 日報 $today

今日のセッションなし

---
*自動生成: daily_brain.ps1*
"@
    Set-Content -Path $dailyPath -Value $emptyContent -Encoding UTF8
    exit 0
}

Write-Log "Found $($todayLogs.Count) session log(s) today"

# 2. user/assistant メッセージのテキスト部分のみ抽出
$transcriptLines = @()
foreach ($log in $todayLogs) {
    try {
        $lines = Get-Content -Path $log.FullName -Encoding UTF8
        foreach ($line in $lines) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            try {
                $obj = $line | ConvertFrom-Json -ErrorAction Stop
                if ($obj.type -ne "user" -and $obj.type -ne "assistant") { continue }
                $role = $obj.type
                $content = ""
                if ($obj.message.content -is [string]) {
                    $content = $obj.message.content
                } elseif ($obj.message.content) {
                    $textParts = @()
                    foreach ($part in $obj.message.content) {
                        if ($part.type -eq "text" -and $part.text) {
                            $textParts += $part.text
                        }
                    }
                    $content = $textParts -join "`n"
                }
                if (-not [string]::IsNullOrWhiteSpace($content)) {
                    # システムリマインダー除外
                    if ($content -match "^<system-reminder>") { continue }
                    if ($content -match "^<command-name>") { continue }
                    # ツール結果系の長すぎる出力をトリム
                    $short = if ($content.Length -gt 1500) { $content.Substring(0, 1500) + "...[truncated]" } else { $content }
                    $transcriptLines += "[$role] $short"
                }
            } catch {
                # JSON parse失敗は無視
            }
        }
    } catch {
        Write-Log "Error reading $($log.FullName): $_"
    }
}

$msgCount = $transcriptLines.Count
Write-Log "Extracted $msgCount messages"

if ($msgCount -eq 0) {
    $emptyContent = @"
---
type: daily
date: $today
sessions: 0件（抽出失敗）
created: $nowStamp
---

# 日報 $today

セッションログはあったが、ユーザー/アシスタント発話の抽出に失敗。

---
*自動生成: daily_brain.ps1*
"@
    Set-Content -Path $dailyPath -Value $emptyContent -Encoding UTF8
    exit 0
}

$transcript = $transcriptLines -join "`n`n"

# 大きすぎる場合は末尾のみ（最新の会話を優先）
$maxChars = 60000
if ($transcript.Length -gt $maxChars) {
    $transcript = "...（前半省略）`n`n" + $transcript.Substring($transcript.Length - $maxChars)
    Write-Log "Transcript truncated to last $maxChars chars"
}

# 3. Claude CLIで要約
$prompt = @"
以下は$($today)の大井湧瑛のClaude Code全セッションログです。これを「ブレイン日報」形式で要約してください。

【出力形式】必ず以下のテンプレに従う。前置き不要、いきなりフロントマターから出力する：

---
type: daily
date: $today
sessions: $($msgCount)件のメッセージ
created: $nowStamp
---

# 日報 $today

## 今日やったこと（時系列順 3〜7項目）
- ...

## 意思決定・方針確定
- ...

## ブレインに追加・更新された情報
- ...

## 残課題・明日への引き継ぎ
- ...

## 数字・KPI・固有名詞
- ...

---
*自動生成: daily_brain.ps1*

【ルール】
- 事実ベースのみ。推測や脚色は禁止
- 数字・固有名詞・日付は正確に
- 雑談・キャッチアップ系は要約から除外
- 各セクション該当なしなら「なし」と書く
- 大井のプロジェクト名（Testall, Gymee, AIpaX, AIpa Web, FishOps, AOF, EEMUS, IPAK, EcoKan, OMNI）は正確に

【会話ログ】
$transcript
"@

# プロンプトを一時ファイルへ
$promptFile = Join-Path $env:TEMP "daily_brain_prompt_$today.txt"
Set-Content -Path $promptFile -Value $prompt -Encoding UTF8

Write-Log "Calling Claude CLI (-p mode)..."
$summary = $null
try {
    # stdin経由でプロンプト送信
    $summary = Get-Content -Path $promptFile -Raw | & $claudeExe -p --model sonnet 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Claude CLI exit code: $LASTEXITCODE"
    }
} catch {
    Write-Log "Claude CLI exception: $_"
}

if ($summary -and $summary.Trim().Length -gt 100) {
    Set-Content -Path $dailyPath -Value $summary.Trim() -Encoding UTF8
    Write-Log "Daily report saved to $dailyPath ($($summary.Length) chars)"
} else {
    # フォールバック：素のログ末尾を保存
    $fallbackTail = if ($transcript.Length -gt 4000) { $transcript.Substring($transcript.Length - 4000) } else { $transcript }
    $fallback = @"
---
type: daily
date: $today
sessions: $($msgCount)件のメッセージ
created: $nowStamp
status: fallback (Claude CLI 要約失敗)
---

# 日報 $today

要約失敗。素のログ末尾を保存。明日手動補完してください。

## 会話末尾抜粋
``````
$fallbackTail
``````

---
*自動生成: daily_brain.ps1 (fallback)*
"@
    Set-Content -Path $dailyPath -Value $fallback -Encoding UTF8
    Write-Log "FALLBACK: saved raw transcript tail"
}

Remove-Item -Path $promptFile -ErrorAction SilentlyContinue
Write-Log "=== Daily Brain Done ==="
