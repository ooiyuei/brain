#requires -Version 5.1
# 競合動向の統合まとめ自動更新
# BG-Competitive で生成された個別ファイル群を meta/competitive-intel.md に集約

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$competitorsDir = Join-Path $brainRoot "wiki\research\competitors"
$outPath = Join-Path $brainRoot "wiki\meta\competitive-intel.md"
$today = (Get-Date).ToString("yyyy-MM-dd")
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")
$utf8 = [System.Text.UTF8Encoding]::new($false)

if (-not (Test-Path $competitorsDir)) {
    Write-Host "No competitors data yet"
    exit 0
}

# 個別ファイルを最新日付ベースでグルーピング
$competitorFiles = Get-ChildItem $competitorsDir -File -Filter "*.md" -ErrorAction SilentlyContinue

if (-not $competitorFiles -or $competitorFiles.Count -eq 0) {
    Write-Host "No competitor files"
    exit 0
}

# 競合名ごとに最新ファイルを抽出
$latest = @{}
foreach ($f in $competitorFiles) {
    # ファイル名: <competitor-slug>-YYYY-MM-DD.md
    if ($f.BaseName -match '^(.+?)-(\d{4}-\d{2}-\d{2})$') {
        $slug = $matches[1]
        $date = $matches[2]
        if (-not $latest.ContainsKey($slug) -or $latest[$slug].Date -lt $date) {
            $latest[$slug] = @{ File = $f; Date = $date }
        }
    }
}

# 各競合のキー情報を抽出
$competitors = @()
foreach ($key in $latest.Keys) {
    $f = $latest[$key].File
    try {
        $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)

        # frontmatterから情報抽出
        $name = $key
        $product = "unknown"
        $category = "unknown"
        $notice = "中"

        if ($content -match '(?m)^competitor:\s*(.+)$') { $name = $matches[1].Trim() }
        if ($content -match '(?m)^target_product:\s*(.+)$') { $product = $matches[1].Trim() }
        if ($content -match '(?m)^category:\s*(.+)$') { $category = $matches[1].Trim() }
        if ($content -match '注意レベル[\s\S]{0,50}?(高|中|低)') { $notice = $matches[1] }

        # 1行サマリーを抽出
        $summary = ""
        if ($content -match '(?s)## 1行サマリー\s*\n+(.+?)(?=\n##)') {
            $summary = $matches[1].Trim() -replace '\s+', ' '
            if ($summary.Length -gt 80) { $summary = $summary.Substring(0, 80) + "..." }
        }

        $competitors += [PSCustomObject]@{
            Name = $name
            Slug = $key
            Product = $product
            Category = $category
            Notice = $notice
            Summary = $summary
            Date = $latest[$key].Date
            FilePath = "wiki/research/competitors/$($f.Name)"
        }
    } catch {
        Write-Host "Error parsing $($f.Name): $($_.Exception.Message)"
    }
}

# 注意レベル順にソート
$noticeOrder = @{ "高" = 1; "中" = 2; "低" = 3 }
$competitors = $competitors | Sort-Object @{Expression={$noticeOrder[$_.Notice]}}, Name

# === MD組み立て ===
$lines = @()
$lines += "---"
$lines += "type: competitive-intel"
$lines += "title: 競合インテリジェンス（自動集約）"
$lines += "updated: $nowStamp"
$lines += "tags: [meta, competitive, intel, auto-aggregated]"
$lines += "---"
$lines += ""
$lines += "# 競合インテリジェンス 統合MAP"
$lines += ""
$lines += "> ``BG-Competitive`` が生成する個別ファイル（``wiki/research/competitors/``）を毎日11:30に自動集約。"
$lines += "> 最終更新: $nowStamp"
$lines += ""
$lines += "## サマリー"
$lines += ""
$lines += "- 監視対象: $($competitors.Count) 社"
$lines += "- 🔴 注意レベル高: $(($competitors | Where-Object { $_.Notice -eq "高" }).Count) 社"
$lines += "- 🟡 注意レベル中: $(($competitors | Where-Object { $_.Notice -eq "中" }).Count) 社"
$lines += "- 🟢 注意レベル低: $(($competitors | Where-Object { $_.Notice -eq "低" }).Count) 社"
$lines += ""

# プロダクト別グループ
$byProduct = $competitors | Group-Object -Property Product
foreach ($g in $byProduct | Sort-Object Name) {
    $lines += "## [[entities/$($g.Name)]] の競合"
    $lines += ""
    $lines += "| 競合 | カテゴリ | 注意 | 直近更新 | サマリー |"
    $lines += "|---|---|---|---|---|"
    foreach ($c in $g.Group) {
        $notice = switch ($c.Notice) {
            "高" { "🔴" }
            "中" { "🟡" }
            "低" { "🟢" }
            default { "⚪" }
        }
        $lines += "| **$($c.Name)** | $($c.Category) | $notice | $($c.Date) | $($c.Summary) |"
    }
    $lines += ""
}

# 注意レベル高 のものを目立たせる
$highNotice = $competitors | Where-Object { $_.Notice -eq "高" }
if ($highNotice.Count -gt 0) {
    $lines += "## 🔴 要警戒（注意レベル高）"
    $lines += ""
    foreach ($c in $highNotice) {
        $lines += "### $($c.Name) → [[entities/$($c.Product)]]"
        $lines += "- $($c.Summary)"
        $lines += "- 詳細: [[research/competitors/$($c.Slug)-$($c.Date)]]"
        $lines += ""
    }
}

# ===========
$lines += "## 関連リンク"
$lines += ""
$lines += "- 個別レポート群: ``wiki/research/competitors/``"
$lines += "- 朝の競合動向: [[_monitor/competitor-$today]]"
$lines += "- AI業界ニュース: [[_monitor/ai-news-$today]]"
$lines += ""
$lines += "---"
$lines += "_このファイルは ``aggregate_competitive.ps1`` が毎日11:30に自動更新_"

$content = $lines -join "`r`n"
[System.IO.File]::WriteAllText($outPath, $content, $utf8)

Write-Host "Aggregated $($competitors.Count) competitors → $outPath"
