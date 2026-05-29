#requires -Version 5.1
# MoE Router (Mythos L2) - タスクから最適fillerを動的選択
# 使い方: ./mythos_router.ps1 -TaskHint "AIpa Web 採用業界SEO記事"

param(
    [Parameter(Mandatory=$false)]
    [string]$TaskHint = ""
)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

# 64エキスパート相当のルーティングマップ
# Mythos的に「複数エキスパート(filler)を1タスクに割り当てる」
$expertMap = @{
    # 営業系 (sales experts)
    "営業|顧客リスト|プロスペクト|商談|アポ|断り|切り返し|提案書" = @{
        Filler = "sales_filler.ps1"
        Priority = "high"
        Weight = 0.9
    }
    # マーケ/コンテンツ系
    "LP|SEO|記事|note|ツイート|X投稿|キャッチコピー|コピーライティング|発信" = @{
        Filler = "writing_filler.ps1"
        Priority = "high"
        Weight = 0.85
    }
    # 金軸 (即収益直結)
    "夢AWARD|応募|契約書|モニター|月15万|月50万|β顧客|料金|価格" = @{
        Filler = "money_filler.ps1"
        Priority = "high"
        Weight = 0.95
    }
    # AIpa Web 専門
    "AIpa Web|採用サイト|採用ペイン|HR Tech|採用業界" = @{
        Filler = "aipa_web_filler.ps1"
        Priority = "high"
        Weight = 1.0
    }
    # School 専門
    "AIpaX school|スクール|中高生|親向け|体験会|カリキュラム" = @{
        Filler = "school_content_filler.ps1"
        Priority = "high"
        Weight = 1.0
    }
    # 主力5事業横断
    "AIpaX|Testall|EEMUS|AOF|横断|事業全体" = @{
        Filler = "biz_filler.ps1"
        Priority = "high"
        Weight = 0.9
    }
}

# Shared experts (常時アクティブ・全タスク共通の質ブースター)
$sharedExperts = @(
    "$brainRoot\wiki\meta\ooi-soul.md",
    "$brainRoot\wiki\concepts\thinking-frameworks-hr.md",
    "$brainRoot\wiki\meta\good-business-definition.md"
) | Where-Object { Test-Path $_ }

if ($TaskHint -eq "") {
    Write-Host "=== Router 状態 ==="
    Write-Host "Routed experts: $($expertMap.Count)"
    Write-Host "Shared experts: $($sharedExperts.Count) (常時注入)"
    foreach ($k in $expertMap.Keys) {
        Write-Host "  [$k] → $($expertMap[$k].Filler)"
    }
    exit 0
}

# Top-K (top 2) のexpert選択
$matched = @()
foreach ($pattern in $expertMap.Keys) {
    if ($TaskHint -match $pattern) {
        $matched += [PSCustomObject]@{
            Pattern = $pattern
            Filler = $expertMap[$pattern].Filler
            Priority = $expertMap[$pattern].Priority
            Weight = $expertMap[$pattern].Weight
        }
    }
}

if ($matched.Count -eq 0) {
    Write-Host "No expert matched for: $TaskHint"
    Write-Host "Fallback: biz_filler.ps1"
    exit 0
}

# Weight順にtop-2
$top = $matched | Sort-Object Weight -Descending | Select-Object -First 2
Write-Host "=== Mythos Router: $TaskHint ==="
foreach ($e in $top) {
    Write-Host "  [$($e.Pattern)] → $($e.Filler) (weight=$($e.Weight))"
}
Write-Host "Shared experts注入: $($sharedExperts.Count) files"

# 実際に主filler発火 (top1のみ・top2はバックアップ表示のみ)
$mainFiller = "$brainRoot\scripts\$($top[0].Filler)"
if (Test-Path $mainFiller) {
    & $mainFiller 2>&1 | Out-Null
    Write-Host "✓ Fired: $($top[0].Filler)"
}
