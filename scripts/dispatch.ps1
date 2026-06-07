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
$prefixPath = Join-Path $brainRoot "scripts\prompt-prefix-v4.md"  # 2026-06-07: v4(60点契約・反復禁止・自己チェック・速度より精度)へ切替。v3はbackup。entity注入は$Promptのみ走査なので肥大しない

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
# 2026-05-19: qwen3.6が事業の実中身を読まず妄想する問題を防ぐ
# 2026-06-03: $finalPrompt(=prefix込み)でなく $Prompt(タスク本文)だけを走査するよう修正。
#   prefixの18個のwikilink一覧まで拾って17 entity注入→57k字→num_ctx 8192で85%切り捨て、になっていた。
$entityMatches = [regex]::Matches($Prompt, '\[\[entities/([a-zA-Z0-9\-_]+)(\|[^\]]*)?\]\]')
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

# 文字化け最終防衛線 (2026-06-03): output_path のファイル名が文字化け(U+FFFD or cp932誤読の特徴的katakana)なら
# ASCII安全名へ自動置換。万一どこかのプロデューサで encoding が崩れても、disk に化けファイル名を二度と作らせない。
if ($OutputPath) {
    $opLeaf = Split-Path $OutputPath -Leaf
    if ($opLeaf -match [char]0xFFFD -or $opLeaf -match '[繝繧繚縺郢竄髢驍髟]') {
        $opDir2 = Split-Path $OutputPath -Parent
        $OutputPath = Join-Path $opDir2 "$Department-$taskId.md"
        Write-Host "  [mojibake-guard] 文字化けファイル名を検出 → $Department-$taskId.md に置換"
    }
}

# 優先度プレフィックス + モデル自動選択
$prio = switch ($Priority) {
    "super"  { "0" }
    "high"   { "1" }
    "normal" { "5" }
    "late"   { "8" }
    "low"    { "9" }
}

# Model 自動選択: 8GB GPU(RTX5060)では qwen3:8b 一択。
# qwen3.6:latest(23GB) は VRAM 超過で OOM→Ollama クラッシュの源だったため 2026-06-03 に全経路から廃止+削除。
# GPU 増設時は super/high をより大きいモデルへ戻すこと (worker.ps1 の oversizedModels ガードも併せて調整)。
if (-not $Model) {
    $Model = switch ($Priority) {
        "super"  { "qwen3:8b" }
        "high"   { "qwen3:8b" }
        "normal" { "qwen3:8b" }
        "late"   { "qwen3:8b" }
        "low"    { "qwen3:8b" }
    }
    Write-Host "  [auto-model] Priority=$Priority → Model=$Model"
}

# 2026-06-03 一元バックプレッシャ: 全プロデューサ(filler/loop/pipeline)は必ずここを通る。
# inbox飽和時(>=150)は super 以外の新規投入をスキップし、プロデューサ/コンシューマ不均衡(自己DoS)を防ぐ。
# 本当に精度が要る単発依頼は -Priority super でバイパス。
$bpInbox = @(Get-ChildItem (Join-Path $brainRoot 'queue\inbox') -Filter '*.json' -File -ErrorAction SilentlyContinue).Count
if ($bpInbox -ge 150 -and $Priority -ne 'super') {
    Write-Host "[backpressure] inbox=$bpInbox >=150 -> skip enqueue (priority=$Priority). superでバイパス可。"
    return
}

# Cost Guard (PDCA cycle6 / GitHub-harvest pattern A): daily enqueue cap across ALL producers -> floods structurally impossible.
# super bypasses. tune $guardMax. counter file rolls by date. complements backpressure(stock) + dedup(12h) with a rate ceiling.
$guardMax = 60
$guardFile = Join-Path $brainRoot ("scripts\.guard_" + (Get-Date).ToString('yyyyMMdd') + ".txt")
$guardCount = 0
if (Test-Path $guardFile) { try { $guardCount = [int]((Get-Content $guardFile -Raw).Trim()) } catch { $guardCount = 0 } }
if ($guardCount -ge $guardMax -and $Priority -ne 'super') {
    Write-Host "[cost-guard] daily enqueue cap $guardMax reached (count=$guardCount) -> skip (priority=$Priority). super bypass."
    return
}

# 2026-06-04 タイトル重複ガード: 同一タイトルが直近12h以内に投入済みなら skip (super除く)。
# 多数のfiller(money_loop/shincoder/recurrent等)が同じタスクを再生成し夜間437本中73%が重複コピーになっていた問題を一元解消。
$dedupFile = Join-Path $brainRoot 'scripts\.dispatch_dedup.json'
$dedup = @{}
if (Test-Path $dedupFile) { try { $dj = Get-Content $dedupFile -Raw -Encoding UTF8 | ConvertFrom-Json; foreach ($pp in $dj.PSObject.Properties) { $dedup[$pp.Name] = $pp.Value } } catch {} }
$titleKey = "$Department|$Title"
if ($Priority -ne 'super' -and $dedup.ContainsKey($titleKey)) {
    try { if ([DateTime]$dedup[$titleKey] -gt (Get-Date).AddHours(-12)) {
        Write-Host "[dedup] '$Title' は直近12h投入済み -> skip (superでバイパス可)"
        return
    } } catch {}
}
$dedup[$titleKey] = (Get-Date).ToString('o')
$dCut = (Get-Date).AddHours(-48)
$dClean = @{}
foreach ($dk in $dedup.Keys) { try { if ([DateTime]$dedup[$dk] -gt $dCut) { $dClean[$dk] = $dedup[$dk] } } catch {} }
[System.IO.File]::WriteAllText($dedupFile, ($dClean | ConvertTo-Json), [System.Text.UTF8Encoding]::new($false))

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

# Cost Guard increment (cycle6): count only ACTUAL enqueues (deduped/backpressured/capped returns never reach here)
try { [System.IO.File]::WriteAllText($guardFile, ([string]($guardCount + 1))) } catch {}

Write-Host "[$Department/$Priority] $Title → $taskId.md"
Write-Host "  inbox: $taskPath"
Write-Host "  output: $OutputPath"
