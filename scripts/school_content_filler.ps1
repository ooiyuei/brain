#requires -Version 5.1
# AIpaX school 教材 + 中高生コンテンツ filler
# HR高等学院ノウハウ統合済 (F1-F5フレームワーク)
# 15分おき - スクール教材を量産

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$logPath = Join-Path $brainRoot "scripts\school_content_filler.log"
$stateFile = Join-Path $brainRoot "scripts\.school_content_filler_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$cooldownHours = 12

$state = @{ history = @() }
if (Test-Path $stateFile) { try { $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json; $state = @{ history = @($loaded.history) } } catch {} }
$cutoff = (Get-Date).AddHours(-$cooldownHours)
$recentSlugs = @($state.history | Where-Object { [DateTime]$_.time -gt $cutoff } | ForEach-Object { $_.slug })

$stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
$shortId = [guid]::NewGuid().ToString().Substring(0,4)

# HR高等学院ノウハウをコンテキスト注入
$ctxFiles = @(
    "$brainRoot\wiki\sources\hr-academy-workshops-2026-05-19.md",
    "$brainRoot\wiki\concepts\thinking-frameworks-hr.md"
) | Where-Object { Test-Path $_ }

$pool = @(
    # === Module 1 教材 (マインドセット+バイブコーディング) ===
    @{ Slug="school-m1-w1-mindset"; Title="[School M1W1] AIマインドセット導入 90分授業"
       Prompt="AIpaX school Module1 Week1 (90分授業) の完全スライド構成。テーマ: AIマインドセット。`n中高生向け・退屈させず・大井のフランクなキャラ。`nスライド構成: 1.AI時代のリアル/2.AIを使えない人vs使える人/3.ストーリーテリング3軸フレーム/4.実例(ジャパネット高田)/5.ワーク『君だけのAI体験記』/6.次回予告。`n各スライド: 見出し/本文要旨/話す内容/ワーク指示。約3500字。" }
    @{ Slug="school-m1-w2-vibe-coding"; Title="[School M1W2] Antigravity 初体験 90分授業"
       Prompt="AIpaX school Module1 Week2の完全授業。中高生がAntigravityで初めて『言葉だけでアプリ作る』を体験。`n90分構成: 0-15開始+デモ/15-40セットアップ+最初の質問/40-75自分専用ToDoアプリ作成/75-90共有+次回予告。`n各セクション: 講師トーク要旨/トラブル対応/生徒の予想反応。約3500字。" }
    @{ Slug="school-m1-w3-vibe-spread"; Title="[School M1W3] バイブコーディング 量産デモ 90分授業"
       Prompt="AIpaX school Module1 Week3。中高生にChatbot/タイマー/カレンダー の3つを連続で作らせて『どんなアプリでも作れる』感覚を身につける。各30分。完全授業設計。約3500字。" }

    # === Module 2 教材 (日常業務自動化+合意形成) ===
    @{ Slug="school-m2-w1-automation"; Title="[School M2W1] 日常自動化導入 90分授業"
       Prompt="AIpaX school Module2 Week1の完全授業。中高生が『AIで毎日のだるい作業をなくす』導入。例: 宿題タスク管理AI/勉強スケジュール自動化/SNS下書きAI/英語添削AI。各15分のワーク。完全授業設計。約3500字。" }
    @{ Slug="school-m2-consensus"; Title="[School] 合意形成4ステップ ワークシート"
       Prompt="HR高等学院の合意形成4ステップ(1.意見を分解→2.共通点を探す→3.再考→4.アイデア出し合う)を中高生向けに完全ワークシート化。題材: 修学旅行プラン/学園祭企画/部活動の改革。各題材30分のワーク手順+講師ガイド。約3500字。" }

    # === Module 3 教材 (探究+11項目ロジック) ===
    @{ Slug="school-m3-w1-tankyu"; Title="[School M3W1] 個人探究テーマ設定 90分授業"
       Prompt="AIpaX school Module3 Week1の完全授業。HR高等学院の11項目ロジックモデル(テーマ概要/Why you?/価値/現状/ありたい姿/問題/原因/課題/解決方法/仮説検証/検証結果)を中高生向けに分解して教える。完全スライド構成+ワーク。約3500字。" }
    @{ Slug="school-m3-11item-worksheet"; Title="[School] 11項目探究ワークシート (記入例3パターン)"
       Prompt="HR高等学院の11項目探究ワークシートを中高生3パターン分の記入例とともに完成版。記入例: ①地元商店街活性化 ②家族の朝の喧嘩を減らすAI ③受験勉強の集中力UP。各完全記入。講師の添削ポイントも。約4000字。" }

    # === Module 4 教材 (アプリ開発+企画) ===
    @{ Slug="school-m4-w1-service-design"; Title="[School M4W1] サービス企画 5項目 90分授業"
       Prompt="AIpaX school Module4 Week1の完全授業。HR高等学院のCHINTAI型5項目企画フォーマット(誰のため/課題/サービス/必要モノ/ビジネスモデル)を中高生に教える。題材: 中高生向け新サービス3つ案出し。完全スライド+ワーク。約3500字。" }
    @{ Slug="school-m4-app-spec-templates"; Title="[School] 中高生向け 月3万アプリ仕様書 雛形5本"
       Prompt="中高生が作って月3万円稼げるアプリの仕様書5本。各: 1週間開発前提/Expo+Supabase/AdMob収益モデル/ASOキーワード。例: 高校生用集中タイマー/部活マネージャー/受験カウントダウン/家族共有家計簿/ペット記録アプリ。各仕様書1000字 x 5 = 5000字。" }

    # === Module 5 教材 (マネタイズ+卒業課題) ===
    @{ Slug="school-m5-monetize"; Title="[School M5] マネタイズ実践 全4週授業"
       Prompt="AIpaX school Module5(月9-12)のマネタイズ実践4週分授業設計。Week1:App Store/Google Play審査/Week2:広告SDK実装/Week3:アナリティクス導入/Week4:価格戦略。各90分の完全スライド構成。約4000字。" }
    @{ Slug="school-m5-graduation-presentation"; Title="[School] 卒業課題 発表会設計"
       Prompt="AIpaX school 1年間の卒業課題発表会の完全設計。生徒5名が各自の個人探究テーマ(11項目)+作ったアプリをプレゼン。タイムテーブル+審査基準+招待ゲスト案+成績評価+卒業証書設計。約3500字。" }

    # === 親向けコンテンツ ===
    @{ Slug="school-parent-monthly-report"; Title="[School親向け] 月次進捗レポート テンプレ"
       Prompt="AIpaX school 親向け月次進捗レポートのテンプレ。記入式・1枚A4で月末送付。項目: 今月学んだこと/作ったアプリ/講師コメント/来月の予定/家庭でやってほしいサポート/質問。実際の記入例も。約3000字。" }
    @{ Slug="school-parent-anxiety-q-a"; Title="[School親向け] よくある不安Q&A 20問"
       Prompt="中高生にAIpaX school を勧める親が抱く不安20問+回答。受験との両立/中学生でも分かるか/月3万の根拠/塾との違い/将来の進路/AI依存リスク/プログラミング不要か/卒業後のキャリア。各回答200字以内。約4000字。" }

    # === 中高生向けコンテンツ (集客用) ===
    @{ Slug="school-student-x-content"; Title="[School中高生] X投稿『AI使う中高生』 30本"
       Prompt="AIpaX school 文脈で『AI使いこなす中高生のリアル』X投稿30本(各140字)。中高生本人が読んで『俺/私もやりたい』と感じる温度感。タレント役は卒業生(架空でも構造リアル)+大井がたまに登場。約3500字。" }
    @{ Slug="school-student-success-stories"; Title="[School] 卒業生サクセスストーリー 5本"
       Prompt="AIpaX school 卒業生5名のサクセスストーリー(各700字)。架空でも構造リアル。Before(普通の中高生)→学習中(挫折と気づき)→After(月3万アプリリリース/SFC AO合格/海外大学進学/起業/専門高校入学)。約4000字。" }
)

$available = $pool | Where-Object { $_.Slug -notin $recentSlugs }
if ($available.Count -eq 0) { $available = $pool }

$pick = $available | Get-Random
$outDir = Join-Path $brainRoot "wiki\_inbox\newbiz"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$outPath = Join-Path $outDir "school-$($pick.Slug)-$stamp-$shortId.md"

& $dispatcher `
    -Department "newbiz" `
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
[System.IO.File]::WriteAllText($stateFile, (@{ history = $newHistory } | ConvertTo-Json -Depth 5), [System.Text.UTF8Encoding]::new($false))

"$nowStamp - school: $($pick.Title)" | Add-Content $logPath -Encoding UTF8
Write-Host "School-filled: $($pick.Title)"
