#requires -Version 5.1
# P1: 大井の「月10万円×100アプリ＝月1000万」戦略の100案を連日生成
# 毎日09:00 起動 / 1日5案 / 20日で100案完了

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$stateFile = Join-Path $brainRoot "scripts\.bg_app_battery_state.json"
$outDir = Join-Path $brainRoot "wiki\_inbox\newbiz\app-battery"
$today = (Get-Date).ToString("yyyy-MM-dd")

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

# state
$state = @{ count = 0; total_target = 100; daily_count = 5 }
if (Test-Path $stateFile) {
    try {
        $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $state.count = [int]$loaded.count
    } catch {}
}

if ($state.count -ge $state.total_target) {
    & "$brainRoot\scripts\notify.ps1" -From OpenClaw -Title "🚀 アプリ量産100案 完了" -Body "100案達成。`nwiki/_inbox/newbiz/app-battery/ を確認。`n次は実装10案を絞り込み。" -Color purple
    exit 0
}

# テーマカテゴリ（バラエティ）
$themes = @(
    "個人事業主の経理・請求書（freee/MFは大きすぎ、もっと特化）"
    "副業の管理・タスク（Notion使えない層向け）"
    "ChatGPTを業務に組み込む小規模ツール"
    "Twitter/X運用の効率化（投稿管理・分析）"
    "メルカリ・ヤフオク・BASE出品者向けツール"
    "YouTube/podcast配信者の業務効率化"
    "美容師・整体師など個人サロンの予約管理"
    "ペット関連（散歩・健康・写真整理）"
    "学習・資格勉強の管理（スマホ完結）"
    "趣味コミュニティの管理（オフ会・グループ）"
    "個人投資家のポートフォリオ可視化"
    "副業ライターの記事管理・納品"
    "個人プログラマーの案件管理"
    "イベント主催（オフ会・勉強会）の運営"
    "サブスク管理（家計の見直し）"
    "電子書籍・kindle出版者の管理"
    "海外移住・ワーホリ準備"
    "結婚式・出産・育児の準備管理"
    "高齢家族のケア記録（介護メモ）"
    "趣味のコレクション管理（カード・本・服）"
)

$batchSize = $state.daily_count
$startIdx = $state.count + 1
$endIdx = [Math]::Min($startIdx + $batchSize - 1, $state.total_target)
$todayThemes = $themes | Get-Random -Count ($endIdx - $startIdx + 1)

$prompt = @"
# タスク: 大井湧瑛の「月10万×100アプリ」戦略・5案具体化（$startIdx 番目〜$endIdx 番目）

## 戦略概要
- 1プロダクト月10万円（サブスク継続課金）
- 100プロダクト並走 = 月1000万円目標
- 1個の開発工数: 既存アプリの1/4規模 = 1週間以内
- ニッチ特化、SEO/SNSで自然流入

## 今日の5テーマ（参考）
$($todayThemes -join "`n")

## 各案について書くこと（厳格に）

\`\`\`markdown
## 案 $startIdx: <アプリ仮称>

### 1行説明（30字以内）
（誰の・どんな痛みを・どう解決）

### 明日使う1人（具体プロファイル）
- 業種・年齢・状況:
- 今困ってる具体事:
- 今使ってる代替案（実在ツール・架空NG）:

### 中核機能 3つ
1. ...
2. ...
3. ...

### 月10万への到達筋（数字）
- 単価: 月¥X
- 必要顧客数: Y人
- 顧客獲得チャネル: SEO/SNS/コミュニティ (具体的に)
- 競合（実在のみ）:

### 開発工数（推定）
- フロント: 約X時間
- バックエンド: 約Y時間
- 計: Z日（1週間以内に収まるか）

### 大井フィット
- 脳汁度: A/B/C
- OS化できる拡張性:
- 大井の強み活かせるか:

### リスク・ボトルネック
- ...

### 完成イメージ MVP最小機能
- ...
\`\`\`

5案分書く。約8000字。架空企業/数字NG。
"@

& $dispatcher `
    -Department "newbiz" `
    -Title "[App-Battery] アプリ量産 $startIdx〜$endIdx 番目" `
    -Prompt $prompt `
    -Model "qwen3:8b" `
    -OutputPath (Join-Path $outDir "batch-$($startIdx.ToString('D3'))-$($endIdx.ToString('D3')).md") `
    -Priority "normal" 2>&1 | Out-Null

# state更新
$state.count = $endIdx
$stateJson = $state | ConvertTo-Json
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

Write-Host "App-Battery: $startIdx-$endIdx dispatched (total $($state.count)/$($state.total_target))"
