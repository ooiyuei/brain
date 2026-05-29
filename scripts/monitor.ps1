#requires -Version 5.1
# 毎朝08:30 - 監視タスク3種類をOpenClawに自動投入。
# dispatch.ps1 が共通prefix（日付・実在entities・出力ルール）を自動付与する。
# シンプル化版: 5→3種類（競合・締切・朝の問い）

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brainRoot = "C:\Users\Owner\business\brain"
$dispatcher = Join-Path $brainRoot "scripts\dispatch.ps1"
$today = (Get-Date).ToString("yyyy-MM-dd")
$monitorDir = Join-Path $brainRoot "wiki\_monitor"

if (-not (Test-Path $monitorDir)) {
    New-Item -ItemType Directory -Path $monitorDir -Force | Out-Null
}

# ========== 1. 競合動向Top3 ==========
$promptCompetitor = @"
# タスク: 大井湧瑛の主力プロダクトの競合動向Top3を構造化

## 監視対象（実在competitor）
1. **Studyplus Planning** — 学習記録SaaS。[[entities/testall]] の最大競合
2. **Notion AI** — 知的生産ワークスペース。[[entities/aipax]] の競合
3. **engage（エン・ジャパン）** — AI採用支援。[[entities/aipa-web]] の競合

## 各社について書くこと（厳格に従う）
- 直近の動き（公開情報ベース、知らないなら「公開情報範囲では特記事項なし」）
- 大井プロダクトへの影響（[[entities/xxx]] 形式でリンク必須）
- 注意レベル: 高/中/低（理由1行付き）

## 出力フォーマット（厳守）
```markdown
# 2026-05-18 競合動向Top3

## 1. Studyplus Planning vs [[entities/testall|Testall]]
**直近の動き**: ...
**影響**: ...
**注意レベル**: 高/中/低 — 理由: ...

## 2. Notion AI vs [[entities/aipax|AIpaX]]
...

## 3. engage vs [[entities/aipa-web|AIpa Web]]
...

## 大井へ一言（30字以内）
...
```

## 字数: 約2000字以内
"@

# ========== 2. ビジコン応募締切リマインド ==========
$promptDeadlines = @"
# タスク: ビジコン応募の締切リマインド作成

## 監視対象（実在ビジコン）
[[entities/business-contests]] の132件のうち、直近の主要5件：
1. **夢AWARD** — 締切 2026-06-07
2. **コムロ起業家アワード** — 締切 2026-06-15
3. **GTE（Global Tech Entrepreneurship）** — 締切 2026-06-30
4. **StartupBase U18** — 締切 2026-07-15
5. **KANSAI起業家コンテスト** — 締切 2026-07-31

## 計算ルール
- 「今日（2026-05-18）」から各締切までの残日数を計算
- 残14日以内 = 🔥 1週間以内ゾーン（要即対応）として扱う
- 残15-30日 = 🌱 2週間〜1ヶ月ゾーン
- 残30日超 = 📅 1ヶ月超ゾーン

## 各ビジコンについて書くこと
- 締切日と残日数（必須）
- 推奨応募事業（実在の [[entities/<slug>]] のみ。下記から選ぶ）
  - [[entities/aipa-web]] / [[entities/testall]] / [[entities/aipax]] / [[entities/aof]] / [[entities/eemus]] / [[entities/aipax-school]]
- 必要準備（応募書類・実績データ・プレゼン資料など具体的に1-2項目）

## 出力フォーマット（厳守）
```markdown
# 2026-05-18 ビジコン締切リマインド

## 🔥 1週間以内（要即対応）
（該当なしなら「該当なし」と1行）

## 🌱 2週間〜1ヶ月以内
- **夢AWARD** — 締切 2026-06-07（残 20日）
  - 推奨応募事業: [[entities/aipa-web|AIpa Web]]（理由: ...）
  - 必要準備: ...

## 📅 1ヶ月超（準備開始タイミング）
...

## 今日着手すべきアクション
- ...

## 今週着手すべきアクション
- ...
```

## 字数: 約1500字以内
## 重要: 架空のentities/<slug>を作らない。上記リストにあるものだけ使う
"@

# ========== 3. 朝の問い3つ ==========
$promptGrill = @"
# タスク: 大井湧瑛が朝起きてハッとする問いを3つ生成

## 大井のプロファイル（必ず踏まえる）
- 1人起業家、15事業並走中（多すぎ・フォーカス散漫が弱み）
- 思考スタイル: 話しながら考える・比喩モデル化・OS化したがる・脳汁駆動
- 今月フォーカス: [[entities/aipa-web|AIpa Web]] / AIコンサル / ビジコン応募 / SFC AO構想
- WISC-V分析あり、認知特性は[[meta/ooi-wisc-profile]]参照
- 大井は「証拠は？」「誰が明日使う？」を問いかけ軸にされると効く

## 問いの構成（厳格に3つ）
- Q1: 今日のフォーカス検証系（「本当に今日それやる？」）
- Q2: 事業ポートフォリオ系（「15事業のうちどれ切る？」）
- Q3: 自分自身系（脳汁・エネルギー・モチベ）

## 各問いに含めること
- 問い本体（30字以内）
- 問いの意図（1行・なぜこの問いを今日投げるか）

## 出力フォーマット（厳守）
```markdown
# 2026-05-18 朝の問い

### Q1（今日のフォーカス検証）
> <問い・30字以内>
**意図**: <1行>

### Q2（事業ポートフォリオ）
> <問い>
**意図**: ...

### Q3（自分自身・脳汁）
> <問い>
**意図**: ...

## 一言（30字以内・大井へのメッセージ）
...
```

## 字数: 約800字以内
## NG: 「正解を出させる」問い、抽象的すぎる問い、AI臭い問い
## OK: 大井の盲点を突く問い、ハッとする比喩を含む問い
"@

# ========== Dispatch投入 ==========

$tasks = @(
    @{ Title = "[Monitor] 競合動向Top3 - $today"; Prompt = $promptCompetitor; OutPath = (Join-Path $monitorDir "competitor-$today.md") }
    @{ Title = "[Monitor] ビジコン締切 - $today"; Prompt = $promptDeadlines; OutPath = (Join-Path $monitorDir "deadlines-$today.md") }
    @{ Title = "[Monitor] 朝の問い - $today"; Prompt = $promptGrill; OutPath = (Join-Path $monitorDir "grill-$today.md") }
)

foreach ($t in $tasks) {
    & $dispatcher -Department "research" -Title $t.Title -Prompt $t.Prompt -OutputPath $t.OutPath -Priority "high"
    Start-Sleep -Milliseconds 200
}

Write-Host ""
Write-Host "Monitor: 3 tasks dispatched for $today"
