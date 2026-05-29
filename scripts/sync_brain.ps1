#requires -Version 5.1
# sync_brain.ps1 - Windows brain -> GitHub backup, conflict-safe.
#
# Transport model (decided 2026-05-29):
#   - PRIMARY Mac<->Windows transport = Obsidian Sync (real-time, whole vault).
#   - Git (origin/main = github.com/ooiyuei/brain.git) = VERSIONED BACKUP + history.
#   - Windows is the SINGLE git committer. Mac never touches git directly.
#     So git rarely diverges; pull is just a safety net for other machines.
#
# Cycle:
#   1. add -A + commit local (capture Obsidian-Sync-delivered Mac edits + factory output)
#   2. pull --rebase --autostash  (receive any other-machine pushes; abort on conflict)
#   3. push                       (publish backup)
# .gitignore excludes Windows-only runtime (queue/, logs, live-status, per-machine .obsidian).

$ErrorActionPreference = 'Continue'
$OutputEncoding = [System.Text.Encoding]::UTF8
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$brain = 'C:\Users\Owner\business\brain'
$log   = Join-Path $brain 'queue\logs\git-sync.log'
$flag  = Join-Path $brain 'queue\.gitsync.lock'
function Log($m){ try { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $m" | Add-Content -Path $log -Encoding UTF8 } catch {} }

if (-not (Test-Path (Join-Path $brain '.git'))) { Log 'no .git, abort'; return }

if (Test-Path $flag) {
    $age = ((Get-Date) - (Get-Item $flag).LastWriteTime).TotalMinutes
    if ($age -lt 10) { Log "skip: sync already running (lock ${age}m)"; return }
    Remove-Item $flag -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType File -Path $flag -Force | Out-Null

try {
    if (-not (& git -C $brain config user.email)) { & git -C $brain config user.email 'ooiyuei@gmail.com' | Out-Null }
    if (-not (& git -C $brain config user.name))  { & git -C $brain config user.name  'Owner-Windows-Factory' | Out-Null }

    & git -C $brain add -A 2>&1 | Out-Null
    $pending = & git -C $brain status --porcelain
    $committed = $false
    if ($pending) {
        $n = @($pending).Count
        & git -C $brain commit -q -m "chore(brain): factory sync $(Get-Date -Format 'yyyy-MM-dd HH:mm') ($n)" 2>&1 | Out-Null
        $committed = $true
        Log "committed $n change(s)"
    }

    $pull = & git -C $brain pull --rebase --autostash origin main 2>&1
    if ($LASTEXITCODE -ne 0 -or ($pull -match 'CONFLICT|could not apply|rebase failed|error:')) {
        Log "PULL/REBASE CONFLICT -> abort, tree preserved"
        & git -C $brain rebase --abort 2>&1 | Out-Null
        try { & (Join-Path $brain 'scripts\notify.ps1') -From Brain -Title 'git-sync conflict' -Body 'Mac/Win git edits collided. Auto-merge skipped; tree safe. Claude must reconcile.' -Color red | Out-Null } catch {}
        return
    }

    $ahead = (& git -C $brain rev-list --count '@{u}..HEAD' 2>$null)
    if ($committed -or ($ahead -and [int]$ahead -gt 0)) {
        $push = & git -C $brain push origin main 2>&1
        if ($LASTEXITCODE -ne 0) { Log "PUSH FAILED: $($push -join ' ')" } else { Log "pushed (ahead=$ahead)" }
    }

    $delta = & git -C $brain rev-list --left-right --count 'origin/main...HEAD' 2>$null
    Log "tick ok delta(behind ahead)=$delta"
}
finally {
    Remove-Item $flag -Force -ErrorAction SilentlyContinue
}
