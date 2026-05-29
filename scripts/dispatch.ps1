#requires -Version 5.1
<#
.SYNOPSIS
    Claudeエージェントが部署別OpenClawにタスクを依頼する統一インターフェース。

.DESCRIPTION
    enqueue.ps1のラッパー。部署タグ・テンプレ参照・優先度を付与してqueue/inbox/に投入。
    各エージェント定義から呼ばれることを想定。

.PARAMETER Department
    依頼元部署: research / newbiz / dev / marketing / corp / secretary / misc

.PARAMETER Title
    タスクのタイトル（dashboard表示・通知に使用）

.PARAMETER Prompt
    OpenClawに渡すプロンプト本体（直接 or テンプレ展開後）

.PARAMETER Template
    使用するテンプレ名（templates/{Department}/{Template}.md）。
    指定するとテンプレ内容を Prompt にprependする。

.PARAMETER ContextFiles
    参照ファイル絶対パスの配列。worker.ps1が各ファイルから8000字までを文脈として注入。

.PARAMETER OutputPath
    結果書き込み先絶対パス（空ならresults/{Department}/{id}.mdのみに保存）。

.PARAMETER Model
    使用モデル（デフォルト qwen3.6:latest）。軽量で量産したい場合qwen3:8bを指定。

.PARAMETER Priority
    high / normal / low（デフォルトnormal）。タスクファイル名のprefixで処理順を制御。

.EXAMPLE
    .\dispatch.ps1 -Department research -Title "競合: Notion" `
        -Template "competitor-row" `
        -Prompt "Notionについて以下の項目を埋めて" `
        -ContextFiles @("C:\path\notion-raw.md") `
        -OutputPath "C:\Users\Owner\business\brain\wiki\research\competitor-notion.md"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("research","newbiz","dev","marketing","corp","secretary","misc")]
    [string]$Department,

    [Parameter(Mandatory=$true)]
    [string]$Title,

    [Parameter(Mandatory=$true)]
    [string]$Prompt,

    [string]$Template = "",
    [string[]]$ContextFiles = @(),
    [string]$OutputPath = "",
    [string]$Model = "",  # 空ならPriorityから自動選択

    [ValidateSet("super","high","normal","low","late")]
    [string]$Priority = "late",

    [switch]$SkipPrefix,
    [switch]$UseAgent   # 重い複数ターンタスクは openclaw agent 経由
)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$inbox = Join-Path $brainRoot "queue\inbox"
$templatesDir = Join-Path $brainRoot "scripts\templates"
$prefixPath = Join-Path $brainRoot "scripts\prompt-prefix.md"

# 共通プレフィックス読み込み（日付プレースホルダー置換）
$prefix = ""
if (Test-Path $prefixPath) {
    $prefix = [System.IO.File]::ReadAllText($prefixPath, [System.Text.Encoding]::UTF8)

    # 日付プレースホルダーの埋め込み
    $todayISO = (Get-Date).ToString("yyyy-MM-dd")
    $cal = [System.Globalization.CultureInfo]::InvariantCulture.Calendar
    $weekNum = $cal.GetWeekOfYear((Get-Date), [System.Globalization.CalendarWeekRule]::FirstFourDayWeek, [DayOfWeek]::Monday)
    $todayWeek = (Get-Date).ToString("yyyy") + "-W" + ("{0:D2}" -f $weekNum)
    $todayMonth = (Get-Date).ToString("yyyy-MM")

    $prefix = $prefix.Replace("{TODAY_ISO}", $todayISO)
    $prefix = $prefix.Replace("{TODAY_WEEK}", $todayWeek)
    $prefix = $prefix.Replace("{TODAY_MONTH}", $todayMonth)
}

# ⚠ ハルシネ事前検知 (2026-05-28 大井指示)
# qwen3:8b / qwen3.6 は実在企業/人物リサーチで捏造する → researcher agent (Claude WebSearch) 推奨
$hallucinationKeywords = @("実在企業", "実在人物", "実在の企業", "実在の人物", "リアル企業", "実存", "実名", "全国50社", "全国30社", "100社リスト", "実在のみ", "架空禁止", "実在ベース")
$detected = @()
foreach ($kw in $hallucinationKeywords) {
    if ($Prompt -match [regex]::Escape($kw)) { $detected += $kw }
}
# リスト系の数字パターン (10社・20社・30社・50社・100社) + 「企業」が同時に出てたら警告
if ($Prompt -match "(\d+)\s*(社|名|人|校).*企業" -or $Prompt -match "リスト.*\d+\s*(社|名|人|校)") {
    $detected += "リスト系数字"
}
if ($detected.Count -gt 0 -and -not $UseAgent) {
    Write-Warning "⚠ ハルシネ事前検知: 実在性が必要なタスク (検出: $($detected -join ', ')) → researcher agent (Claude WebSearch) 推奨"
    Write-Warning "  qwen3:8b/qwen3.6 では架空企業名を捏造する可能性が高い。"
    Write-Warning "  対処: Agent ツールで researcher subagent_type を使うか、-UseAgent フラグ追加"
    # 投入は続けるが警告ログを残す
    $warnLog = "C:\Users\Owner\business\brain\queue\logs\hallucination-warnings.log"
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | $Title | detected: $($detected -join ', ')" | Add-Content $warnLog -Encoding UTF8
}

# テンプレ展開
$finalPrompt = $Prompt
if ($Template) {
    $tplPath = Join-Path $templatesDir "$Department\$Template.md"
    if (Test-Path $tplPath) {
        $tplContent = [System.IO.File]::ReadAllText($tplPath, [System.Text.Encoding]::UTF8)
        $finalPrompt = "$tplContent`n`n# 依頼内容`n$Prompt"
    } else {
        Write-Warning "Template not found: $tplPath (使わずに続行)"
    }
}

# プレフィックスをprepend（軽量タスクはSkipPrefixで除外）
$autoSkip = ($Prompt.Length -lt 200)  # 200字未満の指示は自動でprefix無し
if ($prefix -and -not $SkipPrefix -and -not $autoSkip) {
    $finalPrompt = $prefix + "`n`n" + $finalPrompt
}

# 🔥 自動 ContextFiles 注入: プロンプト内の [[entities/xxx]] を検出して対応ファイルを自動添付
# 2026-05-19 重要修正: qwen3.6が事業の実中身を読まず妄想する問題を防ぐ
$entityMatches = [regex]::Matches($finalPrompt, '\[\[entities/([a-zA-Z0-9\-_]+)(\|[^\]]*)?\]\]')
$autoCtxFiles = @()
foreach ($m in $entityMatches) {
    $entityName = $m.Groups[1].Value
    $entityPath = Join-Path $brainRoot "wiki\entities\$entityName.md"
    if ((Test-Path $entityPath) -and ($autoCtxFiles -notcontains $entityPath)) {
        $autoCtxFiles += $entityPath
    }
}
# 既存ContextFilesにマージ (重複排除)
if ($autoCtxFiles.Count -gt 0) {
    $ContextFiles = @($ContextFiles) + $autoCtxFiles | Select-Object -Unique
    Write-Host "  [auto-ctx] entities注入: $($autoCtxFiles.Count) files"
}

# 結果デフォルトパス
$taskId = ([guid]::NewGuid().ToString().Substring(0, 8))
if (-not $OutputPath) {
    $OutputPath = Join-Path $brainRoot "queue\results\$Department\$taskId.md"
}

# 優先度プレフィックス + モデル自動選択
$prio = switch ($Priority) {
    "super"  { "0" }
    "high"   { "1" }
    "normal" { "5" }
    "late"   { "8" }
    "low"    { "9" }
}

# Model 自動選択 (Priority基準):
#  super/high = qwen3.6:latest (23GB・最強・遅い)
#  normal     = qwen3.6:latest
#  late/low   = qwen3:8b (5GB・速い・軽量) ← 大井「基本late」方針
if (-not $Model) {
    $Model = switch ($Priority) {
        "super"  { "qwen3.6:latest" }
        "high"   { "qwen3.6:latest" }
        "normal" { "qwen3.6:latest" }
        "late"   { "qwen3:8b" }
        "low"    { "qwen3:8b" }
    }
    Write-Host "  [auto-model] Priority=$Priority → Model=$Model"
}

$stamp = (Get-Date).ToString("yyyyMMdd-HHmmss-fff")
$fileName = "$prio-$stamp-$taskId.json"
$taskPath = Join-Path $inbox $fileName

$job = [ordered]@{
    id = $taskId
    title = $Title
    department = $Department
    template = $Template
    model = $Model
    priority = $Priority
    use_agent = [bool]$UseAgent
    prompt = $finalPrompt
    context_files = $ContextFiles
    output_path = $OutputPath
    retries = 0
    created_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    requested_by = "claude-agent"
}

$json = $job | ConvertTo-Json -Depth 5
$utf8 = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($taskPath, $json, $utf8)

Write-Host "[$Department/$Priority] $Title → $taskId.md"
Write-Host "  inbox: $taskPath"
Write-Host "  output: $OutputPath"
