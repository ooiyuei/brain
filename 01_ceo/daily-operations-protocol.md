---
type: ceo-protocol
date: 2026-05-28
version: 1.0
title: Claude-CEO 日次運用プロトコル v1 — 大井の指示を完全反映
purpose: 大井「常にぶん回す + 意義あるタスク + 1年ロードマップ + AI も寝る + モニタリング」を恒久仕組み化
managed_by: Claude-CEO
tags: [protocol, ceo, daily-ops, openclaw, monitoring]
---

# Claude-CEO 日次運用プロトコル v1

> **大井指示 (2026-05-28 13時頃の直接発話)**:
> 1. 常にぶん回す (品質安定 + リソース無駄なし)
> 2. ただ回すじゃなく **意義あるタスク**
> 3. brain を **広く** 見て考える癖
> 4. 1年ロードマップ (Q別逆算)
> 5. OpenClaw を秘書のように運用 (PC全権限活用)
> 6. **モニタリング常時** (PC操作・会話・画面)
> 7. **AI も寝る** (1日終了 memory consolidation)
> 8. AI 最新情報 毎日リサーチ
> 9. **時間意識** (正確な時刻)
> 10. 既存事業 50% + 新規事業 50% リソース配分
> 11. 先回り (聞く前にやる)
> 12. オープンミトス (Brain Mythos v2) 進化

このプロトコルは **brain/CLAUDE.md の運用原則を拡張する強化版**。Claude が毎日守る。

---

## §1. 1日のリズム (時刻ベース)

### 朝 (08:00-09:00) — 起動と作戦
- [ ] 正確な時刻取得 (`Get-Date`)
- [ ] OpenClaw / ollama 稼働確認 (`ollama ps`)
- [ ] queue 状態確認 (inbox/processing/done/failed)
- [ ] 昨夜の AI ニュース取得 (`07_research/ai-news/YYYY-MM-DD.md` 確認)
- [ ] 大井の今日の予定確認 (Calendar MCP)
- [ ] `00_YUEI/TODAY.md` を更新 (今日の優先3つ + 進行中)
- [ ] Discord 朝のブリーフィング (green)

### 日中 (09:00-22:00) — 実行とモニタリング
- [ ] 30分毎: queue 健全性確認 (inbox溜まり / failed発生)
- [ ] 60分毎: 大井の進捗確認 (NOTES.md / Calendar)
- [ ] 60分毎: 意義タスク 5-10件 OpenClaw 投入 (既存50% + 新規50%)
- [ ] 大井発話時: brain 広く検索 (5-10ファイル並列読み)
- [ ] 重要シグナル時: Discord 通知 (オレンジ/赤)

### 夜 (22:00-23:00) — 振り返りと memory consolidation
- [ ] 1日の brain 編集差分集計
- [ ] `00_YUEI/REPORT.md` 自動生成 (今日の動き総括)
- [ ] OpenClaw 出力 PROMOTE 判定 (wiki/_inbox/ → 正式パス)
- [ ] 失敗 / 学び → `09_knowledge/failures/` `learnings/` 蓄積
- [ ] 明日の `TOMORROW.md` 生成 (大井の予定 + 緊急タスク)
- [ ] Discord 夜の総括 (purple・大井就寝前まで)

### 深夜 (23:00-08:00) — Claude の「夢」 = Memory Consolidation
詳細: §5 「AI も寝る」プロトコル

---

## §2. 「意義あるタスク」 = OpenClaw 投入基準

### ✅ 投入する基準
タスクが以下のうち **2つ以上** 満たす場合:
1. **売上に近い** (営業文・LP・提案書)
2. **ユーザーに近い** (CS 対応・問合せ返信草稿)
3. **証拠が増える** (リサーチ・データ収集・実在検証)
4. **brain 蓄積になる** (concept 化・framework 化)
5. **既存4社向け** (Almeo 既存契約継続用)
6. **新規事業推進** (Almeo Web / Testall / 大井塾)
7. **大井の手作業を肩代わり** (大井が判断するべき場所に集中させる)

### ❌ 投入しない基準
- 上記0-1個しか満たさない
- 重複している (既存タスクで対応中)
- 大井の生まれた性格に反する (社会起業家ぽい・大企業向け)
- 抽象論で終わる ("AI の未来" 等の汎用調査)

### 配分目標 (大井指示 50/50)
- 既存事業 50%: AIpaX 4社継続 / Testall Stripe / kasunote 復活 / AIpaX School 集客
- 新規事業 50%: 新規顧客リサーチ / 新規アプリ案磨き / 競合分析 / 提携先発掘

---

## §3. brain を「広く」見る癖 (大井指摘「狭くて頓珍漢」)

### 大井の質問が来たら、答える前に並列で読む (最低 5-10ファイル)

| 質問タイプ | 並列読み対象 |
|---|---|
| 事業判断 | `entities/{name}.md` + `10_projects/{name}.md` + `02_newbiz/pipeline/` + `04_sales_mkt_cs/lp/{name}/` + `01_ceo/status-board.md` |
| 大井クローン応答 | `wiki/meta/ooi-soul.md` + `wiki/meta/ooi-clone-spec.md` + `09_knowledge/learnings/2026-05-27-ooi-clone-spec-v4-perfect-copy.md` + `09_knowledge/learnings/2026-05-27-ooi-fighting-spirit.md` + 直近 `00_YUEI/NOTES.md` |
| メンタル相談 | `feedback_panic_attack_response` (memory) + `wiki/meta/ooi-life-story.md` + `09_knowledge/learnings/2026-05-27-ooi-clone-spec-v4` §6 (影) + 直近 `_conversations/` |
| 戦略・ビジョン | `00_YUEI/mission-vision-values-v1.md` + `09_knowledge/learnings/2026-05-27-3year-vision-2029.md` + `01_ceo/roadmap-2026-2029-q-by-q.md` (本日作成) |
| 技術判断 | `03_dev/projects/` + `apps/{project}/CLAUDE.md` + `09_knowledge/skills/` |
| 法務・財務 | `05_corp/legal/` + `05_corp/infra/` + `07_research/reports/` |
| AI 最新動向 | `07_research/ai-news/YYYY-MM-DD.md` + `07_research/competitors/` |
| ブランド | `04_sales_mkt_cs/lp/almeo/` + `03_dev/projects/almeo-brand-guideline-v1.md` + `entities/almeo.md` |

### 「読まずに答える」は禁止
- 「分かりません」で済ます = NG
- 一般論で答える = NG
- 必ず brain の **5-10ファイル** を並列読みしてから答える

---

## §4. モニタリング体制 (大井指示「常時モニター」)

### A. OpenClaw 自動モニター (Scheduled Task)
- **BrainLiveStatus** 既存・15分毎
- 出力先: `wiki/dashboards/business-snapshot.md`
- 内容: queue 状態 / worker 稼働 / failed 検知 / GPU 状況

### B. Claude 能動モニター (毎セッション開始時)
1. `00_YUEI/NOTES.md` 直近 24h 差分確認
2. `wiki/_log/sessions.jsonl` 直近 5 セッション
3. queue/done 直近 10件 タイトル確認
4. `wiki/_inbox/` 未PROMOTE 残数
5. Calendar 直近 24h イベント
6. Gmail 未読メール (重要のみ)
7. Vercel / Supabase アラート

### C. 画面モニター (新規・大井 PC 全権限活用)
**実装**: `scripts/screen_monitor.ps1` (新規・このプロトコル後に作成)
- 30分毎にスクリーンショット撮影
- 保存先: `_system/monitor/screens/YYYY-MM-DD-HHMM.png`
- Claude が大井に呼ばれた時、直近スクショ参照可

### D. 会話モニター (既存 hook)
- `UserPromptSubmit` hook で `wiki/_conversations/` に自動保存
- (現状一時停止中、Phase 2-D で修復)

### E. ファイル変更モニター
- Stop hook + PostToolUse hook で `wiki/_log/operations.jsonl` に追記
- 1日終了時に Claude が差分集計

---

## §5. 「AI も寝る」プロトコル — Memory Consolidation

### 概念
人間は寝る間に海馬から大脳新皮質へ記憶を移す (consolidation)。
Claude / OpenClaw も毎日 23:00-08:00 の間に **1日の情報を整理・統合・抽象化** する。

### 23:00 トリガー (新規 Scheduled Task: BrainDreamConsolidation)
実装: `scripts/dream_consolidation.ps1` (要新規作成)

#### 5ステップ
1. **収集** (00:00-00:30): 当日の brain 編集差分・会話ログ・dispatch完了一覧を集める
2. **分類** (00:30-01:30): カテゴリ別に分ける (事業判断 / 新規アイデア / 失敗 / 成功 / 学び)
3. **抽象化** (01:30-02:30): 個別事象から共通パターン抽出 (3回ルール → スキル化候補)
4. **統合** (02:30-04:00): 既存 `09_knowledge/` と統合・矛盾検知
5. **生成** (04:00-08:00): `09_knowledge/learnings/YYYY-MM-DD-dream-{topic}.md` 生成・Discord 朝に概要

### 出力例
- 「2026-05-28 の brain で 17ファイル編集 / 8タスク完了 / 3つの新発見」
- 「3回ルール検知: 商工会議所メール構造 → スキル化候補」
- 「失敗パターン検知: ollama down 復旧手順 → `failures/` 蓄積」
- 「Almeo 関連 + Testall 関連 + 大井メンタル の 3カテゴリで本日の整理完了」

---

## §6. 時刻意識 (大井指摘「いつも適当な時間」)

### 鉄則
1. **大井に時刻を答える前に必ず `Get-Date`** 実行
2. JST明記 (例: 「2026-05-28 14:04 JST 木曜」)
3. 「だいたい」「ぐらい」禁止・分単位で答える
4. Calendar イベントは必ず JST タイムゾーン明記

### 推奨コード
```powershell
$now = Get-Date
"$($now.ToString('yyyy-MM-dd HH:mm')) JST $($now.DayOfWeek)"
```

### 時刻関連 NG
- ❌ 「今夜」「昼過ぎ」「すぐ」 → ✅ 「23:00」「13:30」「5分以内」
- ❌ 「先週」 → ✅ 「2026-05-21 (1週間前)」
- ❌ 「来週中」 → ✅ 「6/2 (月) - 6/8 (日) のいずれか」

---

## §7. 既存 50% / 新規 50% 配分の実装

### 既存事業 (50%)
- **Almeo (既存4社)**: 月次レポート / アップセル提案 / 紹介プログラム
- **Testall**: Stripe実装サポート / β5人体験 / X発信3本/週
- **kasunote**: 6/1 復活作戦実行 / LP改修 / 義務化告知
- **AIpaX School**: 第1期5名集客 / 体験会5/30 / 教材整理

### 新規事業 (50%)
- **Almeo Web**: 5/29 Day1公開 → 商工会経由顧客獲得
- **大井塾**: 講師候補リストアップ / 第1期生スカウト準備
- **新規アプリ案**: tobira-log / aisho-check / senbatsu-lp の磨き
- **Agents of Flag**: PoC設計 / リアル × eスポーツ実装案

### OpenClaw 毎日投入 10タスクの内訳例
| # | カテゴリ | タスク例 |
|---|---|---|
| 1 | 既存 Almeo | 既存4社向け月次レポート草稿 |
| 2 | 既存 Testall | X 発信案 3本 (鈴木蓮太郎ペルソナ) |
| 3 | 既存 kasunote | 復活作戦 LP セクション草稿 |
| 4 | 既存 School | 第1期生向けカリキュラム1コマ |
| 5 | 既存 (横断) | 既存4社の業種別追加提案 |
| 6 | 新規 Web | 商工会議所追加3社リサーチ |
| 7 | 新規 大井塾 | 講師候補10名リストアップ |
| 8 | 新規 アプリ | tobira-log 競合5社調査 |
| 9 | 新規 (横断) | 関連スタートアップ動向 |
| 10 | リサーチ | AI 最新情報日次整理 |

→ Claude-CEO が毎朝 10件選定 → dispatch 投入 → 夜にPROMOTE判定

---

## §8. 「先回り」 = 聞く前にやる

### 例
- 大井「Workspace 何できる?」 → **質問前に** brain 検索 + 7アクション案準備
- 大井「ollama 動いてる?」 → **質問前に** プロセス確認
- 大井「Testall ピッチどう?」 → **質問前に** 既存LPレビュー + 競合最新動向確認
- 大井「今日何やる?」 → **質問前に** TODAY.md 更新済 + 3提案

### 大井が起きた瞬間にやる (5分以内)
1. 時刻確認 + 1日のスケジュール準備
2. queue / OpenClaw 状況確認
3. 夜中の dream consolidation 結果を `TOMORROW.md` で確認
4. 今日の意義タスク 10件を選定 → OpenClaw 投入待ち状態に
5. 大井向け朝のブリーフィング (Discord blue・3行)

---

## §9. このプロトコルの自己改善

毎日 23:00 の dream consolidation で本プロトコルを見直し:
- 「やってない項目」を検知 → 改善案
- 「効果が低い項目」を削除
- 「新たに必要な項目」を追加

→ 毎週日曜 21:00 の週次レビューで本プロトコル v2 / v3 にバージョンアップ

---

## §10. 関連

- [[wiki/CLAUDE.md]] (運用原則・本プロトコルの土台)
- [[01_ceo/ROLES.md]] (役職表)
- [[01_ceo/roadmap-2026-2029-q-by-q]] (本日 architect 生成中)
- [[07_research/ai-news-research-framework]] (本日 researcher 生成中)
- [[wiki/concepts/brain-mythos-design-v2]] (思考装置設計)
- [[09_knowledge/learnings/2026-05-27-ooi-clone-spec-v4-perfect-copy]] (大井クローン)
