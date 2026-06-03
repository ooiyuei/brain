#requires -Version 5.1
# Game Guard - ゲーム検知で自動 pause / 終了で自動 resume
# 2026-06-03 新規: 大井のゲーム中(LoL等)に OpenClaw が GPU を奪わないよう、ゲーム起動を検知したら
#   .paused フラグを立て VRAM を即解放。ゲーム終了を検知したら(=自分が立てたpauseなら)自動解除。
# - queue_guard.ps1 / worker.ps1 / 各filler は .paused があれば exit するので、フラグ1枚で全停止。
# - 手動 pause (pause_brain) と区別するため .paused_by_game マーカーを使い、ゲーム由来のpauseだけ自動解除。

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$queue = "$brain\queue"
$paused = "$queue\.paused"
$gameMarker = "$queue\.paused_by_game"
$logPath = "$brain\scripts\game_guard.log"
$cfgPath = "$brain\scripts\game_processes.txt"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

# ゲームプロセス名リスト (拡張子なし)。config が無ければ既定を作成。大井が1行追加で拡張可。
$defaults = @(
    'League of Legends',          # LoL 本体
    'VALORANT-Win64-Shipping',    # Valorant 本体
    'valorant',
    'csgo', 'cs2',
    'FortniteClient-Win64-Shipping',
    'GenshinImpact', 'YuanShen',
    'eldenring',
    'overwatch',
    'apex_legends', 'r5apex'
)
if (-not (Test-Path $cfgPath)) {
    $header = "# ゲームプロセス名 (拡張子なし・1行1個)。ここに追加すると game_guard が検知して自動pauseする。"
    Set-Content -Path $cfgPath -Value (@($header) + $defaults) -Encoding UTF8
}
$gameProcs = @(Get-Content $cfgPath -Encoding UTF8 -ErrorAction SilentlyContinue | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object { $_.Trim() })
if ($gameProcs.Count -eq 0) { $gameProcs = $defaults }

$running = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -in $gameProcs })

if ($running.Count -gt 0) {
    # ゲーム稼働中
    if (-not (Test-Path $paused)) {
        Set-Content -Path $paused -Value $nowStamp -Force
        Set-Content -Path $gameMarker -Value $running[0].ProcessName -Force
        # VRAM 即解放: ロード中モデルを unload + llama server kill
        try {
            $ps = (Invoke-WebRequest -Uri "http://localhost:11434/api/ps" -UseBasicParsing -TimeoutSec 3).Content | ConvertFrom-Json
            foreach ($m in $ps.models) {
                $b = @{ model = $m.name; keep_alive = 0 } | ConvertTo-Json
                try { Invoke-WebRequest -Uri "http://localhost:11434/api/generate" -Method POST -Body $b -ContentType "application/json" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue | Out-Null } catch {}
            }
        } catch {}
        Get-Process ollama_llama_server -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        "$nowStamp - GAME検知 ($($running[0].ProcessName)) → 自動pause + VRAM解放" | Add-Content $logPath -Encoding UTF8
        Write-Host "game_guard: paused for $($running[0].ProcessName)"
    } else {
        # 既にpause中ならフラグの鮮度だけ保つ(queue_guardの怪奇削除対策。ただしqueue_guardは.pausedでexitするので保険)
        if (Test-Path $gameMarker) { (Get-Item $paused).LastWriteTime = Get-Date }
    }
} else {
    # ゲーム非稼働
    if ((Test-Path $paused) -and (Test-Path $gameMarker)) {
        # 自分(ゲーム)が立てたpauseのみ自動解除。手動pause(マーカー無し)は触らない。
        Remove-Item $paused -Force -ErrorAction SilentlyContinue
        Remove-Item $gameMarker -Force -ErrorAction SilentlyContinue
        "$nowStamp - GAME終了 → 自動resume (.paused解除)" | Add-Content $logPath -Encoding UTF8
        Write-Host "game_guard: resumed (game closed)"
    }
}
