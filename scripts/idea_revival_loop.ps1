#requires -Version 5.1
# Idea Revival Loop - 全entities (17事業) を順番に再評価+ブラッシュアップ
# 2026-05-26 新規: 大井指示「没アプリも自動運用で掘り起こし+ブラッシュアップ」
#
# 1日1回・1事業棚卸し → 17日サイクル
# 各事業: 市場変化考慮した最新ピボット案を生成
# 出力: brain/wiki/concepts/business-revival/{事業}-{日付}.md

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
if (Test-Path "$brain\queue\.paused") { exit 0 }

$dispatcher = "$brain\scripts\dispatch.ps1"
$logPath = "$brain\scripts\idea_revival_loop.log"
$stateFile = "$brain\scripts\.idea_revival_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$today = (Get-Date).ToString("yyyy-MM-dd")

# inbox 300件超ならスキップ
$inboxCount = (Get-ChildItem "$brain\queue\inbox" -File -Filter "*.json" -ErrorAction SilentlyContinue).Count
if ($inboxCount -gt 300 -and $env:REVIVAL_FORCE -ne '1') {
    "$nowStamp - skip: inbox $inboxCount > 300" | Add-Content $logPath -Encoding UTF8
    exit 0
}

# State 読み込み (どのentityを次に処理するか・最終処理日)
$state = @{ index = 0; last_processed = @{} }
if (Test-Path $stateFile) {
    try {
        $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($null -ne $loaded.index) { $state.index = $loaded.index }
        if ($loaded.last_processed) {
            foreach ($p in $loaded.last_processed.PSObject.Properties) {
                $state.last_processed[$p.Name] = $p.Value
            }
        }
    } catch {}
}

# 全entities取得
$entities = Get-ChildItem "$brain\wiki\entities" -Filter '*.md' -ErrorAction SilentlyContinue |
    Where-Object { $_.BaseName -notmatch '^_' } |
    Sort-Object Name

if ($entities.Count -eq 0) {
    "$nowStamp - no entities found" | Add-Content $logPath -Encoding UTF8
    exit 0
}

# 7日以内に処理されてないentityを優先
$cutoff = (Get-Date).AddDays(-7)
$candidates = $entities | Where-Object {
    -not $state.last_processed.ContainsKey($_.BaseName) -or
    ([DateTime]$state.last_processed[$_.BaseName] -lt $cutoff)
}

if ($candidates.Count -eq 0) {
    "$nowStamp - all entities processed in last 7 days, recycling" | Add-Content $logPath -Encoding UTF8
    $candidates = $entities  # 全部処理済みなら全部再走
}

# 次に処理するentity (rotation)
$target = $candidates[$state.index % $candidates.Count]
$entityName = $target.BaseName
$state.index = ($state.index + 1) % $candidates.Count

# 出力先準備
$revivalDir = "$brain\wiki\concepts\business-revival"
if (-not (Test-Path $revivalDir)) { New-Item -ItemType Directory $revivalDir -Force | Out-Null }
$outPath = "$revivalDir\$entityName-$today.md"

# プロンプト生成
$prompt = @"
# タスク: $entityName 事業ピボット+ブラッシュアップ案 ($today)
[[entities/$entityName]]

大井湧瑛 (17→18yo・静岡・現役起業家) の事業 [[$entityName]] を再評価し、最新版ピボット+改善案を出力する。

## 必読
- 既存事業内容: [[entities/$entityName]] のYAML+本文
- 最新市場文脈: [[meta/business-action-from-ai-economy-2026]] [[hot]]
- 大井の判断軸: [[meta/ooi-soul]]
- 森岡毅式コンセプト診断: [[sources/morioka-probability-strategy-2-deep-2026-05-26]]
- シンコード式11ステップ: [[concepts/solopreneur-11steps]]

## 出力フォーマット

### 1. 現状診断 (300字)
- 現ステータス (アクティブ/休眠/没/モニター)
- これまでの実績 (数字あれば)
- なぜ伸びてないか (もし伸びてないなら)

### 2. 森岡式9軸スコア (現状)
| 軸 | 現状スコア | 改善方向 |
|---|---|---|
| 1. 憑依対象 (凡人/狂人) | __/10 | __ |
| 2. WHO (絶対に買う1人) | __/10 | __ |
| 3. WHAT (4要素分解) | __/10 | __ |
| 4. HOW (タッチポイント) | __/10 | __ |
| 5. 一言コンセプト (15字) | __/10 | __ |
| 6. 脳内記号活用 | __/10 | __ |
| 7. インサイト深さ | __/10 | __ |
| 8. エクイティ設計図 | __/10 | __ |
| 9. 絶対に買う1人実在 | __/10 | __ |
| 総合 | __/90 | __ |

### 3. ピボット案3つ (各300字)
それぞれに:
- ピボット方向 (どこを変えるか)
- なぜそれが効くか (市場根拠)
- 最初の1週間アクション (具体的・実行可能)
- 想定収益 (月次)

### 4. シンコード式数字判定 (もしデータあれば)
- CPA測定 推奨予算: __
- PMF判定 推奨期間: __
- LTV/CAC 想定値: __

### 5. 即実行アクション (今週)
- 月曜: __
- 水曜: __
- 金曜: __

### 6. 「もう寝かせる」判定 (場合により)
- 寝かせる根拠: 機会コスト/学習価値/市場タイミング
- 6ヶ月後再評価予定日: __

## ルール
- 大井1人称・キャラ反映 ("俺" "やる" "やめる")
- 数字は推測なら「推測」と明記
- AI臭排除 (「〜することが重要」「様々な」禁止)
- 約3000字以内
"@

& $dispatcher -Department "newbiz" -Title "[Revival] $entityName 再評価+ピボット ($today)" -Prompt $prompt -Model "qwen3:8b" -OutputPath $outPath -Priority "high" 2>&1 | Out-Null

$state.last_processed[$entityName] = (Get-Date).ToString("o")

# State 保存
$serialized = @{
    index = $state.index
    last_processed = $state.last_processed
} | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($stateFile, $serialized, [System.Text.Encoding]::UTF8)

"$nowStamp - dispatched $entityName (index=$($state.index), inbox=$inboxCount)" | Add-Content $logPath -Encoding UTF8
Write-Host "idea_revival: dispatched $entityName (out: $outPath)"
