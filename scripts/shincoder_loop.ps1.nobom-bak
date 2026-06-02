#requires -Version 5.1
# Shincoder Loop - シンコード11ステップを自動回す (2026-05-26 新規)
# 大井指示「アプリのアイディア出しからローンチまでのステップ・数字で決める部分」を実装
#
# 違い:
#   money_loop.ps1   = 短期収益直結 (営業文・アップセル提案)
#   shincoder_loop   = 方法論実装 (アイデア→LP→広告→CPA→PMF→スケール)
#
# 1h毎発火・1サイクル3件dispatch・8時間クールダウン
# 数字判定タスクは大井記入用テンプレを _final/decisions/ に出力

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
if (Test-Path "$brain\queue\.paused") { exit 0 }

$dispatcher = "$brain\scripts\dispatch.ps1"
$logPath = "$brain\scripts\shincoder_loop.log"
$stateFile = "$brain\scripts\.shincoder_loop_state.json"
$nowStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$today = (Get-Date).ToString("yyyy-MM-dd")

# inbox 250件超ならスキップ (Force=1 で無視)
$inboxCount = (Get-ChildItem "$brain\queue\inbox" -File -Filter "*.json" -ErrorAction SilentlyContinue).Count
if ($inboxCount -gt 250 -and $env:SHINCODER_FORCE -ne '1') {
    "$nowStamp - skip: inbox $inboxCount > 250 (set SHINCODER_FORCE=1 to override)" | Add-Content $logPath -Encoding UTF8
    exit 0
}

# State 読み込み
$state = @{ used = @{} }
if (Test-Path $stateFile) {
    try {
        $loaded = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($loaded.used) { foreach ($p in $loaded.used.PSObject.Properties) { $state.used[$p.Name] = $p.Value } }
    } catch {}
}

# === シンコード11ステップ実装 タスクプール ===
# 各タスクはdept・タイトル・プロンプト・ステップ番号を持つ

$shincoderTasks = @(
    # Step1: アイデア発掘 (毎日マイクロフラストレーション10個)
    @{
        step=1; d="newbiz"; t="マイクロフラストレーション 10個収集 ($today)"
        p=@"
# タスク: 大井のマイクロフラストレーション 10個 ($today 分)
[[concepts/solopreneur-11steps]] step1

シンコード式: 「自分の痛み = 本物の事業ネタ」原則。
大井の17事業ポートフォリオに **新規追加候補** となる小さな痛み (Micro Frustration) を10個挙げる。

## 出力フォーマット
1. **痛み名**: <30字以内>
   - 発生場面: <具体的なシーン>
   - 既存解決法: <現状の代替手段>
   - なぜ不満か: <1行>
   - **事業化可能性**: 高/中/低 + 1行理由
   - 既存17事業との被り: <被るならどれ・被らないなら新規>

## 制約
- 大井(17歳→6/9で18歳・現役起業家・静岡・元里子) の生活/事業文脈に沿う
- AI/教育/採用/SaaS領域以外も OK (生活/趣味/食/移動 等)
- 痛みが本物 = 大井が **過去30日に実際に経験** していそうなもの
- 既存17事業 (AIpaX/Testall/EEMUS/AOF/AIpa Web/AIpaX school/Gymee/EcoKan/OMNI/IPAK系/和コウチャイ/フルーツソース等) に被るものは「被り」と明記
"@
    },

    # Step2: LP草案生成 (毎日新規アイデア1本)
    @{
        step=2; d="newbiz"; t="新規アイデアLP草案 ($today)"
        p=@"
# タスク: 新規事業候補LP草案 1本 ($today)
[[concepts/solopreneur-11steps]] step2

シンコード式: アイデア出たら **24時間以内にLP草案** → 広告検証 → CPA判定。
大井が今週中に X/Meta広告に投下できるLP内容を草案する。

## 選定方法
- 直近の マイクロフラストレーション 蓄積 ($brain/wiki/_inbox/newbiz/ の microfrustration-* 参照) から1個選ぶ
- 候補ない場合: シンコード推奨「日本未進出の海外バズアプリ」をローカライズ角度で1個

## 出力フォーマット (LP草案 約2500字)
\`\`\`yaml
---
type: lp-draft
status: ready-for-cpa-test
created: $today
target_cpa: 100-300円
ad_budget: 10000円 (X/Meta 各5000)
---
\`\`\`

### 1. キャッチコピー候補 3本 (各30字以内)
- A案 (痛み訴求)
- B案 (ベネフィット訴求)
- C案 (Before/After)

### 2. ヒーロー画像説明 (Claude Design + GPT Image 2 指示書)
- スクショ映えする1画面の具体描写
- 配色・構図・テキスト配置

### 3. 本文セクション (5ブロック)
- 痛み (現状の不便)
- 解決 (アプリで何ができる)
- 機能 (3つに絞る)
- 価格 (買切 or サブスク・価格設定根拠)
- CTA (ウェイトリスト登録 or 早期割引)

### 4. ウェイトリスト計測項目
- 想定CTR (X広告): 2-5%
- 想定CVR (LP→登録): 5-15%
- **GO判定CPA**: 300円以下
- **即PIVOT判定CPA**: 500円以上
"@
    },

    # Step3-4: 広告検証 → CPA判定テンプレ (週1・数字記入用)
    @{
        step=4; d="corp"; t="CPA判定シート ($today 週分)"
        p=@"
# タスク: CPA判定シート 大井記入用テンプレ ($today 週分)
[[concepts/solopreneur-11steps]] step3-4
[[meta/shincoder-actions-for-ooi-2026-05-25]]

シンコード式 CPA = 100-300円 が需要証明ライン。
大井が **数字を埋めるだけ** で GO/PIVOT判定できるテンプレ。

## 出力先
$brain/wiki/_final/decisions/cpa-check-$today.md

## フォーマット

\`\`\`markdown
# CPA判定シート $today

## 検証中LP一覧

| LP/アプリ名 | 広告投下 | 期間 | クリック数 | CTR | LP訪問→登録 CVR | ウェイトリスト人数 | **CPA** | 判定 |
|---|---|---|---|---|---|---|---|---|
| AIpaX 5社目 (静岡製造業3社向け) | 5000円 | __日 | __ | __% | __% | __人 | __円 | __ |
| AIpa Web 静岡向け | 5000円 | __日 | __ | __% | __% | __人 | __円 | __ |
| Testall 親向け | 5000円 | __日 | __ | __% | __% | __人 | __円 | __ |
| 新規候補 (アイデア発掘から) | 5000円 | __日 | __ | __% | __% | __人 | __円 | __ |

## 判定ルール (シンコード基準)
- **CPA ≤ 100円**: 即GO・追加投下5万円
- **CPA 100-300円**: GO・本開発スタート
- **CPA 300-500円**: HOLD・LPコピー1箇所変えて再検証 (3日)
- **CPA ≥ 500円**: 即PIVOT・LPかオーディエンス変更
- **登録0人**: 即PIVOT・別アイデアへ

## 大井の判断ログ
- 今週の判定結果:
- ピボット決定アイデア:
- 本開発GO決定アイデア:
- 次週検証予定:
\`\`\`

実数値が分からない箇所は __ で残す。
推測値で埋めない (シンコード鉄則: 数字は実測のみ)。
"@
    },

    # Step6: ビルドインパブリック X投稿草案 (毎日3本)
    @{
        step=6; d="marketing"; t="ビルドインパブリックX投稿 3本 ($today)"
        p=@"
# タスク: 大井1人称 ビルドインパブリック X投稿 3本 ($today)
[[concepts/solopreneur-11steps]] step6
[[meta/ooi-soul]]

シンコード式: 開発過程を毎日X発信 → β顧客リスト構築 → バズ起点。
大井の主力5事業から3つ選び、各1本ずつ。

## 出力フォーマット
各投稿:
- 文字数: 130字以内 (リプ展開しやすく)
- 大井1人称 ("俺" "やる" "今日" 多用)
- 数字必須 (進捗・人数・売上・期日いずれか)
- フック (最初3秒で目を止める) 強化
- 17歳→18歳になる現役起業家 USP 自然反映
- AI臭ペナルティ: 「〜することが重要」「様々な」「〜と言えるでしょう」禁止
- 絵文字: 1投稿につき1-2個まで

## ジャンル分散
1. **進捗** (今日やったこと)
2. **学び** (失敗 or 気付き)
3. **募集 or 告知** (β顧客 or 商談 or 応募)

## 投稿例 (参考フォーマット・コピペ不可)
"AIpaX 5社目契約、静岡製造業向けに LP作って今日広告1万円投下した。
CPA 300円切ったら本契約に進む。
中小企業の社員AI教育、絶対需要ある。データ出たら共有する。"
"@
    },

    # Step8-9: ファネル分析テンプレ (週1・大井記入用)
    @{
        step=9; d="corp"; t="ファネル分析シート ($today 週分)"
        p=@"
# タスク: 主力5事業 ファネル分析シート 大井記入用 ($today 週分)
[[concepts/solopreneur-11steps]] step8-9
[[concepts/pmf-validation]]

シンコード式: ファネル分析 = バケツの穴埋め。離脱多い箇所がPMFの壁。

## 出力先
$brain/wiki/_final/decisions/funnel-analysis-$today.md

## フォーマット

\`\`\`markdown
# ファネル分析シート $today

## AIpaX (現在: PMF判定中・4社契約)

| 段階 | 今週数 | 離脱率 | 改善優先度 |
|---|---|---|---|
| 認知 (LP訪問・営業メール開封) | __ | - | - |
| 興味 (返信・問い合わせ) | __ | __% | __ |
| 商談1回目 (Zoom) | __ | __% | __ |
| 商談2回目 (見積) | __ | __% | __ |
| 契約 | __ | __% | __ |

**今週の最大の穴**: __ (例: 商談1→2が落ちすぎ)
**改善案**: __ (シンコード式: マイクロコピー1個変えで CVR 1.3倍狙う)

## Testall (現在: MVP開発中・β募集前)
| 段階 | 今週数 | 離脱率 |
|---|---|---|
| LP訪問 | __ | - |
| Google認証完了 | __ | __% |
| 1日プラン生成 | __ | __% |
| 課金 (β月980円) | __ | __% |

**判定**:
- CVR 1%超え = OK
- CVR 1%未満 = 改善必要 (シンコード式 200人で0人課金=ピボット)

## AIpa Web / EEMUS / AIpaX school (各事業同様の構造)
[省略・上記と同じ構造で出力]

## 今週の改善コミット (大井記入)
- 最優先で直す穴1箇所:
- 改善内容:
- 効果測定 (来週同じ表で比較):
\`\`\`

数字未測定の箇所は __ で残す。
"@
    },

    # Step10: PMF判定 (週1・大井記入用)
    @{
        step=10; d="corp"; t="PMF判定シート ($today 週分)"
        p=@"
# タスク: 主力5事業 PMF判定シート 大井記入用 ($today 週分)
[[concepts/solopreneur-11steps]] step10
[[concepts/pmf-validation]]
[[meta/shincoder-actions-for-ooi-2026-05-25]]

シンコード式 PMF達成シグナル 3軸 (定量/訂正/経済) で判定。

## 出力先
$brain/wiki/_final/decisions/pmf-judge-$today.md

## フォーマット

\`\`\`markdown
# PMF判定シート $today

## 判定基準 (シンコード式・全事業共通)

### 軸1: 定量
- [ ] 継続率 15%以上 / 30日
- [ ] CVR 3%以上 (LP→課金 or 訪問→アクション)
- [ ] オーガニック成長 (広告止めても新規増える)

### 軸2: 訂正 (顧客の声)
- [ ] 「なくなったら残念」回答 40%以上 (Sean Ellis Test)
- [ ] 紹介口コミ自然発生 (アンケート/Discord/X等で)

### 軸3: 経済
- [ ] LTV ≧ CAC × 3
- [ ] 月次MRRが3ヶ月連続増加

## 主力5事業 現状判定

| 事業 | 軸1 定量 | 軸2 訂正 | 軸3 経済 | **総合判定** |
|---|---|---|---|---|
| AIpaX | 継続率 4/4=100% / CVR __ / オーガニック __ | 残念率 __% / 紹介 __件 | LTV __円 / CAC __円 / 倍率 __ | PMF達成 / 接近中 / 未達 |
| Testall | (β前) | - | - | 未達・MVP段階 |
| AIpa Web | 継続率 __ / CVR __ | - | - | 未達・モニター獲得段階 |
| EEMUS | - | - | - | 未達・LP段階 |
| AIpaX school | - | - | - | 未達・MVP段階 |

## 大井の判断 (記入)
- 今週PMF達成宣言できる事業: __
- 「もう少し」状態の事業 + 次に動かす1手: __
- 即ピボット候補: __
- 来週の重点投下事業: __
\`\`\`

未測定箇所は __ で残す (推測禁止)。
"@
    },

    # Step11: ユニットエコノミクス (月1・大井記入用)
    @{
        step=11; d="corp"; t="ユニットエコノミクス計算シート ($today 月分)"
        p=@"
# タスク: 主力5事業 ユニットエコノミクス計算シート ($today 月分)
[[concepts/solopreneur-11steps]] step11

シンコード式: LTV/CAC ≧ 3 がスケール条件。

## 出力先
$brain/wiki/_final/decisions/unit-economics-$today.md

## フォーマット

\`\`\`markdown
# ユニットエコノミクス $today

## 共通計算式
- **LTV** = 平均月額 × 平均継続月数 - AI API原価
- **CAC** = (広告費 + 営業時間×時給) ÷ 新規獲得数
- **倍率** = LTV ÷ CAC

## AIpaX
- 月額: 15万円
- 平均継続月数: __ ヶ月 (現状4社全部継続中=未確定)
- AI API原価: __ 円/月/社
- **LTV** = 15万 × __ - __ = __ 円
- 広告費 (累計): __ 円
- 営業時間 (累計): __ 時間 × 時給0円 (大井自分) = 0
- 新規獲得数: 4社
- **CAC** = __ ÷ 4 = __ 円
- **倍率** = __ ← **3以上ならスケールGO**

## Testall (β開始後に記入)
- 月額: 980円 (β) → 2,980円 (通常)
- ...

## AIpa Web / EEMUS / AIpaX school (同じ構造)

## 判定
- 倍率 ≥ 3: 集客拡大期へ (広告・インフルエンサー・紹介プログラム全開)
- 倍率 1-3: 改善余地あり (LTV伸ばす or CAC下げる)
- 倍率 < 1: 即停止 or 価格見直し

## 大井の意思決定
- 今月スケール宣言する事業: __
- 価格見直し候補: __
- AI API原価圧縮余地: __
\`\`\`
"@
    },

    # 横断: スクショ映え1画面UI改善案 (週1)
    @{
        step=99; d="marketing"; t="スクショ映え1画面 UI改善案 ($today)"
        p=@"
# タスク: 主力5事業の「スクショ映え1画面」UI改善案 ($today)
[[meta/shincoder-actions-for-ooi-2026-05-25]] H2

シンコード式: X バズ100万 impressionの起点は「1秒で理解できる1画面」。
主力5事業の現状LP/アプリ画面から **スクショで拡散される1画面** を再設計する。

## 対象 (1サイクル1事業ローテーション・今回は AIpaX)
- 現状画面の問題点 (3点)
- スクショされやすい1画面の設計案
  - 構成: ヘッダー / メイン情報 / 数字インパクト / CTA
  - 配色: Claude Design推奨パレット
  - フォント: 1秒で読める階層
  - 「数字 + 大井の顔写真 + 一言」のような映え要素
- Claude Design + GPT Image 2 で生成する画像プロンプト 3案
- X投稿に添付する想定キャプション 1案

## 制約
- 大井1人称・17歳→18歳USP活用
- AI臭排除・人間味
"@
    }
)

# 8時間クールダウン
$cutoff = (Get-Date).AddHours(-8)
$available = $shincoderTasks | Where-Object {
    if (-not $state.used.ContainsKey($_.t)) { return $true }
    $last = [DateTime]$state.used[$_.t]
    return ($last -lt $cutoff)
}

if ($available.Count -eq 0) {
    "$nowStamp - all on cooldown" | Add-Content $logPath -Encoding UTF8
    exit 0
}

# 3件投入
$batch = $available | Get-Random -Count ([Math]::Min(3, $available.Count))
$dispatched = 0
foreach ($t in $batch) {
    $stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
    $sid = [guid]::NewGuid().ToString().Substring(0,4)
    $slug = ($t.t -replace '[^\w]','-').ToLower()
    if ($slug.Length -gt 40) { $slug = $slug.Substring(0, 40) }
    $outPath = "$brain\wiki\_inbox\$($t.d)\shincoder-s$($t.step)-$slug-$stamp-$sid.md"
    & $dispatcher -Department $t.d -Title "[Shincoder S$($t.step)] $($t.t)" -Prompt $t.p -Model "qwen3.6:latest" -OutputPath $outPath -Priority "high" 2>&1 | Out-Null
    $state.used[$t.t] = (Get-Date).ToString("o")
    $dispatched++
}

# State 保存
$jsonState = @{ used = $state.used } | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($stateFile, $jsonState, [System.Text.Encoding]::UTF8)

"$nowStamp - dispatched $dispatched shincoder tasks (inbox=$inboxCount)" | Add-Content $logPath -Encoding UTF8
Write-Host "shincoder_loop: dispatched $dispatched / available $($available.Count) (inbox=$inboxCount)"
