#requires -Version 5.1
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$dispatcher = "$brain\scripts\dispatch.ps1"

# ============================================================
# 業務タスク10本まとめ投入 (主力5事業中心・寝てる間に量産)
# ============================================================

$tasks = @(
    @{ Dept="newbiz"; Title="EEMUS夢AWARD第2章下書き"; OutDir="newbiz"; Prompt=@"
# タスク: 夢AWARD応募 第2章下書き「数字が語る構造的欠陥」(800字)
[[entities/eemus]]
- 静岡県外大学進学71%・Uターン就職率33%・正社員不足50.8%・建設業人手不足79.5%・高卒3年離職率38.4%
- 数字ごとに出典1行
- 「数字を並べるだけで終わるな」→ そこから「これは構造の問題」と言い切る
- 大井キャラ・関西弁混じり可・断定
"@ },
    @{ Dept="newbiz"; Title="EEMUS夢AWARD第3章下書き"; OutDir="newbiz"; Prompt=@"
# タスク: 夢AWARD応募 第3章下書き「既存事業の限界」(800字)
[[entities/eemus]]
- Wantedly/マイナビ/地方紙の限界を具体的に
- Wantedly=大学生中心、マイナビ=新卒採用イベント止まり、地方紙=求人広告だけ
- なぜ高校生×中堅企業のマッチング市場が空いてるか3点
- 大井キャラ
"@ },
    @{ Dept="newbiz"; Title="EEMUS夢AWARD第4章下書き"; OutDir="newbiz"; Prompt=@"
# タスク: 夢AWARD応募 第4章下書き「EEMUSが提供する3つの転換」(900字)
[[entities/eemus]]
- 転換1: 進学一択→選択肢の解像度UP
- 転換2: 企業の採用ミス→入社前マッチング
- 転換3: 静岡離れ→静岡で生きる選択肢の見える化
- 各転換に具体メカニズム (どうやって?)
- 大井キャラ
"@ },
    @{ Dept="marketing"; Title="Testall β顧客100名募集LP草稿"; OutDir="marketing"; Prompt=@"
# タスク: Testall β顧客100名募集LP草稿 (2500字)
[[entities/testall]]
- ターゲット: 受験生 (高2-高3) と 保護者
- USP: 模試弱点→1日45分プラン自動生成
- 構成: Hero/Problem/Solution/Proof/Pricing/CTA
- 価格: 月980円 (β限定) → 通常2,980円
- 「明日読む高校3年生1人」を冒頭で名指し
- 大井キャラ
"@ },
    @{ Dept="marketing"; Title="AIpaX 月次レポートフォーマット"; OutDir="corp"; Prompt=@"
# タスク: AIpaX 月次レポートフォーマット (既存4社向け)
[[entities/aipax]]
- 各セクション: 今月の利用状況 / ROI試算 / 改善提案 / 次月の追加機能
- 顧客が30秒で読める1ページ + 詳細5ページ構成
- 数字を表形式で
- 「来月の20分MTGで聞きたいこと」を最後に
"@ },
    @{ Dept="marketing"; Title="AIpa Web SEO記事『中小企業 採用サイト 自社制作』"; OutDir="marketing"; Prompt=@"
# タスク: SEO記事『中小企業 採用サイト 自社制作』本文 (3500字)
[[entities/aipa-web]]
- 検索意図: 「採用サイト 自社制作 vs 外注」で悩んでる中小経営者
- 結論: AIで自社制作の時代・ただし「採用に使える」サイト設計が肝
- 競合engageの限界 → AIpa Webの位置づけ
- 3つのチェックリスト (応募が来ない採用サイトの典型ミス)
- CTA: モニター15万円プラン
"@ },
    @{ Dept="newbiz"; Title="Testall 受験生ペルソナ5パターン詳細"; OutDir="newbiz"; Prompt=@"
# タスク: Testall ユーザーペルソナ5パターン詳細
[[entities/testall]]
各ペルソナ:
1. 名前・年齢・学校レベル・志望校
2. 現在の悩み (具体)
3. 1日の勉強時間と挫折ポイント
4. 親との関係
5. なぜTestallを使うか
6. 解約理由になりうる事
パターン:
- 偏差値60・地方公立高3・東京MARCH志望
- 偏差値55・私立特進高2・関関同立
- 偏差値45・地方私立高3・地元国立
- 偏差値68・進学校高2・東大文一
- 偏差値50・通信制高3・専門学校
"@ },
    @{ Dept="research"; Title="競合徹底比較: Studyplus Planning vs Testall"; OutDir="research"; Prompt=@"
# タスク: Studyplus Planning vs Testall 徹底比較
[[entities/testall]]
比較項目:
- 機能 (学習計画自動生成・進捗管理・コーチング)
- UX (登録ハードル・継続のしやすさ)
- 価格 (月額・無料機能の範囲)
- ターゲット (どんな受験生?)
- 強み・弱み
- Testallが勝てる5点
出典: 各社の公式LP・App Store・Google Play 直近レビュー
"@ },
    @{ Dept="newbiz"; Title="AOF (Agents of Flag) ホットスプリングス商談資料"; OutDir="newbiz"; Prompt=@"
# タスク: AOF ホットスプリングス面談 提案資料 (3000字)
[[entities/agents-of-flag]]
- 既存機材PoC打診の文脈
- 構成:
  1. AOF概要 (300字)
  2. 競技ルール詳細 (光線銃+センサー+音+振動+ランク)
  3. 既存機材活用のシナジー
  4. 共同PoC提案 (静岡会場・10チーム×4人)
  5. 投資・収益の概算
  6. 来年Q1着手スケジュール
- 大井キャラ・かっこいい言葉許可
"@ },
    @{ Dept="corp"; Title="AIpaX 業務委託契約書 (β契約済企業向け運用版)"; OutDir="corp"; Prompt=@"
# タスク: AIpaX 業務委託契約書テンプレ (既存4社向け運用版)
[[entities/aipax]]
含めるべき条項:
- 業務範囲 (社内AIチャット/CS対応AI/新人教育AI 等の選択制)
- 月額費用と支払い条件 (初期100万・月10-15万)
- データ取り扱い (顧客データの保護・秘密保持)
- 解約条件 (3ヶ月前通知)
- 知財 (作ったAIプロンプト等の帰属)
- 損害賠償の上限
- 反社条項
- 自動更新
リーガルレビュー前のドラフトとして3000字
"@ }
)

$dispatched = 0
foreach ($t in $tasks) {
    $stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
    $sid = [guid]::NewGuid().ToString().Substring(0,4)
    $slug = ($t.Title -replace '[^\w]','-').ToLower()
    if ($slug.Length -gt 40) { $slug = $slug.Substring(0, 40) }
    $outPath = "$brain\wiki\_inbox\$($t.OutDir)\bulk-$slug-$stamp-$sid.md"
    
    & $dispatcher `
        -Department $t.Dept `
        -Title "[Bulk] $($t.Title)" `
        -Prompt $t.Prompt `
        -Model "qwen3.6:latest" `
        -OutputPath $outPath `
        -Priority "normal" `
        -UseAgent 2>&1 | Out-Null
    
    $dispatched++
    Write-Host "[$dispatched/$($tasks.Count)] $($t.Title)"
}

Write-Host "===  Bulk dispatch complete: $dispatched tasks ==="
