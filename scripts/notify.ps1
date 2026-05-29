#requires -Version 5.1
<#
.SYNOPSIS
    Claude（私）が Discord 通知を送るための短縮ヘルパー。

.EXAMPLE
    # 朝の作戦完了
    .\notify.ps1 -From Claude -Title "朝の作戦完了" -Body "今日の最優先: AIpa Web モニター獲得" -Color green

    # 重要アラート
    .\notify.ps1 -From Claude -Title "⚠️ 緊急" -Body "Sentryでクリティカルエラー" -Color red

    # OpenClaw完了報告
    .\notify.ps1 -From OpenClaw -Title "競合分析完了" -Body "Notion/Studyplus/engage 3社" -Color blue -Link "wiki/_inbox/research/"
#>

param(
    [Parameter(Mandatory=$true)][string]$Title,
    [string]$Body = "",
    [ValidateSet("Claude","OpenClaw","Health","Monitor","Worker","Brain")]
    [string]$From = "Claude",
    [ValidateSet("blue","green","red","yellow","purple","gray","orange")]
    [string]$Color = "blue",
    [string]$Link = ""
)

& "C:\Users\Owner\business\brain\scripts\discord_notify.ps1" `
    -Title $Title `
    -Body $Body `
    -From $From `
    -Color $Color `
    -Link $Link
