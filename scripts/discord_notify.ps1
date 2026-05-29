param(
    [Parameter(Mandatory=$true)][string]$Title,
    [string]$Body = "",
    [ValidateSet("blue","green","red","yellow","purple","gray","orange")]
    [string]$Color = "blue",
    [string[]]$Fields = @(),
    [string]$From = "Brain",         # 送信元（Claude / OpenClaw / Health / Monitor / Worker）
    [string]$Link = ""                # 関連リンク（wiki/路径など）
)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$configPath = "C:\Users\Owner\business\brain\scripts\config.json"
if (-not (Test-Path $configPath)) {
    Write-Host "config.json not found"
    exit 1
}

$config = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$webhookUrl = $config.discord.webhook_url

if (-not $webhookUrl -or $webhookUrl -eq "") {
    Write-Host "Discord webhook_url not configured (skipping notification)"
    exit 0
}

# Discord embed の制限
# title: 256字 / description: 4096字 / field.value: 1024字
if ($Title.Length -gt 256) { $Title = $Title.Substring(0, 253) + "..." }
if ($Body.Length -gt 4000) { $Body = $Body.Substring(0, 3997) + "..." }

$colorMap = @{
    "blue"   = 3447003
    "green"  = 5763719
    "red"    = 15548997
    "yellow" = 16776960
    "purple" = 10181046
    "gray"   = 9807270
    "orange" = 15105570
}
$colorCode = if ($colorMap.ContainsKey($Color)) { $colorMap[$Color] } else { 3447003 }

# 送信元別のアイコン・絵文字
$fromIcons = @{
    "Claude"   = "🧠"
    "OpenClaw" = "🦞"
    "Health"   = "🩺"
    "Monitor"  = "👀"
    "Worker"   = "⚙️"
    "Brain"    = "🧠"
}
$icon = if ($fromIcons.ContainsKey($From)) { $fromIcons[$From] } else { "🧠" }
$username = "$icon Brain $From"

$embed = [ordered]@{
    title = $Title
    description = $Body
    color = $colorCode
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

if ($Fields.Count -gt 0) {
    $fieldList = @()
    for ($i = 0; $i -lt $Fields.Count; $i += 2) {
        if ($i + 1 -lt $Fields.Count) {
            $name = $Fields[$i]
            $value = $Fields[$i + 1]
            if ($value.Length -gt 1024) { $value = $value.Substring(0, 1021) + "..." }
            $fieldList += [ordered]@{
                name = $name
                value = $value
                inline = $true
            }
        }
    }
    $embed["fields"] = $fieldList
}

if ($Link) {
    $embed["url"] = $Link
}

$embed["footer"] = [ordered]@{ text = (Get-Date).ToString("yyyy-MM-dd HH:mm") }

$payload = [ordered]@{
    username = $username
    embeds = @($embed)
}

$json = $payload | ConvertTo-Json -Depth 10 -Compress
try {
    $null = Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $json -ContentType "application/json; charset=utf-8" -TimeoutSec 10
    Write-Host "Discord: [$From] $Title"
} catch {
    Write-Host "Discord notification failed: $($_.Exception.Message)"
}
