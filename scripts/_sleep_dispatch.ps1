#requires -Version 5.1
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$dispatcher = "$brain\scripts\dispatch.ps1"
$stamp = (Get-Date).ToString("yyyyMMdd-HHmm")

# 1. 夢AWARD章別下書き (大井が明日編集できる素材)
$sid1 = [guid]::NewGuid().ToString().Substring(0,4)
$p1 = @"
# タスク: 夢AWARD応募 第1章下書き「私が静岡で見た景色」(800字・原体験ベース)

[[entities/eemus]] [[meta/ooi-life-story]] [[meta/ooi-soul]]

## コンテキスト
- 締切: 2026-06-07 (残18日)
- 第1章は審査員が一番見るところ。1人称・原体験ベース。
- 本人が明日編集する素材としての下書き

## 要件
1. 800字
2. 1人称 (俺/私)・大井のキャラ (フランク・関西弁混じり可)
3. 必ず含める3要素:
   - 静岡県西部の具体的な景色 (実在の地名・建物・現象)
   - 親が建設業経営という設定 (本人プロファイル)
   - 「教師に『君の選択肢は東京しかない』と言われた」エピソード
4. 数字を1個入れる (県外大学進学71% or Uターン33%)
5. 「審査員1人を動かす」フレーズを1つ仕込む
6. 抽象論ゼロ (「若者の未来を切り拓く」系NG)

## NG
- 「と考えられます」「と思われます」連発
- 推測の数字 (出典なしは『推測:』必須)
- AIpaX/Testall の話 (これは別事業)
"@
& $dispatcher -Department newbiz -Title "[Sleep] 夢AWARD第1章下書き" -Prompt $p1 -Model "qwen3.6:latest" -OutputPath "$brain\wiki\_inbox\newbiz\sleep-yume-award-ch1-$stamp-$sid1.md" -Priority "high" -UseAgent 2>&1 | Out-Null

# 2. AIpaX 5社目クロージング想定問答
$sid2 = [guid]::NewGuid().ToString().Substring(0,4)
$p2 = @"
# タスク: AIpaX 5社目クロージング 想定問答10問

[[entities/aipax]] [[sources/aipax-spec-v1-2026-05-19]]

## コンテキスト
- AIpaX 既に4社契約 (初回事例価格)
- 5社目以降は通常価格 (初期100-150万・月10-15万)
- 商談2回目〜3回目の質問対応

## 要件: 5社目候補が必ず聞いてくる10問の想定問答

各問答に:
1. 質問 (中堅企業の経営者目線)
2. 回答 (大井キャラ・断定・数字根拠)
3. 補足: クローズに繋げる一言

例:
Q1. 「AIに丸投げして本当に大丈夫?」
A1. 大丈夫じゃない。だから初回100万分の人間サポートが入ってる。AIが7割、人間が3割。3ヶ月後にAIが9割になる設計。
補足: 「うちの4社目までの導入企業、全員『最初は不安だった』と言ってる。3ヶ月後に同じこと言わなくなる。」

質問テーマ:
- 1. AIの精度・誤動作リスク
- 2. 社員の反発
- 3. 競合(ChatGPT直接利用)との違い
- 4. 月10-15万の費用根拠
- 5. 解約時のデータ
- 6. 既存システムとの連携
- 7. 守秘義務・セキュリティ
- 8. 教育コスト
- 9. ROI測定方法
- 10. 大井(高校生)の信頼性

各300-400字。
"@
& $dispatcher -Department marketing -Title "[Sleep] AIpaX 5社目想定問答10問" -Prompt $p2 -Model "qwen3.6:latest" -OutputPath "$brain\wiki\_inbox\marketing\sleep-aipax-qa10-$stamp-$sid2.md" -Priority "high" -UseAgent 2>&1 | Out-Null

# 3. AIpa Web 接触メール5パターン (商工会経由・直接コールド)
$sid3 = [guid]::NewGuid().ToString().Substring(0,4)
$p3 = @"
# タスク: AIpa Web モニター接触メール 5パターン

[[entities/aipa-web]] [[meta/competitive-aipa-web]]

## コンテキスト
- ターゲット: 静岡 地方30-300名 建設/製造/運輸/サービス業
- モニター価格15万円 (通常25万)・月額運用5万 (通常10万)
- 接触経路: 商工会議所・取引先紹介・直接コールド・X・LinkedIn

## 要件: 5パターン

各パターン:
1. 経路 (商工会経由 / 取引先紹介 / 直接コールド / X DM / LinkedIn)
2. 件名 (40字以内・開封率上げる)
3. 本文 (300字以内)
4. CTA (返信のハードル最低化)

各経路で文体が違うこと:
- 商工会経由: フォーマル・地域貢献感
- 取引先紹介: 中間的・「お聞きしました」起点
- 直接コールド: 切り込み型・痛みフック
- X DM: フランク・「いきなりですいません」
- LinkedIn: ビジネスライク・実績前提

NG:
- 「ご提案させていただきたく」系の硬さ
- 「AIで業務効率化」抽象論
- 件名で「無料」連発
"@
& $dispatcher -Department marketing -Title "[Sleep] AIpa Web 接触メール5パターン" -Prompt $p3 -Model "qwen3.6:latest" -OutputPath "$brain\wiki\_inbox\marketing\sleep-aipa-web-contact-5-$stamp-$sid3.md" -Priority "high" -UseAgent 2>&1 | Out-Null

Write-Host "Dispatched 3 sleep-mode priority tasks"
