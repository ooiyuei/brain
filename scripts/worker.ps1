param(
    [ValidateSet("heavy","light","any")]
    [string]$Lane = "any"
)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$queueRoot = "C:\Users\Owner\business\brain\queue"
$brainRoot = Split-Path -Parent $queueRoot
$inbox = Join-Path $queueRoot "inbox"
$processing = Join-Path $queueRoot "processing"
$done = Join-Path $queueRoot "done"
$failed = Join-Path $queueRoot "failed"
$results = Join-Path $queueRoot "results"
$logsDir = Join-Path $queueRoot "logs"
$lockFile = Join-Path $queueRoot ".worker-$Lane.lock"   # レーン別ロック
$logPath = Join-Path $logsDir "worker-$Lane.log"
$ollamaUrl = "http://localhost:11434/api/generate"
$defaultModel = if ($Lane -eq "light") { "qwen3:8b" } else { "qwen3:8b" }  # 2026-05-28: Heavy も qwen3:8b に統一 (GPU フィット優先・大井指示)
$maxRetries = 3

# レーン判定関数（改善版）
function Test-LaneMatch {
    param($job, $lane)
    if ($lane -eq "any") { return $true }

    # 2026-06-03 レーン飢餓修正: 全ジョブ qwen3:8b 統一後、use_agent→heavy 固定が原因で
    # 全タスクが heavy に偏り light ワーカーが遊休→実質1レーン直列に退化していた。
    # プロンプト長のみで振り分け、中間長は any (両レーンが取得可)。これで2レーン並列が機能しドレインが2倍。
    $len = 0
    if ($job.prompt) { $len = [int]$job.prompt.Length }
    $jobLane = "any"
    if ($len -gt 3000) { $jobLane = "heavy" }
    elseif ($len -lt 800) { $jobLane = "light" }
    else { $jobLane = "any" }

    if ($jobLane -eq "any") { return $true }
    return $jobLane -eq $lane
}

function Write-WorkerLog {
    param([string]$msg)
    $stamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$stamp $msg" | Add-Content $logPath -Encoding UTF8
}

# Pause チェック（最優先）
$pauseFile = Join-Path $queueRoot ".paused"
if (Test-Path $pauseFile) {
    Write-WorkerLog "Skip: system is paused"
    exit 0
}

if (Test-Path $lockFile) {
    $lockAge = (Get-Date) - (Get-Item $lockFile).LastWriteTime
    if ($lockAge.TotalMinutes -lt 60) {
        Write-WorkerLog "Skip: worker already running (lock age: $([int]$lockAge.TotalMinutes)min)"
        exit 0
    } else {
        Write-WorkerLog "Stale lock detected, removing"
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    }
}

try {
    Invoke-RestMethod -Uri "http://localhost:11434/" -TimeoutSec 5 | Out-Null
} catch {
    Write-WorkerLog "Ollama not reachable, exiting"
    exit 0
}

$allTasks = Get-ChildItem -Path $inbox -Filter "*.json" -File -ErrorAction SilentlyContinue | Sort-Object Name
if (-not $allTasks -or $allTasks.Count -eq 0) {
    exit 0
}

# レーン適合するタスクだけを抽出
$task = $null
foreach ($t in $allTasks) {
    try {
        $previewRaw = Get-Content $t.FullName -Raw -Encoding UTF8
        $previewJob = $previewRaw | ConvertFrom-Json
        if (Test-LaneMatch -job $previewJob -lane $Lane) {
            $task = $t
            break
        }
    } catch { continue }
}
if (-not $task) { exit 0 }
"locked $(Get-Date)" | Set-Content $lockFile -Encoding UTF8

try {
    $taskPath = $task.FullName
    $processingPath = Join-Path $processing $task.Name
    Move-Item $taskPath $processingPath -Force
    Write-WorkerLog "Started: $($task.Name)"

    $raw = Get-Content $processingPath -Raw -Encoding UTF8
    $job = $raw | ConvertFrom-Json

    if (-not $job.id) { $job | Add-Member -NotePropertyName id -NotePropertyValue ([guid]::NewGuid().ToString()) -Force }
    if (-not $job.retries) { $job | Add-Member -NotePropertyName retries -NotePropertyValue 0 -Force }
    if (-not $job.model) { $job | Add-Member -NotePropertyName model -NotePropertyValue $defaultModel -Force }

    # VRAM フィットガード (2026-06-03 診断): 8GB GPU(RTX5060)に乗らないモデルは qwen3:8b へ降格。
    # qwen3.6:latest(23-27GB) は 76%CPU 実行になり激遅・30分タイムアウトの主因だった。
    # GPU を増設したら $oversizedModels を空配列にすれば dispatch.ps1 の policy 通りに戻る。
    $oversizedModels = @('qwen3.6:latest')
    if ($oversizedModels -contains $job.model) {
        Write-WorkerLog "Model cap: $($job.model) -> qwen3:8b (8GB GPU fit)"
        $job.model = 'qwen3:8b'
    }

    $contextText = ""
    if ($job.context_files) {
        foreach ($cf in $job.context_files) {
            if (Test-Path $cf) {
                $cfContent = Get-Content $cf -Raw -Encoding UTF8
                $cfShort = $cfContent.Substring(0, [Math]::Min($cfContent.Length, 8000))
                $contextText += "`n`n=== $cf ===`n$cfShort"
            }
        }
    }

    $finalPrompt = $job.prompt
    if ($contextText) {
        $finalPrompt = "$($job.prompt)`n`n[参考資料]$contextText"
    }

    $response = $null

    if ($job.use_agent) {
        # openclaw agent経由（複数ターン自律実行）
        $agentName = "main"
        # 部署別エージェントがあれば使う
        if ($job.department) {
            $deptAgents = @{
                "research" = "research-agent"
                "newbiz" = "newbiz-agent"
                "marketing" = "marketing-agent"
                "dev" = "dev-agent"
                "corp" = "main"
                "secretary" = "main"
                "misc" = "main"
            }
            if ($deptAgents.ContainsKey($job.department)) {
                $candidate = $deptAgents[$job.department]
                # エージェント存在確認
                $existing = openclaw agents list 2>&1 | Select-String -Pattern $candidate
                if ($existing) { $agentName = $candidate }
            }
        }

        Write-WorkerLog "Calling openclaw agent: $agentName, prompt_len=$($finalPrompt.Length)"
        $agentFailed = $false
        try {
            $agentResult = openclaw agent --agent $agentName --message $finalPrompt --json --timeout 1500 2>&1
            $agentResultStr = ($agentResult | Out-String).Trim()
            # openclaw gateway failure detection: stderr starts with "node.exe" prefix or contains EMBEDDED FALLBACK / GatewayTransportError / TimeoutError
            if ($agentResultStr -match '^node\.exe\s*:' -or $agentResultStr -match 'EMBEDDED FALLBACK|GatewayTransportError|CommandLaneTaskTimeoutError') {
                Write-WorkerLog "Agent gateway failed, falling back to direct Ollama"
                $agentFailed = $true
            } else {
                $agentJson = $agentResultStr | ConvertFrom-Json
                if ($agentJson.status -eq "ok" -or $agentJson.status -eq "completed") {
                    $response = $agentJson.result.payloads[0].text
                    $duration = [Math]::Round($agentJson.result.meta.durationMs / 1000, 1)
                    Write-WorkerLog "Agent ok: $duration sec, $($response.Length) chars"
                } else {
                    Write-WorkerLog "Agent status not ok: $($agentJson.status), fallback to Ollama"
                    $agentFailed = $true
                }
            }
        } catch {
            Write-WorkerLog "Agent error (fallback to Ollama): $($_.Exception.Message)"
            $agentFailed = $true
        }
        if ($agentFailed) {
            # Direct Ollama fallback (same as use_agent=false path)
            $bodyObj = [ordered]@{
                model = $job.model
                prompt = $finalPrompt
                stream = $false
                think = $false
                options = [ordered]@{ temperature = 0.3; num_predict = 4000; num_ctx = 8192 }
            }
            $bodyJson = $bodyObj | ConvertTo-Json -Depth 6
            Write-WorkerLog "Fallback Ollama: model=$($job.model), prompt_len=$($finalPrompt.Length)"
            $resp = Invoke-RestMethod -Uri $ollamaUrl -Method Post -Body $bodyJson -ContentType "application/json; charset=utf-8" -TimeoutSec 1800
            $response = $resp.response
            Write-WorkerLog "Fallback Ollama got: $($response.Length) chars"
        }
    } else {
        # 既存のOllama API直叩き（1ターン処理）
        $bodyObj = [ordered]@{
            model = $job.model
            prompt = $finalPrompt
            stream = $false
            think = $false
            options = [ordered]@{ temperature = 0.3; num_predict = 4000; num_ctx = 8192 }
        }
        $bodyJson = $bodyObj | ConvertTo-Json -Depth 6

        Write-WorkerLog "Calling Ollama: model=$($job.model), prompt_len=$($finalPrompt.Length)"
        $resp = Invoke-RestMethod -Uri $ollamaUrl -Method Post -Body $bodyJson -ContentType "application/json; charset=utf-8" -TimeoutSec 1800
        $response = $resp.response
        Write-WorkerLog "Got response: $($response.Length) chars"
    }

    # 完全に空 or null のみエラー扱い（短いレスポンスは意図通りの可能性あり）
    if ([string]::IsNullOrWhiteSpace($response)) {
        throw "Empty response from Ollama (got $($response.Length) chars). Likely model returned empty - retry with different model."
    }

    $resultId = $job.id
    $resultPath = Join-Path $results "$resultId.md"
    $resultHeader = "---`ntask_id: $resultId`ntitle: $($job.title)`nmodel: $($job.model)`ncompleted: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))`n---`n`n"
    [System.IO.File]::WriteAllText($resultPath, $resultHeader + $response, [System.Text.UTF8Encoding]::new($false))

    if ($job.output_path) {
        # 相対パスは brain 配下に解決 (Task Scheduler起動時のCWD=C:\WINDOWS\system32 への書込み失敗を防止)
        $outPath = $job.output_path
        if ($outPath -notmatch '^[A-Za-z]:\\') { $outPath = Join-Path $brainRoot $outPath }
        $outDir = Split-Path -Parent $outPath
        if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
        [System.IO.File]::WriteAllText($outPath, $resultHeader + $response, [System.Text.UTF8Encoding]::new($false))
        Write-WorkerLog "Wrote output_path: $outPath"
    }

    $job | Add-Member -NotePropertyName completed_at -NotePropertyValue ((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) -Force
    $job | Add-Member -NotePropertyName result_path -NotePropertyValue $resultPath -Force
    $donePath = Join-Path $done $task.Name
    $job | ConvertTo-Json -Depth 6 | Set-Content $donePath -Encoding UTF8
    Remove-Item $processingPath -Force
    Write-WorkerLog "Done: $($task.Name)"

    $notifyScript = "C:\Users\Owner\business\brain\scripts\discord_notify.ps1"
    $configFile = "C:\Users\Owner\business\brain\scripts\config.json"
    if ((Test-Path $notifyScript) -and (Test-Path $configFile)) {
        try {
            $cfg = Get-Content $configFile -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($cfg.discord.webhook_url -and $cfg.discord.notify_on_success) {
                $preview = $response.Substring(0, [Math]::Min($response.Length, 300))
                & powershell.exe -NonInteractive -ExecutionPolicy Bypass -File $notifyScript -Title "AI完了: $($job.title)" -Body $preview -Color "green"
            }
        } catch { Write-WorkerLog "Notify error: $($_.Exception.Message)" }
    }

} catch {
    $errMsg = $_.Exception.Message
    Write-WorkerLog "ERROR: $errMsg"
    try {
        $job.retries = [int]$job.retries + 1
        if ($job.retries -ge $maxRetries) {
            $job | Add-Member -NotePropertyName last_error -NotePropertyValue $errMsg -Force
            $failedPath = Join-Path $failed $task.Name
            $job | ConvertTo-Json -Depth 6 | Set-Content $failedPath -Encoding UTF8
            if (Test-Path $processingPath) { Remove-Item $processingPath -Force }
            Write-WorkerLog "Moved to failed after $($job.retries) retries"
            $notifyScript = "C:\Users\Owner\business\brain\scripts\discord_notify.ps1"
            $configFile = "C:\Users\Owner\business\brain\scripts\config.json"
            if ((Test-Path $notifyScript) -and (Test-Path $configFile)) {
                try {
                    $cfg = Get-Content $configFile -Raw -Encoding UTF8 | ConvertFrom-Json
                    if ($cfg.discord.webhook_url -and $cfg.discord.notify_on_failure) {
                        & powershell.exe -NonInteractive -ExecutionPolicy Bypass -File $notifyScript -Title "AI失敗: $($job.title)" -Body "$errMsg`n($($job.retries)回リトライ後)" -Color "red"
                    }
                } catch {}
            }
        } else {
            $job | Add-Member -NotePropertyName last_error -NotePropertyValue $errMsg -Force
            $retryPath = Join-Path $inbox $task.Name
            $job | ConvertTo-Json -Depth 6 | Set-Content $retryPath -Encoding UTF8
            if (Test-Path $processingPath) { Remove-Item $processingPath -Force }
            Write-WorkerLog "Requeued for retry ($($job.retries)/$maxRetries)"
        }
    } catch {
        Write-WorkerLog "FATAL during error handling: $($_.Exception.Message)"
    }
} finally {
    Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
}
