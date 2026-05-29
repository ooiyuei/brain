#requires -Version 5.1
# Recurrent Pipeline (Mythos L3) - 1タスクを最大3回ループしてブラッシュアップ
# 動作: 既存 _inbox/ 成果物の中で要改善のものを Depth2/Depth3 でリトライ
# ACT Halting: スコア伸び率<5で自動停止

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$logPath = Join-Path $brainRoot "scripts\recurrent_pipeline.log"
$stateFile = Join-Path $brainRoot "scripts\.recurrent_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

$reviewsDir = Join-Path $brainRoot "wiki\_inbox\_reviews"
$processedDir = Join-Path $reviewsDir "_processed"
$depthTemplates = Join-Path $brainRoot "scripts\prompt_templates"

# Original探索: _inbox → _promoted → _archive → _processed の順で探す
function Find-OriginalFile {
    param([string]$Dept, [string]$OrigName)
    $searchPaths = @(
        "$brainRoot\wiki\_inbox\$Dept\$OrigName",
        "$brainRoot\wiki\_promoted\$Dept\$OrigName",
        "$brainRoot\wiki\_inbox\_archive\$Dept\$OrigName"
    )
    foreach ($p in $searchPaths) {
        if (Test-Path $p) { return $p }
    }
    # 深い検索 (再帰)
    $hit = Get-ChildItem "$brainRoot\wiki\_inbox" -Recurse -File -Filter $OrigName -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($hit) { return $hit.FullName }
    return $null
}

# state: 各ファイルのDepth履歴・スコア推移
$state = @{ depth = @{} }
if (Test-Path $stateFile) {
    try { $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($loaded.depth) {
            foreach ($p in $loaded.depth.PSObject.Properties) { $state.depth[$p.Name] = $p.Value }
        }
    } catch {}
}

# 1回の実行で処理する最大ファイル数 (負荷分散)
$maxBatch = 5

# 候補: review済 KEEP判定 (22-34点) のファイル = 改善余地あり
# _reviews/{dept}/ と _reviews/_processed/{dept}/ 両方を見る
$candidates = @()
$searchDirs = @()
foreach ($dept in @("marketing","newbiz","research","dev","corp","secretary")) {
    $searchDirs += Join-Path $reviewsDir $dept
    $searchDirs += Join-Path $processedDir $dept
}
foreach ($dDir in $searchDirs) {
    if (-not (Test-Path $dDir)) { continue }
    $dept = if ($dDir -like "*_processed*") { Split-Path $dDir -Leaf } else { Split-Path $dDir -Leaf }
    Get-ChildItem $dDir -File -Filter "*-review.md" -ErrorAction SilentlyContinue | ForEach-Object {
        $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
        $sm = [regex]::Match($content, 'SCORE:\s*(\d+)\s*/\s*50')
        $dm = [regex]::Match($content, 'DECISION:\s*(PROMOTE|KEEP|ARCHIVE)')
        if (-not $dm.Success) { return }
        $score = if ($sm.Success) { [int]$sm.Groups[1].Value } else { 0 }
        $decision = $dm.Groups[1].Value.ToUpper()

        # KEEP判定 (22-34点) のみが Recurrent対象
        # 既にDepth3まで処理済はスキップ
        if ($decision -eq "KEEP" -and $score -ge 22 -and $score -le 34) {
            $origName = $_.BaseName -replace '-review$', '.md'
            $origPath = Find-OriginalFile -Dept $dept -OrigName $origName
            if ($origPath) {
                $key = "$dept/$origName"
                $depthLevel = if ($state.depth[$key]) { $state.depth[$key].depth } else { 1 }
                if ($depthLevel -ge 3) { return }  # Depth3完了済はスキップ

                # ACT Halting v2 (Multi-Criteria) - L4' Brain Mythos v2
                # 4条件のうち1つでも成立で halt
                if ($state.depth[$key]) {
                    $prevScore = $state.depth[$key].lastScore
                    $slope = $score - $prevScore

                    # 条件1: slope < 5 (改善幅小・Depth2以降)
                    if ($slope -lt 5 -and $depthLevel -ge 2) {
                        Add-Content $logPath -Value "$nowStamp - HALT[slope] [$key] slope=$slope D$depthLevel" -Encoding UTF8
                        return
                    }

                    # 条件2: spectral regression (スコア悪化 = 発散兆候・L7)
                    if ($slope -lt 0) {
                        Add-Content $logPath -Value "$nowStamp - HALT[spectral] [$key] slope=$slope (regression) D$depthLevel" -Encoding UTF8
                        return
                    }
                }

                # 条件3: high confidence (score >= 45/50 = 90% = もう完成)
                if ($score -ge 45) {
                    Add-Content $logPath -Value "$nowStamp - HALT[confidence] [$key] score=$score >= 45 D$depthLevel" -Encoding UTF8
                    return
                }

                $candidates += [PSCustomObject]@{
                    Department = $dept
                    OrigPath = $origPath
                    ReviewPath = $_.FullName
                    OrigName = $origName
                    Score = $score
                    DepthLevel = $depthLevel
                    Key = $key
                    ReviewContent = $content
                }
            }
        }
    }
}

if ($candidates.Count -eq 0) {
    "$nowStamp - no recurrent candidates" | Add-Content $logPath -Encoding UTF8
    Write-Host "No recurrent candidates"
    exit 0
}

# スコア低い順 (改善余地大) を優先
$batch = $candidates | Sort-Object Score | Select-Object -First $maxBatch
Write-Host "Recurrent batch: $($batch.Count) files"

foreach ($c in $batch) {
    $nextDepth = $c.DepthLevel + 1
    $origContent = [System.IO.File]::ReadAllText($c.OrigPath, [System.Text.Encoding]::UTF8)
    if ($origContent.Length -gt 3000) { $origContent = $origContent.Substring(0, 3000) }

    # Depth別テンプレート読み込み
    $tplPath = Join-Path $depthTemplates "depth_${nextDepth}_*.md"
    $tplFiles = Get-ChildItem $tplPath -ErrorAction SilentlyContinue | Select-Object -First 1
    $depthTpl = ""
    if ($tplFiles) {
        $depthTpl = [System.IO.File]::ReadAllText($tplFiles.FullName, [System.Text.Encoding]::UTF8)
    } else {
        # フォールバック: ハードコードDepth別指示
        $depthTpl = switch ($nextDepth) {
            2 { "## Depth 2 改善モード`n前回の弱点に絞って書き直せ。下記レビューの『改善提案』を全部反映。" }
            3 { "## Depth 3 仕上げモード`n大井のキャラ(フランク・断定・関西弁混じり可・AI臭NG)を徹底。実在事業entities/必読。" }
            default { "## 改善モード" }
        }
    }

    # 大井ソウルとフレームワーク注入用パス
    $ctxFiles = @()
    foreach ($f in @("wiki\meta\ooi-soul.md", "wiki\concepts\thinking-frameworks-hr.md")) {
        $p = Join-Path $brainRoot $f
        if (Test-Path $p) { $ctxFiles += $p }
    }

    $prompt = @"
$depthTpl

## 前回成果物 (Depth $($c.DepthLevel) 出力)
$origContent

## 採点フィードバック (改善点)
$($c.ReviewContent.Substring(0, [Math]::Min(2000, $c.ReviewContent.Length)))

## あなたの仕事
上記の改善点を全部反映して、Depth $nextDepth 版を書き直せ。
- Depth 2: 改善ポイント特化で書き直し
- Depth 3: 大井キャラ厳密化 + entities/参照 + 実在企業名のみ

字数: 2000-3500字 (前回より具体性UP)
"@

    # Depth別の出力先 (元ファイルを更新じゃなく別ファイル)
    $newName = $c.OrigName -replace '\.md$', "-d$nextDepth.md"
    $newPath = Join-Path "$brainRoot\wiki\_inbox\$($c.Department)" $newName

    & $dispatcher `
        -Department $c.Department `
        -Title "[D$nextDepth] $($c.OrigName)" `
        -Prompt $prompt `
        -Model "qwen3.6:latest" `
        -ContextFiles $ctxFiles `
        -OutputPath $newPath `
        -Priority "high" `
        -UseAgent 2>&1 | Out-Null

    # state更新
    $state.depth[$c.Key] = @{
        depth = $nextDepth
        lastScore = $c.Score
        lastUpdate = (Get-Date).ToString("o")
    }

    "$nowStamp - DEPTH$nextDepth [$($c.Key)] prevScore=$($c.Score)" | Add-Content $logPath -Encoding UTF8
    Write-Host "Recurrent D$nextDepth -> $newName (prev: $($c.Score)pt)"

    Start-Sleep -Milliseconds 200
}

# state保存
$stateJson = $state | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

"$nowStamp - dispatched $($batch.Count) recurrent tasks" | Add-Content $logPath -Encoding UTF8
Write-Host "Recurrent pipeline: $($batch.Count) dispatched"
