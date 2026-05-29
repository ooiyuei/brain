#requires -Version 5.1
<#
.SYNOPSIS
    Obsidian(Mac) → 工場(OpenClaw) インテーク・ブリッジ。ファクトリーパターンの「受付」。

.DESCRIPTION
    大井が Mac の Obsidian で `00_YUEI/工場.md` に書いた指示を、
    Obsidian Sync 経由で Windows に届いた後、自動で queue へ投入する。
    Claude セッションが開いていなくても Task Scheduler (BrainFactoryBridge / 3分毎) で動く。

    設計（producer → queue → consumer のファクトリーパターン）:
      [Mac Obsidian] --同期--> 00_YUEI/工場.md  (唯一の受付口 = 単一の真実)
                                     |  factory_bridge.ps1 (この受付係)
                                     v
                              queue/inbox/*.json  --> worker.ps1 (qwen3.6/qwen3:8b)
                                     |
                                     v
                              00_YUEI/工場-受付.md (受領レシート、Macへ同期して返す)

    分断しない工夫:
      - Windows 側は 工場.md に書き戻さない（大井が Mac で編集中でも衝突しない）
      - 投入済みは別ファイル(ledger)でハッシュ管理 → 再同期で二重投入しない
      - レシートは別ファイルに出すので、Mac で「受け付けた」が見える
#>

$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.Encoding]::UTF8
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$brain    = 'C:\Users\Owner\business\brain'
$intake   = Join-Path $brain '00_YUEI\工場.md'
$receipts = Join-Path $brain '00_YUEI\工場-受付.md'
$ledger   = Join-Path $brain 'queue\.factory_ledger.json'
$dispatch = Join-Path $brain 'scripts\dispatch.ps1'
$logDir   = Join-Path $brain 'queue\logs'
$logf     = Join-Path $logDir 'factory-bridge.log'

if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Force $logDir | Out-Null }
function Log($m){ try { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $m" | Add-Content -Path $logf -Encoding UTF8 } catch {} }

if (-not (Test-Path $intake)) { Log "intake missing: $intake"; return }
if (-not (Test-Path $dispatch)) { Log "FATAL dispatch.ps1 missing"; return }

# --- ledger 読み込み (hash -> info) ---
$seen = @{}
if (Test-Path $ledger) {
    try {
        $ltext = [System.IO.File]::ReadAllText($ledger, [System.Text.Encoding]::UTF8)
        if ($ltext.Trim()) {
            $obj = $ltext | ConvertFrom-Json
            foreach ($p in $obj.PSObject.Properties) { $seen[$p.Name] = $p.Value }
        }
    } catch { Log "ledger parse error (続行): $($_.Exception.Message)" }
}

$validDepts = @('research','newbiz','dev','marketing','corp','secretary','misc')
$validPrio  = @('super','high','normal','low','late')
$sha = New-Object System.Security.Cryptography.SHA256Managed

$raw = [System.IO.File]::ReadAllText($intake, [System.Text.Encoding]::UTF8)
$lines = $raw -split "`r?`n"
$dispatched = @()
$inProcessed = $false   # 「処理済み」見出し以降は無視

foreach ($raw in $lines) {
    $line = $raw.Trim()
    if ($line -match '^#{1,6}\s') {
        if ($line -match '処理済み|受付済|DONE|done|履歴|ARCHIVE') { $inProcessed = $true } else { $inProcessed = $false }
        continue
    }
    if ($inProcessed) { continue }
    if ($line -notmatch '^[-*]\s+\S') { continue }           # 箇条書き行だけが指示
    $body = ($line -replace '^[-*]\s+','').Trim()
    if ($body.Length -lt 4) { continue }
    if ($body -match '^(✅|☑|\[x\]|\[X\]|済|DONE|done)') { continue }   # 大井が消化済みにした行
    if ($body -match '^(>|例[:：]|format|フォーマット|書き方)') { continue }  # 説明行

    $norm = ($body -replace '\s+',' ').Trim()
    $hash = [System.BitConverter]::ToString($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($norm))).Replace('-','').Substring(0,16)
    if ($seen.ContainsKey($hash)) { continue }               # 投入済み → スキップ(二重投入防止)

    # 任意ヒント:  @部署  !優先度  （無くてOK）
    $dept = 'newbiz'; $prio = 'normal'
    $md = [regex]::Match($body, '@([A-Za-z_]+)')
    if ($md.Success -and ($validDepts -contains $md.Groups[1].Value.ToLower())) { $dept = $md.Groups[1].Value.ToLower() }
    $mp = [regex]::Match($body, '!(super|high|normal|low|late)')
    if ($mp.Success) { $prio = $mp.Groups[1].Value }

    $prompt = ($body -replace '@[A-Za-z_]+','' -replace '!(super|high|normal|low|late)','').Trim()
    if ($prompt.Length -lt 4) { continue }
    $title = if ($prompt.Length -gt 40) { $prompt.Substring(0,40) } else { $prompt }

    try {
        & $dispatch -Department $dept -Title $title -Prompt $prompt -Priority $prio 2>&1 | Out-Null
        $seen[$hash] = [ordered]@{ at = (Get-Date).ToString('yyyy-MM-dd HH:mm'); dept = $dept; prio = $prio; title = $title }
        $dispatched += [pscustomobject]@{ dept = $dept; prio = $prio; title = $title }
        Log "DISPATCH [$dept/$prio] $title"
    } catch {
        Log "ERROR dispatch '$title': $($_.Exception.Message)"
    }
}

# --- ledger 保存 ---
try { [System.IO.File]::WriteAllText($ledger, ($seen | ConvertTo-Json -Depth 5), (New-Object System.Text.UTF8Encoding($false))) } catch { Log "ledger save error: $($_.Exception.Message)" }

# --- レシート (Macへ同期して返す。工場.md には触らない) ---
if ($dispatched.Count -gt 0) {
    if (-not (Test-Path $receipts)) {
        @(
            '---','type: factory-receipts','managed_by: factory_bridge.ps1 (自動)','---','',
            '# 🏭 工場 受付レシート',
            '',
            '> `00_YUEI/工場.md` に書いた指示が工場(OpenClaw)に投入されると、ここに記録される。',
            '> 成果物は数分〜数十分後に `wiki/_inbox/{部署}/` に届く。',
            ''
        ) -join "`n" | Set-Content -Path $receipts -Encoding UTF8
    }
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
    $blk = @("", "### $stamp — $($dispatched.Count) 件 投入") + ($dispatched | ForEach-Object { "- ✅ [$($_.dept)/$($_.prio)] $($_.title)" })
    ($blk -join "`n") | Add-Content -Path $receipts -Encoding UTF8

    try {
        & (Join-Path $brain 'scripts\notify.ps1') -From Claude -Title "🏭 工場に $($dispatched.Count) 件投入" -Body (($dispatched | ForEach-Object { $_.title }) -join ' / ') -Color blue | Out-Null
    } catch {}
    Log "receipts +$($dispatched.Count)"
}

Log "tick done (new=$($dispatched.Count), ledger=$($seen.Count))"
