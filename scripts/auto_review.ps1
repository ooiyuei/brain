#requires -Version 5.1
# wiki/_inbox/ の OpenClaw 成果物を 1時間おきに自動レビュー
# OpenClaw自身に「スコアリング・類似検知・優劣判定」させる
# 高点 → wiki/_promoted/ に昇格、低点 → wiki/_inbox/_archive/

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$inboxDir = Join-Path $brainRoot "wiki\_inbox"
$promotedDir = Join-Path $brainRoot "wiki\_promoted"
$archiveDir = Join-Path $inboxDir "_archive"
$logPath = Join-Path $brainRoot "scripts\auto_review.log"
$today = (Get-Date).ToString("yyyy-MM-dd")
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

if (-not (Test-Path $promotedDir)) { New-Item -ItemType Directory -Path $promotedDir -Force | Out-Null }
if (-not (Test-Path $archiveDir)) { New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null }

# 部署別の未レビュー成果物（30分以上古い = 安定 + 既レビュー除外）
$reviewsDir = Join-Path $inboxDir "_reviews"
$processedDir = Join-Path $reviewsDir "_processed"
$targets = @()
Get-ChildItem $inboxDir -Directory | Where-Object { $_.Name -in @("research","newbiz","dev","marketing","corp","secretary","misc") } | ForEach-Object {
    $dept = $_.Name
    Get-ChildItem $_.FullName -File -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
        $age = ((Get-Date) - $_.LastWriteTime).TotalMinutes
        if ($age -gt 30) {
            # 重複防止: 既に review がある (_reviews/<dept>/ or _processed/<dept>/) ならスキップ
            $revName = ($_.BaseName) + "-review.md"
            $alreadyPending = Test-Path (Join-Path $reviewsDir "$dept\$revName")
            $alreadyProcessed = Test-Path (Join-Path $processedDir "$dept\$revName")
            if ($alreadyPending -or $alreadyProcessed) { return }

            $targets += [PSCustomObject]@{
                Department = $dept
                Path = $_.FullName
                Name = $_.Name
                Age = [int]$age
            }
        }
    }
}

if ($targets.Count -eq 0) {
    "$nowStamp - no targets to review" | Add-Content $logPath -Encoding UTF8
    Write-Host "No review targets"
    exit 0
}

Write-Host "Found $($targets.Count) files to review"

# 1回のレビューで最大5件処理（負荷分散）
$batch = $targets | Sort-Object Age -Descending | Select-Object -First 15

foreach ($t in $batch) {
    # ファイル内容を読む（最大3000字）
    $content = [System.IO.File]::ReadAllText($t.Path, [System.Text.Encoding]::UTF8)
    if ($content.Length -gt 3000) { $content = $content.Substring(0, 3000) }

    # 同じ部署の他ファイルと類似度比較するため、最近の同部署成果物リスト取得
    $sameDeptOthers = Get-ChildItem (Join-Path $inboxDir $t.Department) -File -Filter "*.md" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne $t.Name } | Sort-Object LastWriteTime -Descending | Select-Object -First 3

    $otherTitles = @()
    foreach ($o in $sameDeptOthers) {
        $otherTitles += $o.Name
    }

    $otherList = if ($otherTitles.Count -gt 0) { "- " + ($otherTitles -join "`n- ") } else { "(同部署他なし)" }

    $reviewPrompt = @"
# タスク: OpenClaw成果物のレビュー・採点

## レビュー対象ファイル
ファイル名: $($t.Name)
部署: $($t.Department)
内容:
``````
$content
``````

## 同部署の他成果物（参考）
$otherList

## 採点軸（各10点・合計50点）厳格化 2026-05-25
1. **明日使えるか (実用性)**: 大井が今すぐ営業・応募・打ち合わせに使えるレベルか (机上論なら3点以下)
2. **数字根拠の精度**: 数字・固有名詞・出典・推測明示 (曖昧なら2点以下)
3. **大井フィット (本人性)**: 大井1人称・キャラ・原体験 (AI臭強いなら2点以下・「思います」連発で-3点)
4. **Mythos準拠 (構造)**: YAML frontmatter ・wikilink `[[entities/xxx]]`・H2構造 (entityリンク無しは2点以下)
5. **新規性/差別化**: 既存wiki成果物との重複でないか・新しい視点があるか

## 判定 (厳格化 2026-05-25)
- 合計 38点以上 → 「PROMOTE」: 正式昇格推奨 (90点級ブラッシュアップ対象)
- 25-37点 → 「KEEP」: Recurrent Pipelineで Depth2/3 再生成
- 25点未満 → 「ARCHIVE」: 価値低い・アーカイブ
※ 「明日使えるか」3点以下なら他軸高くてもKEEP止まり

## 出力フォーマット（厳守・JSONじゃなくMD）
``````markdown
SCORE: <合計点>/50
DECISION: <PROMOTE | KEEP | ARCHIVE>

## 各軸の点数
- 完成度: X
- 新規性: X
- 実用性: X
- 具体性: X
- 大井フィット: X

## 理由（3行以内）
1. ...
2. ...
3. ...

## 改善提案（あれば）
- ...
``````

JSON出力NG、必ずMarkdown。約500字以内。
"@

    # 品質重視: qwen3.6:latest でレビュー
    # priority=high: queue内の大量タスクに埋もれないように優先処理
    & $dispatcher `
        -Department $t.Department `
        -Title "[Auto-Review] $($t.Name)" `
        -Prompt $reviewPrompt `
        -Model "qwen3.6:latest" `
        -OutputPath (Join-Path $brainRoot "wiki\_inbox\_reviews\$($t.Department)\$($t.Name -replace '\.md', '')-review.md") `
        -Priority "high" 2>&1 | Out-Null

    Start-Sleep -Milliseconds 200
}

"$nowStamp - dispatched $($batch.Count) reviews" | Add-Content $logPath -Encoding UTF8
Write-Host "Dispatched $($batch.Count) review tasks (light lane)"
