# brain 掘り起こしスクリプト (毎週日曜 21:00)
# 大井指示 (2026-05-28): brain 掘り起こしたら活用されてないのとか死ぬほどあると思う・常に監視して掘り起こして
# 出力: 09_knowledge/excavation/YYYY-MM-DD-excavation.md

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$date = (Get-Date).ToString("yyyy-MM-dd")
$nowFull = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$outDir = "$brain\09_knowledge\excavation"
$outPath = "$outDir\$date-excavation.md"

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

$now = Get-Date

# 1. 30日以上更新されてないが、内容が3000字以上ある重要そうなファイル
$cutoff30 = $now.AddDays(-30)
$dormant = Get-ChildItem $brain -Filter "*.md" -Recurse -ErrorAction SilentlyContinue |
    Where-Object {
        $_.LastWriteTime -lt $cutoff30 -and
        $_.Length -gt 3000 -and
        $_.FullName -notlike "*\queue\*" -and
        $_.FullName -notlike "*\_archive\*" -and
        $_.FullName -notlike "*\_secrets\*" -and
        $_.FullName -notlike "*\node_modules\*"
    } |
    Sort-Object Length -Descending |
    Select-Object -First 30

# 2. 90日以上完全に放置 (削除候補)
$cutoff90 = $now.AddDays(-90)
$abandoned = Get-ChildItem $brain -Filter "*.md" -Recurse -ErrorAction SilentlyContinue |
    Where-Object {
        $_.LastWriteTime -lt $cutoff90 -and
        $_.Length -gt 500 -and
        $_.FullName -notlike "*\queue\*" -and
        $_.FullName -notlike "*\_archive\*" -and
        $_.FullName -notlike "*\_secrets\*" -and
        $_.FullName -notlike "*\node_modules\*"
    } |
    Sort-Object LastWriteTime |
    Select-Object -First 20

# 3. 今日 (一週間以内) 編集されたが、wiki/_inbox にあって PROMOTE 待ちのもの
$inboxWaiting = Get-ChildItem "$brain\wiki\_inbox" -Filter "*.md" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -gt 1000 } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 20

# 4. 09_knowledge/ 配下で skills/ failures/ successes/ が薄い (蓄積率)
$knowSkills = (Get-ChildItem "$brain\09_knowledge\skills" -Filter "*.md" -Recurse -ErrorAction SilentlyContinue).Count
$knowFails = (Get-ChildItem "$brain\09_knowledge\failures" -Filter "*.md" -Recurse -ErrorAction SilentlyContinue).Count
$knowSuccess = (Get-ChildItem "$brain\09_knowledge\successes" -Filter "*.md" -Recurse -ErrorAction SilentlyContinue).Count
$knowLearn = (Get-ChildItem "$brain\09_knowledge\learnings" -Filter "*.md" -Recurse -ErrorAction SilentlyContinue).Count

# 5. Markdown 生成
$md = @"
---
type: brain-excavation
date: $date
generated_at: $nowFull JST
purpose: brain 掘り起こし - 活用されていない知識を発見し、復活/統合/削除を判定
tags: [excavation, brain-maintenance, dormant-files]
---

# Brain Excavation $date

> 大井指示 (2026-05-28): 「brain 掘り起こしたら活用されてないのとか死ぬほどあると思う」
> 週次自動実行 (BrainExcavation Scheduled Task)。Claude が朝に確認して PROMOTE / DELETE / 再活用 判定。

## 📊 ナレッジ蓄積率 (09_knowledge/)

| カテゴリ | 件数 | 健全度 |
|---|---|---|
| learnings | $knowLearn | $(if ($knowLearn -gt 20) {'OK'} else {'low'}) |
| frameworks (要追加) | - | - |
| skills | $knowSkills | $(if ($knowSkills -gt 10) {'OK'} else {'low'}) |
| successes | $knowSuccess | $(if ($knowSuccess -gt 5) {'OK'} else {'low'}) |
| failures | $knowFails | $(if ($knowFails -gt 5) {'OK'} else {'low'}) |

## 💤 30日以上 dormant な重要ファイル ($($dormant.Count) 件)

これらは「書いたけど使われてない」可能性。Claude が中身確認して、PROMOTE / 再要約 / アクション化 を判断する。

"@

foreach ($f in $dormant) {
    $rel = $f.FullName.Substring($brain.Length + 1) -replace '\\', '/'
    $size = [Math]::Round($f.Length / 1KB, 1)
    $age = [Math]::Floor(($now - $f.LastWriteTime).TotalDays)
    $md += "- [[$rel]] ($($size)KB / ${age}日前)`n"
}

$md += @"

## 🗑 90日以上放置 ($($abandoned.Count) 件・削除候補)

"@

foreach ($f in $abandoned) {
    $rel = $f.FullName.Substring($brain.Length + 1) -replace '\\', '/'
    $size = [Math]::Round($f.Length / 1KB, 1)
    $age = [Math]::Floor(($now - $f.LastWriteTime).TotalDays)
    $md += "- $rel (${size}KB / ${age}日前)`n"
}

$md += @"

## 📥 wiki/_inbox PROMOTE 待ち ($($inboxWaiting.Count) 件)

"@

foreach ($f in $inboxWaiting) {
    $rel = $f.FullName.Substring($brain.Length + 1) -replace '\\', '/'
    $size = [Math]::Round($f.Length / 1KB, 1)
    $md += "- [[$rel]] ($($size)KB)`n"
}

$md += @"

## 🎯 Claude が次にやるアクション

1. **dormant 30件** を上から5件読んで、PROMOTE / 再要約 / アクション化を判定
2. **abandoned 20件** を上から5件読んで、削除 OK か確認
3. **inbox 20件** を全部 PROMOTE 判定
4. successes / failures が少ないので、過去の事例を learnings から抽出して蓄積

## 関連
- [[01_ceo/daily-operations-protocol]] (§3 brain 広く見る)
- [[wiki/CLAUDE.md]] (ノウハウライフサイクル)
"@

$utf8 = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($outPath, $md, $utf8)
Write-Host "[brain_excavation] saved: $outPath"

# Discord 通知 (yellow・週次の重要レポート)
$titleText = "[Brain Excavation] " + $date
$summaryBody = "dormant 30件・abandoned 20件・inbox PROMOTE待ち 20件を検出. Claude 朝の確認待ち.`nlearnings $knowLearn / skills $knowSkills / successes $knowSuccess / failures $knowFails"
& "$brain\scripts\discord_notify.ps1" -Title $titleText -Body $summaryBody -Color "yellow" -From "Monitor"
