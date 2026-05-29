#requires -Version 5.1
# 営業部署 filler - 顧客リスト・営業メール・提案書・トーク台本
# sales-rep エージェント経由 (qwen3:8b) で品質を上げる

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$logPath = Join-Path $brainRoot "scripts\sales_filler.log"
$stateFile = Join-Path $brainRoot "scripts\.sales_filler_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$cooldownHours = 6

# 営業部署が抱えるべき成果物が少ない時のみ動く
$salesInbox = (Get-ChildItem (Join-Path $brainRoot "wiki\_inbox\marketing") -File -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*sales*" -or $_.Name -like "*outreach*" }).Count
$promoted = (Get-ChildItem (Join-Path $brainRoot "wiki\_promoted\marketing") -File -Filter "*.md" -ErrorAction SilentlyContinue).Count
$totalSales = $salesInbox + $promoted
if ($totalSales -ge 20) {
    "$nowStamp - sales materials sufficient ($totalSales), skip" | Add-Content $logPath -Encoding UTF8
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

# 営業部署のタスクプール (sales-rep agent 経由で深いリサーチ → 成果物)
$pool = @(
    @{ Slug="sales-prospect-aipa-construction"; Title="[Sales] AIpa Web 建設業 30社プロファイル"
       Prompt="[[entities/aipa-web]] のターゲット業種『建設業・従業員30-300名・地方』のプロスペクト30社をリサーチして、各社のプロファイル+アプローチ案を作る。`n`n各社（実在企業を可能な限り推測してリストアップ・架空なら『業界の典型像として』と注記）:`n1. 社名/業種/規模/地域`n2. 採用課題の仮説（HPの古さ・求人サイト掲載状況・離職率仮説）`n3. アプローチ媒体（採用担当メール/問合せフォーム/SNS）`n4. 件名+本文（200字以内）`n5. 想定反応と次の一手`n`n約4000字、リアルさ優先、推測には『推測:』。" }

    @{ Slug="sales-prospect-aipa-mfg"; Title="[Sales] AIpa Web 製造業 30社プロファイル"
       Prompt="[[entities/aipa-web]] のターゲット『製造業・従業員30-300名・地方』のプロスペクト30社プロファイル+アプローチ案。`n各社: 業種/規模/地域/採用課題仮説/接点/メール案/想定反応。`n約4000字、推測明示。" }

    @{ Slug="sales-prospect-aipa-service"; Title="[Sales] AIpa Web サービス業 30社プロファイル"
       Prompt="[[entities/aipa-web]] のターゲット『サービス業（介護・保育・物流等）・従業員30-300名』のプロスペクト30社プロファイル+アプローチ案。`n各社: 業種/規模/地域/採用課題/接点/メール案/想定反応。`n約4000字、推測明示。" }

    @{ Slug="sales-prospect-aipax-mid"; Title="[Sales] AIpaX 中堅企業β候補20社"
       Prompt="[[entities/aipax]] のβ顧客候補20社をリサーチ。基準: 50-200名・AI興味あり・予算50万出せる中小企業。`n各社: 業種規模/想定業務課題3つ/AI解決可能性/接点/50万円提案ロジック。`n約4000字、推測明示。" }

    @{ Slug="sales-email-sequence-aipa"; Title="[Sales] AIpa Web 5通シーケンス"
       Prompt="[[entities/aipa-web]] の自動メールシーケンス5通を作る。`n初回接触→3日後リマインダー→1週間後ケーススタディ→2週間後質問型→1ヶ月後最終CTA。`n各通: 件名+本文(300字)+想定開封率+次のステップ。`n大井のフランクなキャラ、AI臭NG。約3000字。" }

    @{ Slug="sales-email-sequence-aipax"; Title="[Sales] AIpaX 5通シーケンス"
       Prompt="[[entities/aipax]] のβ顧客向け5通自動メールシーケンス。`n初回接触→事例紹介→ROI試算→無料相談誘導→最終提案。`n各通: 件名+本文(300字)+想定開封率+次のステップ。約3000字。" }

    @{ Slug="sales-cold-call-script-aipa"; Title="[Sales] AIpa Web 電話トーク台本"
       Prompt="[[entities/aipa-web]] の電話アポイントメント獲得トーク台本。初回30秒で『話を聞きたい』と言わせる構成。`n- オープニング（10秒）`n- フック（採用に関する1問質問）`n- 価値訴求（30秒）`n- 想定される断り5パターン×切り返し`n- アポクロージング`n- 失敗時の連絡先確保`n約3000字、関西弁混じり可、AI臭NG。" }

    @{ Slug="sales-proposal-aipa-15man"; Title="[Sales] AIpa Web モニター提案書15万円版"
       Prompt="[[entities/aipa-web]] のモニター月15万円契約の提案書フル版。`n- 表紙+クライアント名差込み欄`n- 課題整理（採用ペイン3つ）`n- ソリューション（16セクションフォーム+AI初稿+月運用）`n- 成果物リスト（月単位）`n- 価格構造（15万の内訳: 5万コピー+5万デザイン+5万運用）`n- 通常制作（150万）との比較表`n- 導入スケジュール（3ヶ月）`n- 大井+チーム紹介`n- リスクと保証（モニター3社限定の理由）`n- FAQ 5問`n約4000字、PDFそのまま使えるレベル。" }

    @{ Slug="sales-proposal-aipax-80man"; Title="[Sales] AIpaX β顧客提案書80万円版"
       Prompt="[[entities/aipax]] のβ顧客向け80万円提案書フル版。`n- 課題（中小企業のAI導入率5%問題）`n- ソリューション（会社別AI保存庫コア+業務ツール）`n- 導入後Before/After（業務シーン3つ）`n- 価格根拠（80万内訳: 30万実装+30万カスタマイズ+20万3ヶ月運用）`n- 通常コンサル（300万）との比較`n- 3ヶ月導入スケジュール`n- 大井+チーム`n- 成功事例（架空でも構造で）`n- リスクと保証`n- FAQ`n約4000字。" }

    @{ Slug="sales-objection-handling"; Title="[Sales] 想定される断り20パターン×切り返し"
       Prompt="高校生起業家の大井湧瑛が法人営業で受ける想定される断り20パターンと、それぞれの切り返しトーク。`n例: 『若いから不安』『実績ない』『他社で十分』『予算ない』『時期じゃない』...`n各断り:`n- 断り文句（実際の言い回し）`n- 心理状態の解釈`n- 切り返し3行（共感→事実→次のアクション）`n- それでもダメな時の縁切り方`n約3500字、大井キャラ厳守。" }

    @{ Slug="sales-followup-rules"; Title="[Sales] フォローアップ自動ルール表"
       Prompt="大井のセールスにおけるフォローアップの自動ルール表を作る。`n顧客アクション→次のステップを定義した if-then 表。`n例:`n- メール返信なし3日→リマインド`n- 返信あり興味薄い→事例3つ提示`n- 商談決定→提案書送付`n- 提案後返事なし1週間→質問型フォロー`n約20パターン、各: トリガー/タイミング/メッセージ案/次のステップ。約3000字。" }

    @{ Slug="sales-pricing-strategy-aipa"; Title="[Sales] AIpa Web 3プラン価格戦略"
       Prompt="[[entities/aipa-web]] の3プラン価格戦略をフル設計。`nプランA: 月10万（モニター・3社限定・大井実績作り）`nプランB: 月15万（標準・月8件目標）`nプランC: 月25万（プレミアム・継続改善付き）`n各プラン: 含まれる成果物/想定顧客像/月X社売って月Y万のロジック/反応予測/価格交渉時のディスカウント上限。`n約3500字、数字根拠明示。" }
)

$available = $pool | Where-Object { $_.Slug -notin $recentSlugs }
if ($available.Count -eq 0) { $available = $pool }

$pick = $available | Get-Random
$outPath = Join-Path $brainRoot "wiki\_inbox\marketing\sales-$($pick.Slug)-$stamp-$shortId.md"

# sales-rep エージェント経由で品質UP (use_agent=true)
& $dispatcher `
    -Department "marketing" `
    -Title $pick.Title `
    -Prompt $pick.Prompt `
    -Model "qwen3:8b" `
    -OutputPath $outPath `
    -Priority "high" `
    -UseAgent 2>&1 | Out-Null

$newHistory = @($state.history) + @(@{ slug = $pick.Slug; time = (Get-Date).ToString("o") })
$cutoffOld = (Get-Date).AddDays(-3)
$newHistory = $newHistory | Where-Object { [DateTime]$_.time -gt $cutoffOld }
$stateJson = @{ history = $newHistory } | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

"$nowStamp - sales: $($pick.Title)" | Add-Content $logPath -Encoding UTF8
Write-Host "Sales-filled: $($pick.Title)"
