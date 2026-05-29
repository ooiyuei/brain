#requires -Version 5.1
# 新規事業 無限 パイプライン: ステージ進行
# 2時間おき 各stage完了済みカードを次stageへdispatch
# 1_seeded -> 2_judged -> 3_refined -> 4_redteam -> 5_prd -> wiki/10_projects/

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$pipelineRoot = Join-Path $brainRoot "wiki\_pipeline"
$inboxQueue = Join-Path $brainRoot "queue\inbox"
$projectsRoot = Join-Path $brainRoot "wiki\10_projects"
$graveyardDir = Join-Path $pipelineRoot "_graveyard"
$logPath = Join-Path $brainRoot "scripts\newbiz_pipeline.log"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$nowFmt = (Get-Date).ToString("yyyy-MM-dd HH:mm")

$dir1 = Join-Path $pipelineRoot "1_seeded"
$dir2 = Join-Path $pipelineRoot "2_judged"
$dir3 = Join-Path $pipelineRoot "3_refined"
$dir4 = Join-Path $pipelineRoot "4_redteam"
$dir5 = Join-Path $pipelineRoot "5_prd"

foreach ($d in @($dir1, $dir2, $dir3, $dir4, $dir5, $graveyardDir, $projectsRoot)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

$advanced = 0; $killed = 0; $shipped = 0

# in-flight チェック
$inFlight = @()
Get-ChildItem $inboxQueue -File -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $j = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($j.output_path) { $inFlight += $j.output_path }
    } catch {}
}

function Get-IdeaTitle {
    param([string]$Content)
    $m = [regex]::Match($Content, '^#\s+(.+)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if ($m.Success) { return $m.Groups[1].Value.Trim() } else { return "(no title)" }
}

# ===== プロンプトテンプレート =====

$judgeTemplate = @'
# 事業案審査(10項目採点)
Thiel/Paul Graham/孫正義/森岡の統合。各10点x10項目=100点満点。

## 採点対象
{{CONTENT}}

## 採点10項目(各0-10点)
1. 課題の切実さ(PG+Thiel) — 自分の痛み?少数が強烈に欲しがるか?放置コスト?
2. 顧客の明確さ(PG) — 最初の10人の顔が見えるか?深さ>広さか?
3. 独占可能性(Thiel) — 小さな市場で圧勝できる?10倍良い要素?
4. 実行可能性 — 今の体制で作れる?届けられる?
5. 収益の割り算(森岡) — 単価x顧客数x頻度がリアル?LTV>CAC?
6. 初速・検証の軽さ — 30日で検証?5万円でテスト?
7. 届ける力(Thiel) — SEO/SNS/営業の導線?
8. 耐久性(Thiel+孫) — 10年後も守れる?スイッチコスト?
9. 市場の勝ちやすさ(Thiel+孫) — 一強がいない?タイミングは今?追い風?
10. 創業者の必然性(PG+孫) — なぜ大井がやる?3年後も燃える?

## 採点の目安(現実的に)
- 10点: 歴史を変えるレベル(年に数件しかない・但し可能性あれば付けてよい)
- 9点: 明確に勝てると確信できる(根拠2つ以上必要)
- 8点: 強い(具体的根拠1つは必要)
- 7点: 良い(普通に強い案はここ)
- 6点: そこそこ(平均より上)
- 5点: 並
- 4点以下: 弱点として要改善

## 足切りルール(以下4項目どれかが5点未満→ティアD固定)
- 課題の切実さ / 独占可能性 / 実行可能性 / 収益の割り算

## ティア判定
- S: 75+ かつ足切りなし → 即PRD化・全力投入
- A: 65-74 かつ足切りなし → 検証加速・リソース集中
- B: 55-64 かつ足切りなし → 検証継続・弱点改善
- C: 40-54 または足切りあり → ピボットor磨き直し
- D: 39以下 → 凍結

## 採点ルール
- 「なんとなく良さそう」は点に入れない(根拠を1行で書く)
- 高得点には根拠が要る(8点以上は根拠2つ・10点なら歴史的事業の特徴を満たす)
- 熱量(脳汁)は加点対象にしない(大井の本人性は項目10で評価)
- いい事業は素直に高く点をつけてOK。8-9点はあり得る

## 大井(創業者)プロフィール
18歳・静岡・高校生起業家。AI/UX/事業企画/SFC視点強み。
弱み: 継続管理・報連相・実装の詰め。
既存15事業: Testall/Gymee/EEMUS/OMNI/AOF/AIpa Web/AIpaX/AIpaX school/EcoKan/IPAK等。

## 出力(YAML必須・1000字以内)

---
type: business-idea-judged
slug: (元のslug)
stage: 2_judged
score: (合計点)
tier: (S|A|B|C|D)
cutoff: (なし|あり)
judged_at: {{NOW}}
tags: [pipeline, newbiz, judged]
---

# {{TITLE}}

## 採点結果
- SCORE: (合計)/100
- TIER: (S|A|B|C|D)
- 足切り: (なし|あり・項目名)

## 各項目の点数(理由1行付き)
1. 課題の切実さ: X — 理由
2. 顧客の明確さ: X — 理由
3. 独占可能性: X — 理由
4. 実行可能性: X — 理由
5. 収益の割り算: X — 理由
6. 初速・検証の軽さ: X — 理由
7. 届ける力: X — 理由
8. 耐久性: X — 理由
9. 市場の勝ちやすさ: X — 理由
10. 創業者の必然性: X — 理由

## 総合コメント
- 強み: 具体的根拠2つ
- リスク: 具体的弱点2つ
- 孫正義的観点: 50年の情熱・社会貢献・グループの核(1行)

## 次のステップ
- S: 即PRD化推奨
- A: 弱点改善ポイント3つ
- B/C: 改善案 or ピボット案
- D: 凍結理由

普通に強い案は7-8点で素直につける。説明できない高得点はNG。
'@

$refineTemplate = @'
# タスク: 事業アイデア磨き上げ(business-refiner)

## 元のseed
{{SEED}}

## 採点結果(judge)
{{JUDGE}}

## あなたの仕事
Tier {{TIER}} のこのアイデアを即実行可能なレベルまで磨く。

## 磨く観点
1. ペルソナ1人を実名級に具体化
2. 比喩を1行で
3. MVP1機能だけ画面1枚レベルで
4. 獲得チャネル具体的3つ
5. 初期検証指標

## 出力(YAML必須・1500-2500字)

---
type: business-idea-refined
slug: (元のslug)
stage: 3_refined
tier: {{TIER}}
refined_at: {{NOW}}
tags: [pipeline, newbiz, refined]
---

# {{TITLE}} (Refined)

## 1行ピッチ(30秒で伝わる)

## ターゲット顧客(具体的に1人)
- 業種:
- 社員規模:
- 役職:
- 月の困りごと3つ:
- 月に払える金額:

## MVPの1機能(画面1枚)
- 何ができる:
- 入力:
- 出力:
- AI使い方:

## 獲得チャネル(具体的3つ)
1.
2.
3.

## 初期検証指標
- 3ヶ月で:
- 6ヶ月で:
- 失敗ライン:

## 想定リスク(3つ)
1.
2.
3.

架空企業名NG。
'@

$redteamTemplate = @'
# タスク: 事業アイデアRed Teamレビュー(容赦なく叩く)

## 磨き済みアイデア
{{CONTENT}}

## あなたの仕事
このアイデアの致命的な穴を探す。
褒めるな。失敗する可能性を全部出す。

## 観点
1. 収益モデルの穴
2. 顧客の穴(本当に金払う？)
3. 競合の穴(既存ツールでなんとかなる？大手が真似したら？)
4. オペレーションの穴(1人で本当に回せる？)
5. 法務・倫理の穴
6. 市場タイミング

## 出力(YAML必須・1500-2000字)

---
type: business-idea-redteam
slug: (元のslug)
stage: 4_redteam
verdict: (GO|HOLD|KILL)
redteam_at: {{NOW}}
tags: [pipeline, newbiz, redteam]
---

# {{TITLE}} (Red Team)

## Verdict
(GO | HOLD | KILL)

## 致命的な穴(最大5個・優先度順)
### 1. (見出し)
- 詳細:
- 回避策あるか:

### 2. ... ### 3. ...

## 軽微な懸念

## このまま進めるなら必要な打ち手
1.
2.
3.

## KILL理由(KILL時のみ・一文要約)

容赦なく。
'@

$prdTemplate = @'
# タスク: PRD化(Product Requirements Document)

## 磨き済みアイデア(refined)
{{REFINED}}

## Red Teamフィードバック
{{REDTEAM}}

## あなたの仕事
GO判定のこのアイデアを開発者が迷わず作れるPRDに落とす。
Red Teamの打ち手を全部織り込む。

## 出力(YAML必須・2500-3500字)

---
type: business-prd
slug: (元のslug)
stage: 5_prd
status: ready-to-build
prd_at: {{NOW}}
tags: [pipeline, newbiz, prd, ready]
---

# {{TITLE}} PRD v1

## 1. 1行サマリー(30字以内)

## 2. 解決する課題(Why)
- 誰が困ってる:
- どれだけ困ってる:
- 今どう代替:
- なぜ今やる:

## 3. ユーザーストーリー(3つ・AC付き)
### US1
- As a:
- I want to:
- So that:
- AC:

### US2 / US3

## 4. MVP機能スコープ(v0.1)
入れる:
- A:
- B:
- C:
入れない(v0.2以降):

## 5. 画面構成(v0.1)
- 画面1:
- 画面2:
- 画面3:

## 6. 技術スタック
- フロント:
- バック:
- DB:
- AI:
- ホスティング:

## 7. データモデル(主要テーブル3つ)

## 8. 開発見積もり
- v0.1: N週間
- v0.2: M週間

## 9. 獲得チャネル(最初の10社)
1. 2. 3.

## 10. 初期検証KPI
- 3ヶ月:
- 6ヶ月:
- KILLライン:

## 11. Red Team対応
- 穴1: 打ち手
- 穴2: 打ち手

実装可能なレベルで具体的に。
'@

# ===== Stage 1->2: Judge =====
Get-ChildItem $dir1 -File -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    $name = $_.Name
    $nextPath = Join-Path $dir2 $name
    if (Test-Path $nextPath) { return }
    if ($inFlight -contains $nextPath) { return }

    $age = ((Get-Date) - $_.LastWriteTime).TotalMinutes
    if ($age -lt 5) { return }

    $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $title = Get-IdeaTitle $content

    $prompt = $judgeTemplate
    $prompt = $prompt.Replace('{{CONTENT}}', $content)
    $prompt = $prompt.Replace('{{TITLE}}', $title)
    $prompt = $prompt.Replace('{{NOW}}', $nowFmt)

    & $dispatcher -Department "newbiz" -Title "[Judge] $title" -Prompt $prompt -Model "qwen3.6:latest" -OutputPath $nextPath -Priority "normal" 2>&1 | Out-Null
    $advanced++
    Start-Sleep -Milliseconds 200
}

# ===== Stage 2->3: Refine (S/A only) =====
Get-ChildItem $dir2 -File -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    $name = $_.Name
    $nextPath = Join-Path $dir3 $name
    if (Test-Path $nextPath) { return }
    if ($inFlight -contains $nextPath) { return }

    $age = ((Get-Date) - $_.LastWriteTime).TotalMinutes
    if ($age -lt 5) { return }

    $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $tierMatch = [regex]::Match($content, 'TIER:\s*([SABCD])')
    $tier = if ($tierMatch.Success) { $tierMatch.Groups[1].Value } else { "C" }

    if ($tier -in @("B", "C", "D")) {
        $gDir = Join-Path $graveyardDir $tier
        if (-not (Test-Path $gDir)) { New-Item -ItemType Directory -Path $gDir -Force | Out-Null }
        Move-Item $_.FullName (Join-Path $gDir $name) -Force
        $seedPath = Join-Path $dir1 $name
        if (Test-Path $seedPath) { Move-Item $seedPath (Join-Path $gDir "seed-$name") -Force }
        "$nowStamp - GRAVE [tier=$tier] $name" | Add-Content $logPath -Encoding UTF8
        $killed++
        return
    }

    $seedPath = Join-Path $dir1 $name
    $seedContent = if (Test-Path $seedPath) { [System.IO.File]::ReadAllText($seedPath, [System.Text.Encoding]::UTF8) } else { "" }
    $title = Get-IdeaTitle $seedContent

    $prompt = $refineTemplate
    $prompt = $prompt.Replace('{{SEED}}', $seedContent)
    $prompt = $prompt.Replace('{{JUDGE}}', $content)
    $prompt = $prompt.Replace('{{TIER}}', $tier)
    $prompt = $prompt.Replace('{{TITLE}}', $title)
    $prompt = $prompt.Replace('{{NOW}}', $nowFmt)

    & $dispatcher -Department "newbiz" -Title "[Refine] $title" -Prompt $prompt -Model "qwen3.6:latest" -OutputPath $nextPath -Priority "normal" 2>&1 | Out-Null
    $advanced++
    Start-Sleep -Milliseconds 200
}

# ===== Stage 3->4: RedTeam =====
Get-ChildItem $dir3 -File -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    $name = $_.Name
    $nextPath = Join-Path $dir4 $name
    if (Test-Path $nextPath) { return }
    if ($inFlight -contains $nextPath) { return }

    $age = ((Get-Date) - $_.LastWriteTime).TotalMinutes
    if ($age -lt 5) { return }

    $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $title = Get-IdeaTitle $content

    $prompt = $redteamTemplate
    $prompt = $prompt.Replace('{{CONTENT}}', $content)
    $prompt = $prompt.Replace('{{TITLE}}', $title)
    $prompt = $prompt.Replace('{{NOW}}', $nowFmt)

    & $dispatcher -Department "newbiz" -Title "[RedTeam] $title" -Prompt $prompt -Model "qwen3.6:latest" -OutputPath $nextPath -Priority "normal" 2>&1 | Out-Null
    $advanced++
    Start-Sleep -Milliseconds 200
}

# ===== Stage 4->5: PRD (GO only) =====
Get-ChildItem $dir4 -File -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    $name = $_.Name
    $nextPath = Join-Path $dir5 $name
    if (Test-Path $nextPath) { return }
    if ($inFlight -contains $nextPath) { return }

    $age = ((Get-Date) - $_.LastWriteTime).TotalMinutes
    if ($age -lt 5) { return }

    $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $verdictMatch = [regex]::Match($content, 'verdict:\s*(GO|HOLD|KILL)', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $verdict = if ($verdictMatch.Success) { $verdictMatch.Groups[1].Value.ToUpper() } else { "HOLD" }

    if ($verdict -eq "KILL") {
        $gDir = Join-Path $graveyardDir "KILLED"
        if (-not (Test-Path $gDir)) { New-Item -ItemType Directory -Path $gDir -Force | Out-Null }
        foreach ($d in @($dir1, $dir2, $dir3, $dir4)) {
            $f = Join-Path $d $name
            if (Test-Path $f) {
                $dn = Split-Path $d -Leaf
                Move-Item $f (Join-Path $gDir "$dn-$name") -Force
            }
        }
        "$nowStamp - KILL by redteam: $name" | Add-Content $logPath -Encoding UTF8
        $killed++
        return
    }
    if ($verdict -eq "HOLD") { return }

    $refinedContent = if (Test-Path (Join-Path $dir3 $name)) {
        [System.IO.File]::ReadAllText((Join-Path $dir3 $name), [System.Text.Encoding]::UTF8)
    } else { "" }
    $title = Get-IdeaTitle $refinedContent

    $prompt = $prdTemplate
    $prompt = $prompt.Replace('{{REFINED}}', $refinedContent)
    $prompt = $prompt.Replace('{{REDTEAM}}', $content)
    $prompt = $prompt.Replace('{{TITLE}}', $title)
    $prompt = $prompt.Replace('{{NOW}}', $nowFmt)

    & $dispatcher -Department "newbiz" -Title "[PRD] $title" -Prompt $prompt -Model "qwen3.6:latest" -OutputPath $nextPath -Priority "normal" 2>&1 | Out-Null
    $advanced++
    Start-Sleep -Milliseconds 300
}

# ===== Stage 5->Ship: wiki/10_projects/{slug}/ =====
Get-ChildItem $dir5 -File -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    $age = ((Get-Date) - $_.LastWriteTime).TotalMinutes
    if ($age -lt 60) { return }

    $name = $_.Name
    $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $slugMatch = [regex]::Match($content, 'slug:\s*(.+)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    $slug = if ($slugMatch.Success) { $slugMatch.Groups[1].Value.Trim() } else { [System.IO.Path]::GetFileNameWithoutExtension($name) }

    $projDir = Join-Path $projectsRoot $slug
    if (Test-Path $projDir) { return }
    New-Item -ItemType Directory -Path $projDir -Force | Out-Null

    foreach ($d in @($dir1, $dir2, $dir3, $dir4, $dir5)) {
        $f = Join-Path $d $name
        if (Test-Path $f) {
            $dn = Split-Path $d -Leaf
            Copy-Item $f (Join-Path $projDir "$dn.md") -Force
        }
    }

    $readme = "---`ntype: project`nslug: $slug`nstatus: prd-ready`nshipped_at: $nowStamp`ntags: [project, newbiz, prd-ready]`n---`n`n# $slug`n`n新規事業 無限 パイプライン から正式昇格したプロジェクト。`n`n## ステータス`n- 段階: PRD完成・実装待ち`n- 進捗: 0%`n`n## ドキュメント`n- 1_seeded.md - 初期アイデア`n- 2_judged.md - 7軸採点`n- 3_refined.md - 磨き上げ`n- 4_redteam.md - Red Team`n- 5_prd.md - PRD(実装仕様)`n`n## 次のアクション`n1. PRDを読む`n2. 技術スタック確定`n3. v0.1着手判断`n"
    Set-Content -Path (Join-Path $projDir "README.md") -Value $readme -Encoding UTF8

    "$nowStamp - SHIPPED: $slug -> wiki/10_projects/$slug/" | Add-Content $logPath -Encoding UTF8
    $shipped++

    try {
        $notifyScript = Join-Path $brainRoot "scripts\notify.ps1"
        if (Test-Path $notifyScript) {
            $titleText = Get-IdeaTitle $content
            $notifyBody = "$titleText" + [Environment]::NewLine + "wiki/10_projects/$slug/ に登録"
            & $notifyScript -From Claude -Title "新規事業PRD完成" -Body $notifyBody -Color purple
        }
    } catch {}
}

$summary = "advanced=$advanced killed=$killed shipped=$shipped"
"$nowStamp - $summary" | Add-Content $logPath -Encoding UTF8
Write-Host "Pipeline advance: $summary"
