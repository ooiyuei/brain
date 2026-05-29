#requires -Version 5.1
# idea_to_launch_loop.ps1 - アイデア→ローンチ ステートマシン
# 2026-05-27 新規
#
# 目的:
#   既存事業 (AIpaX/Testall/EEMUS/AIpa Web/AIpaX school) ならびに
#   新規候補アイデアが、シンコード11ステップのどこにいるかを
#   .local/idea_states.json で管理し、自動で次タスクをdispatchする。
#
# 差分 (既存 shincoder_loop.ps1 との違い):
#   shincoder_loop.ps1 = ステップ無関係のランダムdispatch (廃止予定ではない・並走)
#   idea_to_launch_loop.ps1 = ステートマシン駆動 (状態見て判断・本スクリプト)
#
# 1時間毎発火 (BrainShincoderLoop スケジューラと同周期)
# 各アイデアの冷却: ステップ内タスク重複発火防止 (6時間)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain       = "C:\Users\Owner\business\brain"
$dispatcher  = "$brain\scripts\dispatch.ps1"
$notifyScript= "$brain\scripts\notify.ps1"
$logPath     = "$brain\scripts\idea_to_launch_loop.log"
$stateFile   = "$brain\.local\idea_states.json"
$decisionsDir= "$brain\wiki\_final\decisions"
$dashDir     = "$brain\wiki\dashboards"
$nowStamp    = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$today       = (Get-Date).ToString("yyyy-MM-dd")

# ポーズチェック
if (Test-Path "$brain\queue\.paused") { exit 0 }

# inbox 過負荷チェック
$inboxCount = (Get-ChildItem "$brain\queue\inbox" -File -Filter "*.json" -ErrorAction SilentlyContinue).Count
if ($inboxCount -gt 280 -and $env:IDEA_LOOP_FORCE -ne '1') {
    "$nowStamp - skip: inbox $inboxCount > 280" | Add-Content $logPath -Encoding UTF8
    exit 0
}

# ===========================================================
# ステップ定義 (シンコード11ステップ)
# ===========================================================
# Step  1 : アイデア発掘 (マイクロフラストレーション特定)
# Step  2 : LP草案生成 (24時間以内)
# Step  3 : 広告投下 (X/Meta 各5000円)
# Step  4 : CPA判定 (GO=<=300円 / HOLD=300-500 / PIVOT=>500)
# Step  5 : MVP開発着手 (Google認証+コア1機能+課金)
# Step  6 : ビルドインパブリック (X毎日発信)
# Step  7 : βリリース + 初回課金
# Step  8 : ファネル分析 (バケツの穴埋め)
# Step  9 : PMF判定 (3軸全クリアでスケールへ)
# Step 10 : ユニットエコノミクス確認 (LTV/CAC >= 3)
# Step 11 : スケール (広告・インフル・リファラル全開)
# ===========================================================

# ===========================================================
# ステートファイル管理
# ===========================================================

function Read-IdeaStates {
    param([string]$Path)
    $default = @{ ideas = @{}; lastUpdated = "" }
    if (-not (Test-Path $Path)) { return $default }
    try {
        $raw = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
        $parsed = $raw | ConvertFrom-Json
        $result = @{ ideas = @{}; lastUpdated = $parsed.lastUpdated }
        if ($parsed.ideas) {
            foreach ($prop in $parsed.ideas.PSObject.Properties) {
                $idea = @{}
                foreach ($p2 in $prop.Value.PSObject.Properties) {
                    $idea[$p2.Name] = $p2.Value
                }
                $result.ideas[$prop.Name] = $idea
            }
        }
        return $result
    } catch {
        return $default
    }
}

function Write-IdeaStates {
    param([hashtable]$States, [string]$Path)
    $States.lastUpdated = (Get-Date).ToString("o")
    $json = $States | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($Path, $json, [System.Text.Encoding]::UTF8)
}

# ===========================================================
# 事業マスター定義 (初期ステップは実態に合わせる)
# ===========================================================

$masterIdeas = @(
    @{
        id       = "aipax"
        name     = "AIpaX"
        initStep = 9    # 4社契約済み・PMF判定中
        dept     = "corp"
        tags     = @("b2b", "ai-consulting", "sme")
    },
    @{
        id       = "testall"
        name     = "Testall"
        initStep = 5    # MVP開発中・β前
        dept     = "dev"
        tags     = @("b2c", "education", "exam")
    },
    @{
        id       = "eemus"
        name     = "EEMUS"
        initStep = 3    # 広告検証前・夢AWARD準備中
        dept     = "newbiz"
        tags     = @("b2b", "hr", "shizuoka")
    },
    @{
        id       = "aipa-web"
        name     = "AIpa Web"
        initStep = 4    # LP検証・CPA測定中
        dept     = "marketing"
        tags     = @("b2b", "recruitment", "sme")
    },
    @{
        id       = "aipax-school"
        name     = "AIpaX school"
        initStep = 5    # MVP段階
        dept     = "newbiz"
        tags     = @("b2c", "education", "highschool")
    }
)

# ===========================================================
# ステート読み込み・初期化
# ===========================================================

$states = Read-IdeaStates -Path $stateFile

foreach ($idea in $masterIdeas) {
    if (-not $states.ideas.ContainsKey($idea.id)) {
        $states.ideas[$idea.id] = @{
            id            = $idea.id
            name          = $idea.name
            step          = $idea.initStep
            status        = "active"     # active / hold / pivot / pmf / scale / paused
            lastDispatch  = ""
            lastAdvance   = ""
            daysInStep    = 0
            stepEnteredAt = $today
            pivotCount    = 0
            moriokaReviewAt = ""
            notes         = ""
        }
    }
}

# ===========================================================
# 自動進行判定: decisions/ ファイルを読んでステート更新
# ===========================================================

function Test-CpaDecision {
    # _final/decisions/cpa-check-*.md の最新ファイルを読み、各事業のCPA判定を返す
    param([string]$IdeaId)
    $pattern = "cpa-check-*.md"
    $files = Get-ChildItem $decisionsDir -Filter $pattern -ErrorAction SilentlyContinue |
             Sort-Object LastWriteTime -Descending | Select-Object -First 3
    foreach ($f in $files) {
        $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
        # 該当事業行を探す (部分マッチ)
        $ideaLabel = switch ($IdeaId) {
            "aipax"       { "AIpaX" }
            "testall"     { "Testall" }
            "eemus"       { "EEMUS" }
            "aipa-web"    { "AIpa Web" }
            "aipax-school"{ "AIpaX school" }
            default       { $IdeaId }
        }
        # CPA数値を抽出: テーブル行から数値列を探す
        $lines = $content -split "`n"
        foreach ($line in $lines) {
            if ($line -match [regex]::Escape($ideaLabel)) {
                # |...|...|...|...|...|...|CPA数値|判定|
                $cols = $line -split "\|" | Where-Object { $_.Trim() -ne "" }
                if ($cols.Count -ge 7) {
                    $cpaRaw = $cols[6].Trim()
                    if ($cpaRaw -match '(\d+)') {
                        return [int]$Matches[1]
                    }
                }
            }
        }
    }
    return $null
}

function Test-PmfDecision {
    param([string]$IdeaId)
    $pattern = "pmf-judge-*.md"
    $files = Get-ChildItem $decisionsDir -Filter $pattern -ErrorAction SilentlyContinue |
             Sort-Object LastWriteTime -Descending | Select-Object -First 2
    foreach ($f in $files) {
        $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
        $ideaLabel = switch ($IdeaId) {
            "aipax"       { "AIpaX" }
            "testall"     { "Testall" }
            "eemus"       { "EEMUS" }
            "aipa-web"    { "AIpa Web" }
            "aipax-school"{ "AIpaX school" }
            default       { $IdeaId }
        }
        # テーブル行: | 事業名 | 軸1 | 軸2 | 軸3 | 総合判定 |
        $lines = $content -split "`n"
        foreach ($line in $lines) {
            if ($line -match [regex]::Escape($ideaLabel)) {
                if ($line -match "PMF達成") { return "PMF_ACHIEVED" }
                if ($line -match "接近中")  { return "PMF_NEAR" }
                if ($line -match "未達")    { return "NOT_YET" }
            }
        }
    }
    return $null
}

function Test-LpDraft {
    param([string]$IdeaId)
    # _inbox 配下に lp-draft 系ファイルが存在するか
    $pattern = "*lp*$IdeaId*"
    $alt = switch ($IdeaId) {
        "aipax"        { "*lp*aipax*" }
        "testall"      { "*lp*testall*" }
        "eemus"        { "*lp*eemus*" }
        "aipa-web"     { "*lp*aipa*web*" }
        "aipax-school" { "*lp*school*" }
        default        { "*lp*$IdeaId*" }
    }
    $found = Get-ChildItem "$brain\wiki\_inbox" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -like $alt } | Select-Object -First 1
    return ($null -ne $found)
}

# ステート自動更新
$stateChanges = @()

foreach ($ideaId in $states.ideas.Keys) {
    $idea = $states.ideas[$ideaId]
    if ($idea.status -eq "paused") { continue }

    $step = [int]$idea.step

    # Step 1->2: LP草案ファイルが存在する
    if ($step -eq 1 -and (Test-LpDraft -IdeaId $ideaId)) {
        $states.ideas[$ideaId].step          = 2
        $states.ideas[$ideaId].stepEnteredAt = $today
        $states.ideas[$ideaId].lastAdvance   = $today
        $stateChanges += "[$ideaId] S1->S2 (LP draft detected)"
    }

    # Step 3->4 or PIVOT: CPA判定ファイルに値がある
    if ($step -eq 3) {
        $cpa = Test-CpaDecision -IdeaId $ideaId
        if ($null -ne $cpa) {
            if ($cpa -ge 500) {
                $states.ideas[$ideaId].step          = 3   # ピボット後に Step3 からやり直し
                $states.ideas[$ideaId].status        = "pivot"
                $states.ideas[$ideaId].pivotCount   += 1
                $states.ideas[$ideaId].lastAdvance   = $today
                $states.ideas[$ideaId].stepEnteredAt = $today
                $stateChanges += "[$ideaId] PIVOT (CPA=$cpa >= 500)"
            } elseif ($cpa -le 300) {
                $states.ideas[$ideaId].step          = 5   # GO -> MVP開発へ
                $states.ideas[$ideaId].status        = "active"
                $states.ideas[$ideaId].lastAdvance   = $today
                $states.ideas[$ideaId].stepEnteredAt = $today
                $stateChanges += "[$ideaId] S3->S5 GO (CPA=$cpa)"
            } else {
                $states.ideas[$ideaId].step          = 4   # HOLD -> LP改善
                $states.ideas[$ideaId].status        = "hold"
                $states.ideas[$ideaId].lastAdvance   = $today
                $states.ideas[$ideaId].stepEnteredAt = $today
                $stateChanges += "[$ideaId] S3->S4 HOLD (CPA=$cpa 300-500)"
            }
        }
    }

    # Step 4 (HOLD) -> Step 3 再検証: 4日以上経過したら自動再投下指示
    if ($step -eq 4 -and $idea.status -eq "hold") {
        $enteredAt = try { [DateTime]$idea.stepEnteredAt } catch { (Get-Date).AddDays(-1) }
        $daysHeld = ((Get-Date) - $enteredAt).Days
        if ($daysHeld -ge 4) {
            $states.ideas[$ideaId].step          = 3   # LP1箇所改善して再広告
            $states.ideas[$ideaId].status        = "active"
            $states.ideas[$ideaId].stepEnteredAt = $today
            $stateChanges += "[$ideaId] S4->S3 re-test (held $daysHeld days)"
        }
    }

    # Step 9 -> Step 10: PMF判定が3軸パス
    if ($step -eq 9) {
        $pmf = Test-PmfDecision -IdeaId $ideaId
        if ($pmf -eq "PMF_ACHIEVED") {
            $states.ideas[$ideaId].step          = 10
            $states.ideas[$ideaId].status        = "pmf"
            $states.ideas[$ideaId].lastAdvance   = $today
            $states.ideas[$ideaId].stepEnteredAt = $today
            $stateChanges += "[$ideaId] S9->S10 PMF ACHIEVED"
        }
    }

    # Step 10 -> Step 11: ユニットエコノミクス LTV/CAC >= 3 (unit-economics ファイルに "スケールGO" or 倍率3超)
    if ($step -eq 10 -and $idea.status -eq "pmf") {
        $ueFiles = Get-ChildItem $decisionsDir -Filter "unit-economics-*.md" -ErrorAction SilentlyContinue |
                   Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($ueFiles) {
            $ueContent = [System.IO.File]::ReadAllText($ueFiles.FullName, [System.Text.Encoding]::UTF8)
            if ($ueContent -match "スケール(GO|宣言)") {
                $states.ideas[$ideaId].step          = 11
                $states.ideas[$ideaId].status        = "scale"
                $states.ideas[$ideaId].lastAdvance   = $today
                $states.ideas[$ideaId].stepEnteredAt = $today
                $stateChanges += "[$ideaId] S10->S11 SCALE GO"
            }
        }
    }
}

# 変更をディスコード通知
if ($stateChanges.Count -gt 0) {
    $pivots  = $stateChanges | Where-Object { $_ -match "PIVOT" }
    $pmfs    = $stateChanges | Where-Object { $_ -match "PMF ACHIEVED" }
    $scales  = $stateChanges | Where-Object { $_ -match "SCALE GO" }

    if ($pivots.Count -gt 0 -and (Test-Path $notifyScript)) {
        $body = ($pivots -join "`n")
        & $notifyScript -From Claude -Title "PIVOT検出 $($pivots.Count)件" -Body $body -Color orange 2>&1 | Out-Null
    }
    if ($pmfs.Count -gt 0 -and (Test-Path $notifyScript)) {
        $body = ($pmfs -join "`n")
        & $notifyScript -From Claude -Title "PMF達成" -Body $body -Color purple 2>&1 | Out-Null
    }
    if ($scales.Count -gt 0 -and (Test-Path $notifyScript)) {
        $body = ($scales -join "`n")
        & $notifyScript -From Claude -Title "スケールGO" -Body $body -Color green 2>&1 | Out-Null
    }
}

# ===========================================================
# ステップ別タスク定義 (ステート駆動)
# ===========================================================

function Get-StepTask {
    param(
        [hashtable]$Idea,
        [string]$IdeaId,
        [string]$IdeaName
    )
    $step   = [int]$Idea.step
    $status = $Idea.status

    switch ($step) {
        1 {
            return @{
                d = "newbiz"
                t = "[$IdeaName] マイクロフラストレーション特定 ($today)"
                p = @"
# タスク: $IdeaName マイクロフラストレーション特定 ($today)
[[concepts/solopreneur-11steps]] step1

シンコード Step1: 自分の痛み = 本物の事業ネタ。
$IdeaName の想定顧客の「小さな痛み」を10個列挙し、最も事業化可能性が高い1個を選定する。

## 出力フォーマット
- 痛み名 (30字以内)
- 発生場面
- 既存解決法
- なぜ不満か (1行)
- 事業化可能性: 高/中/低 + 理由

末尾に 「最有力候補: (選んだ痛み名)」を記載。
"@
            }
        }
        2 {
            return @{
                d = "newbiz"
                t = "[$IdeaName] LP草案生成 ($today)"
                p = @"
# タスク: $IdeaName LP草案 ($today)
[[concepts/solopreneur-11steps]] step2

シンコード Step2: アイデア出たら24時間以内にLP草案 → CPA検証へ。
$IdeaName のウェイトリスト獲得LPを生成する。

## 出力フォーマット (YAML frontmatter必須)
---
type: lp-draft
idea: $IdeaId
status: ready-for-cpa-test
created: $today
target_cpa: 100-300円
---

### キャッチコピー3本 (各30字以内)
### ヒーロー画像説明 (GPT Image 2 指示付き)
### 本文5ブロック (痛み/解決/機能3つ/価格/CTA)
### ウェイトリスト計測設定 (CTR想定/CVR想定/GO判定CPA)
"@
            }
        }
        3 {
            $pivotNote = if ($Idea.pivotCount -gt 0) { "($($Idea.pivotCount)回目のピボット後・LPコピー改善案を含める)" } else { "" }
            return @{
                d = "marketing"
                t = "[$IdeaName] 広告投下計画 $pivotNote ($today)"
                p = @"
# タスク: $IdeaName 広告投下計画 $pivotNote ($today)
[[concepts/solopreneur-11steps]] step3

シンコード Step3: X広告5000円+Meta広告5000円 → CPA計測。
$IdeaName の広告素材と投下計画を作成する。ピボット回数: $($Idea.pivotCount)

## 出力
1. X広告コピー3本 (各140字以内)
2. Meta広告コピー3本 (各200字以内)
3. ターゲティング設定 (年齢/興味/地域)
4. UTMパラメータ設計
5. CPA計測スプレッドシート行フォーマット

出力先: $brain\wiki\_final\decisions\cpa-check-$today.md の「検証中LP一覧」欄を更新する形式で出力
"@
            }
        }
        4 {
            return @{
                d = "corp"
                t = "[$IdeaName] HOLD CPA改善: LPコピー1箇所変更案 ($today)"
                p = @"
# タスク: $IdeaName CPA HOLD 改善 ($today)
[[concepts/solopreneur-11steps]] step4 (HOLD状態)

CPA 300-500円のため HOLD。シンコード: マイクロコピー1箇所だけ変えて3日再検証。
変更する1箇所を厳選し、A案/B案を出す。他は変えない。

## 出力
1. 現状のどこが問題か (CTR低下 or CVR低下 の特定)
2. 変更する1箇所: 変更前 → 変更後
3. 変更理由 (シンコード事例との対応)
4. 3日後の再計測チェックリスト
"@
            }
        }
        5 {
            return @{
                d = "dev"
                t = "[$IdeaName] MVP機能スコープ確定 ($today)"
                p = @"
# タスク: $IdeaName MVP機能スコープ確定 ($today)
[[concepts/solopreneur-11steps]] step5

シンコード Step5: MVPは「Google認証 + コア機能1個 + 課金」のみ。4-5日でリリース。
$IdeaName のMVP機能を絞り込む。

## 出力
1. 入れる機能 (3個以内・各1行)
2. 入れない機能 (v0.2以降)
3. 技術スタック確定 (Next.js/Supabase/Stripe を推奨)
4. 4日タイムライン (Day1-4 各タスク)
5. リリース判定条件 (最低限動く状態の定義)
"@
            }
        }
        6 {
            return @{
                d = "marketing"
                t = "[$IdeaName] ビルドインパブリック X投稿3本 ($today)"
                p = @"
# タスク: $IdeaName ビルドインパブリック X投稿3本 ($today)
[[concepts/solopreneur-11steps]] step6
[[meta/ooi-soul]]

シンコード Step6: 開発過程を毎日X発信 → β顧客リスト構築。
$IdeaName の進捗を大井1人称で投稿する。

## 出力 (3本・各130字以内)
1. 進捗投稿 (今日やったこと + 数字)
2. 学び投稿 (失敗or気付き・人間味)
3. 募集投稿 (β顧客/商談/応募)

制約: 俺/やる/今日 多用・絵文字1-2個・AI臭ペナルティ禁止
"@
            }
        }
        7 {
            return @{
                d = "marketing"
                t = "[$IdeaName] βリリース告知文 + 初回課金導線 ($today)"
                p = @"
# タスク: $IdeaName βリリース告知文 ($today)
[[concepts/solopreneur-11steps]] step7

シンコード Step7: βリリース → 初回課金まで最短で。
$IdeaName のβリリース告知文と初回課金導線を作る。

## 出力
1. Xリリース告知スレッド (3ツイート構成)
2. ProductHunt 投稿文 (英語・300字)
3. 既存ウェイトリスト向けメール本文 (大井1人称・400字)
4. 初回課金特典設計 (早期割引率・期限・人数上限)
"@
            }
        }
        8 {
            return @{
                d = "corp"
                t = "[$IdeaName] ファネル分析シート ($today)"
                p = @"
# タスク: $IdeaName ファネル分析シート ($today)
[[concepts/solopreneur-11steps]] step8

シンコード Step8: バケツの穴埋め。離脱最大の段階を特定。

## 出力先
$brain\wiki\_final\decisions\funnel-analysis-$today.md

## フォーマット
| 段階 | 今週数 | 離脱率 | 改善優先度 |
(認知/興味/検討/決定/継続 の5段階・$IdeaName 分のみ)

末尾に「最大の穴: (段階名) / 改善案: (マイクロコピー1箇所)」
未測定箇所は __ で残す (推測禁止)
"@
            }
        }
        9 {
            return @{
                d = "corp"
                t = "[$IdeaName] PMF判定シート ($today)"
                p = @"
# タスク: $IdeaName PMF判定シート ($today)
[[concepts/solopreneur-11steps]] step9-10
[[concepts/pmf-validation]]

シンコード: PMF = 定量(継続率15%+/CVR3%+/オーガニック増) + 訂正(Sean Ellis 40%+) + 経済(LTV>=CAC*3)

## 出力先
$brain\wiki\_final\decisions\pmf-judge-$today.md

## フォーマット
### $IdeaName PMF判定
| 軸 | 指標 | 実測値 | 合否 |
|---|---|---|---|
| 定量1 | 継続率 | __% | / |
| 定量2 | CVR | __% | / |
| 定量3 | オーガニック増 | ○/× | / |
| 訂正 | Sean Ellis 40%+ | __% | / |
| 経済 | LTV/CAC | __ 倍 | / |

**総合判定**: PMF達成 / 接近中 / 未達

3軸全クリアで 「PMF達成」と記載する。
未測定は __ で残す (推測禁止)。
"@
            }
        }
        10 {
            return @{
                d = "corp"
                t = "[$IdeaName] ユニットエコノミクス ($today)"
                p = @"
# タスク: $IdeaName ユニットエコノミクス計算 ($today)
[[concepts/solopreneur-11steps]] step11

シンコード: LTV/CAC >= 3 でスケールGO。

## 出力先
$brain\wiki\_final\decisions\unit-economics-$today.md

## フォーマット
### $IdeaName
- 月額: 円
- 平均継続月数: __ ヶ月
- AI API原価: __ 円/月
- LTV = 月額 × 継続月数 - 原価 = __ 円
- CAC = (広告費 + 営業コスト) ÷ 新規獲得数 = __ 円
- 倍率 = LTV ÷ CAC = __ 倍

**判定**:
- 倍率 >= 3: スケールGO宣言
- 倍率 1-3: 改善余地
- 倍率 < 1: 即停止

未測定は __ で残す。
"@
            }
        }
        11 {
            return @{
                d = "marketing"
                t = "[$IdeaName] スケール計画 ($today)"
                p = @"
# タスク: $IdeaName スケール計画 ($today)
[[concepts/solopreneur-11steps]] step11

PMF達成・ユニットエコノミクス確認済み。集客拡大フェーズへ。

## 出力
1. 広告スケール計画 (月額予算 × チャネル配分)
2. インフルエンサー施策 (候補3名・アプローチ文)
3. 紹介プログラム設計 (報酬率・期限・計測方法)
4. 来月MRR目標 (現在×1.5倍 を最低ライン)
5. バイアウト/継続の判断基準 (LTV × 月次ユーザー数)
"@
            }
        }
        default {
            return $null
        }
    }
}

# ===========================================================
# 森岡9軸レビュー (3ステップごと・前回から21日以上経過)
# ===========================================================

function Should-MoriokaReview {
    param([hashtable]$Idea)
    $step = [int]$Idea.step
    # Step 3/6/9 に到達したタイミングでレビュー
    if ($step -notin @(3, 6, 9)) { return $false }
    $lastReview = $Idea.moriokaReviewAt
    if ([string]::IsNullOrEmpty($lastReview)) { return $true }
    try {
        $lastDate = [DateTime]$lastReview
        return ((Get-Date) - $lastDate).Days -ge 21
    } catch {
        return $true
    }
}

function Get-MoriokaTask {
    param([hashtable]$Idea, [string]$IdeaId, [string]$IdeaName)
    return @{
        d = "corp"
        t = "[$IdeaName] 森岡式 コンセプト診断 Step$($Idea.step) ($today)"
        p = @"
# タスク: $IdeaName 森岡式コンセプト診断 ($today)
[[_routines/morioka-decision-templates]]
[[sources/morioka-probability-strategy-2-deep-2026-05-26]]

シンコード数字判定(Step$($Idea.step)) に対応する森岡式概念判定。
両方クリアで「売れるコンセプト × 売れる数字」の二重補強。

## 診断対象
事業: $IdeaName (シンコード現在ステップ: $($Idea.step))

## 診断項目 (全5軸・記入式)

### 1. 絶対に買う1人 定義
- 仮名: __ / 年齢: __ / 役職: __
- 深層の痛み (本能レベル): __
- なぜこの商品を絶対に買うか: __

### 2. WHO/WHAT/HOW 確認
- WHOは決まっているか: ○/×
- WHATの4要素は分解されているか: ○/×
- HOWはWHATを積む手段になっているか: ○/×

### 3. 凡人/狂人 憑依判定
大井5事業推奨は全て 狂人憑依。$IdeaName の場合:
- 狂人ターゲット1人: __
- LTV桁違いになる根拠: __

### 4. プレファレンス/認知/配荷 弱点特定
- 最も低い変数: __
- 来週の最大投資先: __円 → (プレ/認知/配荷) のどれか

### 5. ブランドエクイティ 一言コンセプト
- 脳内につくる最終形 (15字以内): __
- 全タッチポイントでその印象を積めているか: ○/×

## 出力先
$brain\wiki\_final\decisions\concept-diagnosis-$IdeaId-$today.md
"@
    }
}

# ===========================================================
# タスク投入ループ
# ===========================================================

$cutoff = (Get-Date).AddHours(-6)
$dispatched = 0
$maxPerRun  = 4   # 1回の実行で最大4件dispatch

foreach ($ideaId in $states.ideas.Keys) {
    if ($dispatched -ge $maxPerRun) { break }

    $idea = $states.ideas[$ideaId]
    if ($idea.status -eq "paused") { continue }

    # 冷却チェック
    $lastD = $idea.lastDispatch
    if (-not [string]::IsNullOrEmpty($lastD)) {
        try {
            $lastDt = [DateTime]$lastD
            if ($lastDt -gt $cutoff) { continue }
        } catch {}
    }

    # 森岡レビューを優先チェック
    if (Should-MoriokaReview -Idea $idea) {
        $moriokaTask = Get-MoriokaTask -Idea $idea -IdeaId $ideaId -IdeaName $idea.name
        $stamp  = (Get-Date).ToString("yyyyMMdd-HHmm")
        $sid    = [guid]::NewGuid().ToString().Substring(0,4)
        $outPath = "$brain\wiki\_inbox\$($moriokaTask.d)\itl-morioka-$ideaId-$stamp-$sid.md"
        & $dispatcher -Department $moriokaTask.d -Title $moriokaTask.t -Prompt $moriokaTask.p `
            -Model "qwen3.6:latest" -OutputPath $outPath -Priority "high" 2>&1 | Out-Null
        $states.ideas[$ideaId].moriokaReviewAt = (Get-Date).ToString("o")
        $states.ideas[$ideaId].lastDispatch    = (Get-Date).ToString("o")
        $dispatched++
        "$nowStamp - [morioka] $ideaId S$($idea.step)" | Add-Content $logPath -Encoding UTF8
        continue
    }

    # 通常ステップタスク
    $task = Get-StepTask -Idea $idea -IdeaId $ideaId -IdeaName $idea.name
    if ($null -eq $task) { continue }

    $stamp   = (Get-Date).ToString("yyyyMMdd-HHmm")
    $sid     = [guid]::NewGuid().ToString().Substring(0,4)
    $slug    = ($task.t -replace '[^\w]','-').ToLower()
    if ($slug.Length -gt 50) { $slug = $slug.Substring(0, 50) }
    $outPath = "$brain\wiki\_inbox\$($task.d)\itl-s$($idea.step)-$ideaId-$stamp-$sid.md"

    & $dispatcher -Department $task.d -Title $task.t -Prompt $task.p `
        -Model "qwen3.6:latest" -OutputPath $outPath -Priority "high" 2>&1 | Out-Null

    $states.ideas[$ideaId].lastDispatch = (Get-Date).ToString("o")
    $dispatched++
    "$nowStamp - [step$($idea.step)] $ideaId" | Add-Content $logPath -Encoding UTF8
}

# ===========================================================
# ダッシュボード更新
# ===========================================================

$dashPath = "$dashDir\idea-launch-pipeline-2026-05-27.md"
if (Test-Path $dashPath) {
    # ダッシュボードのアクティブ一覧テーブルを書き換え
    $tableLines = @("| 事業名 | Step | ステータス | 滞在日数 | 次アクション | リスクフラグ |")
    $tableLines += @("|---|---|---|---|---|---|")
    foreach ($ideaId in $states.ideas.Keys) {
        $idea = $states.ideas[$ideaId]
        $stepNames = @{1="S1:発掘";2="S2:LP";3="S3:広告";4="S4:HOLD";5="S5:MVP";6="S6:BIP";7="S7:β";8="S8:ファネル";9="S9:PMF判定";10="S10:Unit$";11="S11:スケール"}
        $stepLabel = if ($stepNames.ContainsKey([int]$idea.step)) { $stepNames[[int]$idea.step] } else { "S$($idea.step)" }
        $enteredAt = try { [DateTime]$idea.stepEnteredAt } catch { Get-Date }
        $daysIn = [math]::Floor(((Get-Date) - $enteredAt).TotalDays)
        $riskFlag = if ($daysIn -gt 14) { "STALE($daysIn日)" } elseif ($idea.status -eq "pivot") { "PIVOT" } elseif ($idea.pivotCount -gt 1) { "PIVOT$($idea.pivotCount)x" } else { "-" }
        $nextAction = switch ([int]$idea.step) {
            3 { "CPA計測"; break }
            4 { "LPコピー改善"; break }
            9 { "PMF3軸記入"; break }
            10 { "LTV/CAC計算"; break }
            default { "dispatch済" }
        }
        $tableLines += "| $($idea.name) | $stepLabel | $($idea.status) | $daysIn 日 | $nextAction | $riskFlag |"
    }
    # 最終更新スタンプだけ置き換え (ファイル全体更新は非効率なので末尾に追記)
    $tableBlock = $tableLines -join "`n"
    $updateLine = "`n`n---`n## Auto-update: $nowStamp`n`n$tableBlock`n"
    Add-Content -Path $dashPath -Value $updateLine -Encoding UTF8
}

# ステート保存
Write-IdeaStates -States $states -Path $stateFile

"$nowStamp - dispatched=$dispatched stateChanges=$($stateChanges.Count) inbox=$inboxCount" | Add-Content $logPath -Encoding UTF8
Write-Host "idea_to_launch_loop: dispatched=$dispatched stateChanges=$($stateChanges.Count)"
