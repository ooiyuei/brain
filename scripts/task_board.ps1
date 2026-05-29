#requires -Version 5.1
# 5分おきに wiki/_tasks/today.md と waiting.md の自動セクションを更新

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$inboxMD = Join-Path $brainRoot "wiki\_tasks\inbox.md"
$todayMD = Join-Path $brainRoot "wiki\_tasks\today.md"
$waitingMD = Join-Path $brainRoot "wiki\_tasks\waiting.md"
$queueInbox = Join-Path $brainRoot "queue\inbox"
$queueProcessing = Join-Path $brainRoot "queue\processing"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$utf8 = [System.Text.UTF8Encoding]::new($false)
$today = (Get-Date).ToString("yyyy-MM-dd")
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")

# 1. inbox.md の #openclaw タグ付き未dispatchタスクをdispatch
if (Test-Path $inboxMD) {
    $inboxContent = [System.IO.File]::ReadAllText($inboxMD, [System.Text.Encoding]::UTF8)
    $lines = $inboxContent -split "`r?`n"
    $newLines = New-Object System.Collections.Generic.List[string]
    $dispatched = 0

    foreach ($line in $lines) {
        $isOpenclawTask = ($line -match '^\s*-\s*\[\s*\]\s*(.+?)\s*#openclaw')
        $alreadyDispatched = ($line -match 'dispatched')

        if ($isOpenclawTask -and -not $alreadyDispatched) {
            $taskText = $matches[1].Trim()
            $shortTitle = $taskText
            if ($shortTitle.Length -gt 60) { $shortTitle = $shortTitle.Substring(0, 60) }

            try {
                & $dispatcher -Department "research" -Title ("[inbox] " + $shortTitle) -Prompt $taskText -Priority "normal" 2>&1 | Out-Null
                $stamp = (Get-Date).ToString("HH:mm")
                $newLine = $line + " [dispatched " + $stamp + "]"
                $newLines.Add($newLine)
                $dispatched++
            } catch {
                $newLines.Add($line)
            }
        } else {
            $newLines.Add($line)
        }
    }

    if ($dispatched -gt 0) {
        $newInbox = [string]::Join("`r`n", $newLines)
        [System.IO.File]::WriteAllText($inboxMD, $newInbox, $utf8)
        Write-Host "Auto-dispatched $dispatched tasks from inbox.md"
    }
}

# 2. queue状況取得
$inboxTasks = @()
$processingTasks = @()

Get-ChildItem $queueInbox -File -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $j = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        $inboxTasks += [PSCustomObject]@{ Title = $j.title; Priority = $j.priority }
    } catch {}
}

Get-ChildItem $queueProcessing -File -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $j = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        $age = [int]((Get-Date) - $_.LastWriteTime).TotalMinutes
        $processingTasks += [PSCustomObject]@{ Title = $j.title; Age = $age }
    } catch {}
}

# 3. 処理中セクションのテキスト生成
$openclawSection = ""
if ($processingTasks.Count -gt 0) {
    foreach ($task in $processingTasks) {
        $openclawSection += "- [ ] **[処理中 " + $task.Age + "分]** " + $task.Title + "`r`n"
    }
}
if ($inboxTasks.Count -gt 0) {
    foreach ($task in $inboxTasks) {
        $openclawSection += "- [ ] [待機] " + $task.Title + "`r`n"
    }
}
if ($openclawSection -eq "") {
    $openclawSection = "- (現在OpenClaw処理待ち・処理中タスクなし)`r`n"
}

# 4. waiting.md を更新
if (Test-Path $waitingMD) {
    $waitingContent = [System.IO.File]::ReadAllText($waitingMD, [System.Text.Encoding]::UTF8)

    $waitingNewSection = "> 自動セクション開始`r`n" + $openclawSection + "> 自動セクション終了"

    # 既存の自動セクション部分を置換（正規表現）
    $pattern = '(?s)>\s*自動セクション開始.*?>\s*自動セクション終了'
    if ($waitingContent -match $pattern) {
        $waitingContent = [System.Text.RegularExpressions.Regex]::Replace($waitingContent, $pattern, $waitingNewSection)
    }

    # updated更新
    $updatedToday = "updated: " + $today
    $waitingContent = $waitingContent -replace 'updated:\s*\d{4}-\d{2}-\d{2}.*', $updatedToday

    [System.IO.File]::WriteAllText($waitingMD, $waitingContent, $utf8)
}

# 5. today.md の OpenClaw処理中セクションを更新
if (Test-Path $todayMD) {
    $todayContent = [System.IO.File]::ReadAllText($todayMD, [System.Text.Encoding]::UTF8)

    # ## ⏳ OpenClaw処理中 セクション全体を置換
    $headerLine = "## ⏳ OpenClaw処理中"
    $hintLine = "> task_board.ps1 が queue/inbox + processing の状況を自動反映"

    # 既存セクションを探して置換
    $pattern2 = '(?s)## ⏳ OpenClaw処理中.*?(?=\n## |\Z)'
    $newSection = $headerLine + "`r`n`r`n" + $hintLine + "`r`n`r`n" + $openclawSection + "`r`n"

    if ($todayContent -match $pattern2) {
        $todayContent = [System.Text.RegularExpressions.Regex]::Replace($todayContent, $pattern2, $newSection)
    }

    # updated / date 更新
    $updatedNow = "updated: " + $nowStamp
    $dateToday = "date: " + $today
    $todayContent = $todayContent -replace '(?m)^updated:\s*.*$', $updatedNow
    $todayContent = $todayContent -replace '(?m)^date:\s*\d{4}-\d{2}-\d{2}$', $dateToday

    [System.IO.File]::WriteAllText($todayMD, $todayContent, $utf8)
}

Write-Host ("Task board updated: inbox=" + $inboxTasks.Count + " processing=" + $processingTasks.Count)
