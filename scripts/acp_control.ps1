#requires -Version 5.1
# OpenClaw ACPブリッジ起動/停止/状態確認
# 用途: VSCode等のACPクライアントから OpenClaw agent (qwen3.6) を使う

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start","stop","status","client")]
    [string]$Action
)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$processName = "node"
$acpLogPath = "C:\Users\Owner\business\brain\scripts\acp.log"

switch ($Action) {
    "start" {
        # 既に起動してないか確認
        $running = Get-Process -Name "openclaw" -ErrorAction SilentlyContinue
        if ($running) {
            Write-Host "ACP already running (PID: $($running.Id))"
            exit 0
        }

        Write-Host "Starting OpenClaw ACP bridge..."
        # openclaw は .cmd なので cmd.exe 経由で起動
        $openclawCmd = "$env:APPDATA\npm\openclaw.cmd"
        Start-Process -FilePath "cmd.exe" `
            -ArgumentList "/c", $openclawCmd, "acp", "--session", "agent:main:main" `
            -WindowStyle Hidden `
            -RedirectStandardOutput $acpLogPath `
            -RedirectStandardError "$acpLogPath.err"

        Start-Sleep -Seconds 3
        $running = Get-Process -Name "openclaw" -ErrorAction SilentlyContinue
        if ($running) {
            Write-Host "✅ ACP started (PID: $($running.Id))"
            Write-Host "Log: $acpLogPath"
            Write-Host "VSCodeから接続: agent:main:main"
        } else {
            Write-Host "❌ ACP failed to start. Check $acpLogPath.err"
        }
    }

    "stop" {
        $running = Get-Process -Name "openclaw" -ErrorAction SilentlyContinue
        if ($running) {
            $running | Stop-Process -Force
            Write-Host "✅ ACP stopped (PID: $($running.Id))"
        } else {
            Write-Host "ACP not running"
        }
    }

    "status" {
        $running = Get-Process -Name "openclaw" -ErrorAction SilentlyContinue
        if ($running) {
            Write-Host "🟢 ACP running (PID: $($running.Id))"
            Write-Host "  CPU: $($running.CPU)"
            Write-Host "  Memory: $([Math]::Round($running.WorkingSet64 / 1MB, 1))MB"
            if (Test-Path $acpLogPath) {
                Write-Host "  Recent log:"
                Get-Content $acpLogPath -Tail 5
            }
        } else {
            Write-Host "🔴 ACP not running"
        }
    }

    "client" {
        # 対話的ACPクライアント起動
        Write-Host "Starting interactive ACP client..."
        & openclaw acp client --session "agent:main:main"
    }
}
