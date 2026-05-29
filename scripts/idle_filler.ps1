#requires -Version 5.1
# 5分おきにアイドル状態を検知して「5軸ベース」の実用タスクを自動投入
# 5軸: 既存事業 / 新規事業 / IS / AI最新 / ビジネス経済

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$logPath = Join-Path $brainRoot "scripts\idle_filler.log"
$stateFile = Join-Path $brainRoot "scripts\.idle_filler_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$cooldownHours = 3   # 3時間以内同テーマ禁止

# Pause チェック
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) {
    "$nowStamp - PAUSED, skip" | Add-Content $logPath -Encoding UTF8
    exit 0
}

# アイドル判定（しきい値: inbox<5 で補充する）
$inbox = (Get-ChildItem (Join-Path $brainRoot "queue\inbox") -File -ErrorAction SilentlyContinue).Count
$processing = (Get-ChildItem (Join-Path $brainRoot "queue\processing") -File -ErrorAction SilentlyContinue).Count
$inboxTarget = 10

if ($inbox -ge $inboxTarget) {
    "$nowStamp - inbox sufficient (inbox=$inbox >= $inboxTarget), skip" | Add-Content $logPath -Encoding UTF8
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

# 既存事業 (重要度A：主力)
$mainEntities = @("aipa-web", "testall", "agents-of-flag", "aipax", "eemus")
$randomMain = $mainEntities | Get-Random

$stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
$shortId = [guid]::NewGuid().ToString().Substring(0,4)

# === 5軸×実用テーマ pool ===
$pool = @(

    # ============ 軸1: 既存事業深掘り（実用・5本） ============
    @{ Slug="existing-customer-$randomMain"; Title="[既存] $randomMain 顧客プロファイル深掘り"; Department="research"; OutDir="research"
       Prompt="[[entities/$randomMain]] の理想顧客像を深掘り。以下を構造化:`n1. 一次顧客（明日契約してくれそうな1社）の具体プロファイル（業種/規模/役職/痛み/予算）`n2. その顧客のJTBD（Job To Be Done）3つ`n3. 既存代替案で何を使ってるか（実在ツール名のみ。架空NG）`n4. 大井がアプローチすべき接点（媒体・コミュニティ）`n5. 1社契約までの最短ステップ5つ`n`n約2500字、推測には『推測:』必須、架空企業名NG。" }

    @{ Slug="existing-strategy-$randomMain"; Title="[既存] $randomMain 戦略仮説3つ"; Department="newbiz"; OutDir="newbiz"
       Prompt="[[entities/$randomMain]] が3ヶ月以内に「1社契約」取るための戦略仮説を3つ。`n各仮説:`n- 仮説（30字）`n- 検証方法（具体的アクション・3日以内に動けるもの）`n- 成功基準（数字で）`n- 失敗時のピボット案`n`n約2000字、抽象論NG、必ず実行可能な具体アクション。" }

    @{ Slug="existing-pricing-$randomMain"; Title="[既存] $randomMain 価格戦略 3パターン"; Department="newbiz"; OutDir="newbiz"
       Prompt="[[entities/$randomMain]] の価格戦略3パターン提案。`n- パターンA: 安売り戦略（リード獲得型）`n- パターンB: 中堅価格（標準）`n- パターンC: プレミアム（少数精鋭）`n`n各パターン:`n- 月額/初期費用の具体数字`n- ターゲット顧客像`n- 月X社売って月Y万円のロジック`n- リスク・反応予測`n`n約2000字、数字根拠を明示、根拠なき数字には『推測:』。" }

    # ============ 軸2: 新規事業創出（勝ち筋ベース・5本） ============
    @{ Slug="newbiz-app-batch"; Title="[新規] アプリ量産案 月10万×100候補"; Department="newbiz"; OutDir="newbiz"
       Prompt="大井の『1プロダクト月10万円×100プロダクト=月1000万』戦略に沿った新規アプリ案を10個提案。`n`n要件（[[meta/good-business-definition]] 参照）:`n- 既存アプリの1/4規模で開発1週間以内`n- SEO/SNSで自然流入可能なニッチ`n- 月10万維持できる継続課金型`n- 競合は『あるけど雑』を『丁寧』に勝つ`n`n各案:`n- 名前（仮称）`n- 1行説明（30字）`n- ターゲット（明日使う1人）`n- 開発工数（推定）`n- 月10万への到達筋（顧客数×単価）`n- 競合（実在）`n`n約3000字、架空企業NG。" }

    @{ Slug="newbiz-pivot-existing"; Title="[新規] 既存事業の派生で新案3つ"; Department="newbiz"; OutDir="newbiz"
       Prompt="大井の既存15事業の『資産・データ・ノウハウ』を活かして派生事業3案を提案。`n`n各案:`n- 既存事業（どれから派生）`n- 新事業の中核アイデア`n- 既存資産の活かし方（具体的に）`n- ターゲット（既存事業の顧客と被るか別か）`n- 立ち上げ最短ルート`n- 大井の脳汁度（A/B/C）`n`n[[meta/good-business-definition]] の10項目で自己採点も。約2500字。" }

    @{ Slug="newbiz-niche-hunt"; Title="[新規] ニッチ市場ハント 5領域"; Department="newbiz"; OutDir="newbiz"
       Prompt="2026年現在、『大手が手を出さない/出せない』ニッチ市場を5つ提案。`n各領域:`n- 領域名と境界`n- なぜ大手が手を出さないか（構造的理由）`n- 大井が攻める時のエントリーポイント`n- 月100万円規模に到達できる根拠`n- 大井の強み（AI/UX/SFC視点）との接点`n`n約2500字、机上の空論NG。" }

    # ============ 軸3: インサイドセールス（顧客獲得・5本） ============
    @{ Slug="is-customer-list-$randomMain"; Title="[IS] $randomMain 顧客リスト作成手順"; Department="marketing"; OutDir="marketing"
       Prompt="[[entities/$randomMain]] の顧客リストを作る具体手順を書く。`n`n出力:`n1. ターゲット業界・規模・地域の絞り方（実在企業の例3社）`n2. リスト収集ソース（GoogleMap / 業界団体 / 求人サイト / Wantedly / Twitterなど）`n3. 各ソースの収集手順（手動 / スクレイピング / API）`n4. 連絡先取得方法（HP問合せ / 採用担当メール / LinkedIn）`n5. リスト100社作る3日間のスケジュール`n`n約2500字、ツール名は実在のみ。" }

    @{ Slug="is-email-templates"; Title="[IS] AIpa Web 営業メールテンプレ5本"; Department="marketing"; OutDir="marketing"
       Prompt="[[entities/aipa-web]] の営業メールテンプレを5パターン作る。`n各テンプレ:`n- 件名（30字以内）`n- 本文（400字以内・結論ファースト）`n- ターゲット（業種・痛み）`n- パターンの特徴（A:ベネフィット直球 / B:質問型 / C:数字訴求 / D:事例紹介 / E:緊急性）`n`n大井のキャラ: フランク、関西弁混じり可、断定形、AI臭NG。" }

    @{ Slug="is-seo-articles"; Title="[IS] AIpa Web SEO記事タイトル20本"; Department="marketing"; OutDir="marketing"
       Prompt="[[entities/aipa-web]] のSEO記事タイトル20本。`n検索意図あるクエリベース（『採用サイト 制作費用』『中小企業 採用 AI』など）。`n各タイトル:`n- タイトル（30字以内）`n- 想定読者`n- 内容骨子（3行）`n- 想定検索ボリューム（推測:大/中/小）`n- 大井事業への誘導CTA`n`n約3000字。" }

    # ============ 軸4: AI最新（実用情報・5本） ============
    @{ Slug="ai-models-week"; Title="[AI] 今週注目AIモデル・ツール3つ"; Department="research"; OutDir="research"
       Prompt="2026-05週で大井が知るべき AI モデル・ツール 3つを紹介。`n各:`n- 名前（実在のみ・公式URL明記）`n- 何ができるか（30字）`n- 大井プロダクトへの応用案（[[entities/]] 具体的に）`n- 試すべき or スルーすべきか`n`n約2000字、知らないものは『不明』、架空モデルNG。" }

    @{ Slug="ai-anthropic-update"; Title="[AI] Anthropic/Claude 直近アップデート"; Department="research"; OutDir="research"
       Prompt="Anthropicの直近Claudeアップデート（モデル・SDK・MCP）で大井が活用すべきものを抽出。`n大井が使ってるClaudeMax/Claude Code との関係性に注目。`n出力:`n- 新機能リスト（実在のみ）`n- 大井のBrain Systemへの応用案`n- 設定変更すべき箇所`n`n約2000字、推測情報は明記。" }

    @{ Slug="ai-tools-comparison"; Title="[AI] ローカルLLM運用 効率化Tips"; Department="research"; OutDir="research"
       Prompt="大井のOllama(qwen3.6/8b)運用を効率化するTipsを5つ。`n- GPU/RAM最適化`n- プロンプトキャッシュ`n- 並列処理パターン`n- モデル選定基準`n- LangChain/LlamaIndex等の統合`n`n具体的なコマンド・設定値を含む。約2500字。" }

    # ============ 軸5: ビジネス経済（事業ヒント・5本） ============
    @{ Slug="biz-saas-trends"; Title="[経済] 中小企業向けSaaS 2026動向"; Department="research"; OutDir="research"
       Prompt="2026年の中小企業向けSaaS市場動向を要約。`n注目セグメント: HR-Tech / 採用 / 業務効率化 / DX支援。`n出力:`n- 市場規模（推測:）`n- 注目プレイヤー（実在のみ）`n- 大井プロダクトに刺さるトレンド`n- 参入チャンスのある隙間`n`n約2500字、架空企業NG。" }

    @{ Slug="biz-startup-funding"; Title="[経済] 国内スタートアップ資金調達トレンド"; Department="research"; OutDir="research"
       Prompt="2026年の国内スタートアップ資金調達トレンドで大井が知るべき動向。`n- 注目調達ラウンド（公開情報・推測）`n- 大井の事業領域に近いプレイヤーの動き`n- VCの関心領域`n- 大井が資金調達するなら狙うべきタイミング`n`n約2500字、知らない調達は『推測:』必須。" }

    @{ Slug="biz-edu-policy"; Title="[経済] 教育・採用政策の変化"; Department="research"; OutDir="research"
       Prompt="2026年の教育・採用関連の政策・規制変更で [[entities/testall]] / [[entities/aipa-web]] / [[entities/eemus]] に影響あるものをまとめる。`n- 直近の法改正・通達`n- 業界団体の動き`n- 助成金・補助金（実在のみ）`n- 大井事業の追い風・逆風`n`n約2500字、架空制度NG。" }
)

# クールダウン除外
$available = $pool | Where-Object { $_.Slug -notin $recentSlugs }
if ($available.Count -eq 0) {
    $available = $pool
}

$pick = $available | Get-Random
$outPath = Join-Path $brainRoot "wiki\_inbox\$($pick.OutDir)\idle-$($pick.Slug)-$stamp-$shortId.md"

# 品質重視: qwen3:8b で じっくり処理（heavy lane）
& $dispatcher `
    -Department $pick.Department `
    -Title $pick.Title `
    -Prompt $pick.Prompt `
    -Model "qwen3:8b" `
    -OutputPath $outPath `
    -Priority "normal" 2>&1 | Out-Null

# state更新
$newHistory = @($state.history) + @(@{ slug = $pick.Slug; time = (Get-Date).ToString("o") })
$cutoffOld = (Get-Date).AddDays(-3)
$newHistory = $newHistory | Where-Object { [DateTime]$_.time -gt $cutoffOld }
$stateJson = @{ history = $newHistory } | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

"$nowStamp - idle dispatched: $($pick.Title) (slug=$($pick.Slug), pool=$($pool.Count), avail=$($available.Count))" | Add-Content $logPath -Encoding UTF8

Write-Host "Idle-filled: $($pick.Title)"
