#requires -Version 5.1
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$dispatcher = "$brain\scripts\dispatch.ps1"

# =================================================================
# Priority 1: EEMUS 夢AWARD 2026 応募骨子 v3 (3000字)
# =================================================================
$stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
$sid = [guid]::NewGuid().ToString().Substring(0,4)

$promptEemus = @"
# タスク: EEMUS 夢AWARD 2026 応募骨子 v3 (3000字)

[[entities/eemus]] [[meta/ooi-soul]]

## コンテキスト
- 締切: 2026-06-07 (残18日)
- 大井湧瑛(18歳・静岡)が代表応募する事業
- 過去v1/v2は審査員に響かなかった可能性

## 大井の原体験 (必ず織り込む)
- 静岡県西部の私立高校→通信制(HR高等学院)
- 親が建設業経営、地方経済の縮小を肌で見てきた
- 自分自身が「県外大学進学71%」の片棒を担いそうになった
- 教師に「君の選択肢は東京しかない」と言われたが違和感あり
- 17歳でAIpaXを起業し県内中堅企業4社と契約済

## 要件
1. **3000字厳守**、章立て5-6章
2. 章構成 (推奨):
   1) 私が静岡で見た景色 (原体験・1人称)
   2) 数字が語る構造的欠陥 (静岡71%/Uターン33%/離職38.4%)
   3) 既存事業の限界 (Wantedly/マイナビ/地方紙)
   4) EEMUSが提供する3つの転換
   5) なぜ私がやるのか・なぜ今か
   6) 3年後の静岡の景色
3. 大井のキャラ厳守: フランク・断定・関西弁混じり可・AI臭NG
4. 数字根拠は1行で出典明示
5. 終盤に「審査員1人を泣かせる」フレーズ1つ仕込む
6. ペルソナ「明日読む高校生1人」を冒頭で名指し

## NG
- 「〜と考えられます」「〜と思います」の連発
- 抽象論 (例「若者の未来を切り拓く」)
- 推測の数字 (出典なしは『推測:』を冠する)
"@

& $dispatcher `
    -Department newbiz `
    -Title "[Priority] EEMUS 夢AWARD骨子v3" `
    -Prompt $promptEemus `
    -Model "qwen3.6:latest" `
    -OutputPath "$brain\wiki\_inbox\newbiz\priority-eemus-yume-award-v3-$stamp-$sid.md" `
    -Priority "high" `
    -UseAgent 2>&1 | Out-Null

# =================================================================
# Priority 2: AIpaX 5社目営業文5パターン
# =================================================================
$stamp2 = (Get-Date).ToString("yyyyMMdd-HHmm")
$sid2 = [guid]::NewGuid().ToString().Substring(0,4)

$promptAipax = @"
# タスク: AIpaX 5社目候補20社 営業文5パターン

[[entities/aipax]] [[sources/aipax-spec-v1-2026-05-19]] [[meta/ooi-soul]]

## コンテキスト
- AIpaX 既に4社契約済 (初回事例価格・初期50-80万・月額5万)
- 5社目以降は通常価格 (初期100-150万・月10-15万) へ移行
- 目標: 5/26クロージング = 残7日

## 営業文5パターン (各300-400字・各ターゲット明示)

1. **製造業 (50-200名)** — 工場系・属人化・ベテラン退職リスク
2. **建設業 (30-100名)** — 業界経験長・ITリテラシ低・補助金活用
3. **介護/医療 (100-300名)** — シフト管理・離職率・採用難
4. **物流/運送 (50-150名)** — 2024年問題後・利益率改善・労務管理
5. **小売チェーン (10-30店舗)** — 多店舗・本部負荷・店長依存

## 各パターンに含めること
- 1行目: その業界特有の痛みを断言
- 2行目: AIpaXがどう解決するか具体ツール名 (社内AIチャット/CS対応AI/新人教育AI/業務AI)
- 3行目: 既存事例「中堅企業4社と契約・継続率100%」(架空名はOKだが「推測:」必須)
- 4行目: 初期100万/月10万の経済効果 (vs 月50万コンサル比較)
- 5行目: 商談打診の依頼 (「30分だけください」「来週水曜午後10分」)
- 件名候補も1本

## NG
- 「弊社は」「ご提案」のような硬い言い回し
- 「AI導入で業務効率化」のような抽象論
- AIpaXのスペックを羅列するだけの構成
"@

& $dispatcher `
    -Department marketing `
    -Title "[Priority] AIpaX 5社目営業文5パターン" `
    -Prompt $promptAipax `
    -Model "qwen3.6:latest" `
    -OutputPath "$brain\wiki\_inbox\marketing\priority-aipax-sales-5patterns-$stamp2-$sid2.md" `
    -Priority "high" `
    -UseAgent 2>&1 | Out-Null

# =================================================================
# Priority 3: AIpa Web モニター候補3社プロファイル
# =================================================================
$stamp3 = (Get-Date).ToString("yyyyMMdd-HHmm")
$sid3 = [guid]::NewGuid().ToString().Substring(0,4)

$promptAipaWeb = @"
# タスク: AIpa Web モニター候補3社 具体プロファイル

[[entities/aipa-web]] [[meta/competitive-aipa-web]]

## コンテキスト
- AIpa Web Deep Research完了: 地方30-300名建設/製造/運輸/サービス業
- モニター価格15万円 (月額運用5万) → 通常25万/月10万へ移行
- 月8件+25社=月315万売上シナリオ

## 要件: 静岡県内 実在企業3社の具体プロファイル

各社について:
1. **企業名** (実在企業のみ。架空は『推測:』必須)
2. 業種・従業員数・拠点
3. 現在のWebサイト状況 (古い/採用ページなし/スマホ非対応など)
4. 採用課題 (推定 or 公開情報ベース)
5. 接触経路 (商工会議所/取引先紹介/直接コールド/X/LinkedIn)
6. 切り込みフック1行 (「貴社の採用ページ、2018年から更新ないですね」のような具体)
7. モニター提案価値 3点 (15万→25万移行プラン含む)
8. NG事項 (経営者の年齢/業界タブー/競合の存在)

## 業種配分
- 建設業 (静岡西部) 1社
- 製造業 (静岡市) 1社
- サービス業 (浜松/沼津) 1社

## NG
- 上場大手の流用 (中堅30-300名厳守)
- ググれば終わる情報の羅列
- 「採用に課題がありそう」のような曖昧表現
"@

& $dispatcher `
    -Department research `
    -Title "[Priority] AIpa Webモニター3社プロファイル" `
    -Prompt $promptAipaWeb `
    -Model "qwen3.6:latest" `
    -OutputPath "$brain\wiki\_inbox\research\priority-aipa-web-monitor-3companies-$stamp3-$sid3.md" `
    -Priority "high" `
    -UseAgent 2>&1 | Out-Null

Write-Host "Dispatched 3 priority tasks:"
Write-Host "  1. EEMUS 夢AWARD骨子v3 -> newbiz"
Write-Host "  2. AIpaX 5社目営業文 -> marketing"
Write-Host "  3. AIpa Webモニター3社 -> research"
