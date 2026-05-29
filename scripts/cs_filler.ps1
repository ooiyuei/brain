#requires -Version 5.1
# CS部署 filler (Marketing傘下) - 顧客対応・FAQ・解約防止
# customer-success エージェント経由

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$logPath = Join-Path $brainRoot "scripts\cs_filler.log"
$stateFile = Join-Path $brainRoot "scripts\.cs_filler_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$cooldownHours = 12

# CS成果物在庫 (marketing/cs-*)
$csCount = (Get-ChildItem (Join-Path $brainRoot "wiki\_inbox\marketing") -File -Filter "cs-*" -ErrorAction SilentlyContinue).Count
if ($csCount -ge 8) {
    "$nowStamp - cs materials sufficient ($csCount), skip" | Add-Content $logPath -Encoding UTF8
    exit 0
}

$state = @{ history = @() }
if (Test-Path $stateFile) {
    try { $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json; $state = @{ history = @($loaded.history) } } catch {}
}
$cutoff = (Get-Date).AddHours(-$cooldownHours)
$recentSlugs = @($state.history | Where-Object { [DateTime]$_.time -gt $cutoff } | ForEach-Object { $_.slug })

$stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
$shortId = [guid]::NewGuid().ToString().Substring(0,4)

$pool = @(
    @{ Slug="cs-faq-aipa"; Title="[CS] AIpa Web FAQ 30問"
       Prompt="[[entities/aipa-web]] の顧客が抱く質問30個とその回答を作る。FAQ用。`n各FAQ:`n- 質問 (顧客の声で・40字以内)`n- 回答 (200字以内・大井のキャラで)`n- カテゴリ (料金・導入・運用・成果・解約・トラブル)`n大井キャラ厳守、AI臭NG。約4000字。" }

    @{ Slug="cs-faq-aipax"; Title="[CS] AIpaX FAQ 30問"
       Prompt="[[entities/aipax]] の顧客FAQ 30問+回答。導入前・導入中・運用中の質問をカバー。約4000字。" }

    @{ Slug="cs-faq-school"; Title="[CS] AIpaX school 親FAQ 30問"
       Prompt="[[entities/aipax-school]] の親が抱くFAQ 30問+回答。`n質問例: 受験勉強と両立できる?中学生でも分かる?月3万円の根拠?塾と比べてどう?`n回答は丁寧かつ大井の人柄が伝わる温度感。約4000字。" }

    @{ Slug="cs-onboarding-aipa"; Title="[CS] AIpa Web 導入後30日プラン"
       Prompt="[[entities/aipa-web]] のモニター契約後30日の顧客成功プログラム。`nDay 0: キックオフ (90分・現場ヒアリング)`nDay 7: 1stドラフト納品`nDay 14: フィードバック反映 + AI応答設定`nDay 21: 公開 + 採用サイトリリース`nDay 30: 1ヶ月レビュー (応募数測定+次月改善案)`n各タイミング: メール文・電話台本・成果物リスト。約3500字。" }

    @{ Slug="cs-onboarding-school"; Title="[CS] AIpaX school 入学後30日プラン"
       Prompt="[[entities/aipax-school]] 入学後30日の生徒/親対応プラン。`n生徒の挫折を防ぎ、最初の30日で『動くアプリ1個』を作らせる。`n親への週次進捗レポートも含む。約3500字。" }

    @{ Slug="cs-churn-prevention"; Title="[CS] 解約防止トーク 10シナリオ"
       Prompt="大井の事業で『解約・契約終了したい』と言われた時のトーク10シナリオ。`n理由別:`n- 効果が見えない / 高いと感じる / 担当者の異動 / 競合検討 / 業績悪化 / etc`n各シナリオ:`n- 顧客の本音解釈`n- 引き留めトーク (押し付けず・誠実に)`n- それでもダメな時の円満終了`n- 後日再アプローチのきっかけ`n約3500字。" }

    @{ Slug="cs-upsell-aipa"; Title="[CS] AIpa Web アップセル提案3パターン"
       Prompt="[[entities/aipa-web]] のモニター契約終了後のアップセル3パターン。`nA: 月15→月25 (プレミアム移行)`nB: 採用以外への拡張 (社内ナレッジ管理サイト追加)`nC: 紹介報酬+運用継続`n各: 提案タイミング・トーク・成功率予測・断られた時の対応。約3000字。" }

    @{ Slug="cs-nps-survey"; Title="[CS] 顧客満足度サーベイ設計"
       Prompt="大井の事業全体で使えるNPS型満足度サーベイ設計。`n- 質問項目10個 (10段階+自由回答)`n- 配信タイミング (契約3ヶ月・6ヶ月・解約直前)`n- 配信方法 (LINE/メール/対面)`n- 結果の集計・改善ループ`n- 推奨者になってくれた顧客への紹介依頼テンプレ`n約3000字。" }
)

$available = $pool | Where-Object { $_.Slug -notin $recentSlugs }
if ($available.Count -eq 0) { $available = $pool }

$pick = $available | Get-Random
$outPath = Join-Path $brainRoot "wiki\_inbox\marketing\cs-$($pick.Slug)-$stamp-$shortId.md"

& $dispatcher `
    -Department "marketing" `
    -Title $pick.Title `
    -Prompt $pick.Prompt `
    -Model "qwen3:8b" `
    -OutputPath $outPath `
    -Priority "normal" `
    -UseAgent 2>&1 | Out-Null

$newHistory = @($state.history) + @(@{ slug = $pick.Slug; time = (Get-Date).ToString("o") })
$cutoffOld = (Get-Date).AddDays(-3)
$newHistory = $newHistory | Where-Object { [DateTime]$_.time -gt $cutoffOld }
$stateJson = @{ history = $newHistory } | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

"$nowStamp - cs: $($pick.Title)" | Add-Content $logPath -Encoding UTF8
Write-Host "CS-filled: $($pick.Title)"
