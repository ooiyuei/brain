#requires -Version 5.1
# 金軸 filler - 3分おきに「お金に直結するタスク」を常時投入
# 大井が直接売上を作るための材料 (営業文/LP/モニター獲得/コンテスト応募/個別提案)
# 通常の idle_filler とは別途、inbox を厚く保つために高頻度実行

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$logPath = Join-Path $brainRoot "scripts\money_filler.log"
$stateFile = Join-Path $brainRoot "scripts\.money_filler_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$today = (Get-Date).ToString("yyyy-MM-dd")
$cooldownHours = 4  # 4時間以内同テーマ禁止

$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

$inbox = (Get-ChildItem (Join-Path $brainRoot "queue\inbox") -File -ErrorAction SilentlyContinue).Count
$inboxTarget = 8  # 金軸も含めて最低8件キープ

if ($inbox -ge $inboxTarget) {
    "$nowStamp - inbox full (=$inbox), skip" | Add-Content $logPath -Encoding UTF8
    exit 0
}

# state読み込み
$state = @{ history = @() }
if (Test-Path $stateFile) {
    try {
        $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $state = @{ history = @($loaded.history) }
    } catch {}
}

$cutoff = (Get-Date).AddHours(-$cooldownHours)
$recentSlugs = @($state.history | Where-Object { [DateTime]$_.time -gt $cutoff } | ForEach-Object { $_.slug })

$stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
$shortId = [guid]::NewGuid().ToString().Substring(0,4)

# ===== 金軸 pool (お金に直結) =====
$pool = @(

    # ============ AIpa Web 集客 (月15万x3社=45万狙い) ============
    @{ Slug="money-aipa-prospect-list"; Title="[金] AIpa Web モニター候補10社+アプローチ案"; Department="marketing"; OutDir="marketing"
       Prompt="[[entities/aipa-web]] のモニター3社獲得(月15万x3=45万)の具体行動として、候補10社リスト作成。`n`n対象基準(必読):`n- 地方の建設/製造/運輸/サービス業`n- 従業員30-300名規模`n- 採用に課題ありそう (求人サイトに掲載中など)`n- 自社採用サイトが古い/無い`n`n各候補:`n1. 業種・規模・地域 (具体的に・架空NG・思いつく範囲でOK)`n2. なぜこの会社か (採用課題の仮説)`n3. アプローチ媒体 (HP問合せ/採用担当メール/紹介)`n4. 初回メッセージ案 (200字以内・件名込み)`n5. 想定される反応と次の一手`n`n注意: 実在企業名は推測できる範囲で。確証ないなら『○○業の中規模企業』と業種で。約3000字。" }

    @{ Slug="money-aipa-email-templates"; Title="[金] AIpa Web 営業メールテンプレ5本"; Department="marketing"; OutDir="marketing"
       Prompt="[[entities/aipa-web]] のモニター獲得用営業メール5パターン。`n`n大井のキャラ: 高校生起業家・フランク・断定形・関西弁混じり可・AI臭NG`n`n各テンプレ:`n- 件名 (30字以内)`n- 本文 (300-400字・結論ファースト・1メッセージ1メリット)`n- 想定読者と痛みポイント`n- パターン特徴 (A:数字訴求 / B:質問型 / C:事例風 / D:緊急性 / E:同世代共感)`n- 返信率を上げるコツ`n`n各メール、開封率まで意識した件名にする。約2500字。" }

    @{ Slug="money-aipa-followup-scripts"; Title="[金] AIpa Web フォローアップトーク台本3本"; Department="marketing"; OutDir="marketing"
       Prompt="[[entities/aipa-web]] 商談後のフォローアップ電話/メール台本3本。`n`nシナリオ:`n1. 初回提案後・反応薄い相手への2回目アプローチ`n2. 『検討中』返信から1週間後のリマインド`n3. 一度断られた相手への半年後再アプローチ`n`n各台本:`n- 想定状況 (3行)`n- メッセージ本文 (300字)`n- 想定される断り文句と返し`n- 次のアクション (商談設定/別商品提案/縁切り)`n`n約2500字、大井キャラ厳守。" }

    @{ Slug="money-aipa-landing-page"; Title="[金] AIpa Web LP コピーライティング 1本"; Department="marketing"; OutDir="marketing"
       Prompt="[[entities/aipa-web]] のLP1ページ完全版コピーライティング。`n`n構成:`n1. ファーストビュー (キャッチコピー30字 + サブコピー60字)`n2. 課題提起 (中小企業の採用ペイン3つ・具体的に)`n3. ソリューション (16セクションフォーム + AI初稿)`n4. 3プラン提示 (モニター月15万/標準/プレミアム の差別化)`n5. 事例 (架空でも構造のみ・『○○業40名規模のA社』形式)`n6. FAQ 5問`n7. CTA (無料相談予約/モニター応募)`n`n約3500字、コピーライターレベルで。大井のWeb制作実績(dinii/HONE)を強みとして示す。" }

    # ============ AIpaX 営業 (β顧客1社 50-80万狙い) ============
    @{ Slug="money-aipax-proposal-template"; Title="[金] AIpaX β顧客向け 提案書テンプレ"; Department="newbiz"; OutDir="newbiz"
       Prompt="[[entities/aipax]] のβ顧客向け提案書を完全に書く。価格: 初回50-80万円・以降月額。`n`n構成:`n1. 顧客課題の言語化 (中小企業のAI導入率5%問題)`n2. AIpaX が解決すること (会社別AI保存庫コア + 業務ツール)`n3. 導入後のBefore/After (具体的な業務シーン3つ)`n4. 価格構造の根拠 (50万円の内訳・通常コンサル200万との比較)`n5. 導入スケジュール (3ヶ月)`n6. 大井+チーム体制`n7. 成功事例 (架空構造でも可)`n8. リスクと保証`n`n約3500字、PDFそのまま使えるレベルで。" }

    @{ Slug="money-aipax-prospects"; Title="[金] AIpaX β顧客候補10社+痛みリサーチ"; Department="newbiz"; OutDir="newbiz"
       Prompt="[[entities/aipax]] のβ顧客10社の選定基準と候補プロファイル。`n`n基準:`n- AI活用に興味あるが導入できてない中小企業`n- 経営者が直接決められる規模 (30-300名)`n- 業務効率化に予算50万円使える`n- 過去にツール導入失敗経験がある`n`n各候補:`n1. 業種・規模 (具体的に)`n2. 想定される業務課題3つ`n3. AIで解決可能な業務 (架電補助/問合せ返信/社内検索など)`n4. アプローチルート`n5. 50万円を払う論理 (1人雇用vs AI導入のROI計算)`n`n約3000字、推測には『推測:』必須。" }

    # ============ AIpaX school 立ち上げ (月3万x5名=15万狙い) ============
    @{ Slug="money-school-curriculum"; Title="[金] AIpaX school 1年カリキュラム詳細v2"; Department="newbiz"; OutDir="newbiz"
       Prompt="[[entities/aipax-school]] の1年カリキュラムを5モジュール構造で完成させる。`n参考: [[concepts/ai-economy-2026-structure]] の Module構造。`n`n各モジュール(2ヶ月):`n- 学習目標 (生徒が何を達成できるか)`n- 週次トピック (8週分)`n- 課題と発表 (生徒が作るアウトプット)`n- 必要ツール (Antigravity/Cursor/Claude/Figma 等)`n- 評価方法`n`n5モジュール:`n1. AIマインドセット + バイブ体験`n2. 日常業務自動化`n3. エンジニアリング思考 + 外部連携`n4. 本格アプリ開発 + リリース`n5. データ分析 + マネタイズ`n`n約4000字。" }

    @{ Slug="money-school-parent-lp"; Title="[金] AIpaX school 親向けLP草稿"; Department="newbiz"; OutDir="newbiz"
       Prompt="[[entities/aipax-school]] 親向けLP完全版。月3万円x5名集客が目標。`n`nペルソナ: 中高生の親・子の将来を案じている・AI時代に何を学ばせるべきか不安`n`n構成:`n1. ファーストビュー: 『AIに使われる人ではなく、AIを使いこなす人に』`n2. 親の不安に共感 (受験勉強で大丈夫?・将来の職業は?)`n3. AIpaX schoolの解決 (1年で動くアプリを作れる中高生に育てる)`n4. カリキュラム概要 (5モジュール簡略)`n5. 大井湧瑛の信頼性 (実績・HR高等学院・事業経験)`n6. 月3万円の価値説明 (塾月8万との比較)`n7. 体験会CTA`n8. FAQ 5問`n`n約3500字、親の不安を解像度高く言語化。" }

    @{ Slug="money-school-trial"; Title="[金] AIpaX school 体験会2時間プログラム"; Department="newbiz"; OutDir="newbiz"
       Prompt="[[entities/aipax-school]] 体験会(2時間)の完全プログラム。最終CTAは月3万契約。`n`n構成:`n0:00-0:15 開会 (大井ストーリー・AI時代の話)`n0:15-0:45 ハンズオン1 (Antigravityで自分専用アプリを作る)`n0:45-1:30 ハンズオン2 (Cursor/Claudeで身近な課題を解決)`n1:30-1:50 1年カリキュラム説明 + 卒業生像`n1:50-2:00 個別相談・契約説明`n`n各セクション:`n- 講師トーク台本 (要旨)`n- 親向け・生徒向けの分け方`n- 使うツール`n- 親へのCTAタイミング`n`n約3500字。" }

    # ============ ビジコン応募 (受賞=賞金+知名度=売上接続) ============
    @{ Slug="money-contest-yume-award"; Title="[金] 夢AWARD応募ストーリー骨子v2"; Department="newbiz"; OutDir="newbiz"
       Prompt="夢AWARD(締切6/7)応募骨子v2。代表事業[[entities/eemus]]で応募。`n`n要件:`n- 高校生対象のビジネス・キャリア系コンテスト`n- 静岡発・地方創生視点で勝負`n- ストーリー: 大井自身の経験から事業化まで`n`n骨子:`n1. 大井の原体験 (HR高等学院・実務経験)`n2. 解決したい課題 (高校生の実務機会の少なさ)`n3. EEMUSの中核 (高校生版Wantedly)`n4. 進捗・実績 (静岡企業との連携状況・推測でも可)`n5. 今後の展開 (静岡→東海→全国)`n6. 大井のリーダーシップビジョン`n`n約3000字、感情を動かす言葉で。" }

    @{ Slug="money-contest-list"; Title="[金] 大井向け6月応募ビジコン5件"; Department="newbiz"; OutDir="newbiz"
       Prompt="2026年6-8月に大井が応募すべき高校生・若手向けビジネスコンテスト5件を提案。`n`n各コンテスト:`n- 名称 (実在のみ)`n- 締切目安`n- 賞金・特典`n- 大井のどの事業で応募すべきか ([[entities/]])`n- 勝算 (自己採点 10点満点)`n- 応募書類の難易度`n`n候補: 夢AWARD / コムロ / GTE / StartupBase / KANSAI / TOKYO STARTUP GATEWAY 等。実在のものを推測も含めて挙げる。約2500字。" }

    # ============ アプリ量産 (月3万x複数=月10万狙い) ============
    @{ Slug="money-app-spec-1week"; Title="[金] 1週間で作れる月3万アプリ仕様書"; Department="newbiz"; OutDir="newbiz"
       Prompt="大井がCursor/Claude Codeで1週間で作れて月3万円稼ぐアプリ1案の完全仕様書。`n`n要件:`n- 開発1週間以内 (バイブコーディング前提)`n- 広告99% : 課金1% モデル`n- ニッチで競合『あるけど雑』レベル`n- 大井のニーズ起点 or 高校生の困りごと起点`n- AdMob/Stripe想定`n`n仕様書:`n1. アプリ名・1行説明`n2. ターゲット (明日使う1人)`n3. 機能リスト v0.1 (MVP・3機能のみ)`n4. 画面構成 (3画面)`n5. データモデル`n6. 技術スタック (React Native+Expo+Supabase推奨)`n7. 月3万円達成のロジック (DAU x 広告単価 or 課金率)`n8. ASO戦略 (App Store/Google Play キーワード)`n9. 開発スケジュール (7日分)`n`n約3500字、明日着手できるレベルで具体的に。" }

    @{ Slug="money-app-niche-hunt"; Title="[金] 月3万アプリ ニッチ需要ハント10案"; Department="newbiz"; OutDir="newbiz"
       Prompt="月3万円稼ぐアプリのニッチ需要を10個ハント。`n`n発想軸:`n- 大井自身が『毎日これ面倒』と感じてること`n- 高校生・親世代の小さな困りごと`n- 既存アプリが雑にしか解決してない領域`n- AdMob/サブスクで継続収益化可`n`n各案:`n- アプリ名仮称`n- 1行コンセプト (30字)`n- ターゲット (明日使う1人)`n- 競合実例 (実在のみ)`n- 月3万円達成までの想定ユーザー数`n- 開発工数 (バイブコーディング前提)`n- 大井の脳汁度 (A/B/C)`n`n約3000字、架空企業名NG。" }

    # ============ SEO / コンテンツ集客 (流入→売上) ============
    @{ Slug="money-seo-aipa"; Title="[金] AIpa Web SEO記事 完全本文1本"; Department="marketing"; OutDir="marketing"
       Prompt="[[entities/aipa-web]] のSEO記事1本完全版を書く。ターゲットKW『中小企業 採用サイト 制作費用』等。`n`n構成:`n1. タイトル (30字以内・検索意図直撃)`n2. ディスクリプション (120字)`n3. 見出しH2 5つ + H3 各2つ`n4. 本文 2500字`n5. CTA (AIpa Web無料相談)`n6. 内部リンク提案`n`n大井のキャラで、AI臭ゼロ、断定形多用。実在企業名・実在ツール名のみ。約3500字。" }

    @{ Slug="money-content-school"; Title="[金] AIpaX school 親向け不安解消記事"; Department="marketing"; OutDir="marketing"
       Prompt="[[entities/aipax-school]] 親向けの不安解消ブログ記事1本。ターゲットKW『AI 子供 学ばせる 何から』。`n`n構成:`n1. 親の不安に共感 (AI時代に何を学ばせるか分からない)`n2. プログラミング教室との違い`n3. 中高生がAIを学ぶ意義 (将来の職業観)`n4. AIpaX schoolの位置づけ`n5. 体験会CTA`n`n2500字本文。感情を動かしつつ論理的に。母親が読んで安心する書き方。" }

    @{ Slug="money-twitter-aipax"; Title="[金] X(Twitter) 大井 1週間分投稿20本"; Department="marketing"; OutDir="marketing"
       Prompt="大井湧瑛 X(Twitter)用 1週間分の投稿20本を作る。`n`n方針:`n- 高校生起業家のリアル発信 (実績・失敗・学び)`n- AI事業の途中経過 (作ったもの・気づき)`n- 静岡発・地方創生視点`n- AI時代の人間論 (大井のクローン仕様書を反映)`n`n各投稿:`n- 140字以内 or スレッド (3-5ツイート)`n- 1日3本のペース (朝/昼/夜)`n- 大井のキャラ厳守 (フランク・断定・関西弁混じり可)`n- ハッシュタグ最大2つ`n`n投稿パターン:`n- 思考の言語化 (5本)`n- 事業の進捗 (5本)`n- 業界への意見 (5本)`n- 高校生向けメッセージ (5本)`n`n約3000字。" }

    # ============ 既存顧客アップセル / リピート ============
    @{ Slug="money-dinii-followup"; Title="[金] dinii時代の人脈 6月接触リスト"; Department="newbiz"; OutDir="newbiz"
       Prompt="大井のdinii時代の関係者・人脈に対して6月にどう接触するかリスト化。`n`n背景:`n- diniiでカスタマーサクセス経験 (飲食店向け)`n- 配信施策の巻き取りで実績`n- 800→1100売上で37.5%増`n`n接触目的:`n- AIpa Web/AIpaXの案件紹介依頼`n- 飲食業界向け派生事業の壁打ち`n- 業界ニュースの情報交換`n`n5パターンの接触シナリオ:`n1. 元同僚 (現役dinii社員)`n2. 元上司`n3. dinii顧客の飲食店オーナー`n4. 業界仲間 (他社CS)`n5. 紹介ハブ人材`n`n各:`n- 接触タイミング`n- メッセージ案 (200字)`n- 想定リターン`n`n約2500字。" }
)

# クールダウン除外
$available = $pool | Where-Object { $_.Slug -notin $recentSlugs }
if ($available.Count -eq 0) {
    $available = $pool
}

$pick = $available | Get-Random
$outPath = Join-Path $brainRoot "wiki\_inbox\$($pick.OutDir)\money-$($pick.Slug)-$stamp-$shortId.md"

# 金軸タスクは品質重視 + High priority (workerが先に拾う)
& $dispatcher `
    -Department $pick.Department `
    -Title $pick.Title `
    -Prompt $pick.Prompt `
    -Model "qwen3:8b" `
    -OutputPath $outPath `
    -Priority "high" 2>&1 | Out-Null

# state更新
$newHistory = @($state.history) + @(@{ slug = $pick.Slug; time = (Get-Date).ToString("o") })
$cutoffOld = (Get-Date).AddDays(-3)
$newHistory = $newHistory | Where-Object { [DateTime]$_.time -gt $cutoffOld }
$stateJson = @{ history = $newHistory } | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

"$nowStamp - money dispatched: $($pick.Title) (slug=$($pick.Slug), inbox_before=$inbox)" | Add-Content $logPath -Encoding UTF8

Write-Host "Money-filled: $($pick.Title)"
