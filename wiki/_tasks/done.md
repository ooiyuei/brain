---
type: task-done
tags: [tasks, done]
updated: 2026-05-18
---

# Done — 完了アーカイブ

> 夜ルーティンが today.md から `- [x]` 完了タスクを日付ごとに移動。
> 直近30日分だけ保持、それ以前は月次でweekly/monthlyに統合。

## 2026-06-W1（6/1-7）

### 2026-06-05

- [x] **昼PDCAレビュー**（12:30 / Claude）: 2件昇格（AIpaX想定問答15選→`marketing/aipax-closing-qa-20260604`・AIpaX契約書β→`05_corp/aipax-contract-template`）・1件再dispatch（EEMUS Stripe設定の事業説明誤認識修正）・3件削除（ハルシネーション骨子/架空企業リスト/テンプレ未入力CF）

### 2026-06-03

- [x] **OpenClaw 24h自走 根治オーバーホール**（深夜〜今朝・Claude/Opus 4.8 全権委任）: qwen3.6削除・qwen3:8b一本化・13件恒久修正・実証完了。8→48件/時、クラッシュゼロ。→ `09_knowledge/failures/2026-06-03-openclaw-24h-自走-根本原因と恒久対策.md`
- [x] **昼PDCA実行**（12:30 / Claude）: 1件昇格（Testall vs Studyplus比較→`wiki/research/competitors/`）・42件削除（夢AWARDストーリー30本+架空企業リスト3+重複etc）

### 2026-06-02

- [x] **昼PDCA実行**（12:30 / Claude）: 1件昇格（AIpa Web静岡中堅企業リスト→`research/aipa-web-shizuoka-companies-2026-06-02.md`）・10件削除（Stripe qwen3:8b×4+重複×6）

### 2026-06-01

- [x] **昼PDCA実行**（12:30 / Claude）: 1件昇格（AIpa Web静岡中堅企業リスト→research/）・10件削除（qwen3:8bバグ3+重複7）⚠️ qwen3:8b worker が ooi-yuei.md を出力するバグ確認

## 2026-05-W4（5/25-31）

### 2026-05-31

- [x] **昼PDCA実行**（12:30 / Claude）: 2件昇格（夢AWARD骨子v3・AIpaXクロージング想定問答15選）・53件削除（ハルシネ企業リスト19+Studyplus重複7+ペルソナ15+Stripe11+EEMUS1）
- [x] **夜PDCA実行**（22:00 / Claude）: 2件昇格（AIpaX80万提案書・EEMUS夢AWARDストーリー）・225件削除（shincoder文字化け197+portfolio-prioritizeハルシネ11+stripe1+studyplus2+80man重複14）

### 2026-05-30

- [x] **昼チェック実行**（12:30 / Claude）: inbox 9件削除（studyplus比較7件=価格ハルシネーション、stripe-setup2件=事業理解ゼロ）。昇格0件。

### 2026-05-29

- [x] **工場ブリッジ `factory_bridge.ps1` 構築+テスト**（Claude）: Mac→OpenClaw自動投入・二重防止・受付レシート機能
- [x] **headless git同期 `sync_brain.ps1` 構築**（Claude）: Obsidian閉でも Mac↔Win 4分毎同期・競合時Discord通知
- [x] **queue ヒール**（Claude）: failed10件・ゾンビ2件アーカイブ、worker再稼働確認
- [x] **brain 12日分・280ファイルをGitHubへ push**（Claude）: 5/17〜停止してたremote復旧、local==remote==最新
- [x] **再起動耐性設定**（Claude）: 全同期タスクに StartWhenAvailable 付与

### 2026-05-28

- [x] **昼チェック実行**（12:30）: wiki/_inbox/ 巡回 3件昇格・3件削除。[[research/testall-vs-studyplus-planning-2026-05-28]]・[[research/aipa-web-market-trend-2026-05-28]]・[[marketing/aipax-closing-qa-2026-05-28]] 昇格。corp/dev 3件は品質不足で削除。
- [x] **AIpa Web inbox 5件昇格判定**（完了 / 5/28）: 上記昼チェック内で実施済み。

### 2026-05-27

- [x] queue/inbox 1521件 archive (BrainAutoReview 5/25誤投入・`_archive/inbox-purge-2026-05-27/`)
- [x] BrainAutoReview Disabled維持、BrainWorkerLight/Heavy 再Enable
- [x] Mac Remote Control 環境構築 (Claude Code CLI v2.1.150 インストール)
- [x] Phase2-A/B: 9部署+大井ホーム(00_YUEI) フォルダ物理化、ROLES.md正本作成
- [x] AIpa Web inbox 9件 PROMOTE (商工会メール3p/LP3案/契約書/X広告/AIpaX Q&A/商工会詳細版)
- [x] Calendar 5件追加 (夢AWARD 5/29/SFC AO 5/28/AIpaX 5社目 5/27/kasunote復活 6/1/Testall Stripe 5/28)
- [x] Gmail 下書き 6件 (商工会A/B/C + 商工会議所3拠点)
- [x] Notion 事業DB 4案登録 (tobira-log/aisho-check/senbatsu-lp/大井塾)
- [x] 大井統合像v2再合成、横展開シナジー発見 (`09_knowledge/learnings/`)
- [x] 大井クローンv4 (spec 46KB/JSONL 36例/実装手順書) 完成
- [x] SFC AO 5論点ドラフト、AIpaX 5社目 closing状況整理
- [x] Almeo MVV「熱狂を、つくる。」確定 + ロゴv4コンセプト
- [x] Testall ピッチ 森岡レビュー + 勝ち筋3軸 整理
- [x] 新規事業30案 → 上位3案 business-refiner 磨き完了
- [x] 会社インフラ確立: ドメイン+Google Workspace+Slack+Notion 同日契約

## 2026-05-W3（5/18-24）

### 2026-05-19

- [x] モニター自動生成 5本完了（05:10〜05:20）— 競合動向/市場シグナル/ビジコン締切/プロジェクト動向/朝の問い
- [x] 昼のPDCAレビュー完了（12:30）— inbox昇格5件（IPAK-darts LP/フルーツソースLP/EEMUS更新提案/Testall深掘り/ビジコン整理）、削除2件（EEMUS・和コウチャイはprompt改善要）

### 2026-05-18

- [x] モニター自動生成 5本完了（05:10〜05:20）— 競合動向/市場シグナル/ビジコン締切/プロジェクト動向/朝の問い
- [x] 昼のPDCAレビュー完了（12:30）— OpenClaw成果物15件昇格・1件削除。wiki/marketing/・wiki/research/・wiki/concepts/ へ振り分け完了

## 2026-05-W2（5/11-17）

（先週分のアーカイブ）

## 関連
- 今日: [[_tasks/today]]
- 週次レビュー: `wiki/_routines/weekly-*.md`
