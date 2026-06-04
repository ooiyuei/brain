#requires -Version 5.1
# Money Loop - 毎日収益直結タスクを自動投入 (永続自走)
# 2026-05-25 新規: 「自動でお金を稼げるように」(大井指示)
# - 営業文・顧客リスト・LP・契約書テンプレ・フォローメール 等を1日3-5件dispatch
# - dispatch時に [[entities/xxx]] 自動注入で大井事業に紐づく
# - 結果は _inbox → review → promote → brushup → _final で90点級に到達

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
if (Test-Path "$brain\queue\.paused") { exit 0 }

$dispatcher = "$brain\scripts\dispatch.ps1"
$logPath = "$brain\scripts\money_loop.log"
$stateFile = "$brain\scripts\.money_loop_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

# inbox 200件超ならスキップ (queue_guard対応)
$inboxCount = (Get-ChildItem "$brain\queue\inbox" -File -Filter "*.json" -ErrorAction SilentlyContinue).Count
if ($inboxCount -gt 200) {
    "$nowStamp - skip: inbox $inboxCount > 200" | Add-Content $logPath -Encoding UTF8
    exit 0
}

# State 読み込み (重複防止)
$state = @{ used = @{} }
if (Test-Path $stateFile) {
    try { $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($loaded.used) { foreach ($p in $loaded.used.PSObject.Properties) { $state.used[$p.Name] = $p.Value } }
    } catch {}
}

# 収益直結タスクプール (12種・毎日3-5件rotation)
$moneyTasks = @(
    # AIpaX 5社目契約獲得 (緊急・6/21期限)
    @{ d="marketing"; t="AIpaX 中堅企業3社 個別アプローチメール"; p="# タスク: AIpaX 5社目候補 中堅企業3社向け個別アプローチメール`n[[entities/aipax]]`n業種別 (製造・建設・サービス) 各社に個別カスタマイズ・件名+本文400字+CTA`n大井1人称・実例「既存4社月20万」自然引用" },
    @{ d="newbiz"; t="AIpaX 5社目商談クロージング想定問答"; p="# タスク: AIpaX 5社目商談 クロージング想定問答15問`n[[entities/aipax]]`n価格・解約・他社比較・社員反発・データ保護・ROI・期間 等15分野・各300字" },
    @{ d="newbiz"; t="AIpaX 既存4社 アップセル提案"; p="# タスク: AIpaX 既存4社 アップセル提案3パターン`n[[entities/aipax]]`n追加ツール・年契約・紹介報酬 各説明書面" },
    # AIpa Web モニター獲得
    @{ d="research"; t="AIpa Web 静岡中堅企業 10社具体リスト"; p="# タスク: AIpa Web モニター候補 静岡県中堅10社具体リスト`n[[entities/aipa-web]]`n実在企業名 (確証ある範囲) ・規模・採用課題仮説・接触経路" },
    @{ d="marketing"; t="AIpa Web 商工会経由営業文"; p="# タスク: AIpa Web 静岡県商工会議所経由営業文`n[[entities/aipa-web]]`n商工会理事宛・モニター15万→月10万移行プラン・地域貢献文脈" },
    # Testall β顧客100名募集
    @{ d="marketing"; t="Testall 受験生インフルエンサー連携 DM10件"; p="# タスク: Testall 受験系インフルエンサー連携DM 10件`n[[entities/testall]]`n登録者10万+ 受験系YouTuber/X 各140字・コラボ提案" },
    @{ d="marketing"; t="Testall 親向けLP コピー改善"; p="# タスク: Testall 親向けLPコピー改善 (3500字)`n[[entities/testall]]`n保護者ペイン3つ→Testall解決3つ→月980円(β)→2,980円(通常)・FAQ12問" },
    # EEMUS 夢AWARD準備 (6/7締切)
    @{ d="newbiz"; t="EEMUS 連携企業5社 具体接触メール"; p="# タスク: EEMUS 連携企業5社 個別接触メール`n[[entities/eemus]]`n静岡県内中堅企業・人材確保フック・各社カスタマイズ400字" },
    @{ d="marketing"; t="夢AWARD 60秒ピッチ動画台本 v3"; p="# タスク: 夢AWARD 60秒ピッチ動画台本 v3`n[[entities/eemus]] [[meta/ooi-life-story]]`n大井1人称・原体験+数字3つ+涙ポイント・撮影指示付き" },
    # 横断 (収益直結インフラ)
    @{ d="corp"; t="主力5事業 月次キャッシュフロー6月予測"; p="# タスク: 主力5事業 月次キャッシュフロー 2026年6月詳細予測`n各事業: 売上見込/コスト/純利益/前月比/翌月予測" },
    @{ d="corp"; t="紹介プログラム 5事業横断ルール"; p="# タスク: 紹介プログラム 主力5事業横断ルール`n紹介者報酬率・被紹介者特典・契約書テンプレ" },
    @{ d="newbiz"; t="6/21月収100万 残30日アクションプラン"; p="# タスク: 月収100万円(2026-06-21期限) 残30日緊急アクションプラン`n[[hot]]`n週次マイルストーン+毎日コミット+残日数別シナリオ3本(楽観/標準/悲観)" }
)

# 4時間クールダウン
$cutoff = (Get-Date).AddHours(-4)
$available = $moneyTasks | Where-Object {
    if (-not $state.used.ContainsKey($_.t)) { return $true }
    $last = [DateTime]$state.used[$_.t]
    return ($last -lt $cutoff)
}

if ($available.Count -eq 0) {
    "$nowStamp - all on cooldown" | Add-Content $logPath -Encoding UTF8
    exit 0
}

# 4件まで一気に投入 (毎時1件 = 1日24件)
$batch = $available | Get-Random -Count ([Math]::Min(4, $available.Count))
$dispatched = 0
foreach ($t in $batch) {
    $stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
    $sid = [guid]::NewGuid().ToString().Substring(0,4)
    $slug = ($t.t -replace '[^\w]','-').ToLower()
    if ($slug.Length -gt 40) { $slug = $slug.Substring(0, 40) }
    $outPath = "$brain\wiki\_inbox\$($t.d)\money-$slug-$stamp-$sid.md"
    & $dispatcher -Department $t.d -Title "[Money] $($t.t)" -Prompt $t.p -Model "qwen3:8b" -OutputPath $outPath -Priority "high" 2>&1 | Out-Null
    $state.used[$t.t] = (Get-Date).ToString("o")
    $dispatched++
}

# State保存・古いcleanup
$weekAgo = (Get-Date).AddDays(-7)
$keysToRemove = @()
foreach ($k in $state.used.Keys) {
    try { if ([DateTime]$state.used[$k] -lt $weekAgo) { $keysToRemove += $k } } catch {}
}
foreach ($k in $keysToRemove) { $state.used.Remove($k) | Out-Null }
$stateJson = $state | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

"$nowStamp - dispatched $dispatched money tasks (inbox=$inboxCount)" | Add-Content $logPath -Encoding UTF8
Write-Host "money_loop: $dispatched tasks dispatched"
