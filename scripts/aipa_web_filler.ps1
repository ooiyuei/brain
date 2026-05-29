#requires -Version 5.1
# AIpa Web 専用 filler - 主力事業1
# 月15万x3社=月45万を取りに行く全方位タスク
# 15分おき・1日10件くらい量産・営業文/LP/競合/契約/SEO/X/プロセスマニュアル

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$logPath = Join-Path $brainRoot "scripts\aipa_web_filler.log"
$stateFile = Join-Path $brainRoot "scripts\.aipa_web_filler_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$cooldownHours = 8

$inboxAipa = (Get-ChildItem (Join-Path $brainRoot "wiki\_inbox") -Recurse -File -Filter "*aipa-web*" -ErrorAction SilentlyContinue).Count
if ($inboxAipa -ge 20) {
    "$nowStamp - aipa-web materials sufficient ($inboxAipa)" | Add-Content $logPath -Encoding UTF8
    exit 0
}

$state = @{ history = @() }
if (Test-Path $stateFile) { try { $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json; $state = @{ history = @($loaded.history) } } catch {} }
$cutoff = (Get-Date).AddHours(-$cooldownHours)
$recentSlugs = @($state.history | Where-Object { [DateTime]$_.time -gt $cutoff } | ForEach-Object { $_.slug })

$stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
$shortId = [guid]::NewGuid().ToString().Substring(0,4)

$pool = @(
    # === 顧客リード獲得 ===
    @{ Slug="aipa-prospect-construction-30"; Title="[AIpaWeb] 建設業ターゲット30社プロファイル"; Dept="marketing"
       Prompt="[[entities/aipa-web]] のターゲット建設業30社プロファイル。地方・従業員30-300名。各社: 業種詳細・規模・地域・採用課題仮説・接点(HP/採用担当/紹介)・初回メール件名+本文(200字)・想定反応・次の一手。約4000字、推測明示。" }
    @{ Slug="aipa-prospect-mfg-30"; Title="[AIpaWeb] 製造業ターゲット30社プロファイル"; Dept="marketing"
       Prompt="[[entities/aipa-web]] の製造業30社プロファイル+アプローチ案。地方・従業員30-300名。各社: 業種詳細/規模/地域/採用課題/接点/メール案/想定反応。約4000字、推測明示。" }
    @{ Slug="aipa-prospect-logistics"; Title="[AIpaWeb] 運輸業ターゲット30社プロファイル"; Dept="marketing"
       Prompt="[[entities/aipa-web]] の運輸業30社プロファイル+アプローチ案。約4000字。" }
    @{ Slug="aipa-prospect-service"; Title="[AIpaWeb] サービス業ターゲット30社プロファイル"; Dept="marketing"
       Prompt="[[entities/aipa-web]] のサービス業(介護/物流/保育/小売)30社プロファイル+アプローチ案。約4000字。" }
    @{ Slug="aipa-prospect-shizuoka-priority"; Title="[AIpaWeb] 静岡優先20社リスト"; Dept="marketing"
       Prompt="[[entities/aipa-web]] の静岡県内優先20社リスト。大井のローカル人脈活用前提。各社: 社名仮想/業種/規模/採用課題/紹介経路の可能性/メール案。実在企業推測でOK・架空なら『業界典型像』と注記。約3500字。" }

    # === 営業オペレーション ===
    @{ Slug="aipa-cold-email-sequence-7"; Title="[AIpaWeb] 営業メール7通シーケンス完全版"; Dept="marketing"
       Prompt="[[entities/aipa-web]] の自動メール7通シーケンス。初回→Day3→Day7→Day14→Day21→Day30→Day60。各通: 件名/本文(300字)/想定開封率/次の手。大井のフランクなキャラ・AI臭NG。約3500字。" }
    @{ Slug="aipa-phone-script-30s"; Title="[AIpaWeb] 30秒電話アポトーク台本"; Dept="marketing"
       Prompt="[[entities/aipa-web]] の電話アポ取得トーク台本。30秒で『話を聞きたい』と言わせる構成+断り5パターン×切り返し+アポ確定後の確認。大井キャラ厳守、関西弁混じり可。約3000字。" }
    @{ Slug="aipa-meeting-flow-90min"; Title="[AIpaWeb] 初回商談90分フロー"; Dept="marketing"
       Prompt="[[entities/aipa-web]] の初回商談90分フロー設計。0:00自己紹介/0:10ヒアリング(20分・採用課題深掘り)/0:30事例紹介/0:45ソリューション提示/1:00価格・3プラン/1:15Q&A/1:25クロージング。各段の話す内容・質問・想定反応・次の確認。約3500字。" }
    @{ Slug="aipa-objection-20"; Title="[AIpaWeb] 想定される断り20×切り返し"; Dept="marketing"
       Prompt="[[entities/aipa-web]] で受ける断り20パターン+切り返し。『若いから不安』『他社で十分』『時期じゃない』『予算ない』『AIは難しい』他。各: 断り文句/心理解釈/切り返し3行/縁切り方。約3500字、大井キャラ。" }

    # === 商談/契約 ===
    @{ Slug="aipa-proposal-15man-full"; Title="[AIpaWeb] モニター15万提案書フル版"; Dept="newbiz"
       Prompt="[[entities/aipa-web]] のモニター月15万契約フル提案書。表紙/クライアント差込み/課題整理(採用ペイン3つ)/ソリューション(16セクション+AI初稿+運用)/成果物リスト(月単位)/価格内訳/通常制作150万との比較表/3ヶ月導入スケジュール/チーム/FAQ/リスク保証。約4000字、PDFそのまま使えるレベル。" }
    @{ Slug="aipa-contract-template"; Title="[AIpaWeb] モニター契約書 法的テンプレ"; Dept="corp"
       Prompt="[[entities/aipa-web]] モニター3社契約書テンプレ。業務範囲/月15万支払い条件/著作権帰属/取材写真利用許諾/解約条件3ヶ月通知/AI応答の責任分担/個人情報保護/紛争解決。約3500字、法務監修前提でも実用レベル。" }
    @{ Slug="aipa-followup-rules"; Title="[AIpaWeb] フォローアップ自動ルール表"; Dept="marketing"
       Prompt="[[entities/aipa-web]] のフォローアップ if-then 表20パターン。例: メール返信なし3日→リマインド/提案後返事なし1週間→質問型/etc。各: トリガー/タイミング/メッセージ案/次のステップ。約3000字。" }

    # === LP/コンテンツ ===
    @{ Slug="aipa-lp-monitor-3sha"; Title="[AIpaWeb] モニター3社募集LP完全版"; Dept="marketing"
       Prompt="[[entities/aipa-web]] モニター3社募集LPフルコピー。FV(キャッチ30字+サブ60字)/採用ペイン3つ/解決/3社限定特典/事例構造/FAQ5/CTA/緊急性訴求。約3500字。" }
    @{ Slug="aipa-seo-saiyo-cost"; Title="[AIpaWeb] SEO『中小企業 採用サイト 制作費用』本文"; Dept="marketing"
       Prompt="検索KW『中小企業 採用サイト 制作費用』のSEO記事完全本文。タイトル30字/メタ120字/H2 5+H3 各2/本文2500字/CTA/内部リンク。約3500字。" }
    @{ Slug="aipa-seo-saiyo-ai"; Title="[AIpaWeb] SEO『中小企業 採用 AI』本文"; Dept="marketing"
       Prompt="検索KW『中小企業 採用 AI 活用』のSEO記事完全本文。H2 5+H3 各2/本文2500字/AIpa Web誘導。約3500字。" }
    @{ Slug="aipa-x-thread-weekly"; Title="[AIpaWeb] X週次スレッド5本"; Dept="marketing"
       Prompt="[[entities/aipa-web]] 進捗発信のX週次スレッド5本(各5ツイート)。大井のフランクなキャラ。約2500字。" }
    @{ Slug="aipa-note-deep-essay"; Title="[AIpaWeb] note『中小企業の採用とAI』長編エッセイ"; Dept="marketing"
       Prompt="大井湧瑛のnote長編記事『中小企業の採用とAIに思うこと』(3000字)。大井の原体験(dinii時代)+AIpa WebのDeep Research知見を統合。導入(高校生起業家の俺が見てる景色)→現状(中小ペイン)→AIの本当の使い方→AIpa Webの発想→読者への問いかけ。大井キャラ厳守、自分語り多め。約3500字。" }

    # === 競合/市場分析 ===
    @{ Slug="aipa-competitor-deep"; Title="[AIpaWeb] 競合5社深掘り分析"; Dept="research"
       Prompt="[[entities/aipa-web]] の競合5社(engage/採用ピックアップ/求人ボックス/Indeed採用ページ/HRBrainの採用機能)深掘り。各: 機能/価格/強み/弱み/AIpa Webとの差別化ポイント/勝ち筋。実在企業のみ。約3500字、推測明示。" }
    @{ Slug="aipa-market-trend"; Title="[AIpaWeb] 採用Tech 2026トレンド"; Dept="research"
       Prompt="2026年の採用Tech市場トレンドで[[entities/aipa-web]]に追い風/逆風となる動向。AI採用・人手不足・地方創生・人材紹介の規制変化等。約3000字。" }

    # === オンボーディング/CS ===
    @{ Slug="aipa-onboarding-30days"; Title="[AIpaWeb] 契約後30日オンボーディング"; Dept="marketing"
       Prompt="[[entities/aipa-web]] モニター契約後30日プログラム。Day0キックオフ90分/Day7 1stドラフト/Day14フィードバック/Day21公開/Day30レビュー。各タイミング: メール文/電話台本/成果物/KPI。約3500字。" }
    @{ Slug="aipa-faq-30q"; Title="[AIpaWeb] FAQ 30問"; Dept="marketing"
       Prompt="[[entities/aipa-web]] のFAQ30問+回答。料金/導入/運用/成果/解約/トラブルをカバー。大井キャラ。約3500字。" }

    # === 数字管理 ===
    @{ Slug="aipa-pl-monthly"; Title="[AIpaWeb] 月次PL試算"; Dept="corp"
       Prompt="[[entities/aipa-web]] 月15万x3社=月45万売上想定の月次PL。売上/原価(工数/外注/AI API/ホスティング)/販管費/大井人件費/営業利益/損益分岐点。約3000字、数字根拠明示。" }
    @{ Slug="aipa-kpi-dashboard"; Title="[AIpaWeb] KPIダッシュボード設計"; Dept="corp"
       Prompt="[[entities/aipa-web]] のKPIダッシュボード設計。週次KPI: アポ数/商談数/成約数/月商/CS満足度/解約率/応募増加率(顧客側)。各KPIの計算式・目標値・改善トリガー。約3000字。" }
)

$available = $pool | Where-Object { $_.Slug -notin $recentSlugs }
if ($available.Count -eq 0) { $available = $pool }

$pick = $available | Get-Random
$outDir = Join-Path $brainRoot "wiki\_inbox\$($pick.Dept)"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$outPath = Join-Path $outDir "biz-aipa-$($pick.Slug)-$stamp-$shortId.md"

& $dispatcher `
    -Department $pick.Dept `
    -Title $pick.Title `
    -Prompt $pick.Prompt `
    -Model "qwen3:8b" `
    -OutputPath $outPath `
    -Priority "high" `
    -UseAgent 2>&1 | Out-Null

$newHistory = @($state.history) + @(@{ slug = $pick.Slug; time = (Get-Date).ToString("o") })
$cutoffOld = (Get-Date).AddDays(-3)
$newHistory = $newHistory | Where-Object { [DateTime]$_.time -gt $cutoffOld }
[System.IO.File]::WriteAllText($stateFile, (@{ history = $newHistory } | ConvertTo-Json -Depth 5), [System.Text.UTF8Encoding]::new($false))

"$nowStamp - aipa-web: $($pick.Title)" | Add-Content $logPath -Encoding UTF8
Write-Host "AIpaWeb-filled: $($pick.Title)"
