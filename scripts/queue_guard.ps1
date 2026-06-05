#requires -Version 5.1
# Queue Guard - 10分毎・queue膨張/古いタスク放置の自動防止
# 2026-05-25 新規: 過去にinbox 1215件膨張 → 処理詰まりの再発防止
# - inbox > 200件で古い normal(5-) を24h以上前のものから順に overflow へ移動
# - failed > 50件で全部 overflow に隔離
# - workers 死亡時に自動復活 (heavy/light 各1基保証)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$queue = "$brain\queue"
$logPath = "$brain\scripts\queue_guard.log"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

# .paused の扱い (2026-06-05 止まらない化):
# ゲーム由来 or 最近(2h以内)の pause は正当 → exit。
# 古い(2h超)かつ game マーカー無し = 手動pause戻し忘れ/クラッシュ残骸 → 自動解除して稼働再開。
# (旧実装は .paused があれば無条件 exit。孤児 .paused で永久停止し自己修復もできなかった最大の停止リスク)
if (Test-Path "$queue\.paused") {
    $pAge = ((Get-Date) - (Get-Item "$queue\.paused").LastWriteTime).TotalHours
    $byGame = Test-Path "$queue\.paused_by_game"
    if ($byGame -or $pAge -lt 2) { exit 0 }
    Remove-Item "$queue\.paused" -Force -ErrorAction SilentlyContinue
    "$nowStamp - 孤児.paused自動解除 (age=$([math]::Round($pAge,1))h) -> 稼働再開" | Add-Content $logPath -Encoding UTF8
}

$inboxCount = (Get-ChildItem "$queue\inbox" -File -Filter "*.json" -ErrorAction SilentlyContinue).Count
$failedCount = (Get-ChildItem "$queue\failed" -File -ErrorAction SilentlyContinue).Count
$overflowDir = "$queue\inbox\_overflow_archive"
if (-not (Test-Path $overflowDir)) { New-Item -ItemType Directory -Path $overflowDir -Force | Out-Null }

$movedOld = 0
$movedFailed = 0
$workersRestarted = 0

# 1. inbox膨張ガード (200件超で古いものから _overflow へ退避)
# 2026-06-03: 5-*.json 限定→全prefix年齢順に修正。高優先(1-*)が大量滞留する現運用で旧globが空振り(oldMoved=0常態)していた問題を是正。
# これは安全弁。本体の排出はworkerが担う(レーン飢餓修正+OOM解消+num_ctxで実効スループット向上済)。
if ($inboxCount -gt 200) {
    $toMove = $inboxCount - 200
    Get-ChildItem "$queue\inbox\*.json" -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddHours(-24) } | Sort-Object LastWriteTime | Select-Object -First $toMove | ForEach-Object {
        Move-Item $_.FullName "$overflowDir\$($_.Name)" -Force -ErrorAction SilentlyContinue
        $movedOld++
    }
}

# 2. failed膨張ガード (50件超で隔離)
if ($failedCount -gt 50) {
    Get-ChildItem "$queue\failed" -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddHours(-6) } | ForEach-Object {
        Move-Item $_.FullName "$overflowDir\$($_.Name)" -Force -ErrorAction SilentlyContinue
        $movedFailed++
    }
}

# 2.4 Ollama 死活 + 自動復活 (Startupショートカット依存の弱点を補完。worker.ps1は到達不可で即exitするため最優先)
$ollamaUp = $false
$ollamaRestarted = 0
try { Invoke-RestMethod -Uri "http://localhost:11434/" -TimeoutSec 5 | Out-Null; $ollamaUp = $true } catch { $ollamaUp = $false }
if (-not $ollamaUp) {
    $ollamaExe = "$env:LOCALAPPDATA\Programs\Ollama\ollama app.exe"
    if (Test-Path $ollamaExe) {
        Start-Process $ollamaExe -WindowStyle Hidden -ErrorAction SilentlyContinue
        $ollamaRestarted = 1
        "$nowStamp - Ollama down → 再起動 ($ollamaExe)" | Add-Content $logPath -Encoding UTF8
        Start-Sleep -Seconds 3
    }
}

# 2.5 processing リーパー (再起動/クラッシュ/スリープで孤児化したタスクを救出)
# 閾値120分: ワーカーの最長タスク(Ollama 1800s + agent 1500s ≒ 最大約55分)の2倍以上 → 走行中タスクを誤って奪わない
# poison-pill 対策: 3回孤児化したタスク(=ワーカーを巻き込んで落ちる毒タスク)は failed へ隔離
$reaped = 0
$reapFailed = 0
Get-ChildItem "$queue\processing" -File -Filter "*.json" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddMinutes(-120) } | ForEach-Object {
    $pname = $_.Name
    try {
        $pj = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        $rc = 0; if ($pj.reaped) { $rc = [int]$pj.reaped }
        $rc++
        if ($rc -ge 3) {
            $pj | Add-Member -NotePropertyName reaped -NotePropertyValue $rc -Force
            $pj | Add-Member -NotePropertyName last_error -NotePropertyValue "orphaned ${rc}x in processing (worker crashed/rebooted mid-task)" -Force
            $pj | ConvertTo-Json -Depth 6 | Set-Content "$queue\failed\$pname" -Encoding UTF8
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            $reapFailed++
        } else {
            $pj | Add-Member -NotePropertyName reaped -NotePropertyValue $rc -Force
            $pj | ConvertTo-Json -Depth 6 | Set-Content "$queue\inbox\$pname" -Encoding UTF8
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            $reaped++
        }
    } catch {
        Move-Item $_.FullName "$queue\inbox\$pname" -Force -ErrorAction SilentlyContinue
        $reaped++
    }
}
if ($reaped -gt 0 -or $reapFailed -gt 0) { "$nowStamp - processing reaper: requeued=$reaped quarantined=$reapFailed" | Add-Content $logPath -Encoding UTF8 }

# 2.6 stale ロック掃除 (90分超のレーンロック = 死亡ワーカーの置き土産。最大60分のstale判定より長く取り誤殺防止)
$lockGrave = "$queue\_lock_graveyard"
if (-not (Test-Path $lockGrave)) { New-Item -ItemType Directory -Path $lockGrave -Force | Out-Null }
$locksCleared = 0
Get-ChildItem "$queue\.worker-*.lock" -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddMinutes(-90) } | ForEach-Object {
    Move-Item $_.FullName "$lockGrave\$($_.Name).$((Get-Date).ToString('yyyyMMddHHmmss'))" -Force -ErrorAction SilentlyContinue
    $locksCleared++
}

# 3. worker健全性 (heavy + light 各最低1基保証)
$workers = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like '*\worker.ps1*' })
$hasHeavy = $false
$hasLight = $false
foreach ($w in $workers) {
    if ($w.CommandLine -match '\bheavy\b') { $hasHeavy = $true }
    if ($w.CommandLine -match '\blight\b') { $hasLight = $true }
}
$vbs = "$brain\scripts\silent_runner.vbs"
if (-not $hasHeavy) {
    Remove-Item "$queue\.worker-heavy.lock" -Force -ErrorAction SilentlyContinue
    Start-Process wscript -ArgumentList "//nologo `"$vbs`" `"$brain\scripts\worker.ps1`" heavy" -WindowStyle Hidden
    $workersRestarted++
}
if (-not $hasLight) {
    Remove-Item "$queue\.worker-light.lock" -Force -ErrorAction SilentlyContinue
    Start-Process wscript -ArgumentList "//nologo `"$vbs`" `"$brain\scripts\worker.ps1`" light" -WindowStyle Hidden
    $workersRestarted++
}

# 3.5 管理外 any レーンワーカー掃除 (2026-06-03)
# run_worker.vbs 等が Lane未指定(=any)で起動した孤児ワーカーが heavy と同一GPUで qwen3:8b を同時生成
# → VRAM 16GB相当要求 → CPU溢れ/Ollama unreachable の温床。heavy+light が揃っている前提で余剰を停止。
$strayKilled = 0
if ($hasHeavy -and $hasLight) {
    foreach ($w in $workers) {
        if ($w.CommandLine -notmatch '\bheavy\b' -and $w.CommandLine -notmatch '\blight\b') {
            try { Stop-Process -Id $w.ProcessId -Force -ErrorAction SilentlyContinue; $strayKilled++ } catch {}
        }
    }
    if ($strayKilled -gt 0) {
        Get-ChildItem "$queue\.worker-any.lock" -Force -ErrorAction SilentlyContinue | ForEach-Object { Move-Item $_.FullName "$lockGrave\$($_.Name).$((Get-Date).ToString('yyyyMMddHHmmss'))" -Force -ErrorAction SilentlyContinue }
        "$nowStamp - stray any-worker killed: $strayKilled" | Add-Content $logPath -Encoding UTF8
    }
}

# 4. .paused 怪奇現象対策 (過去にscheduler triggerで勝手にpaused復活)
# 大井が手動でpauseしたい時は dashboard ボタン or pause_brain.ps1
# .paused が古い (1h以上前で) + 全schedulers有効 = 怪奇復活 → 削除
if (Test-Path "$queue\.paused") {
    $pAge = ((Get-Date) - (Get-Item "$queue\.paused").LastWriteTime).TotalHours
    $enabledSchedulers = @(Get-ScheduledTask | Where-Object { $_.TaskName -match '^BrainWorker' -and $_.State -ne 'Disabled' }).Count
    if ($pAge -gt 1 -and $enabledSchedulers -gt 0) {
        Remove-Item "$queue\.paused" -Force -ErrorAction SilentlyContinue
        "$nowStamp - 怪奇.paused削除 (age=$([math]::Round($pAge,1))h・schedulers有効)" | Add-Content $logPath -Encoding UTF8
    }
}

# 6. 文字化け常設センサー (2026-06-03): 直近20分に生成された化けファイル名を自動隔離。
# 源(BOM/encoding)は断ってあるが、万一の再発を10分以内に検知・隔離して二度と溜めない最終保険。
$mojiQuar = "$brain\wiki\_inbox\_archive\_corrupted-auto"
$mojiFound = 0
$recentMoji = Get-ChildItem "$brain\wiki\_inbox" -Recurse -File -Filter *.md -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-20) -and $_.FullName -notmatch '_corrupted' -and ($_.Name -match [char]0xFFFD -or $_.Name -match '[繝繧繚縺郢竄髢驍髟]') }
if ($recentMoji) {
    if (-not (Test-Path $mojiQuar)) { New-Item -ItemType Directory -Path $mojiQuar -Force | Out-Null }
    foreach ($rf in $recentMoji) { Move-Item $rf.FullName (Join-Path $mojiQuar $rf.Name) -Force -ErrorAction SilentlyContinue; $mojiFound++ }
    "$nowStamp - WARN 文字化けファイル $mojiFound 件を自動隔離 (源の再発か要確認)" | Add-Content $logPath -Encoding UTF8
}

# 7. done/ アーカイブ (6時間毎・7日超を _archive へ。done肥大でダッシュボード/全スクリプトが遅くなるのを恒久防止)
$archMarker = "$queue\.last_done_archive"
$doArch = $true
if (Test-Path $archMarker) { if (((Get-Date) - (Get-Item $archMarker).LastWriteTime).TotalHours -lt 6) { $doArch = $false } }
if ($doArch) {
    $doneArch = "$queue\done\_archive"
    if (-not (Test-Path $doneArch)) { New-Item -ItemType Directory -Path $doneArch -Force | Out-Null }
    $cutDone = (Get-Date).AddDays(-7)
    $archivedDone = 0
    Get-ChildItem "$queue\done" -Filter *.json -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutDone } | ForEach-Object {
        Move-Item $_.FullName "$doneArch\$($_.Name)" -Force -ErrorAction SilentlyContinue; $archivedDone++
    }
    Set-Content $archMarker -Value (Get-Date).ToString('o') -Force
    # ログローテーション: 5MB超の*.logは末尾2000行だけ残す(auto_promote.log等の肥大防止)
    Get-ChildItem "$brain\scripts\*.log" -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 5MB } | ForEach-Object {
        try { $tail = Get-Content $_.FullName -Tail 2000 -ErrorAction SilentlyContinue; Set-Content $_.FullName -Value $tail -Encoding UTF8 } catch {}
    }
    if ($archivedDone -gt 0) { "$nowStamp - done archived: $archivedDone (>7d)" | Add-Content $logPath -Encoding UTF8 }
}

# 8. 出力フロー監視 (2026-06-05 止まらない化): inboxにタスクがあるのに長時間1件も完成しない=沈黙ストール検知。
# workers生存/ollama稼働でもhungリクエストやロック居座りで実質停止する事故を25分で自己修復(ロック強制解放+ワーカー蹴り)。
if ($inboxCount -gt 0 -and $ollamaUp) {
    $lastDone = Get-ChildItem "$queue\done" -Filter *.json -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($lastDone -and (((Get-Date) - $lastDone.LastWriteTime).TotalMinutes -gt 25)) {
        Get-ChildItem "$queue\.worker-*.lock" -Force -ErrorAction SilentlyContinue | ForEach-Object { Move-Item $_.FullName "$lockGrave\$($_.Name).stall.$((Get-Date).ToString('yyyyMMddHHmmss'))" -Force -ErrorAction SilentlyContinue }
        Start-Process wscript -ArgumentList "//nologo `"$vbs`" `"$brain\scripts\worker.ps1`" heavy" -WindowStyle Hidden
        Start-Process wscript -ArgumentList "//nologo `"$vbs`" `"$brain\scripts\worker.ps1`" light" -WindowStyle Hidden
        "$nowStamp - 沈黙ストール検知 -> ロック強制解放+ワーカー再起動" | Add-Content $logPath -Encoding UTF8
    }
}

$ollamaState = if ($ollamaUp) { 'up' } else { "restarted$ollamaRestarted" }
$summary = "inbox=$inboxCount oldMoved=$movedOld failed=$failedCount failedMoved=$movedFailed workers=$($workers.Count) restarted=$workersRestarted reaped=$reaped reapQuarantined=$reapFailed locksCleared=$locksCleared ollama=$ollamaState"
"$nowStamp - $summary" | Add-Content $logPath -Encoding UTF8
Write-Host "queue_guard: $summary"
