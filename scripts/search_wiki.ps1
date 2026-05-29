#requires -Version 5.1
# wiki RAG検索：クエリに最も近いチャンクをN件返す

param(
    [Parameter(Mandatory=$true)][string]$Query,
    [int]$TopK = 5
)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$vectorFile = Join-Path $brainRoot "scripts\.wiki_vectors.jsonl"
$ollamaUrl = "http://localhost:11434/api/embeddings"
$model = "nomic-embed-text"

if (-not (Test-Path $vectorFile)) {
    Write-Host "ERROR: vector file not found. Run embed_wiki.ps1 first."
    exit 1
}

# クエリを埋め込み
$body = @{ model = $model; prompt = $Query } | ConvertTo-Json
$resp = Invoke-RestMethod -Uri $ollamaUrl -Method Post -Body $body -ContentType "application/json" -TimeoutSec 30
$queryEmbed = $resp.embedding

# コサイン類似度
function Get-CosineSimilarity {
    param($v1, $v2)
    $dot = 0.0; $n1 = 0.0; $n2 = 0.0
    for ($i = 0; $i -lt $v1.Count; $i++) {
        $dot += $v1[$i] * $v2[$i]
        $n1 += $v1[$i] * $v1[$i]
        $n2 += $v2[$i] * $v2[$i]
    }
    if ($n1 -eq 0 -or $n2 -eq 0) { return 0 }
    return $dot / ([Math]::Sqrt($n1) * [Math]::Sqrt($n2))
}

# 全レコードと類似度計算
$scores = @()
Get-Content $vectorFile -Encoding UTF8 | ForEach-Object {
    if ($_.Trim() -eq "") { return }
    try {
        $r = $_ | ConvertFrom-Json
        $sim = Get-CosineSimilarity -v1 $queryEmbed -v2 $r.embedding
        $scores += [PSCustomObject]@{
            Path = $r.path
            ChunkIdx = $r.chunk_idx
            Preview = $r.text
            Score = $sim
        }
    } catch {}
}

# 上位K件
$top = $scores | Sort-Object Score -Descending | Select-Object -First $TopK

Write-Host "=== Query: $Query ==="
Write-Host ""
foreach ($t in $top) {
    Write-Host "📄 $($t.Path) [chunk $($t.ChunkIdx)] (score: $([Math]::Round($t.Score, 3)))"
    Write-Host "   $($t.Preview)"
    Write-Host ""
}
