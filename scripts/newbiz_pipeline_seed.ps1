#requires -Version 5.1
# 新規事業 無限 パイプライン: 種まきステージ
# 毎朝07:00 2案/日 を新規事業アイデアとしてOpenClawにdispatch
# 出力先: wiki/_pipeline/1_seeded/{slug}.md

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$pipelineRoot = Join-Path $brainRoot "wiki\_pipeline"
$seedDir = Join-Path $pipelineRoot "1_seeded"
$logPath = Join-Path $brainRoot "scripts\newbiz_pipeline.log"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$today = (Get-Date).ToString("yyyy-MM-dd")

if (-not (Test-Path $seedDir)) { New-Item -ItemType Directory -Path $seedDir -Force | Out-Null }

$themes = @(
    @{ Axis = "AIx中小企業"; Hint = "従業員30-300名の地方中小企業が抱える日常業務の小さな痛みをAIで解決する事業" }
    @{ Axis = "個人クリエイター"; Hint = "Webクリエイター個人事業主小規模クリニック等が月3万-10万出して使う特化型ツール" }
    @{ Axis = "教育xAI"; Hint = "中高生受験生社会人学習者向け。SFC MBA思考力育成AOなど大井の体験を活かせる事業" }
    @{ Axis = "ローカル産業"; Hint = "建設製造運輸サービス業の現場知識をデジタル化標準化継承する仕組み" }
    @{ Axis = "サブスク量産"; Hint = "月額500-3000円既存ツールのあるけど雑を丁寧にやる型の単機能SaaS" }
)

$selected = $themes | Get-Random -Count 2

Write-Host "[$nowStamp] Newbiz Pipeline: seeding $($selected.Count) ideas"

$promptTemplate = @'
# タスク: 新規事業アイデア 1案 生成

## 軸
{{AXIS}}

## ヒント
{{HINT}}

## 大井湧瑛の事業判断基準
- 脳汁駆動: 大井が直感で動ける案
- 比喩で語れる: 30秒で説明できる比喩
- OS化できる: 拡張性ある仕組み
- 狭く深い: ここだけ勝てるニッチ
- 明日使う1人: XX社YYさんが明日使うと言える
- 3ヶ月で1社契約: 初期検証3ヶ月以内可
- 1人で立ち上げ可: 大井1人 or 外注で実行

## NG
- 顧客像が広すぎ
- Google/Microsoft等と真正面勝負
- 抽象的すぎる
- 初期に大金必要
- 既存15事業(Testall/Gymee/EEMUS/OMNI/AOF/AIpa Web/AIpaX school/EcoKan/IPAK/和コウチャイ)と重複

## 出力フォーマット(YAML必須・1500-2000字)

---
type: business-idea-seed
slug: {{SLUG}}
axis: {{AXIS}}
stage: 1_seeded
created: {{TODAY}}
tags: [pipeline, newbiz, seeded]
---

# (30字以内の事業名)

## 一行コンセプト
(1文30字以内で何を誰に売るか)

## 比喩
(○○のXX版のような30秒で伝わる比喩)

## ターゲット顧客(具体的に1人)
- 業種・規模:
- ペルソナ:
- 今困っていること:
- 月に払える金額:

## 解決方法
(3行以内・AIをどう使うか)

## 勝ち筋
1.
2.
3.

## 収益モデル
- 単価: 月¥
- 想定顧客数: 件
- 月商目標: ¥

## 3ヶ月での検証ステップ
- Week 1-2:
- Month 1:
- Month 3:

## OS化の可能性(3行以内)

具体性最優先。架空企業名NG。
'@

foreach ($theme in $selected) {
    $slug = ($theme.Axis -replace '[^\w]', '-').ToLower()
    $ideaSlug = "$today-$slug-" + ([guid]::NewGuid().ToString().Substring(0, 6))
    $outputPath = Join-Path $seedDir "$ideaSlug.md"

    $prompt = $promptTemplate
    $prompt = $prompt.Replace('{{AXIS}}', $theme.Axis)
    $prompt = $prompt.Replace('{{HINT}}', $theme.Hint)
    $prompt = $prompt.Replace('{{SLUG}}', $ideaSlug)
    $prompt = $prompt.Replace('{{TODAY}}', $today)

    & $dispatcher `
        -Department "newbiz" `
        -Title "[Seed] $($theme.Axis)" `
        -Prompt $prompt `
        -Model "qwen3.6:latest" `
        -OutputPath $outputPath `
        -Priority "normal" 2>&1 | Out-Null

    Start-Sleep -Milliseconds 300
}

"$nowStamp - seeded $($selected.Count) ideas" | Add-Content $logPath -Encoding UTF8
Write-Host "Seeded $($selected.Count) newbiz ideas"
