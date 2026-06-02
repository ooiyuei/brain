#requires -Version 5.1
# Brain System リアルタイム状態（2秒おきに自動更新）
# Ctrl+C で停止
# 使い方: & scripts\status_live.ps1
# オプション: -IntervalSec 5

param([int]$IntervalSec = 2)

while ($true) {
    & "C:\Users\Owner\business\brain\scripts\status.ps1"
    Start-Sleep -Seconds $IntervalSec
}
