#requires -Version 5.1
<#
.SYNOPSIS
    OpenClaw出力のMarkdownを40点満点で採点する。

.DESCRIPTION
    4次元 x 10点 = 40点満点。
    次元1: フォーマット準拠
    次元2: 声調マッチ（AI臭なし・大井向けトーン）
    次元3: 数字の誠実さ（推測/不明/[要確認]が適切）
    次元4: 実用価値（明日使えるか）

.PARAMETER Path
    採点対象のMarkdownファイルパス（単一ファイルまたはディレクトリ）

.PARAMETER Department
    部署タグ（newbiz/research/marketing/dev/corp/secretary/misc）
    newbiz系はリスク・撤退条件チェックが追加される。

.PARAMETER Threshold
    この点数以下の場合に $LASTEXITCODE = 1 を返す（デフォルト 24）

.PARAMETER Verbose
    詳細な採点理由を表示する

.EXAMPLE
    .\quality_score.ps1 -Path "C:\Users\Owner\business\brain\wiki\_inbox\newbiz\*.md" -Department newbiz
    .\quality_score.ps1 -Path "C:\Users\Owner\business\brain\wiki\_inbox\research\foo.md" -Department research -Verbose
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,

    [ValidateSet("research","newbiz","dev","marketing","corp","secretary","misc")]
    [string]$Department = "misc",

    [int]$Threshold = 24,

    [switch]$Verbose
)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ---------------------------------------------------------------------------
# AI臭禁止パターン（regex）
# ---------------------------------------------------------------------------
$AiSmellPatterns = @(
    'することが重要(です|だ)',
    '様々な',
    'と言えるでしょう',
    'ではないでしょうか',
    'ニーズが高まって(いる|います)',
    '依然として有効',
    'お手伝いします',
    'サポートします',
    'とても重要|非常に重要',
    '珍しくない|少なくない',
    'が課題となっています',
    'を意識することが大切'
)

# ---------------------------------------------------------------------------
# Helper: ファイル一覧を取得
# ---------------------------------------------------------------------------
function Get-TargetFiles {
    param([string]$InputPath)
    if (Test-Path $InputPath -PathType Container) {
        return Get-ChildItem -Path $InputPath -Filter "*.md" -File
    }
    elseif ($InputPath -match '\*') {
        $dir = Split-Path $InputPath -Parent
        $filter = Split-Path $InputPath -Leaf
        return Get-ChildItem -Path $dir -Filter $filter -File
    }
    elseif (Test-Path $InputPath -PathType Leaf) {
        return @(Get-Item $InputPath)
    }
    else {
        Write-Warning "Path not found: $InputPath"
        return @()
    }
}

# ---------------------------------------------------------------------------
# 採点本体
# ---------------------------------------------------------------------------
function Invoke-ScoreFile {
    param(
        [System.IO.FileInfo]$File,
        [string]$Dept,
        [bool]$ShowDetail
    )

    $raw = [System.IO.File]::ReadAllText($File.FullName, [System.Text.Encoding]::UTF8)
    $lines = $raw -split "`n"
    $charCount = $raw.Length

    $scores = @{
        Format  = 0
        Voice   = 0
        Numbers = 0
        Value   = 0
    }
    $reasons = @()

    # =========================================================
    # 次元1: フォーマット準拠（10点）
    # =========================================================

    # YAMLフロントマター（2点）
    $hasYaml = $raw -match '(?s)^---\s*\n.+?\n---'
    if ($hasYaml) {
        $scores.Format += 2
    } else {
        $reasons += "[Format] YAMLフロントマターなし: -2"
    }

    # Markdown見出し（2点）
    $headingCount = ($lines | Where-Object { $_ -match '^#{1,3}\s' }).Count
    if ($headingCount -ge 2) {
        $scores.Format += 2
    } elseif ($headingCount -eq 1) {
        $scores.Format += 1
        $reasons += "[Format] 見出しが1つのみ: -1"
    } else {
        $reasons += "[Format] 見出しなし: -2"
    }

    # 架空wikilink（3点）
    $allowedEntities = @(
        'testall','gymee','agents-of-flag','aipax','aipa-web','aipax-school',
        'eemus','omni','ipak-cafe','ipak-ofuro','ipak-darts','ipak-fishing',
        'ecokan','almeo-aipax','fruits-sauce','wa-kouchai','business-contests',
        'ooi-yuei'
    )
    $wikilinkMatches = [regex]::Matches($raw, '\[\[([^\]|]+)(\|[^\]]*)?\]\]')
    $badLinks = 0
    foreach ($m in $wikilinkMatches) {
        $linkTarget = $m.Groups[1].Value.Trim()
        # entities/ 配下のリンクのみチェック
        if ($linkTarget -match '^entities/(.+)$') {
            $entitySlug = $Matches[1].ToLower()
            if ($allowedEntities -notcontains $entitySlug) {
                $badLinks++
                $reasons += "[Format] 架空wikilink検出: [[$linkTarget]]"
            }
        }
    }
    if ($badLinks -eq 0) {
        $scores.Format += 3
    } elseif ($badLinks -eq 1) {
        $scores.Format += 1
        $reasons += "[Format] 架空wikilink $badLinks 件: -2"
    } else {
        $reasons += "[Format] 架空wikilink $badLinks 件: -3"
    }

    # 字数（3点）
    if ($charCount -ge 300 -and $charCount -le 3000) {
        $scores.Format += 3
    } elseif ($charCount -gt 3000 -and $charCount -le 4000) {
        $scores.Format += 1
        $reasons += "[Format] 字数超過 $charCount 字（〜3000推奨）: -2"
    } elseif ($charCount -lt 300) {
        $scores.Format += 1
        $reasons += "[Format] 字数不足 $charCount 字（300〜推奨）: -2"
    } else {
        $reasons += "[Format] 字数大幅超過 $charCount 字: -3"
    }

    # =========================================================
    # 次元2: 声調マッチ（10点）
    # =========================================================

    # AI臭禁止パターン（4点、1パターン = -1点、最低0点）
    $smellCount = 0
    foreach ($pattern in $AiSmellPatterns) {
        if ($raw -match $pattern) {
            $smellCount++
            $matched = [regex]::Match($raw, $pattern).Value
            $reasons += "[Voice] AI臭: '$matched'"
        }
    }
    $voicePatternScore = [Math]::Max(0, 4 - $smellCount)
    $scores.Voice += $voicePatternScore
    if ($smellCount -gt 0) {
        $reasons += "[Voice] AI臭 $smellCount パターン検出: 4点から -$smellCount 点"
    }

    # 前置き・挨拶なし（2点）
    $firstLine = ($lines | Where-Object { $_.Trim() -ne '' -and $_ -notmatch '^---' } | Select-Object -First 1)
    $hasGreeting = $firstLine -match '(承知しました|かしこまり|ご依頼|おつかれ|よろしく)'
    if (-not $hasGreeting) {
        $scores.Voice += 2
    } else {
        $reasons += "[Voice] 前置き・挨拶あり: -2"
    }

    # 「証拠は？」「誰が明日使う？」視点（2点）
    $hasActionView = $raw -match '(誰が|明日|使える|使う|アクション|手を動かす|具体的に|次の一手)'
    if ($hasActionView) {
        $scores.Voice += 2
    } else {
        $reasons += "[Voice] 実行視点（明日使える/誰が等）なし: -2"
    }

    # 任意加点: 大井原体験・文脈への言及（2点）
    $hasOoiContext = $raw -match '(自立|仕組み|OS化|脳汁|比喩|里親|一人|完全一人|フォーカス)'
    if ($hasOoiContext) {
        $scores.Voice += 2
    }

    # =========================================================
    # 次元3: 数字の誠実さ（10点）
    # =========================================================

    # 根拠なし数字チェック（4点）
    # 数字が含まれている場合、推測:/不明/[要確認] のどれかが近傍にあるか確認
    $numberPattern = '\d+[%億万円人社件回]'
    $numberMatches = [regex]::Matches($raw, $numberPattern)
    $bareNumbers = 0
    foreach ($nm in $numberMatches) {
        $start = [Math]::Max(0, $nm.Index - 50)
        $end = [Math]::Min($raw.Length, $nm.Index + 80)
        $context = $raw.Substring($start, $end - $start)
        if ($context -notmatch '(推測[:：]|\[要確認\]|不明|出典|要確認|データ|統計|%はdata)') {
            $bareNumbers++
        }
    }
    if ($bareNumbers -eq 0) {
        $scores.Numbers += 4
    } elseif ($bareNumbers -le 2) {
        $scores.Numbers += 2
        $reasons += "[Numbers] 根拠不明数字 $bareNumbers 箇所: -2"
    } else {
        $reasons += "[Numbers] 根拠不明数字 $bareNumbers 箇所: -4"
    }

    # 架空企業名の禁止（3点）
    # 実在確実リストにない固有名詞を断言的に書いていないか
    # 「推測:」「[要確認]」なしで知られていない社名を断言するパターン
    $knownNames = @('Microsoft','Google','OpenAI','Anthropic','Apple','Meta','Amazon',
                    'Salesforce','Notion','Slack','Stripe','SmartHR','freee',
                    'ChatGPT','Claude','Gemini','Copilot','qwen','llama',
                    'コカ・コーラ','サントリー','トヨタ','ソニー','NTT','KDDI','ソフトバンク')
    # 架空企業パターン: CamelCase英語名が推測なしで登場 (heuristic)
    $suspiciousCompany = [regex]::Matches($raw, '(?<![推測:\[要確認])([A-Z][a-z]+[A-Z][a-zA-Z]+)(?!\]\]|\s*[:/（])')
    $suspCount = 0
    foreach ($sc in $suspiciousCompany) {
        $name = $sc.Groups[1].Value
        if ($knownNames -notcontains $name) {
            $start = [Math]::Max(0, $sc.Index - 20)
            $ctxSnippet = $raw.Substring($start, [Math]::Min(60, $raw.Length - $start))
            if ($ctxSnippet -notmatch '(推測[:：]|\[要確認\])') {
                $suspCount++
                $reasons += "[Numbers] 未検証企業名の可能性: '$name'"
            }
        }
    }
    if ($suspCount -eq 0) {
        $scores.Numbers += 3
    } elseif ($suspCount -le 2) {
        $scores.Numbers += 1
        $reasons += "[Numbers] 架空企業名の可能性 $suspCount 件: -2"
    } else {
        $reasons += "[Numbers] 架空企業名の可能性 $suspCount 件: -3"
    }

    # 架空ニュース・架空法律（3点）
    $fakeNewsPattern = '(先週|先月|今月|今年|2025年|2026年).{0,20}(リリース|発表|改正|義務化|解禁|施行)'
    $fakeMatches = [regex]::Matches($raw, $fakeNewsPattern)
    $fakeCount = 0
    foreach ($fm in $fakeMatches) {
        $start = [Math]::Max(0, $fm.Index - 30)
        $ctxSnippet = $raw.Substring($start, [Math]::Min(80, $raw.Length - $start))
        if ($ctxSnippet -notmatch '(推測[:：]|\[要確認\]|不明)') {
            $fakeCount++
            $reasons += "[Numbers] 要確認なし断言ニュース/法律: '$($fm.Value)'"
        }
    }
    if ($fakeCount -eq 0) {
        $scores.Numbers += 3
    } elseif ($fakeCount -eq 1) {
        $scores.Numbers += 1
        $reasons += "[Numbers] 断言ニュース/法律 $fakeCount 件: -2"
    } else {
        $reasons += "[Numbers] 断言ニュース/法律 $fakeCount 件: -3"
    }

    # =========================================================
    # 次元4: 実用価値（10点）
    # =========================================================

    # 明日使えるアクションが1つ以上（4点）
    $hasAction = $raw -match '(## .*(アクション|推奨|次の|やること|TODO)|^\d+\.\s.*(する|確認|取る|確定|設定|送る|作る))'
    if ($hasAction) {
        $scores.Value += 4
    } else {
        $reasons += "[Value] 具体的アクションセクションなし: -4"
    }

    # 撤退条件・リスク（3点）※newbiz/research系は必須
    $hasRiskOrExit = $raw -match '(撤退|リスク|ブロッカー|失敗|課題).{0,100}(条件|基準|ライン|要因)'
    $riskMentioned = $raw -match '(## .*(リスク|ブロッカー|撤退|失敗)|撤退条件|リスク[:：])'
    if ($riskMentioned -or $hasRiskOrExit) {
        $scores.Value += 3
    } else {
        if ($Dept -eq 'newbiz' -or $Dept -eq 'research') {
            $reasons += "[Value] リスク・撤退条件なし（newbiz/researchでは必須）: -3"
        } else {
            $scores.Value += 2  # 他部署は任意（部分点）
        }
    }

    # スコープ外追加なし（3点）
    # 長すぎる出力（4000字超）や指示に明らかにないセクションを追加している場合に減点
    $outOfScopePatterns = @(
        '## Phase [0-9]',
        '## ロードマップ',
        '## 将来展望',
        '## 長期計画'
    )
    $outOfScopeFound = $false
    foreach ($osp in $outOfScopePatterns) {
        if ($raw -match $osp) {
            $outOfScopeFound = $true
            $reasons += "[Value] スコープ外セクション検出: '$osp'"
        }
    }
    if (-not $outOfScopeFound -and $charCount -le 3500) {
        $scores.Value += 3
    } elseif (-not $outOfScopeFound) {
        $scores.Value += 1
        $reasons += "[Value] 字数過多でスコープ外追加の疑い: -2"
    }

    # =========================================================
    # 合計・判定
    # =========================================================
    $total = $scores.Format + $scores.Voice + $scores.Numbers + $scores.Value

    $grade = switch ($true) {
        { $total -ge 32 } { "A: 即昇格可" }
        { $total -ge 24 } { "B: 軽修正で昇格" }
        { $total -ge 16 } { "C: redispatch推奨" }
        default           { "D: 削除" }
    }

    # =========================================================
    # 出力
    # =========================================================
    $shortName = $File.Name
    Write-Host ""
    Write-Host "============================================================"
    Write-Host "  $shortName"
    Write-Host "------------------------------------------------------------"
    Write-Host ("  Format:  {0,2}/10  |  Voice:  {1,2}/10  |  Numbers: {2,2}/10  |  Value: {3,2}/10" -f `
        $scores.Format, $scores.Voice, $scores.Numbers, $scores.Value)
    Write-Host ("  TOTAL:   {0,2}/40   |  判定: {1}" -f $total, $grade)

    if ($ShowDetail -and $reasons.Count -gt 0) {
        Write-Host ""
        Write-Host "  --- 減点・注意 ---"
        foreach ($r in $reasons) {
            Write-Host "  $r"
        }
    }

    Write-Host "============================================================"

    return $total
}

# ---------------------------------------------------------------------------
# メイン処理
# ---------------------------------------------------------------------------
$files = Get-TargetFiles -InputPath $Path

if ($files.Count -eq 0) {
    Write-Warning "採点対象ファイルが見つかりません: $Path"
    exit 1
}

$allScores = @()
foreach ($file in $files) {
    $score = Invoke-ScoreFile -File $file -Dept $Department -ShowDetail ($Verbose.IsPresent)
    $allScores += $score
}

if ($files.Count -gt 1) {
    $avg = [Math]::Round(($allScores | Measure-Object -Average).Average, 1)
    $min = ($allScores | Measure-Object -Minimum).Minimum
    $max = ($allScores | Measure-Object -Maximum).Maximum
    Write-Host ""
    Write-Host "============================================================"
    Write-Host "  合計 $($files.Count) ファイル"
    Write-Host ("  平均: {0}/40  最低: {1}  最高: {2}" -f $avg, $min, $max)
    Write-Host "============================================================"
}

$anyFailed = $allScores | Where-Object { $_ -lt $Threshold }
if ($anyFailed) {
    exit 1
}
exit 0
