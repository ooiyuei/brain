#requires -Version 5.1
# 既存事業 universal filler - AIpaX / AIpaX school / EEMUS / Testall を順番に
# ぶん回しモード・10分おき・各事業の必要な成果物を全方位で量産

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$logPath = Join-Path $brainRoot "scripts\biz_filler.log"
$stateFile = Join-Path $brainRoot "scripts\.biz_filler_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$cooldownHours = 12

$state = @{ history = @() }
if (Test-Path $stateFile) { try { $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json; $state = @{ history = @($loaded.history) } } catch {} }
$cutoff = (Get-Date).AddHours(-$cooldownHours)
$recentSlugs = @($state.history | Where-Object { [DateTime]$_.time -gt $cutoff } | ForEach-Object { $_.slug })

$stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
$shortId = [guid]::NewGuid().ToString().Substring(0,4)

$pool = @(
    # ===== AIpaX (中小企業AI導入・月50万x1社 = 月50万狙い) =====
    @{ Slug="aipax-prospect-30"; Title="[AIpaX] β顧客候補30社プロファイル"; Dept="newbiz"
       Prompt="[[entities/aipax]] のβ顧客候補30社。基準: 50-200名・AI導入意欲・予算50万出せる中小企業。各社: 業種規模/想定業務課題3つ/AI解決可能性/接点/50万円提案ロジック/競合知見。約4000字、推測明示、架空企業NG。" }
    @{ Slug="aipax-proposal-80man"; Title="[AIpaX] β顧客80万提案書フル版"; Dept="newbiz"
       Prompt="[[entities/aipax]] のβ顧客80万円提案書フル版。課題(AI導入率5%問題)/ソリューション(保存庫コア+業務ツール)/Before/After/価格根拠(80万内訳: 30万実装+30万カスタマイズ+20万3ヶ月運用)/通常コンサル300万比較/3ヶ月スケジュール/成功事例/リスク保証/FAQ。約4000字。" }
    @{ Slug="aipax-lp-beta"; Title="[AIpaX] β顧客5社募集LP完全版"; Dept="marketing"
       Prompt="[[entities/aipax]] のβ顧客5社募集LP完全版コピー。50-80万円の根拠明示。FV/中小企業のAI導入5%問題/解決/β特典/事例/価格根拠/FAQ/CTA。約3500字、論理重視、信頼性訴求。" }
    @{ Slug="aipax-seo-chusho-ai"; Title="[AIpaX] SEO『中小企業 AI 導入 失敗』本文"; Dept="marketing"
       Prompt="検索KW『中小企業 AI 導入 失敗』のSEO記事完全本文。読者: AI導入失敗経験ある中小企業経営者。H2 5+H3 各2/本文2500字/AIpaX誘導/内部リンク。約3500字。" }
    @{ Slug="aipax-x-thread-tips"; Title="[AIpaX] X投稿『AI導入Tips』20本"; Dept="marketing"
       Prompt="[[entities/aipax]] 文脈での『AI導入Tips』X投稿20本(各140字以内)。中小企業経営者向け。各: 投稿本文+想定リーチ層+CTA。大井キャラ。約2500字。" }
    @{ Slug="aipax-contract-template"; Title="[AIpaX] 業務委託契約書テンプレ"; Dept="corp"
       Prompt="[[entities/aipax]] のβ契約書テンプレ。業務範囲(AI保存庫+運用)/初回80万+月額/著作権/秘密保持/データ取扱い/解約条件。約3500字。" }
    @{ Slug="aipax-pl-monthly"; Title="[AIpaX] 月次PL試算"; Dept="corp"
       Prompt="[[entities/aipax]] のβ1社月50万+運用継続のPL。売上構成/原価(実装工数+AI API+保管庫運用)/損益分岐点/6社契約まで予測。約3000字。" }

    # ===== AIpaX school (中高生スクール・月3万x5名 = 月15万狙い) =====
    @{ Slug="school-curriculum-v2"; Title="[School] 1年カリキュラム詳細v2"; Dept="newbiz"
       Prompt="[[entities/aipax-school]] の1年カリキュラム5モジュール完成版。各モジュール(2ヶ月): 学習目標/週次トピック8/課題/必要ツール/評価方法。AIマインドセット→日常業務自動化→エンジニアリング思考+外部連携→本格アプリ開発+リリース→データ分析+マネタイズ。約4000字。" }
    @{ Slug="school-parent-lp"; Title="[School] 親向けLP完全版"; Dept="marketing"
       Prompt="[[entities/aipax-school]] 親向けLP。月3万円x5名集客目標。ペルソナ: 中高生の親・子の将来案じてる・AI時代の不安。FV(『AIに使われる人ではなく使う人に』)/親不安共感/解決/カリキュラム/大井実績/月3万円根拠(塾月8万比較)/体験会CTA/FAQ。約3500字。" }
    @{ Slug="school-trial-2h-program"; Title="[School] 体験会2時間プログラム"; Dept="newbiz"
       Prompt="[[entities/aipax-school]] 体験会(2時間)完全プログラム。最終CTA月3万契約。0:00-0:15開会/0:15-0:45ハンズオン1(Antigravity自分専用アプリ)/0:45-1:30ハンズオン2(Cursor身近課題解決)/1:30-1:50カリキュラム説明+卒業生像/1:50-2:00個別相談+契約説明。約3500字。" }
    @{ Slug="school-onboarding"; Title="[School] 入学後30日プラン"; Dept="marketing"
       Prompt="[[entities/aipax-school]] 入学後30日の生徒/親対応プラン。30日で『動くアプリ1個』作らせる。親への週次進捗レポート含む。約3500字。" }
    @{ Slug="school-faq-parent-30"; Title="[School] 親FAQ 30問"; Dept="marketing"
       Prompt="[[entities/aipax-school]] 親FAQ 30問+回答。受験勉強と両立?中学生で分かる?月3万根拠?塾と比べて?他。丁寧かつ大井の人柄が伝わる温度感。約4000字。" }
    @{ Slug="school-tos"; Title="[School] 利用規約・特商法表記"; Dept="corp"
       Prompt="[[entities/aipax-school]] (中高生向け) 利用規約と特商法表記。契約者(親)と受講者(中高生)関係/月謝3万支払い・解約・返金/知的財産(生徒制作物著作権)/退学規定/個人情報(中高生保護)/体験会キャンセル。約3500字、塾業界標準準拠。" }
    @{ Slug="school-x-content"; Title="[School] X『中高生×AI』20投稿"; Dept="marketing"
       Prompt="[[entities/aipax-school]] のX『中高生×AI』20投稿。親と中高生両方に刺さる。各140字。大井キャラ。約2500字。" }
    @{ Slug="school-note-parent-essay"; Title="[School] note『AI時代に子供に渡したいもの』"; Dept="marketing"
       Prompt="大井のnote記事『AIpaX schoolで子供たちに渡したいもの』(3000字)。なぜAI学ばせるべきか・何を学ばせるべきか・大井自身の中高生時代との対比。自分語り→社会観察→事業仮説→親への問いかけ。約3500字。" }

    # ===== EEMUS (高校生x企業・夢AWARD応募事業) =====
    @{ Slug="eemus-dream-award-story"; Title="[EEMUS] 夢AWARD応募ストーリー骨子"; Dept="newbiz"
       Prompt="夢AWARD(締切6/7)応募骨子。[[entities/eemus]] で応募。高校生対象・静岡発・地方創生視点。骨子: 大井原体験(HR高等学院・実務経験)/解決したい課題(高校生実務機会不足)/EEMUS中核(高校生版Wantedly)/進捗・実績/今後の展開(静岡→東海→全国)/大井リーダーシップビジョン。約3000字、感情を動かす言葉で。" }
    @{ Slug="eemus-pitch-deck-10p"; Title="[EEMUS] ピッチデック10枚構成"; Dept="newbiz"
       Prompt="[[entities/eemus]] のピッチデック10枚構成完全版。1:タイトル/2:課題/3:既存解決の限界/4:EEMUSソリューション/5:市場規模/6:ビジネスモデル/7:競合差別化/8:Traction/9:チーム/10:Ask。各スライド: 見出し+本文要点+ビジュアル指示+話す内容。約4000字。" }
    @{ Slug="eemus-target-schools-20"; Title="[EEMUS] 提携高校候補20校リスト"; Dept="newbiz"
       Prompt="[[entities/eemus]] の連携候補高校20校リスト。静岡県内優先。各校: 校名(実在推測OK)/特徴(進学校/実業/通信制)/連携メリット仮説/接点(校長/進路指導/PTA)/提案案。約3500字、推測明示。" }
    @{ Slug="eemus-target-companies-20"; Title="[EEMUS] 連携企業候補20社"; Dept="newbiz"
       Prompt="[[entities/eemus]] の高校生インターン受入企業候補20社。静岡県中堅・成長企業中心。各社: 業種規模/インターン受入メリット仮説/接点。約3500字。" }
    @{ Slug="eemus-lp-mvp"; Title="[EEMUS] MVP LP完全版"; Dept="marketing"
       Prompt="[[entities/eemus]] MVP段階のLP完全版。高校生・親・企業の3ターゲット向けセクション。FV/共通課題/3者向け価値/事例(架空構造)/FAQ/CTA。約3500字。" }
    @{ Slug="eemus-content-stories"; Title="[EEMUS] 高校生インターン体験談コンテンツ3本"; Dept="marketing"
       Prompt="[[entities/eemus]] の高校生インターン体験談コンテンツ3本(各700字)。架空でも構造リアル。導入/挫折/学び/今後。note・公式サイトに使う。約2500字。" }

    # ===== Testall (受験×AI・名取り事業) =====
    @{ Slug="testall-content-strategy"; Title="[Testall] コンテンツ戦略3ヶ月"; Dept="newbiz"
       Prompt="[[entities/testall]] のコンテンツ戦略3ヶ月計画。受験生向けTikTok/X/YouTube。週次投稿カレンダー/コンテンツテーマ/タレント(大井?or別人?)/想定リーチ目標。約3500字。" }
    @{ Slug="testall-competitor-studyplus"; Title="[Testall] Studyplus Planning徹底比較"; Dept="research"
       Prompt="[[entities/testall]] vs Studyplus Planning(最大競合)の徹底比較。機能/UX/価格/ユーザー層/勝ち筋。Testall勝ち筋3つ抽出。約3500字。" }
    @{ Slug="testall-teacher-outreach"; Title="[Testall] 教育者連携アプローチ"; Dept="marketing"
       Prompt="[[entities/testall]] の教育者(塾講師・予備校・高校教師)連携プログラム。連携メリット/初期5名募集案/連携契約書草案/インセンティブ設計。約3500字。" }
    @{ Slug="testall-user-personas-5"; Title="[Testall] ユーザーペルソナ5パターン"; Dept="research"
       Prompt="[[entities/testall]] のユーザーペルソナ5パターン詳細。各: 高校生像/学習課題/利用シーン/支払い者(本人/親)/Testallが解決する瞬間。約3500字。" }
    @{ Slug="testall-x-content-30"; Title="[Testall] X受験あるある投稿30本"; Dept="marketing"
       Prompt="[[entities/testall]] のX『受験あるある』投稿30本(各140字)。共感×Testall訴求。約3000字。" }

    # ===== 横断 (全事業共通) =====
    @{ Slug="cross-portfolio-prioritize"; Title="[横断] 15事業の優先順位再評価"; Dept="newbiz"
       Prompt="大井の15事業について今月の優先順位再評価。各事業の3ヶ月内目標達成可能性・大井の脳汁度・市場タイミング・必要工数で評価。Top5に絞った理由+今月止める/寝かす事業の判断。約4000字。" }
    @{ Slug="cross-stripe-setup"; Title="[横断] Stripe決済設定 5事業ロードマップ"; Dept="dev"
       Prompt="大井の主力5事業(AIpa Web/AIpaX/AIpaX school/EEMUS/Testall)それぞれのStripe決済設定ロードマップ。各: 商品設定/価格モデル(定期vs単発)/支払い方法/法的考慮/導入工数。約3500字。" }
    @{ Slug="cross-investor-pitch"; Title="[横断] 投資家向けピッチ1分版"; Dept="newbiz"
       Prompt="大井湧瑛 投資家向け1分ピッチ。チーム(大井+0)・15事業ポートフォリオ・1事業集中vs複数並走の戦略選択・今後12ヶ月のキャッシュフロー予測。約2500字、Stripped down版+詳細版両方。" }
)

$available = $pool | Where-Object { $_.Slug -notin $recentSlugs }
if ($available.Count -eq 0) { $available = $pool }

$pick = $available | Get-Random
$outDir = Join-Path $brainRoot "wiki\_inbox\$($pick.Dept)"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$outPath = Join-Path $outDir "biz-$($pick.Slug)-$stamp-$shortId.md"

& $dispatcher `
    -Department $pick.Dept `
    -Title $pick.Title `
    -Prompt $pick.Prompt `
    -Model "qwen3:8b" `
    -OutputPath $outPath `
    -Priority "high" `
    -UseAgent 2>&1 | Out-Null

$newHistory = @($state.history) + @(@{ slug = $pick.Slug; time = (Get-Date).ToString("o") })
$cutoffOld = (Get-Date).AddDays(-4)
$newHistory = $newHistory | Where-Object { [DateTime]$_.time -gt $cutoffOld }
[System.IO.File]::WriteAllText($stateFile, (@{ history = $newHistory } | ConvertTo-Json -Depth 5), [System.Text.UTF8Encoding]::new($false))

"$nowStamp - biz: $($pick.Title)" | Add-Content $logPath -Encoding UTF8
Write-Host "Biz-filled: $($pick.Title)"
