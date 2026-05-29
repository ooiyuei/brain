#requires -Version 5.1
# P2: AIpa Web 顧客獲得 - リスト作成 → メール送信 → リード獲得
# 毎日09:45 起動 / 3フェーズ循環（リスト/メール/分析）

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$stateFile = Join-Path $brainRoot "scripts\.bg_aipa_outreach_state.json"
$outBaseDir = Join-Path $brainRoot "wiki\_inbox\marketing\aipa-outreach"
$today = (Get-Date).ToString("yyyy-MM-dd")

if (-not (Test-Path $outBaseDir)) { New-Item -ItemType Directory -Path $outBaseDir -Force | Out-Null }

# state: フェーズ管理（list / email / analyze）
$state = @{ phase = 0; cycle = 1 }
if (Test-Path $stateFile) {
    try {
        $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $state.phase = [int]$loaded.phase
        $state.cycle = [int]$loaded.cycle
    } catch {}
}

$phases = @(
    @{
        Name = "list"
        Title = "[AIpa-OUT] サイクル$($state.cycle) フェーズ1: 顧客リスト10社"
        Prompt = @"
# タスク: [[entities/aipa-web]] のターゲット顧客10社を具体的にリストアップ

## ターゲット要件
- 業種: 建設・物流・製造・サービス業のいずれか
- 規模: 従業員30〜300名
- 地域: 静岡県（大井の地元）を含む地方
- 採用に困ってそう（求人サイトに頻繁に出てる等）
- ホームページが古い・採用ページが弱い

## 出力（10社）
各社について:
\`\`\`markdown
## $($state.cycle * 10 - 9). <会社名（実在）>
- 業種:
- 所在地:
- 従業員数（推測:）:
- ホームページURL:
- 採用情報（求人サイト掲載状況等）:
- 推測される痛み:
- 大井のAIpa Webが解決できそうな点:
- 連絡先（HP問合せフォーム/採用ページ/電話）:
- 優先度: A/B/C
\`\`\`

## 重要
- **実在企業のみ**。架空企業を作らない
- 確認できる範囲で具体的に
- 「○○な企業」のような抽象NG
- 連絡先は探せる範囲で明記

約4000字。
"@
        OutSuffix = "list"
    },
    @{
        Name = "email"
        Title = "[AIpa-OUT] サイクル$($state.cycle) フェーズ2: 上記10社向けメール"
        Prompt = @"
# タスク: 前フェーズで作った10社リストに送る個別アプローチメール

## 前提
直近のリストファイル wiki/_inbox/marketing/aipa-outreach/cycle-X-list.md を参照（context_files で渡る場合）。

各社にカスタマイズしたメール案を10通作成。

## 各メールの構成
\`\`\`markdown
## メール$N: <会社名>

### 件名（30字以内・興味引く）
...

### 本文（400字以内）
- 結論ファースト（モニター価格15万円で採用サイト制作）
- なぜ御社か（具体的に1文）
- 大井 / AIpa Web の信頼担保
- 次のアクション（30分Zoom or 資料送付）

### 送信時刻推奨
平日朝9-11時 or 火-木の14-16時

### フォローアップ予定
3日後: 既読確認、未返信なら2通目（ライト）
1週間後: 別アプローチ角度
\`\`\`

10通分。約4000字。
キャラ: フランクだが誠実、関西弁混じり可、AI臭NG。
"@
        OutSuffix = "emails"
        UseContextFile = $true
    },
    @{
        Name = "analyze"
        Title = "[AIpa-OUT] サイクル$($state.cycle) フェーズ3: 改善提案"
        Prompt = @"
# タスク: AIpa Web 営業活動の改善提案

## 視点
過去のサイクルで作ったリスト・メールテンプレを振り返り、以下を分析:

1. **ターゲット業界の見直し**: 建設・物流・製造のうち、どこが反応良さそうか推測
2. **メール文面の改善案**: 件名パターン、本文構成、CTAの改善
3. **アプローチチャネル**: メール以外でもっと効くチャネル（電話/手紙/紹介/X DM等）
4. **大井が手薄な点**: 営業活動の弱点・抜け
5. **次のサイクルでやるべき変更**: 具体的に3つ

## 出力
\`\`\`markdown
## サイクル$($state.cycle) 振り返り

### 1. ターゲット見直し
...

### 2. メール改善
...

### 3. チャネル提案
...

### 4. 弱点
...

### 5. 次サイクルの変更点
1. ...
2. ...
3. ...
\`\`\`

約2500字、抽象論NG、具体的アクション。
"@
        OutSuffix = "review"
    }
)

$currentPhase = $phases[$state.phase % 3]

$outPath = Join-Path $outBaseDir "cycle-$($state.cycle.ToString('D2'))-$($currentPhase.OutSuffix).md"

# email フェーズなら前のlistをcontextに渡す
$contextFiles = @()
if ($currentPhase.UseContextFile) {
    $listFile = Join-Path $outBaseDir "cycle-$($state.cycle.ToString('D2'))-list.md"
    if (Test-Path $listFile) {
        $contextFiles = @($listFile)
    }
}

if ($contextFiles.Count -gt 0) {
    & $dispatcher `
        -Department "marketing" `
        -Title $currentPhase.Title `
        -Prompt $currentPhase.Prompt `
        -ContextFiles $contextFiles `
        -Model "qwen3:8b" `
        -OutputPath $outPath `
        -Priority "normal" 2>&1 | Out-Null
} else {
    & $dispatcher `
        -Department "marketing" `
        -Title $currentPhase.Title `
        -Prompt $currentPhase.Prompt `
        -Model "qwen3:8b" `
        -OutputPath $outPath `
        -Priority "normal" 2>&1 | Out-Null
}

# state進める
$state.phase = $state.phase + 1
if ($state.phase % 3 -eq 0) {
    $state.cycle = $state.cycle + 1
}
$stateJson = $state | ConvertTo-Json
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

Write-Host "AIpa-Outreach: $($currentPhase.Title) dispatched"
