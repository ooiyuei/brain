#requires -Version 5.1
# brushup_pipeline.ps1 — Sonnet/Depth3 ブラッシュアップ
# _promoted/ の PROMOTE済成果物 (35+/50点) を更に磨いて _final/ へ配置
# 大井「70点→90点」の核心ask実装

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$pause = "$brain\queue\.paused"
if (Test-Path $pause) { exit 0 }

$dispatcher = "$brain\scripts\dispatch.ps1"
$promotedDir = "$brain\wiki\_promoted"
$finalDir = "$brain\wiki\_final"
$reviewsProcessed = "$brain\wiki\_inbox\_reviews\_processed"
$stateFile = "$brain\scripts\.brushup_state.json"
$logPath = "$brain\scripts\brushup_pipeline.log"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

# State: brushup済を再処理しない
$state = @{ brushed = @{} }
if (Test-Path $stateFile) {
    try { $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($loaded.brushed) { foreach ($p in $loaded.brushed.PSObject.Properties) { $state.brushed[$p.Name] = $p.Value } }
    } catch {}
}

# 1回最大6件 (workers 4基並列なので増設) — 質重視・夜中ぶん回し対応
$maxBatch = 10
$dispatched = 0

# 各部署の _promoted/ を巡回
$candidates = @()
foreach ($dept in @("marketing","newbiz","dev","corp","research","secretary")) {
    $deptDir = Join-Path $promotedDir $dept
    if (-not (Test-Path $deptDir)) { continue }

    Get-ChildItem $deptDir -File -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
        $f = $_
        $key = "$dept/$($f.Name)"
        if ($state.brushed.ContainsKey($key)) { return }  # 既処理

        # 対応するreview取得 (_processed内)
        $revName = $f.BaseName + "-review.md"
        $revPath = Join-Path $reviewsProcessed "$dept\$revName"
        $score = 0
        $reviewBody = ""
        if (Test-Path $revPath) {
            $revC = [System.IO.File]::ReadAllText($revPath, [System.Text.Encoding]::UTF8)
            $sm = [regex]::Match($revC, 'SCORE:\s*(\d+)\s*/\s*50')
            if ($sm.Success) { $score = [int]$sm.Groups[1].Value }
            $reviewBody = $revC
        }

        $candidates += [PSCustomObject]@{
            Dept = $dept
            File = $f.FullName
            Name = $f.Name
            Score = $score
            ReviewBody = $reviewBody
            Key = $key
        }
    }
}

if ($candidates.Count -eq 0) {
    "$nowStamp - no brushup candidates" | Add-Content $logPath -Encoding UTF8
    Write-Host "No brushup candidates (empty _promoted/)"
    exit 0
}

# 高スコア優先 (最も価値のあるものから磨く)
$batch = $candidates | Sort-Object Score -Descending | Select-Object -First $maxBatch

foreach ($c in $batch) {
    $origContent = [System.IO.File]::ReadAllText($c.File, [System.Text.Encoding]::UTF8)
    if ($origContent.Length -gt 4000) { $origContent = $origContent.Substring(0, 4000) }
    $revShort = if ($c.ReviewBody.Length -gt 1500) { $c.ReviewBody.Substring(0, 1500) } else { $c.ReviewBody }

    # 大井ソウル + フレームワーク注入
    $ctxFiles = @()
    foreach ($f in @("wiki\meta\ooi-soul.md", "wiki\concepts\thinking-frameworks-hr.md", "wiki\hot.md")) {
        $p = Join-Path $brain $f
        if (Test-Path $p) { $ctxFiles += $p }
    }

    $prompt = @"
# タスク: 70点→90点ブラッシュアップ (Sonnet級品質)

## 元成果物 (qwen3.6によるDepth1出力・PROMOTE済 $($c.Score)点)
$origContent

## 採点フィードバック (改善点はここに書いてある)
$revShort

## あなたの仕事
これは「70点を90点にする」最終仕上げ。以下を厳守:

### 必須改善ポイント
1. **大井湧瑛のキャラを徹底注入** (フランク・断定・関西弁混じり可・AI臭NG・「〜と考えられます」「〜と思われます」は1個も使うな)
2. **数字を3つ以上追加** (「業界平均」ではなく「住信SBI調査2025年5月で37.5%」みたいに出典1行)
3. **実在企業名/ツール名のみ** (架空には『推測:』必須)
4. **明日読む1人を冒頭で名指し** (「静岡市の建設業40名・採用担当の田中さん」レベルの具体性)
5. **3ヶ月以内に検証可能なアクション** で締める (「来週水曜10時に〇〇する」)
6. **「審査員/読者を泣かせる/動かす」フレーズ1つ仕込む** (原体験ベース)

### 文体
- 結論→具体例→学び の順
- 接続詞「だが」「ただし」「とはいえ」を3回以上
- 1段落=3-5行以内
- ですます/だ・である は元のスタイルに揃える

### 字数
- 元の1.3倍まで (具体性UP)
- 最大 4500字

### NG
- 抽象論で終わる ("〜を切り拓く" "未来のために" 系)
- 既存事例の流用なしで断言する
- AIpaX/Testall/EEMUS等の実数値を「だいたい」で書く (必ずentities/を参照)

出力は90点版の完成形のみ。前置きも後書きもなし。
"@

    # _final/ への配置パス
    $stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
    $sid = [guid]::NewGuid().ToString().Substring(0,4)
    $finalName = ($c.Name -replace '\.md$', "-90pt-$stamp-$sid.md")
    $finalPath = Join-Path "$finalDir\$($c.Dept)" $finalName

    # NOTE 2026-05-25: Priority="super" (0- prefix) で他のhigh task に埋もれない・最優先処理
    # NOTE 2026-05-25: -UseAgent 外した (openclaw gateway壊れ・直接Ollama)
    & $dispatcher `
        -Department $c.Dept `
        -Title "[Brushup 90pt] $($c.Name.Substring(0, [Math]::Min(50, $c.Name.Length)))" `
        -Prompt $prompt `
        -Model "qwen3.6:latest" `
        -ContextFiles $ctxFiles `
        -OutputPath $finalPath `
        -Priority "super" 2>&1 | Out-Null

    # 元promoted ファイルを _archive へ移動 (二重brushup防止 + 後で復元可)
    $promotedArchive = Join-Path $brain "wiki\_promoted\_brushed"
    if (-not (Test-Path "$promotedArchive\$($c.Dept)")) {
        New-Item -ItemType Directory -Path "$promotedArchive\$($c.Dept)" -Force | Out-Null
    }
    Move-Item $c.File (Join-Path "$promotedArchive\$($c.Dept)" $c.Name) -Force

    $state.brushed[$c.Key] = @{
        score = $c.Score
        final = $finalName
        at = (Get-Date).ToString("o")
    }
    $dispatched++
    "$nowStamp - BRUSHUP [$($c.Score)pt] $($c.Key) -> _final/$($c.Dept)/$finalName" | Add-Content $logPath -Encoding UTF8
    Write-Host "Brushup: [$($c.Score)pt] $($c.Key) -> $finalName"
}

# State保存
$stateJson = $state | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

# Discord通知
if ($dispatched -gt 0) {
    $body = "$dispatched 件を _final/ へブラッシュアップ投入中 (元70→90点目標)"
    & "$brain\scripts\notify.ps1" -From Claude -Title "✨ Brushup Pipeline" -Body $body -Color purple 2>&1 | Out-Null
}

"$nowStamp - dispatched $dispatched brushup tasks" | Add-Content $logPath -Encoding UTF8
Write-Host "Brushup pipeline: $dispatched dispatched"

