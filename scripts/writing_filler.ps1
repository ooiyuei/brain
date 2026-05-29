#requires -Version 5.1
# マーケ部署 - 執筆系専門 filler
# X下書き・note記事・SEO記事・LP・大井のキャラで量産
# brainのwiki情報を ContextFiles として注入し、大井本人の知見ベースで書く

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$logPath = Join-Path $brainRoot "scripts\writing_filler.log"
$stateFile = Join-Path $brainRoot "scripts\.writing_filler_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$cooldownHours = 6

# 執筆系成果物の在庫チェック (note/X/LP/SEO)
$writeInbox = (Get-ChildItem (Join-Path $brainRoot "wiki\_inbox\marketing") -File -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*write*" -or $_.Name -like "*note*" -or $_.Name -like "*twitter*" }).Count
if ($writeInbox -ge 15) {
    "$nowStamp - writing materials sufficient ($writeInbox), skip" | Add-Content $logPath -Encoding UTF8
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

# wikiの大井プロファイルを ContextFiles として注入 (大井のキャラで書かせる)
$ctxFiles = @(
    "$brainRoot\wiki\meta\ooi-clone-spec.md",
    "$brainRoot\wiki\meta\ooi-self-mirror.md"
)
$ctxFiles = $ctxFiles | Where-Object { Test-Path $_ }

# 執筆系タスクプール
$pool = @(
    # === X(Twitter) ===
    @{ Slug="write-x-thread-aipa-week"; Title="[Write] X週次スレッド AIpa Web進捗"
       Prompt="大井湧瑛のXに投稿する『今週のAIpa Web進捗』スレッド(5ツイート)を作る。`n各ツイート140字以内、大井のフランクなキャラ、断定形、関西弁混じり可、AI臭NG。`n構成: 1.今週やったこと / 2.気づき / 3.困ってる/詰まり / 4.来週の予定 / 5.読者への問いかけ。`n約1500字。" }
    @{ Slug="write-x-pickup-tweets-20"; Title="[Write] X単発ツイート 大井の気づき20本"
       Prompt="大井湧瑛のXに投稿する単発ツイート20本。`n各140字以内、独立して読める。`n話題: AI事業の試行錯誤/高校生起業家のリアル/静岡発の視点/大井の人生観/AI時代の人間論。`n大井キャラ厳守、断定形、絵文字ほぼなし。約2500字。" }
    @{ Slug="write-x-engagement-replies"; Title="[Write] X 他人のポストへの返信テンプレ10本"
       Prompt="大井湧瑛がXで他人のポストに返信する時の鋭い返答テンプレ10本。`n話題別: AI事業/教育/起業/政治経済/SaaS/採用/地方創生/中小企業/学生/メンタル。`n各返信: 想定される元ポスト要旨+大井の返信(140字)+狙い。`n大井キャラ厳守、媚びない、共感より問いかけ多め。約2500字。" }

    # === note ===
    @{ Slug="write-note-aipa-deep-research"; Title="[Write] note 中小企業の採用とAIに思うこと"
       Prompt="大井湧瑛がnoteに書く長編記事(3000字)『中小企業の採用とAIに思うこと』。`n大井が[[entities/aipa-web]]のDeep Research で得た知見+原体験を組み合わせる。`n構成: 1.導入(高校生起業家の俺が見てる景色) / 2.現状(中小企業の採用ペイン具体例) / 3.AIの本当の使い方 / 4.AIpa Web の発想 / 5.読んだ人への問いかけ。`n大井キャラ厳守、自分語り多め、結論一行禁止。約3500字。" }
    @{ Slug="write-note-ai-school-vision"; Title="[Write] note AIpaX schoolで子供たちに渡したいもの"
       Prompt="大井湧瑛がnoteに書く長編記事(3000字)『AIpaX school で子供たちに渡したいもの』。`nテーマ: なぜAIを学ばせるべきか、何を学ばせるべきか、大井自身の中高生時代との対比。`n構成: 自分語り→社会観察→事業仮説→親への問いかけ。`n大井キャラ厳守、教育論じゃなく現場感。約3500字。" }
    @{ Slug="write-note-failure-stories"; Title="[Write] note 高校生起業家の失敗5連発"
       Prompt="大井湧瑛がnoteに書く『高校生起業家の失敗5連発』(3000字)。`n大井のwiki情報から失敗・恥ずかしい体験・うまくいかなかった事業案を5つ拾って、それぞれ200-300字でリアルに描く。`n読者層: 起業を考えてる若い人。`n大井キャラ厳守、自虐多め、最後に学びを薄く配置。約3500字。" }
    @{ Slug="write-note-claude-workflow"; Title="[Write] note 俺のClaudeフル活用ワークフロー"
       Prompt="大井湧瑛がnoteに書く『俺のClaudeフル活用ワークフロー』(3000字)。`nテーマ: brain system+OpenClaw+wiki+pipeline 全部組み合わせて24h自走させてる現状を、技術じゃなく『発想と運用』視点で解説。`n読者層: AI使いたい起業家/フリーランス。`n大井キャラ厳守、自慢にならず実利重視。約3500字。" }

    # === SEO記事 ===
    @{ Slug="write-seo-saiyo-cost"; Title="[Write] SEO『中小企業 採用サイト 制作費用』完全本文"
       Prompt="検索KW『中小企業 採用サイト 制作費用』のSEO記事完全本文。`n読者: 採用サイト発注検討中の中小企業の人事担当・社長。`n構成: タイトル30字以内/メタ120字/H2 5つ+各H3 2つ/本文2500字/CTA(AIpa Web)/内部リンク提案。`n大井キャラで書きつつ採用担当者にも読める形に。約3500字。" }
    @{ Slug="write-seo-saiyo-ai"; Title="[Write] SEO『中小企業 採用 AI 活用』完全本文"
       Prompt="検索KW『中小企業 採用 AI 活用』のSEO記事完全本文。`n読者: 採用にAI使いたい中小企業の人事担当・社長。`n構成: タイトル30字以内/メタ120字/H2 5つ+各H3 2つ/本文2500字/AIpa Web誘導/内部リンク。`n約3500字。" }
    @{ Slug="write-seo-ai-school-parent"; Title="[Write] SEO『中高生 AI 学習 何から』完全本文"
       Prompt="検索KW『中高生 AI 学習 何から』のSEO記事完全本文。`n読者: 子供にAI学ばせたい親。`n構成: タイトル/メタ/H2 5+H3 各2/本文2500字/AIpaX school誘導/内部リンク。`n親が安心できる書き方、大井キャラは控えめに。約3500字。" }

    # === LP/コピー ===
    @{ Slug="write-lp-aipa-monitor"; Title="[Write] AIpa Web モニター3社募集LP完全版"
       Prompt="[[entities/aipa-web]] のモニター3社募集LP完全版コピー。3社限定の緊急性で書く。`n構成: FV(キャッチ30字+サブ60字+CTA)/痛み3つ/解決/モニター特典(月10万・通常の1/3)/3社限定の理由/事例(架空でも構造)/FAQ 5/最終CTA。`n約3500字、緊急性と希少性を強調、大井キャラ。" }
    @{ Slug="write-lp-aipax-beta"; Title="[Write] AIpaX β顧客募集LP完全版"
       Prompt="[[entities/aipax]] のβ顧客5社募集LP完全版コピー。50-80万円の根拠を明示。`n構成: FV/中小企業のAI導入5%問題/解決/β特典/事例/価格根拠/FAQ/CTA。約3500字、論理重視、信頼性訴求。" }
    @{ Slug="write-lp-school-trial"; Title="[Write] AIpaX school 体験会LP完全版"
       Prompt="[[entities/aipax-school]] 体験会LP完全版コピー。親向け。`n構成: FV(子のAI時代の不安に共感)/現状の教育の限界/AIpaX schoolの解決/2時間体験会の中身/大井の信頼性/参加特典/FAQ/CTA。`n母親が読んで予約したくなる温度感。約3500字。" }

    # === 大井の発信ポートフォリオ ===
    @{ Slug="write-portfolio-bio"; Title="[Write] 大井プロフィール 3バージョン"
       Prompt="大井湧瑛のプロフィール文を3バージョン書く。`n1.X(140字以内)`n2.note自己紹介(800字)`n3.事業提案時の自己紹介(400字・信頼性重視)`n大井の実績(EXPACT/dinii/PM Agent/HONE等)を盛り込みつつ、キャラを保つ。約2000字。" }
)

$available = $pool | Where-Object { $_.Slug -notin $recentSlugs }
if ($available.Count -eq 0) { $available = $pool }

$pick = $available | Get-Random
$outPath = Join-Path $brainRoot "wiki\_inbox\marketing\write-$($pick.Slug)-$stamp-$shortId.md"

# marketer エージェント経由 (use_agent=true) で品質UP・brainのコンテキストを注入
& $dispatcher `
    -Department "marketing" `
    -Title $pick.Title `
    -Prompt $pick.Prompt `
    -Model "qwen3:8b" `
    -OutputPath $outPath `
    -ContextFiles $ctxFiles `
    -Priority "high" `
    -UseAgent 2>&1 | Out-Null

$newHistory = @($state.history) + @(@{ slug = $pick.Slug; time = (Get-Date).ToString("o") })
$cutoffOld = (Get-Date).AddDays(-3)
$newHistory = $newHistory | Where-Object { [DateTime]$_.time -gt $cutoffOld }
$stateJson = @{ history = $newHistory } | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

"$nowStamp - writing: $($pick.Title)" | Add-Content $logPath -Encoding UTF8
Write-Host "Writing-filled: $($pick.Title)"
