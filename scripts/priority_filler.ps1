#requires -Version 5.1
# Priority Filler - today_priorities.json だけを読んでdispatch (Get-Random静的プールを置換)
# 2026-06-04 品質監査の最重要fix: producerが中央の優先順位を無視し最優先タスク(夢AWARD)が放置される問題を根治。
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
if (Test-Path "$brain\queue\.paused") { exit 0 }
$dispatcher = "$brain\scripts\dispatch.ps1"
$priFile = "$brain\scripts\today_priorities.json"
$logPath = "$brain\scripts\priority_filler.log"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

if (-not (Test-Path $priFile)) { "$nowStamp - no today_priorities.json (Claude未生成)" | Add-Content $logPath -Encoding UTF8; exit 0 }
$pri = Get-Content $priFile -Raw -Encoding UTF8 | ConvertFrom-Json
# 鮮度: generated から48h以内なら有効 (夜通し日付をまたいでも優先順位を効かせる)
$stale = $true
try { $stale = (([DateTime]$pri.generated) -lt (Get-Date).AddHours(-48)) } catch { $stale = $true }

# openclaw_draft を dispatch (dispatch側のdedupガードが12h重複を防ぐ)。staleなら投入せずClaude再生成を待つ。
$dispatched = 0
if (-not $stale) {
    foreach ($t in $pri.openclaw_draft) {
        $stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
        $sid = [guid]::NewGuid().ToString().Substring(0,4)
        $slug = ($t.title -replace '[^\w]','-').ToLower(); if ($slug.Length -gt 40) { $slug = $slug.Substring(0,40) }
        $outPath = "$brain\wiki\_inbox\$($t.department)\pri-$slug-$stamp-$sid.md"
        & $dispatcher -Department $t.department -Title $t.title -Prompt $t.prompt -Model "qwen3:8b" -OutputPath $outPath -Priority "high" 2>&1 | Out-Null
        $dispatched++
    }
} else {
    "$nowStamp - today_priorities が古い(generated=$($pri.generated))。openclaw投入skip・Claude再生成待ち" | Add-Content $logPath -Encoding UTF8
}

# human_only を TODAY.md に昇格 (機械がドラフト量産で『仕事した感』を出して人間のボトルネックを誤魔化すのを止める)
$todayMd = "$brain\00_YUEI\TODAY.md"
$humanLines = @("", "## 🔥 最優先 (機械はやれない・大井の着手が要る) — 更新 $nowStamp")
foreach ($h in $pri.human_only) { $humanLines += "- [ ] **$($h.title)** — $($h.why)" }
foreach ($d in $pri.deadline_watch) {
    $daysLeft = ([DateTime]$d.date - (Get-Date)).Days
    $humanLines += "- ⏰ $($d.title): $($d.date) (残$daysLeft日)"
}
try {
    if (Test-Path $todayMd) {
        $cur = Get-Content $todayMd -Raw -Encoding UTF8
        $cur = [regex]::Replace($cur, "(?ms)^## 🔥 最優先 \(機械はやれない.*?(?=^## |\z)", "")
        [System.IO.File]::WriteAllText($todayMd, $cur.TrimEnd() + "`n" + ($humanLines -join "`n") + "`n", [System.Text.UTF8Encoding]::new($false))
    } else {
        [System.IO.File]::WriteAllText($todayMd, "# TODAY`n" + ($humanLines -join "`n") + "`n", [System.Text.UTF8Encoding]::new($false))
    }
} catch {}

"$nowStamp - priority_filler: dispatched=$dispatched human_only=$($pri.human_only.Count) (stale=$stale)" | Add-Content $logPath -Encoding UTF8
Write-Host "priority_filler: dispatched=$dispatched stale=$stale"
