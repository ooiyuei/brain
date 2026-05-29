# Claude の「夢」 = 1日の memory consolidation
# 23:00 にトリガー (Scheduled Task: BrainDreamConsolidation)
# 1日の brain 編集差分 + OpenClaw 完了タスクを集計 → 09_knowledge/learnings/ に保存
# 朝の Claude セッションでこのファイルを最初に確認することで「夢を見た」状態になる

param(
    [string]$Date = (Get-Date).ToString("yyyy-MM-dd")
)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$outDir = "$brain\09_knowledge\learnings"
$outPath = "$outDir\$Date-dream-consolidation.md"
$today = [DateTime]::ParseExact($Date, "yyyy-MM-dd", $null).Date
$tomorrow = $today.AddDays(1)

Write-Host "[dream] 1日の memory consolidation 開始 ($Date)"

# 1. brain 内で当日に変更された .md ファイル収集
$changedFiles = Get-ChildItem -Path $brain -Filter "*.md" -Recurse -ErrorAction SilentlyContinue |
    Where-Object {
        $_.LastWriteTime -ge $today -and $_.LastWriteTime -lt $tomorrow -and
        $_.FullName -notlike "*\queue\*" -and
        $_.FullName -notlike "*\_archive\*" -and
        $_.FullName -notlike "*\_secrets\*"
    } |
    Sort-Object LastWriteTime

# 2. 部署別カウント
$byDept = @{}
foreach ($f in $changedFiles) {
    $rel = $f.FullName.Substring($brain.Length + 1)
    $dept = ($rel -split '\\')[0]
    if (-not $byDept.ContainsKey($dept)) { $byDept[$dept] = @() }
    $byDept[$dept] += $rel
}

# 3. OpenClaw 完了タスク (当日)
$doneTasks = Get-ChildItem -Path "$brain\queue\done" -Filter "*.json" -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $today -and $_.LastWriteTime -lt $tomorrow }
$failedTasks = Get-ChildItem -Path "$brain\queue\failed" -Filter "*.json" -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $today -and $_.LastWriteTime -lt $tomorrow }

# 4. Markdown 生成
$md = @"
---
type: dream-consolidation
date: $Date
generated_at: $((Get-Date).ToString("yyyy-MM-dd HH:mm:ss")) JST
purpose: 1日の brain 編集差分 + OpenClaw 活動を memory consolidation
tags: [dream, consolidation, daily, memory]
---

# Dream Consolidation $Date

> Claude の「夢」 = 1日の脳整理。
> 23:00 自動生成。朝の Claude セッション開始時に最初にこれを読む。

## 📊 1日のサマリー

| 項目 | 数値 |
|---|---|
| brain 編集ファイル数 | $($changedFiles.Count) |
| OpenClaw 完了タスク | $($doneTasks.Count) |
| OpenClaw 失敗タスク | $($failedTasks.Count) |

## 🗂 部署別 編集ファイル

"@
foreach ($dept in $byDept.Keys | Sort-Object) {
    $files = $byDept[$dept]
    $md += "`n### $dept ($($files.Count)件)`n"
    foreach ($file in $files | Select-Object -First 10) {
        $md += "- [[$file]]`n"
    }
    if ($files.Count -gt 10) {
        $md += "- ... +$($files.Count - 10) 件`n"
    }
}

# 5. OpenClaw 完了タスク タイトル一覧
$md += "`n## 🤖 OpenClaw 完了タスク`n"
if ($doneTasks.Count -gt 0) {
    foreach ($t in $doneTasks | Select-Object -First 20) {
        try {
            $j = Get-Content $t.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            $md += "- [$($t.LastWriteTime.ToString('HH:mm'))] $($j.title) (model: $($j.model))`n"
        } catch {
            $md += "- [$($t.LastWriteTime.ToString('HH:mm'))] $($t.Name)`n"
        }
    }
    if ($doneTasks.Count -gt 20) {
        $md += "- ... +$($doneTasks.Count - 20) 件`n"
    }
} else {
    $md += "(なし)`n"
}

# 6. failed タスク
if ($failedTasks.Count -gt 0) {
    $md += "`n## ❌ 失敗タスク (要確認)`n"
    foreach ($t in $failedTasks) {
        $md += "- $($t.Name)`n"
    }
}

# 7. 翌日への申し送り (placeholder - Claude が朝に追記)
$md += @"

## 🌅 翌日の Claude へ申し送り

> このセクションは Claude 朝のセッション開始時に上記サマリーを読んで、以下を埋める:
> - 新発見 3件
> - 失敗パターン (3回ルール検知ならスキル化候補)
> - 大井向け朝のブリーフィング 1行
> - 今日投入すべき意義タスク Top 5

(朝の Claude が追記)

## 🔗 関連
- [[01_ceo/daily-operations-protocol]]
- [[01_ceo/REPORT]]
- [[00_YUEI/TOMORROW]]
"@

# 8. 保存
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$utf8 = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($outPath, $md, $utf8)
Write-Host "[dream] 保存: $outPath"

# 9. Discord 通知 (gray・朝に大井が起きる前)
$summaryBody = @"
brain 編集: $($changedFiles.Count) ファイル
OpenClaw 完了: $($doneTasks.Count) タスク
失敗: $($failedTasks.Count) 件

朝の Claude が consolidate して TOMORROW.md に反映
"@
& "$brain\scripts\discord_notify.ps1" -Title "🌙 Dream Consolidation $Date" -Body $summaryBody -Color "gray" -From "Claude"
