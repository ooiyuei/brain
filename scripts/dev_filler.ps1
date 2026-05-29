#requires -Version 5.1
# Dev部署 filler - アプリ仕様・コード雛形・技術設計
# developer エージェント経由 (qwen3:8b)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$pauseFile = Join-Path $brainRoot "queue\.paused"
if (Test-Path $pauseFile) { exit 0 }

$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$logPath = Join-Path $brainRoot "scripts\dev_filler.log"
$stateFile = Join-Path $brainRoot "scripts\.dev_filler_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$cooldownHours = 8

# Dev部署在庫
$devCount = (Get-ChildItem (Join-Path $brainRoot "wiki\_inbox\dev") -File -ErrorAction SilentlyContinue).Count
if ($devCount -ge 10) {
    "$nowStamp - dev materials sufficient ($devCount), skip" | Add-Content $logPath -Encoding UTF8
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
    @{ Slug="dev-app-spec-pet-translator"; Title="[Dev] AIペット翻訳 1週間アプリ仕様"
       Prompt="月3万狙いの『AIペット翻訳』アプリの完全仕様書を作る。`n- 1週間で開発・Expo+Supabase想定`n- ターゲット: 30-50代の犬猫飼い主`n- 機能リスト v0.1 (3機能・MVP)`n- 画面構成3画面+遷移図`n- データモデル (Supabaseテーブル設計)`n- 技術スタック詳細 (依存パッケージリスト)`n- AdMob/Stripe実装ポイント`n- ASOキーワード20個`n- 7日間開発スケジュール (日次タスク)`n約3500字、Cursorで即着手レベル。" }

    @{ Slug="dev-app-spec-study-timer"; Title="[Dev] 高校生用 集中タイマー仕様"
       Prompt="月3万狙いの『高校生用 集中タイマー』アプリの完全仕様書。SNS連携機能で差別化。`n- 1週間開発・React Native+Expo`n- ターゲット: 大学受験生・高1-3`n- 機能: ポモドーロ+進捗グラフ+友達ランキング+カミングアウト共有`n- 画面構成・データモデル・技術スタック・ASO・スケジュール`n約3500字。" }

    @{ Slug="dev-app-spec-receipt-ai"; Title="[Dev] 領収書AI整理アプリ仕様"
       Prompt="月3万狙いの『領収書AI整理』アプリ完全仕様書。フリーランス・個人事業主向け。`n- カメラで撮影→AIで日付/金額/勘定科目抽出→CSV書き出し`n- 1週間開発・Expo+Supabase+OpenAI Vision`n- 機能・画面・データモデル・技術スタック・ASO・スケジュール`n約3500字。" }

    @{ Slug="dev-arch-aipa-web"; Title="[Dev] AIpa Web 技術アーキテクチャ v2"
       Prompt="[[entities/aipa-web]] の技術アーキテクチャを再設計する。`n- 16セクションフォーム→AI初稿→納品の自動化フロー`n- 採用サイト生成エンジンの構成 (Next.js+Vercel)`n- AI応募者対応エンジン (Claude API/MCP)`n- 月運用フェーズの自動更新仕組み`n- 1モニター月15万でも採算合うコスト構造`n- 技術選定理由とリスク`n約3500字、図示は無理でも構造を文字で。" }

    @{ Slug="dev-arch-aipax"; Title="[Dev] AIpaX 会社別保存庫コア アーキテクチャ"
       Prompt="[[entities/aipax]] の『会社別AI保存庫コア+業務ツール』のアーキテクチャ設計。`n- 各企業のドキュメント・履歴を保管するベクトルDB構成`n- リアルタイム電話/営業回答支援AIの統合`n- セキュリティ (企業間データ分離)`n- 月額50万円コースの構成・契約スコープ`n- 拡張性 (新業務ツール追加の容易さ)`n約3500字。" }

    @{ Slug="dev-build-brain-extension"; Title="[Dev] Brain System 次の拡張案 5本"
       Prompt="大井のBrain System (現状: dashboard 7777/pipeline/departments/OpenClaw/idle_filler等) に追加すべき機能5本を提案。`n各機能:`n- 名称・目的`n- 期待効果 (時間節約/売上接続)`n- 技術構成`n- 実装工数 (日)`n- 大井の脳汁度`n優先順位もつける。約3000字。" }

    @{ Slug="dev-vibe-code-template"; Title="[Dev] バイブコーディング用 雛形テンプレ 3種"
       Prompt="大井がCursor/Claude Codeで爆速開発する時に使う『プロジェクト雛形テンプレ』3種類を完成させる。`n1. SaaS Web (Next.js+Supabase+Stripe+Vercel)`n2. スマホアプリ (Expo+Supabase+RevenueCat)`n3. AI機能組み込み (OpenAI/Claude API+MCP)`n各テンプレ:`n- package.json (依存リスト)`n- ディレクトリ構造`n- 初期セットアップコマンド`n- 認証・決済の最小実装`n- AIへ与える『あなたは○○エンジニアです』プロンプト`n約4000字、即コピペで動くレベル。" }

    @{ Slug="dev-mcp-setup-guide"; Title="[Dev] MCP セットアップガイド 5サーバー分"
       Prompt="大井のCursor/Claude Codeに導入すべきMCPサーバー5つのセットアップ手順を完全に書く。`n1. Supabase MCP (DB操作)`n2. GitHub MCP (リポジトリ操作)`n3. Brave Search MCP (リサーチ)`n4. Figma MCP (デザイン→コード)`n5. Slack/Notion MCP (連携)`n各: 公式リンク・インストール手順・JSON設定・トラブルシュート。約3500字。" }

    @{ Slug="dev-failure-recovery"; Title="[Dev] バイブコーディング 事故復旧の8パターン"
       Prompt="バイブコーディング中によく起きる事故8パターンと、Git/Docker/環境変数で復旧する手順。`n例: AIがファイル全消し、認証情報漏洩、無限ループ課金、依存パッケージ破壊、デザイン崩壊、データベース誤更新、デプロイミス、APIキー流出。`n各: 起きるシナリオ・即応手順・予防策・大井向けの教訓。約3500字。" }

    @{ Slug="dev-monitor-stack"; Title="[Dev] 個人開発の監視・運用スタック"
       Prompt="大井が月3万x複数アプリを運用する時の監視・運用スタック設計。`n- エラー監視 (Sentry等)`n- ログ集約 (Logtail等)`n- 課金監視 (Stripe webhook+Discord通知)`n- ユーザー行動 (PostHog/Plausible)`n- 死活監視 (UptimeRobot等)`n- すべて月¥3000以内に収める`n各ツール: 選定理由・無料枠・設定手順。約3000字。" }
)

$available = $pool | Where-Object { $_.Slug -notin $recentSlugs }
if ($available.Count -eq 0) { $available = $pool }

$pick = $available | Get-Random
# wiki/_inbox/dev を保存先に
$devInbox = Join-Path $brainRoot "wiki\_inbox\dev"
if (-not (Test-Path $devInbox)) { New-Item -ItemType Directory -Path $devInbox -Force | Out-Null }
$outPath = Join-Path $devInbox "dev-$($pick.Slug)-$stamp-$shortId.md"

& $dispatcher `
    -Department "dev" `
    -Title $pick.Title `
    -Prompt $pick.Prompt `
    -Model "qwen3:8b" `
    -OutputPath $outPath `
    -Priority "normal" `
    -UseAgent 2>&1 | Out-Null

$newHistory = @($state.history) + @(@{ slug = $pick.Slug; time = (Get-Date).ToString("o") })
$cutoffOld = (Get-Date).AddDays(-3)
$newHistory = $newHistory | Where-Object { [DateTime]$_.time -gt $cutoffOld }
$stateJson = @{ history = $newHistory } | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($stateFile, $stateJson, [System.Text.UTF8Encoding]::new($false))

"$nowStamp - dev: $($pick.Title)" | Add-Content $logPath -Encoding UTF8
Write-Host "Dev-filled: $($pick.Title)"
