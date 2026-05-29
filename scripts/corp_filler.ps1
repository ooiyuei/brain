#requires -Version 5.1
# Corp部署 filler - 財務・法務・人事
# cfo/legal/hr-recruiter エージェント経由 (qwen3:8b)
# 週単位で実行 (毎日は要らない)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$logPath = Join-Path $brainRoot "scripts\corp_filler.log"
$stateFile = Join-Path $brainRoot "scripts\.corp_filler_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$cooldownHours = 24

# Corp部署在庫 (週1ペースで良い)
$corpCount = (Get-ChildItem (Join-Path $brainRoot "wiki\_inbox\corp") -File -ErrorAction SilentlyContinue).Count
if ($corpCount -ge 7) {
    "$nowStamp - corp materials sufficient ($corpCount), skip" | Add-Content $logPath -Encoding UTF8
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
    # === 財務 (cfo) ===
    @{ Slug="corp-pl-aipa-monthly"; Title="[Corp/CFO] AIpa Web 月次PL試算"; Agent="cfo"
       Prompt="[[entities/aipa-web]] のモニター月15万×3社=月45万売上想定の月次PLを作成。`n- 売上: 45万 (3社モニター)`n- 原価: 制作工数 (大井+外注ライター) ・ホスティング・AI API課金`n- 販管費: 営業活動費・広告 (月5万想定)`n- 大井の人件費 (月の労働時間×想定時給)`n- 営業利益と利益率`n- 損益分岐点 (何社で黒字?)`n- 6ヶ月後の利益計画`n約3000字、数字根拠を明示、推測には『推測:』。" }

    @{ Slug="corp-pl-aipax-monthly"; Title="[Corp/CFO] AIpaX 月次PL試算"; Agent="cfo"
       Prompt="[[entities/aipax]] のβ顧客月50-80万×1社+月額継続を想定したPL。`n- 売上構成・原価 (実装工数+AI API課金+保管庫運用コスト)`n- 損益分岐点`n- 6社契約までのキャッシュフロー予測`n約3000字、数字根拠明示。" }

    @{ Slug="corp-pl-school-monthly"; Title="[Corp/CFO] AIpaX school 月次PL試算"; Agent="cfo"
       Prompt="[[entities/aipax-school]] の月謝3万×5名=15万売上の月次PL。`n- 売上・原価 (講師費用→大井+AI/ツール費)`n- 集客広告費・体験会運営費`n- 損益分岐点・10名/20名/50名時のスケーリング`n約3000字。" }

    @{ Slug="corp-cashflow-12m"; Title="[Corp/CFO] 12ヶ月キャッシュフロー予測"; Agent="cfo"
       Prompt="大井の事業全体 (AIpa Web/AIpaX/AIpaX school) の12ヶ月キャッシュフロー予測。`n月別: 売上/原価/販管費/CF/累計貯金。`n- 開始貯金: ¥70,000`n- 期待売上カーブ (Q1:1案・Q2:3案・Q3:5案・Q4:バイアウト検討)`n- 突発費 (機材・登記費・税金)`n- 月収100万円達成タイミング予測`n約3500字、Excel化できる表形式で。" }

    @{ Slug="corp-tax-checklist"; Title="[Corp/CFO] 高校生起業家の税務チェックリスト"; Agent="cfo"
       Prompt="高校生で個人事業/法人を回す大井向けの税務チェックリスト。`n- 開業届/法人化のタイミング (年商何円から?)`n- 経費にできるもの一覧 (PC・サブスク・通信費・家賃按分等)`n- 確定申告 (青色控除65万・帳簿付け方)`n- インボイス制度・消費税の対応`n- 親の扶養との関係 (税金面)`n- 18歳での口座/契約の制限`n約3000字、推測には『推測:』、税理士相談推奨ラインも明示。" }

    # === 法務 (legal) ===
    @{ Slug="corp-contract-aipa-monitor"; Title="[Corp/Legal] AIpa Web モニター契約書 雛形"; Agent="legal"
       Prompt="[[entities/aipa-web]] のモニター3社向け契約書の雛形を作成。`n- 業務範囲 (採用サイト制作+運用)`n- 月15万の支払い条件 (前払い/分割)`n- 成果物の著作権帰属`n- 取材・写真撮影の利用許諾`n- 解約条件 (相互3ヶ月通知)`n- AIによる自動応答の責任分担`n- データ取扱い (個人情報保護)`n約3500字、実用レベルで。" }

    @{ Slug="corp-tos-aipax-school"; Title="[Corp/Legal] AIpaX school 利用規約・特商法表記"; Agent="legal"
       Prompt="[[entities/aipax-school]] (中高生向けスクール) の利用規約と特商法表記の雛形。`n- 契約者 (親) と受講者 (中高生) の関係明示`n- 月謝3万円の支払い条件・解約・返金規定`n- 知的財産権 (生徒制作物の著作権)`n- 退学・除籍の規定`n- 個人情報保護方針 (中高生の保護)`n- 体験会キャンセル規定`n約3500字、塾業界の標準に準拠。" }

    @{ Slug="corp-privacy-aipa"; Title="[Corp/Legal] プライバシーポリシー雛形 (AI使用前提)"; Agent="legal"
       Prompt="大井の各事業共通のプライバシーポリシー雛形 (AI利用前提)。`n- AIサービス (OpenAI/Anthropic等) への入力データの扱い`n- 採用候補者の応募情報の取り扱い`n- Cookie・アクセスログ`n- 第三者提供の条件`n- 削除請求への対応`n約3000字、実装可能なレベルで具体的に。" }

    # === 人事 (hr-recruiter) ===
    @{ Slug="corp-hire-criteria"; Title="[Corp/HR] 大井チームに必要な人材像 3パターン"; Agent="hr-recruiter"
       Prompt="大井の弱み (継続管理・細部・報連相・実装の詰め・事務・睡眠管理) を埋めるために必要な人材像3パターン。`n各人材:`n- 役割名 (CTO・COO・営業マネージャー等)`n- 求められるスキル・性格`n- 大井の弱みをどう埋めるか具体例`n- 想定月額 (フリーランス・業務委託・正社員)`n- 接触可能なコミュニティ (Wantedly・YOUTRUST等)`n- スカウト文テンプレ`n約3500字。" }

    @{ Slug="corp-outsource-tasks"; Title="[Corp/HR] 大井が外注すべきタスク10選"; Agent="hr-recruiter"
       Prompt="大井が今すぐ外注すべき業務10個。1個1時間以下・月¥1000-5000で頼めるもの中心。`n各:`n- タスク内容`n- 月の発生頻度`n- 外注先 (クラウドワークス・ココナラ・専門業者等の実在のみ)`n- 想定単価`n- 大井が浮く時間の計算`n約3000字、実在サービス名のみ。" }
)

$available = $pool | Where-Object { $_.Slug -notin $recentSlugs }
if ($available.Count -eq 0) { $available = $pool }

$pick = $available | Get-Random
$corpInbox = Join-Path $brainRoot "wiki\_inbox\corp"
if (-not (Test-Path $corpInbox)) { New-Item -ItemType Directory -Path $corpInbox -Force | Out-Null }
$outPath = Join-Path $corpInbox "corp-$($pick.Slug)-$stamp-$shortId.md"

& $dispatcher `
    -Department "corp" `
    -Title $pick.Title `
    -Prompt $pick.Prompt `
    -Model "qwen3:8b" `
    -OutputPath $outPath `
    -Priority "normal" `
    -UseAgent 2>&1 | Out-Null

$newHistory = @($state.history) + @(@{ slug = $pick.Slug; time = (Get-Date).ToString("o") })
$cutoffOld = (Get-Date).AddDays(-7)
$newHistory = $newHistory | Where-Object { [DateTime]$_.time -gt $cutoffOld }
$stateJson = @{ history = $newHistory } | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

"$nowStamp - corp: $($pick.Title)" | Add-Content $logPath -Encoding UTF8
Write-Host "Corp-filled: $($pick.Title)"
