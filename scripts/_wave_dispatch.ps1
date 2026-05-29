#requires -Version 5.1
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$dispatcher = "$brain\scripts\dispatch.ps1"

$tasks = @(
    # Wave A: 既存事業ブラッシュアップ
    @{ d="newbiz"; w="brushup"; t="Testall β to paid 90day"; p="# タスク: Testall β→有料転換 90日シナリオ`n[[entities/testall]]`n- 現状: JUDGE 75点・課金未着手・9月MVP予定`n- 構成: 初月95%継続フック / 3ヶ月解約防止 / 6ヶ月アップセル`n- 各シナリオに数値KPI・施策3つ・必要工数`n- 2026年12月で月50万売上ロードマップ`n- 3000字" },
    @{ d="newbiz"; w="brushup"; t="AOF competitive rule v2"; p="# タスク: AOF 競技ルール v2`n[[entities/agents-of-flag]]`n- 光線銃+センサー+音+振動+ランクシステム`n- 1試合分単位フロー / 違反失格20条 / 観戦UI仕様 / 大会形式使い分け / 機材リスト`n- 3500字" },
    @{ d="newbiz"; w="brushup"; t="IPAK-darts properties comparison"; p="# タスク: IPAK-darts 物件3か所比較表`n[[entities/ipak-darts]]`n- 静岡県内3エリア(浜松/静岡/沼津)で各物件: 坪数/家賃/工事費/想定来店数/BEP37名可能性/周辺競合距離/集客動線/リスク3点/推奨度ランク`n- 3000字" },
    @{ d="newbiz"; w="brushup"; t="FishOps Agent spec v2"; p="# タスク: FishOps Agent (水産AI基盤) 機能仕様 v2`n[[entities/ipak-fishing]]`n- コア機能5つ: 漁獲量予測/海水温分析/漁船配置最適化/市場価格予測/後継者マッチング`n- 各機能: 入力データ/処理ロジック/出力UI/利用業界`n- MVP優先順位 / 競合3社`n- 3000字" },
    @{ d="marketing"; w="brushup"; t="AIpaX school 2h trial program"; p="# タスク: AIpaX school 体験会2h プログラム詳細`n[[entities/aipax-school]]`n- ターゲット: 中高生5名・親同席可`n- 2h内訳: 自己紹介15/AI体験45/事業ピッチ実践30/Q&A30`n- 各セクションスクリプト + スライド構成`n- 中高生「やりたい!」と言わせる5トリガー / 親「払う!」と言わせる3フック / 大井17歳USP活用`n- 3000字" },
    @{ d="marketing"; w="brushup"; t="kasunote 10oct law LP"; p="# タスク: カスハラノート 10月義務化対策LP`n[[entities/kasunote]]`n- 2026/10/1からカスハラ防止義務化 (改正労働施策総合推進法)`n- LP構成: Hero/問題提起/データ/Solution/事例/価格/FAQ/CTA`n- ターゲット: 飲食店長/小売店長/サービス業マネージャー`n- 980円→2,980円改定の説明`n- 2500字" },
    @{ d="marketing"; w="brushup"; t="yakki-check 5emails"; p="# タスク: 薬機チェック 健康食品EC営業 5パターン`n- ターゲット: 健康食品EC運営者 (年商1-10億)`n- 痛み: 薬機法違反で広告停止/Amazon BAN/法的リスク`n- 各メール: 件名/300字本文/CTA`n- パターン: コールド/紹介/業界誌/X DM/再アプローチ`n- TRUSQUETTAとの差別化1行" },
    @{ d="newbiz"; w="brushup"; t="zairyu-check shoshi partnership"; p="# タスク: 在留チェック × 行政書士連携プラン`n- 外国人雇用中小企業30社プロファイル`n- 行政書士事務所との紹介手数料スキーム`n- 利益配分・紹介→契約までの平均日数試算`n- 競合不在ニッチ拡大計画`n- 3000字" },
    @{ d="newbiz"; w="brushup"; t="taxlink jp 30 firms strategy"; p="# タスク: TaxLink JP 税理士30事務所 アプローチ戦略`n- 単科税理士〜10名規模事務所`n- 月15,000円 + プレミアム45,000円 / LTV/CAC 7.2x維持`n- TaxDome未上陸の好機 / TKC・税理士会総会経由のアプローチ`n- 3000字" },
    @{ d="marketing"; w="brushup"; t="EEMUS 5 schools outreach"; p="# タスク: EEMUS β高校5校 営業文`n[[entities/eemus]]`n- 静岡県内高校5校・校長宛/進路指導主任宛/PTA会長宛`n- 「県外進学71%」「Uターン33%」切り口`n- 月10時間キャリア授業協力セット提案`n- 大井(高校生起業家)体験談`n- 各800字×3パターン" },
    @{ d="research"; w="brushup"; t="Gymee revival conditions"; p="# タスク: Gymee 再評価 — 何があれば蘇生`n[[entities/gymee]]`n- 現状: docomoクローズで寝かす確定`n- Q1) 別パートナー(KDDI/SB)で蘇生可? Q2) BtoC転用は? Q3) コア技術(会議AI実行追跡)の他事業転用`n- 5年後マーケット予測 / 蘇生条件3点 / 蘇生しない場合のリサイクル先`n- 2500字" },
    @{ d="newbiz"; w="brushup"; t="OMNI restart scenario"; p="# タスク: OMNI 事業 再起動シナリオ`n- 現状: 動きなし・将来再評価`n- 何が起きれば再起動か / 競合動き / 市場規模最新数字 / 主力5事業との相乗効果 / 2026年中着手判定基準`n- 2500字" },
    @{ d="newbiz"; w="brushup"; t="EcoKan shizuoka local"; p="# タスク: EcoKan 静岡ローカル特化シナリオ`n- 環境×官民連携構造`n- 静岡県内自治体3つ起点の地域実証スキーム`n- 補助金活用 (静岡県環境政策課・浜松市)`n- 月100万売上の初期施策 / 競合との差別化`n- 3000字" },
    @{ d="marketing"; w="brushup"; t="ooi personal branding strategy"; p="# タスク: 大井湧瑛 個人ブランディング戦略`n- 「世界のユウエイ」物語の章立て (現在→1年後→3年後)`n- 各メディア(X/note/YouTube/TikTok/LinkedIn)発信方針`n- 17→18歳節目で打つコンテンツ案10本`n- 静岡→全国→世界 段階的露出戦略 / 危機管理`n- 3000字" },
    @{ d="marketing"; w="brushup"; t="SEO matrix 5 businesses"; p="# タスク: 主力5事業 SEO戦略マトリックス`n- AIpaX/Testall/AIpa Web/AIpaX school/EEMUS`n- 各事業×競合×KW で30マス(5×6)`n- 各マスに: KW難易度/月間検索数/上位3社/勝てる切り口`n- 優先記事10本ランキング`n- 3000字" },
    @{ d="corp"; w="brushup"; t="price strategy 17 businesses"; p="# タスク: 価格戦略 全事業横断`n- 17事業の現状価格 + 推奨改定`n- 各事業の最適モデル選定理由 / 統一感ブランド価格帯`n- アップセル/クロスセル経路5本 / 競合との価格ポジショニング図`n- 3000字" },
    @{ d="corp"; w="brushup"; t="ROI sheet vs consulting"; p="# タスク: ROI試算シート 月50万コンサル vs AIpaX 80万円`n[[entities/aipax]]`n- 1年間総コスト比較 (コンサル600万 vs AIpaX 80万+月10万×12=200万)`n- 提供価値定量化 / 顧客側ROI試算式 / 商談1枚スライド版 / 業界別カスタマイズ3つ`n- 2500字" },
    @{ d="newbiz"; w="brushup"; t="referral program 5 businesses"; p="# タスク: 主力5事業 横断 紹介プログラム設計`n- 既存4社AIpaX→紹介報酬モデル / AIpa Webモニター→Testall β送客 / AIpaX school卒業生→EEMUSインターン`n- 各経路: 報酬率/手続き/顧客側メリット / 営業ツール紹介用1ページPDF`n- 3000字" },
    @{ d="newbiz"; w="brushup"; t="churn prevention common"; p="# タスク: 解約防止プログラム 全事業共通`n- AIpaX/Testall/AIpa Web/AIpaX school 共通の解約予兆検知`n- 3ヶ月前/1ヶ月前/1週間前 の介入アクション`n- 解約理由TOP5 と対処スクリプト / 「神カスタマーサクセス」最低工数`n- 3000字" },
    @{ d="newbiz"; w="brushup"; t="mentor people map"; p="# タスク: 大井の人脈マッピング (連絡優先順位)`n- メンター・先輩・投資家を5層分類 (Tier1月1接触 / Tier2四半期 / Tier3半年 / Tier4年1 / Tier5緊急時)`n- 各人物のテーマ別役割 (技術/営業/資金/紹介/精神)`n- 直近3ヶ月で連絡すべき5名 / 静岡県内キーマン名簿`n- 3000字" },
    # Wave B: 新規 SaaS / アプリ案 大量生成
    @{ d="newbiz"; w="newsaas"; t="logistics 2024 issue 5"; p="# タスク: 2024年問題後の物流業界向け SaaS案 5本`n- 残業規制で人手不足顕在化`n- 各案: 名称/痛み/ターゲット/価格/初期顧客10社獲得法/MVP1ヶ月版/競合`n- 大井が今参入し18ヶ月で月500万売上到達可能なものに限定`n- 「弱者の違和感」のダサい瞬間を入れる`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="inbound tourism AI app 5"; p="# タスク: 2026年インバウンド観光向け AIアプリ案 5本`n- 円安・訪日4000万人時代`n- 各案: 名称/問題/解決/ターゲット国/料金/初期100ユーザー獲得法/競合`n- 既存(Klook/GetYourGuide/HIS)が拾えないニッチ`n- 静岡県観光資源(富士山/伊豆/熱海)活用1本含む`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="silver 60-75 saas 5"; p="# タスク: シルバー層 (60-75歳) 向け SaaS/アプリ案 5本`n- スマホ第2世代になりつつあるシルバー`n- 各案: 名称/痛み/料金/獲得チャネル(LINE/紙DM)/MVP`n- 「孫に教わらなくて済む」シンプルUI前提`n- 既存(らくらくスマホ・dヘルスケア)の隙間`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="Z gen saas 5"; p="# タスク: Z世代向け 新規SaaS/アプリ案 5本`n- TikTok・BeReal の次に来る行動様式`n- 各案: 名称/痛み/解決/価格(500-2000円)/獲得チャネル`n- メンタルヘルス・自己分析・キャリア・恋愛・お金 から各1本`n- 既存(Snowman・Pairsteenager)が拾えないニッチ`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="SMB manufacturing AI 5"; p="# タスク: 中小製造業向け AI SaaS案 5本`n- ベテラン退職リスク・技能継承・品質管理`n- 各案: 名称/痛み/解決/価格/初期10社獲得法/MVP`n- AIpaXの隣接事業として展開可能なもの3本`n- 既存(キヤノンMJ・SAP)の隙間`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="shigyo saas 5"; p="# タスク: 士業(税理士・行政書士・弁護士)向けSaaS案 5本`n- TaxLink JPの隣接事業`n- 各士業×案のマトリックス`n- 各案: 名称/痛み/解決/価格(15000-50000円)/獲得チャネル`n- 業界団体経由のアプローチを明示`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="clinic saas 5"; p="# タスク: 個人クリニック・医療法人向けSaaS案 5本`n- 開業医・歯科・整骨院`n- 各案: 名称/痛み/解決/価格/初期20軒獲得法`n- 厚労省関連の規制を逆手に取る`n- AIpaXの隣接展開可能性`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="realestate construction 5"; p="# タスク: 不動産・建設業向け SaaS/アプリ案 5本`n- 業界経験長・ITリテラシ低・補助金枠あり`n- 各案: 名称/痛み/解決/価格/紙→デジタル移行フック`n- AIpaXの隣接展開`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="education vertical 5"; p="# タスク: 教育機関向けSaaS案 5本 (Testall隣接)`n[[entities/testall]]`n- 塾チェーン・予備校・通信制高校`n- 各案: 名称/痛み/解決/価格/初期20校獲得法`n- 9月新学期前に契約取れるサイクル`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="creator economy 5"; p="# タスク: クリエイター(YouTuber・配信者・ライター・絵師)向けSaaS 5本`n- 個人ブランドビジネスの基盤づくり`n- 各案: 名称/痛み/解決/価格(980-9800円)/獲得チャネル`n- 既存(Patreon・Fanbox・MyShopify)の隙間`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="labor shortage industries 5"; p="# タスク: 人手不足深刻3業界(介護・飲食・小売)向けSaaS 5本`n- 採用・シフト・教育の3軸`n- 各案: 名称/痛み/解決/価格/初期20社獲得`n- AIpa Webの隣接展開`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="freelance skill share 5"; p="# タスク: 副業・スキルシェア 新規SaaS案 5本`n- 既存(Lancers・クラウドワークス・ココナラ)の隙間`n- ニッチ業界×副業マッチングを各案で`n- 各案: 名称/痛み/解決/価格(無料+成果報酬5-10%)/MVP`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="healthcare fitness AI 5"; p="# タスク: 個人向け ヘルスケア・フィットネス AI SaaS 5本`n- パーソナライズ化・継続率高い設計`n- 各案: 名称/痛み/解決/価格(980-2980円)/獲得チャネル`n- 既存(あすけん・FiNC・Asics Run)の隙間`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="parents kids 5"; p="# タスク: 親子・育児向け 新規SaaS/アプリ案 5本`n- 0-3歳/3-6歳/小学生/中学生 各層`n- 各案: 名称/痛み/解決/価格(500-3000円)/獲得チャネル(ママ友・保育園)`n- 既存(まいにちのたまひよ・トモニテ)の隙間`n- 3500字" },
    @{ d="newbiz"; w="newsaas"; t="LLM vertical SaaS 10"; p="# タスク: LLM時代に「縦特化(バーティカル)SaaS」案 10本`n- GPT/Claude が水平展開する中、縦に深く刺す事業`n- 業界×LLM応用で10本 (異なる業界)`n- 各案: 名称/業界/具体的タスク/価格/初期10社獲得/参入障壁`n- 「OpenAI/Anthropic直接やりにくい」理由を各案に1行`n- 3500字" }
)

$dispatched = 0
foreach ($t in $tasks) {
    $stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
    $sid = [guid]::NewGuid().ToString().Substring(0,4)
    $slug = ($t.t -replace '[^\w]','-').ToLower()
    if ($slug.Length -gt 40) { $slug = $slug.Substring(0, 40) }
    $outPath = "$brain\wiki\_inbox\$($t.d)\$($t.w)-$slug-$stamp-$sid.md"

    & $dispatcher `
        -Department $t.d `
        -Title "[$($t.w)] $($t.t)" `
        -Prompt $t.p `
        -Model "qwen3.6:latest" `
        -OutputPath $outPath `
        -Priority "normal" 2>&1 | Out-Null

    $dispatched++
}
Write-Host "Wave dispatched: $dispatched tasks"
