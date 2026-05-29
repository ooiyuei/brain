---
type: ceo-status-board
date: 2026-05-27
updated_at: 2026-05-27 08:35
generator: Claude-CEO (大井指示の全社監査)
status: 監査完了・要対応シグナル3件
---

# 全社状況ステータスボード (2026-05-27 08:35 監査)

> **大井指示「全部の事業の状況をキャッチアップしてレビュー」に対する Claude-CEO の全方位監査結果。**
> 監査範囲: 全15+事業 / OpenClaw / 新規事業部 / brain活用度 / git / Vercel / Gmail / hook / 別セッション

---

## 🚨 緊急対応3件 (大井が見落としてる重大シグナル)

### A. Supabase Testall プロジェクト pause された (5/22)
- **Project ID**: `qpckkyjawjmeumnynynt`
- **状態**: 7日間活動なしで **自動 pause** (5/22 Supabase からメール)
- **影響**: localhost:3010 開発・Vercel production 接続に支障
- **次のアクション**: https://supabase.com/dashboard/project/qpckkyjawjmeumnynynt から unpause (90日以内)
- **Pro へのアップグレード推奨** (今後の自動 pause 防止)

### B. Supabase Critical: RLS 無効テーブル検知 (5/17検知, 5/20メール)
- **検知**: testall プロジェクトに **Row-Level Security 無効のテーブル** あり
- **意味**: 「Project URL を知る誰でもデータ読取/編集/削除可能」 = **データ漏洩リスク**
- **アラート名**: `rls_disabled_in_public`
- **対応**: https://supabase.com/dashboard/project/qpckkyjawjmeumnynynt/advisors/security から修正

### ⚪ C. Vercel Testall 本番デプロイ失敗 ×2 → **自己解決済み (訂正)**
- 5/25 03:54 失敗 (`dpl_AoKRG...`): commit `9210996` "fix: 第2回 code-review High3+Medium1" by `Yoei Ooi <ooi@local>` → 大井がローカル commit→push→build fail
- 5/25 03:57 失敗 (`dpl_2BVfP...`): commit `f38c05b` "fix(dark): bg-white を dark で cream-100" → 同じく fail
- **その後 c002b0c (5/26 push) で fix されて main は通っている** → 緊急対応不要、Gmail 未読のままだが実害なし
- 注: 別 Claude セッションが PR #1 (`docs: 事業案 v3.0 — 逆算設計OS / 25分ブロック / マス層へ再定義`) でブランチ作業中、preview deploy が building

---

## 📊 主力5事業の現ステップ (シンコーダー11ステップ適用)

| 事業 | 現Step | 状態 | 直近の動き | 次の1手 |
|---|---|---|---|---|
| **Testall** | **8-10** (運用+PMF判定段階) | 🟢 v0.6+, 別Claude Code セッションが PR #1 で a11y強化中 | 5/26 PR#1作成・複数Vercel deploy | **Stripe課金 + Supabase pause解除 + RLS修正** (5/28 Calendar設定済) |
| **AIpaX** | **8-10** | 🟢 4社契約継続中 | 中堅3社向け個別メール本日完成 (PROMOTE) | **Sean Ellis Test 4社 (6/3 Calendar) + 5社目クロージング (今夜20:00)** |
| **AIpa Web** | **3-4** (広告需要検証) | 🟡 商工会メール3パターン Gmail下書き済 | 商工会経由営業文 v2 本日完成 | **X広告1万円投化 → CPA測定 (5/31判定)** |
| **AIpaX school** | **5-6** | 🟡 第1期5名募集中 | 動きなし (5/19 entity 更新止まり) | 第1期5名集客 + 体験会 (5/30) |
| **EEMUS** | **2** | 🟢 夢AWARDピッチv3 PROMOTE済 | ピッチv3 (5/27朝) | **夢AWARD骨子v1 (5/29 14-17 Calendar設定済)** |

---

## 📊 既存MVP稼働中アプリ (Tier採点済)

| アプリ | URL | Tier | GitHub | 現状 |
|---|---|---|---|---|
| Testall | testall-git-main-... | A 75点 | github.com/ooiyuei/testall | 開発活発 |
| kasunote | kasunote.vercel.app | A 72点 | (private/不明・gh で見えず) | **2026/10義務化で需要爆発予定** |
| juken-os | juken-os.vercel.app | A 70点 | (private/不明) | Testall に進化、参考保持 |
| yakki-check | yakki-check.vercel.app | B 67点 | (private/不明) | 薬機法AI判定 |

---

## 🔥 既存MVP 4個の実態 (Vercel deploy 確認 2026-05-27 8:50)

| アプリ | 最終 deploy | 状態 | 評価 |
|---|---|---|---|
| **Testall** | 2026-05-27 (最新) | 🟢 **アクティブ開発中** (PR#1 building) | 主戦場 |
| **kasunote** | 2026-04-01 (1.5ヶ月前) | 🟡 **塩漬け** (auto: daily sync のみ) | **2026/10義務化で復活必須・最優先** |
| **juken-os** | 2026-04-08 (約1.5ヶ月前) | 🟡 **塩漬け** | Testallに進化済、参考保持 |
| **yakki-check** | 2026-04-03 (約1.5ヶ月前) | 🟡 **塩漬け** | B Tier、後回し |

→ **「既存4MVP稼働中」は誤認だった。実態はTestallだけアクティブ、他3つは4月以降止まってる**

### kasunote 復活作戦 (今日のセッションで決定)
- 価格 980円→2,980円
- LP更新 (2026/10義務化緊急訴求)
- SEO「カスハラ 義務化 2026」集中強化
- X広告 月1万円常時投化
- 6/1 10-16時 Calendar 設定済
- LP構成案 OpenClaw dispatch 中 (9b9e35aa、9:00頃完成)

---

## 🔥 Vercel に未登録のアプリ30個 (brain entities に無い)

Vercel team_3HJIyzwuV3Jou9KUAwoi5W2B に **38プロジェクト** 実在。brain entities にあるのは 4個 (testall/kasunote/yakki-check/juken-os) のみ。

**未登録30個 (推測カテゴリ別)**:
- **規制系**: tokusho-check (特商法) / rodocheck (労働) / zairyu-check (在留) / kenkyo-alert (建設?) / kabe-sim (壁工事?) / koujin
- **校務系 SchoolOS**: schoolos-attendance / -club / -contact / -grades / -schedule / -survey
- **教育系**: oyanote (親) / hoiku-draft (保育) / jyuken-ai-app
- **業務系**: bizflow-ai / genba-note (現場) / genka-check (原価) / gessha-note (月謝) / hacchu (発注) / hiyareport (ヒヤリ) / timebill / ai-consul / meeting-app
- **その他**: banana-juice / sleep-calc / sorasido / jintori-walk / apex-labor / mushikingi / taxlink-jp / finance / app

→ **大井が過去に作って放置している可能性**。次セッションで棚卸し推奨 (Vercel API で各 deploy 状況を一括取得 → entities にあるもの・無いものの突き合わせ)。

---

## ⚙️ OpenClaw 稼働状況 (リアルタイム)

| 指標 | 値 |
|---|---|
| Scheduled Task (WorkerLight/Heavy/TaskBoard/Harvest/QueueGuard) | ✅ 全て LastRun 0x0 / NextRun 1分以内 |
| Ollama | ✅ Running |
| queue inbox | 6件 (5/27朝の TaskBoard 投入分) |
| processing | 1件 (再dispatch `0c3cff5d` は完了済、別の長文ジョブ処理中) |
| done 累計 | 908件 (5/27朝から +23件) |
| failed | 0件 |

### 再dispatch 3件の結果
- ✅ **`1321e603`** (X広告整形) → 完了 8:25、`04_sales_mkt_cs/content/` に5,134字
- ⏳ **`43c2d51d`** (静岡10社実在版) → inbox待機中 (5h以上経過、要確認)
- ✅ **`0c3cff5d`** (月収100万カスタム) → 完了 7:50、`01_ceo/decisions/` に5,319字

---

## 🎯 PROMOTE 判定状況 (今朝の worker 出力 11件)

### ✅ 本日 PROMOTE した4件 (Claude-CEO判定)
- ✅ aipa-web 商工会メール3パターン (5/26着弾) → `04_sales_mkt_cs/leads/aipa-web/`
- ✅ aipa-web LP ヒーロー3案 → `04_sales_mkt_cs/lp/aipa-web/`
- ✅ aipa-web モニター契約書テンプレ → `05_corp/legal/contracts/`
- ✅ 夢AWARD ピッチv3 → `02_newbiz/pitch-eemus/`

### ✅ 監査セッションで追加 PROMOTE 3件
- ✅ aipax 中堅3社個別アプローチメール (5/27朝) → `04_sales_mkt_cs/leads/aipax/2026-05-27-3industries-approach-mails.md`
- ✅ 紹介プログラム 5事業横断ルール (5/27朝) → `01_ceo/decisions/2026-05-27-referral-program-5businesses.md` (法務テンプレ含む完全版)
- ✅ Testall 1日45分プラン自動生成ロジック設計 (5/27朝) → `03_dev/projects/2026-05-27-testall-45min-plan-logic.md`

### 🔄 KEEP (重複・要統合)
- aipa-web 商工会経由営業文 v2 (5/27朝) → 既存の3パターン (A/B/C) と内容重複。**1本に統合**して `04_sales_mkt_cs/leads/aipa-web/` に置き換え推奨 (大井判断待ち)

### ⏳ 未判定 (今朝の worker 出力で要レビュー)
- bank-業務委託契約書--β契約済企業向け運用版- (corp)
- bank-β顧客100名募集lp- (marketing)
- bank-出店候補エリア3か所-物件調査詳細- (newbiz)
- bank-既存4社オンボーディング30日プラン- (newbiz)
- bank-機材リスト-原価試算- (newbiz)
- bank-卒業後3年後ストーリー- (newbiz)
- shincoder-s9-ファネル分析- (corp、文字化け)

---

## 🏢 各部署稼働度 (Phase 2-A/B以降)

| 部署 | _log 最終更新 | 今日のアクション |
|---|---|---|
| 01_ceo | 8:10 | 16件 (Phase 2 / Plan承認 / 全宿題並列 / 30案 / Testall handoff / monitoring) |
| 02_newbiz | 8:10 | 4件 (5社目状況 / 横展開 / 30案 / 11ステップ診断 / tobira-log PRD) |
| 03_dev | 7:01 | 2件 (Testall ハンドオフ / 45min plan logic 配置) |
| 04_sales_mkt_cs | 7:43 | 5件 (5件PROMOTE / 商工会下書き / LP3案 / X広告再dispatch / 3社個別メール) |
| 05_corp | 7:30 | 2件 (モニター契約書 / 紹介プログラム) |
| 06_secretary | 7:31 | 8件 (RC環境 / queue整理 / Calendar 5 / Gmail 3 / SFC論点) |
| 07_research | 7:02 | 2件 (静岡10社再dispatch / tobira-log 競合分析) |
| 08_openclaw | 7:03 | 1件 (queue滞留事故対応) |
| 09_knowledge | 7:43 | 7件 (大井統合像v2 / 横展開シナジー / シンコーダー11ステップ / PMF / CPA / スキル化 / 30案) |
| _system | 7:03 | 1件 (Phase 2 ログ) |

→ **全部署稼働中**。新規事業部 (02_newbiz) は今朝から特に活発。

---

## ⚠️ Phase 2-D 改善必須項目 (発覚)

### hook 動いてない問題
- sessions.jsonl 最終: 6:27 (今 8:35、**約2時間止まってる**)
- operations.jsonl 最終: 5:18 (**3時間以上止まってる**)
- 仮説: **Mac から Remote Control 経由で繋いだ後、Win側の hook が発火してない**
- 影響: 機械ログ未取得 → 過去操作の検索が効かない
- 対応: Phase 2-D で Remote Control 経由でも hook 発火する仕組み調査

### OpenClaw filename too long エラー
- `openclaw agent --message $finalPrompt` でWindows引数制限 (8191字) 超え → Ollama 直叩きフォールバック
- 影響: agent モードの複数ターン自律実行を活かせていない
- 対応: `prompt` を一時ファイル経由 (`--message-file`) に変更

### Vercel 38プロジェクト vs brain entities 20件のズレ
- 18件以上のアプリが entities に未登録
- 死んでるアプリの整理 + 価値あるアプリの再棚卸し必要
- 対応: 次セッションで Vercel API + Vercel runtime logs で各アプリの直近活動を確認

### BrainAutoReview の自動投入は永久停止 (再確認)
- 5/25 の 1500件一気投入事故再発防止
- 手動でのみ実行、最大 100件/回 ルール

---

## 🎯 大井に今すぐ判断依頼 (3件)

### 1. Supabase testall プロジェクトを unpause するか
- 影響: localhost:3010 / Vercel production 復活
- 推奨: 今すぐ unpause + RLS 修正 + Pro アップグレード検討
- **対応者: 大井 (Supabase dashboard で1クリック)**

### 2. AIpa Web 商工会経由営業文 v2 と既存3パターン の統合方法
- v2 (5/27朝) は 構造化・補助金ロジック含む
- 既存 (5/26着弾) は 3パターン (実績/地域貢献/緊急性)
- 推奨: v2 を本体にして、3パターン分の冒頭バリエーション化
- **対応者: Claude (大井OKならすぐ統合)**

### 3. Vercel 38プロジェクト棚卸し
- 価値あるもの → entities に追加・育成
- 死んでるもの → Vercel から削除 (容量節約)
- 推奨: 次セッションで棚卸し専用時間確保 (1時間)
- **対応者: 大井判断 + Claude実行**

---

## 関連ファイル

- 主力5事業診断詳細: [[01_ceo/decisions/2026-05-27-shincoder-for-5businesses]]
- フレームワーク: [[09_knowledge/frameworks/shincoder-11steps-roadmap]]
- 新規事業30案: [[02_newbiz/ideas/2026-05-27-30-new-business-candidates]]
- 上位3案磨き: [[02_newbiz/pipeline/2026-05-27-top3-refined]]
- 大井統合像: [[09_knowledge/learnings/2026-05-27-ooi-integrated-portrait]]
- 横展開シナジー: [[09_knowledge/learnings/2026-05-27-cross-business-connections]]
