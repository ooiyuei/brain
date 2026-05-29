#requires -Version 5.1
# Task Bank Filler - wiki/meta/task-bank.md から在庫不足時にランダム1件投入
# 大井「全部入れとけばOpenClawがやる」方針の実装

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$pause = "$brain\queue\.paused"
if (Test-Path $pause) { exit 0 }

$dispatcher = "$brain\scripts\dispatch.ps1"
$bankPath = "$brain\wiki\meta\task-bank.md"
$stateFile = "$brain\scripts\.task_bank_state.json"
$logPath = "$brain\scripts\task_bank_filler.log"
$now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

# 在庫チェック
$inbox = (Get-ChildItem "$brain\queue\inbox" -File -Filter "*.json" -ErrorAction SilentlyContinue).Count
if ($inbox -ge 30) {
    "$now - inbox sufficient (=$inbox), skip" | Add-Content $logPath -Encoding UTF8
    exit 0
}

# State 読み込み
$state = @{ used = @{} }
if (Test-Path $stateFile) {
    try {
        $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($loaded.used) {
            foreach ($p in $loaded.used.PSObject.Properties) {
                $state.used[$p.Name] = $p.Value
            }
        }
    } catch {}
}

# task-bank.md から「数字. タスク」行を全部抽出
$bankText = [System.IO.File]::ReadAllText($bankPath, [System.Text.Encoding]::UTF8)
$sections = @{}
$currentSection = "uncategorized"
$tasks = @()

foreach ($line in ($bankText -split "`r?`n")) {
    if ($line -match '^### (.+)$') {
        $currentSection = $matches[1].Trim()
    } elseif ($line -match '^\s*(\d+)\.\s+(.+)$') {
        $num = $matches[1]
        $taskText = $matches[2].Trim()
        $taskKey = "$currentSection :: $taskText"
        $tasks += [PSCustomObject]@{
            Section = $currentSection
            Text = $taskText
            Key = $taskKey
        }
    }
}

# クールダウン (4h以内に使ったタスクは除外)
$cutoff = (Get-Date).AddHours(-4)
$available = $tasks | Where-Object {
    if (-not $state.used.ContainsKey($_.Key)) { return $true }
    $lastUsed = [DateTime]$state.used[$_.Key]
    return ($lastUsed -lt $cutoff)
}

if ($available.Count -eq 0) {
    "$now - no available tasks (all on cooldown)" | Add-Content $logPath -Encoding UTF8
    Write-Host "No available tasks"
    exit 0
}

# ランダム選択
$pick = $available | Get-Random

# 部署とentities自動判定
$dept = "newbiz"
$entityRef = ""
foreach ($e in @("testall","aipax","aipa-web","aipax-school","eemus","agents-of-flag","ipak-darts","ipak-fishing","kasunote","gymee","juken-os","yakki-check")) {
    if ($pick.Section -match $e -or $pick.Text -match $e -or $pick.Section -match "AIpaX|Testall|AOF|EEMUS|IPAK|AIpa") {
        $entityRef = "[[entities/$e]]"
        if ($pick.Section -match "AIpa Web|aipa-web") { $entityRef = "[[entities/aipa-web]]"; $dept = "marketing" }
        elseif ($pick.Section -match "AIpaX") { $entityRef = "[[entities/aipax]]"; $dept = "newbiz" }
        elseif ($pick.Section -match "Testall|testall") { $entityRef = "[[entities/testall]]"; $dept = "newbiz" }
        elseif ($pick.Section -match "EEMUS|eemus") { $entityRef = "[[entities/eemus]]"; $dept = "newbiz" }
        elseif ($pick.Section -match "Agents of Flag|agents-of-flag|AOF") { $entityRef = "[[entities/agents-of-flag]]"; $dept = "newbiz" }
        elseif ($pick.Section -match "IPAK-darts") { $entityRef = "[[entities/ipak-darts]]"; $dept = "newbiz" }
        elseif ($pick.Section -match "FishOps|fishing") { $entityRef = "[[entities/ipak-fishing]]"; $dept = "newbiz" }
        elseif ($pick.Section -match "AIpaX school|AI塾") { $entityRef = "[[entities/aipax-school]]"; $dept = "marketing" }
        elseif ($pick.Section -match "カスハラ") { $entityRef = "[[entities/kasunote]]"; $dept = "marketing" }
        break
    }
}

# タスク内容にカスタマイズ
if ($pick.Text -match "営業|商談|アポ|顧客|モニター|セミナー|プロファイル") { $dept = "marketing" }
elseif ($pick.Text -match "LP|SEO|note|X投稿|記事|TikTok|広告|ピッチ|スライド|台本") { $dept = "marketing" }
elseif ($pick.Text -match "契約書|価格|PL|ROI|事業計画") { $dept = "corp" }
elseif ($pick.Text -match "仕様|アプリ|機能|システム|データモデル") { $dept = "dev" }
elseif ($pick.Text -match "プラン|戦略|ペルソナ|分析|競合|ピボット") { $dept = "newbiz" }

$stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
$shortId = [guid]::NewGuid().ToString().Substring(0,4)
$slug = ($pick.Text -replace '[^\w]', '-').ToLower().Substring(0, [Math]::Min(40, $pick.Text.Length))
$outName = "bank-$slug-$stamp-$shortId.md"
$outPath = "$brain\wiki\_inbox\$dept\$outName"

$prompt = @"
# タスク: $($pick.Text)

## コンテキスト
事業/カテゴリ: $($pick.Section)
$entityRef

## 大井湧瑛の現状 (2026-05-19)
- 月収100万円期限: 2026-06-21 (残33日)
- AIpaX 4社契約済・月20万
- 3本柱: Testall(名)/AIpaX(金)/Agents of Flag(夢)

## 要件
1. **2500-3500字** で具体的に書く
2. 大井のキャラ (フランク・断定・関西弁混じり可・AI臭NG)
3. 実在企業名・実在ツールのみ (架空NG・推測には『推測:』)
4. 数字は根拠1行付き
5. 「明日使う1人」が明確
6. 3ヶ月以内に検証可能なアクション

ContextFilesから entities/$($entityRef -replace '\[\[entities/','' -replace '\]\]','') の中身を読んで、事業の実中身を反映。
"@

& $dispatcher `
    -Department $dept `
    -Title "[Bank] $($pick.Text.Substring(0, [Math]::Min(50, $pick.Text.Length)))" `
    -Prompt $prompt `
    -Model "qwen3:8b" `
    -OutputPath $outPath `
    -Priority "normal" `
    -UseAgent 2>&1 | Out-Null

# State更新
$state.used[$pick.Key] = (Get-Date).ToString("o")
# 古いstate cleanup (1週間以上前を削除)
$weekAgo = (Get-Date).AddDays(-7)
$keysToRemove = @()
foreach ($k in $state.used.Keys) {
    try {
        if ([DateTime]$state.used[$k] -lt $weekAgo) { $keysToRemove += $k }
    } catch {}
}
foreach ($k in $keysToRemove) { $state.used.Remove($k) | Out-Null }

$stateJson = $state | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

"$now - Bank dispatched: [$dept] $($pick.Text.Substring(0,[Math]::Min(60,$pick.Text.Length)))" | Add-Content $logPath -Encoding UTF8
Write-Host "Bank-filled: [$dept] $($pick.Text.Substring(0,[Math]::Min(60,$pick.Text.Length)))"
