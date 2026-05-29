#requires -Version 5.1
# 毎日09:30 - ビジコン132件のうち10件を個別深掘り。13日で完了。
# state ファイルで進捗管理（次に処理すべき batch番号を保存）

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$contestSource = Join-Path $brainRoot "wiki\entities\business-contests.md"
$stateFile = Join-Path $brainRoot "scripts\.bg_contest_state.json"
$outDir = Join-Path $brainRoot "wiki\research\contests"
$today = (Get-Date).ToString("yyyy-MM-dd")

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

# state読み込み（次のbatch番号）
$state = @{ batch = 0; total_batches = 14; completed = $false }
if (Test-Path $stateFile) {
    try {
        $state = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $state = @{ batch = [int]$state.batch; total_batches = [int]$state.total_batches; completed = [bool]$state.completed }
    } catch {}
}

if ($state.completed) {
    Write-Host "All contest batches completed. Delete BrainBGContests task."
    exit 0
}

$batchNum = $state.batch + 1
$startIdx = $state.batch * 10 + 1
$endIdx = $batchNum * 10

# 132件想定なので最後はoffsetだけ
if ($startIdx -gt 132) {
    # 完了
    $state.completed = $true
    $stateJson = $state | ConvertTo-Json
    [System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

    & "$brainRoot\scripts\notify.ps1" -From OpenClaw -Title "🦞 ビジコン仕分け 全件完了" -Body "132件すべて深掘り完了。`n$outDir に集約。次は Claude が tier付け統合まとめ作成。" -Color green
    exit 0
}

# OpenClawに依頼
$prompt = @"
# タスク: 高校生・学生ビジコン10件の深掘り分析（バッチ$batchNum/14）

## 対象
[[entities/business-contests]] の132件のうち、$startIdx番目〜$endIdx番目（10件）について分析。

## 必要なソース情報
[[entities/business-contests]] を参照してください（worker.ps1がcontext_filesで渡します）。

## 各コンテストについて書くこと
1. 主催・締切・賞金
2. 応募要件（年齢・チーム規模・テーマ）
3. 過去受賞傾向（推定）
4. 大井湧瑛が応募する場合の推奨事業
   - 候補: [[entities/aipa-web]] / [[entities/testall]] / [[entities/agents-of-flag]] / [[entities/aipax]] / [[entities/eemus]] / [[entities/aipax-school]]
5. 勝率予測: ★★★高い / ★★中 / ★低い（理由1行）
6. 応募コスト（推定時間）

## 出力フォーマット
```markdown
---
type: contest-analysis
batch: $batchNum
date: $today
range: $startIdx-$endIdx
tags: [contest, batch-$batchNum]
---

# ビジコン深掘り バッチ$batchNum（$startIdx-$endIdx番目）

## $startIdx. <コンテスト名>
- 主催: ...
- 締切: ...
- 賞金: ...
- 応募要件: ...
- 推奨事業: [[entities/<slug>]]
- 勝率予測: ★★★/★★/★（理由: ...）
- 応募コスト: 約X時間
- 大井へのコメント: ...

## $($startIdx+1). <コンテスト名>
...
```

## 字数: 約4000字以内
## 重要: 推測には「推測:」プレフィックス、不明は「不明」と明記
"@

& $dispatcher `
    -Department "research" `
    -Title "[BG-Contests] バッチ$batchNum ($startIdx-$endIdx)" `
    -Prompt $prompt `
    -ContextFiles @($contestSource) `
    -OutputPath "$outDir\batch-$($batchNum.ToString('D2')).md" `
    -Priority "normal"

# state更新
$state.batch = $batchNum
$stateJson = $state | ConvertTo-Json
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

Write-Host "BG-Contests: dispatched batch $batchNum/$($state.total_batches)"
