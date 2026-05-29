#requires -Version 5.1
# wiki/ 全mdファイルを nomic-embed-text で埋め込みベクトル化
# 結果: scripts/.wiki_vectors.jsonl
# 形式: 1行1チャンク = {path, chunk_idx, text, embedding}

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$wikiRoot = Join-Path $brainRoot "wiki"
$entitiesRoot = Join-Path $brainRoot "10_projects"
$conceptsRoot = Join-Path $brainRoot "wiki\concepts"
$vectorFile = Join-Path $brainRoot "scripts\.wiki_vectors.jsonl"
$ollamaUrl = "http://localhost:11434/api/embeddings"
$model = "nomic-embed-text"
$chunkSize = 800   # 文字数
$chunkOverlap = 100

# 既存のvector file をバックアップ
if (Test-Path $vectorFile) {
    $backup = "$vectorFile.bak"
    Move-Item $vectorFile $backup -Force
    Write-Host "Backup: $backup"
}

# 対象ディレクトリ
$targets = @(
    @{ Dir = $wikiRoot; Recurse = $true },
    @{ Dir = $entitiesRoot; Recurse = $false },
    @{ Dir = (Join-Path $brainRoot "routines"); Recurse = $false }
)

$totalChunks = 0
$totalFiles = 0
$utf8 = [System.Text.UTF8Encoding]::new($false)

# Ollamaが embedding model 持ってるか確認
try {
    $modelCheck = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 5
    $hasEmbed = $modelCheck.models | Where-Object { $_.name -like "$model*" }
    if (-not $hasEmbed) {
        Write-Host "ERROR: $model not available. Run: ollama pull $model"
        exit 1
    }
} catch {
    Write-Host "ERROR: Ollama not reachable"
    exit 1
}

foreach ($t in $targets) {
    if (-not (Test-Path $t.Dir)) { continue }
    $files = Get-ChildItem $t.Dir -Filter "*.md" -File -Recurse:$t.Recurse |
        Where-Object { $_.FullName -notmatch "_archive|_inbox\\" }

    foreach ($f in $files) {
        $totalFiles++
        try {
            $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
            $relPath = $f.FullName.Replace($brainRoot, "").TrimStart("\")

            # 短すぎるファイルはスキップ
            if ($content.Length -lt 50) { continue }

            # チャンク分割
            $chunks = @()
            $pos = 0
            $chunkIdx = 0
            while ($pos -lt $content.Length) {
                $end = [Math]::Min($pos + $chunkSize, $content.Length)
                $chunk = $content.Substring($pos, $end - $pos)
                $chunks += @{ idx = $chunkIdx; text = $chunk }
                $chunkIdx++
                $pos = $end - $chunkOverlap
                if ($pos -ge $content.Length) { break }
            }

            foreach ($c in $chunks) {
                # Ollamaに埋め込み依頼
                $body = @{ model = $model; prompt = $c.text } | ConvertTo-Json
                $resp = Invoke-RestMethod -Uri $ollamaUrl -Method Post -Body $body -ContentType "application/json" -TimeoutSec 60

                $record = [ordered]@{
                    path = $relPath
                    chunk_idx = $c.idx
                    text = $c.text.Substring(0, [Math]::Min(200, $c.text.Length))  # プレビュー保存
                    embedding = $resp.embedding
                }
                $jsonLine = $record | ConvertTo-Json -Compress -Depth 5
                $jsonLine | Out-File -FilePath $vectorFile -Append -Encoding UTF8 -NoNewline
                "`n" | Out-File -FilePath $vectorFile -Append -Encoding UTF8 -NoNewline
                $totalChunks++
            }
            Write-Host "✓ $relPath ($($chunks.Count) chunks)"
        } catch {
            Write-Host "✗ $($f.FullName): $($_.Exception.Message)"
        }
    }
}

Write-Host ""
Write-Host "Done: $totalFiles files / $totalChunks chunks → $vectorFile"
