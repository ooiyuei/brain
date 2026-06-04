#requires -Version 5.1
# AI 最新情報 日次リサーチ dispatch ラッパー (BrainAINewsDaily から silent_runner 経由で呼ぶ用)
# 2026-06-04: タスクが powershell -Command 直叩きでウィンドウ点滅していたため、-File 形式のラッパーに分離して完全無音化。
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

& "C:\Users\Owner\business\brain\scripts\dispatch.ps1" `
    -Department research `
    -Title "AI 最新情報日次リサーチ" `
    -Prompt "今日のAI最新情報を framework に沿ってリサーチ。情報源: Anthropic公式・OpenAI公式・Google AI・TechCrunch・The Verge・ITmedia AI+・arxiv。出力: Top3ヘッドライン + 主要ニュース詳細 + 大井のAlmeo/Testall への適用可能性。実在しないニュースを創作しない。不明なら不明と書く。" `
    -Priority high 2>&1 | Out-Null
