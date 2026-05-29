#requires -Version 5.1
# 5分おきに wiki/dashboard.md を更新。Brain System 全体の状況を一画面で。

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$outPath = Join-Path $brainRoot "wiki\dashboard.md"
$now = (Get-Date)
$nowStamp = $now.ToString("yyyy-MM-dd HH:mm")
$today = $now.ToString("yyyy-MM-dd")
$todayShort = $now.ToString("yyyyMMdd")
$utf8 = [System.Text.UTF8Encoding]::new($false)

# 1. queue状況
$inboxCount = (Get-ChildItem (Join-Path $brainRoot "queue\inbox") -File -ErrorAction SilentlyContinue).Count
$processingCount = (Get-ChildItem (Join-Path $brainRoot "queue\processing") -File -ErrorAction SilentlyContinue).Count
$failedCount = (Get-ChildItem (Join-Path $brainRoot "queue\failed") -File -ErrorAction SilentlyContinue).Count
$todayDoneCount = (Get-ChildItem (Join-Path $brainRoot "queue\done") -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime.Date -eq [DateTime]::Today }).Count

# 2. processing詳細
$processingDetail = @()
Get-ChildItem (Join-Path $brainRoot "queue\processing") -File -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $j = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        $age = [int]((Get-Date) - $_.LastWriteTime).TotalMinutes
        $processingDetail += "- ⚙️ **[$age 分]** $($j.title)"
    } catch {}
}

# 3. inbox 上位5件
$inboxDetail = @()
Get-ChildItem (Join-Path $brainRoot "queue\inbox") -File -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -First 5 | ForEach-Object {
    try {
        $j = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        $inboxDetail += "- [$($j.priority)] $($j.title)"
    } catch {}
}

# 4. BG進捗
$contestState = Get-Content (Join-Path $brainRoot "scripts\.bg_contest_state.json") -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
$entitiesState = Get-Content (Join-Path $brainRoot "scripts\.bg_entities_state.json") -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
$businessState = Get-Content (Join-Path $brainRoot "scripts\.bg_business_state.json") -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
$competitiveState = Get-Content (Join-Path $brainRoot "scripts\.bg_competitive_state.json") -Raw -Encoding UTF8 -ErrorAction SilentlyContinue

$contestProgress = "進捗 不明"
if ($contestState) {
    try {
        $s = $contestState | ConvertFrom-Json
        $contestProgress = "バッチ $($s.batch)/$($s.total_batches) ($([Math]::Round($s.batch / $s.total_batches * 100))%)"
    } catch {}
}

$entitiesProgress = "進捗 不明"
if ($entitiesState) {
    try {
        $s = $entitiesState | ConvertFrom-Json
        $refreshed = if ($s.refreshed) { @($s.refreshed).Count } else { 0 }
        $entitiesProgress = "ラウンド $($s.round) / $refreshed 件更新済"
    } catch {}
}

$businessProgress = "進捗 不明"
if ($businessState) {
    try {
        $s = $businessState | ConvertFrom-Json
        $businessProgress = "事業 $($s.current_idx)/15 / 視点 $($s.current_viewpoint)/4"
    } catch {}
}

$competitiveProgress = "進捗 不明"
if ($competitiveState) {
    try {
        $s = $competitiveState | ConvertFrom-Json
        $competitiveProgress = "$($s.current_idx)/15 社"
    } catch {}
}

# 5. wiki/_inbox/ 滞留
$inboxStaleCount = 0
$inboxByDept = @{}
if (Test-Path (Join-Path $brainRoot "wiki\_inbox")) {
    Get-ChildItem (Join-Path $brainRoot "wiki\_inbox") -Directory | Where-Object { $_.Name -ne "_archive" } | ForEach-Object {
        $count = (Get-ChildItem $_.FullName -File -Filter "*.md" -ErrorAction SilentlyContinue).Count
        if ($count -gt 0) { $inboxByDept[$_.Name] = $count }
    }
    $allInboxFiles = Get-ChildItem (Join-Path $brainRoot "wiki\_inbox") -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Directory.Name -ne "_archive" }
    $inboxStaleCount = ($allInboxFiles | Where-Object { ((Get-Date) - $_.LastWriteTime).TotalHours -gt 24 }).Count
}

# 6. スケジューラ状況
$schedTasks = schtasks /query /fo CSV 2>&1 | ConvertFrom-Csv | Where-Object { $_.TaskName -match "Brain|Daily" -and $_.TaskName -notmatch "Microsoft" }
$schedRunning = ($schedTasks | Where-Object { $_.Status -eq "Running" }).Count
$schedReady = ($schedTasks | Where-Object { $_.Status -eq "Ready" }).Count

# 7. Ollama状態
$ollamaOk = $false
$ollamaModels = 0
try {
    $r = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 3
    $ollamaOk = $true
    $ollamaModels = $r.models.Count
} catch {}

# 8. 今朝の監視結果リンク
$monitorLinks = @()
@("competitor", "deadlines", "grill", "ai-news", "projects", "signals") | ForEach-Object {
    $p = Join-Path $brainRoot "wiki\_monitor\$_-$today.md"
    if (Test-Path $p) {
        $monitorLinks += "- [[_monitor/$_-$today|$_]]"
    }
}

# 9. 今日の予定（今日のtoday.md冒頭）
$todayMd = Get-Content (Join-Path $brainRoot "wiki\_tasks\today.md") -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
$todayFocus = "未設定"
if ($todayMd -and $todayMd -match '(?s)## 🔥 絶対やる.*?\n(.+?)(?=\n## )') {
    $todayFocus = $matches[1].Trim() -replace '\s+', ' '
    if ($todayFocus.Length -gt 100) { $todayFocus = $todayFocus.Substring(0, 100) + "..." }
}

# ========== ダッシュボード出力 ==========
$lines = @()
$lines += "---"
$lines += "type: dashboard"
$lines += "updated: $nowStamp"
$lines += "tags: [dashboard, system]"
$lines += "---"
$lines += ""
$lines += "# Brain Dashboard"
$lines += ""
$lines += "**最終更新**: $nowStamp"
$lines += "**Ollama**: $(if ($ollamaOk) { "🟢 稼働中 ($ollamaModels モデル)" } else { "🔴 応答なし" })"
$lines += "**スケジューラ**: 🟢 $schedReady Ready / 🔄 $schedRunning Running"
$lines += ""
$lines += "## ⚡ Queue 状況"
$lines += ""
$lines += "| 項目 | 件数 |"
$lines += "|---|---|"
$lines += "| 📥 inbox | $inboxCount |"
$lines += "| ⚙️ processing | $processingCount |"
$lines += "| ✅ 今日完了 | $todayDoneCount |"
$lines += "| ❌ failed | $failedCount |"
$lines += "| 📝 wiki/_inbox 未レビュー | $($allInboxFiles.Count) (うち24h+古い: $inboxStaleCount) |"
$lines += ""

if ($processingDetail.Count -gt 0) {
    $lines += "### 処理中"
    $lines += $processingDetail
    $lines += ""
}

if ($inboxDetail.Count -gt 0) {
    $lines += "### Inbox 上位"
    $lines += $inboxDetail
    $lines += ""
}

$lines += "## 🎯 今日のフォーカス"
$lines += ""
$lines += $todayFocus
$lines += ""
$lines += "→ 詳細: [[_tasks/today]]"
$lines += ""

$lines += "## 📊 バックグラウンドタスク進捗"
$lines += ""
$lines += "| タスク | 進捗 |"
$lines += "|---|---|"
$lines += "| 📅 ビジコン分析 (14日) | $contestProgress |"
$lines += "| 📚 entities更新 (9日サイクル) | $entitiesProgress |"
$lines += "| 🏢 事業深掘り (45日サイクル) | $businessProgress |"
$lines += "| ⚔️ 競合監視 (3日サイクル) | $competitiveProgress |"
$lines += ""

if ($monitorLinks.Count -gt 0) {
    $lines += "## 🌅 今朝の監視結果"
    $lines += ""
    $lines += $monitorLinks
    $lines += ""
}

if ($inboxByDept.Count -gt 0) {
    $lines += "## 📝 wiki/_inbox/ 部署別未レビュー"
    $lines += ""
    foreach ($k in $inboxByDept.Keys) {
        $lines += "- $k : $($inboxByDept[$k]) 件"
    }
    $lines += ""
}

$lines += "## 🔗 主要リンク"
$lines += ""
$lines += "- [[hot]] — 直近コンテキスト"
$lines += "- [[index]] — Wiki全体索引"
$lines += "- [[_tasks/_MOC]] — Tasks MOC"
$lines += "- [[_routines/_MOC]] — Routines MOC"
$lines += "- [[meta/enhancement-roadmap]] — 強化ロードマップ"
$lines += ""
$lines += "---"
$lines += ""
$lines += "_このdashboardは5分おきに自動更新（BrainDashboard）_"

$content = $lines -join "`r`n"
[System.IO.File]::WriteAllText($outPath, $content, $utf8)

Write-Host "Dashboard updated: $outPath"
