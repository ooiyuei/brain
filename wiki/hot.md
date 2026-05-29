---
type: hot-cache
updated: 2026-05-27 22:10
structure_version: 2
managed_by: Claude (must update every session)
---

# 🔥 hot.md — 直近コンテキスト & 先回りヒント貯蔵庫

> **このファイルは Claude が毎セッション読み・毎セッション更新する。**
> 単なる「直近の事実」ではなく「Claude が次に動くために必要な全情報」を集約。
> 詳細スナップショット (静的) → [[dashboards/business-snapshot]]
> 大井プロファイル入口 → [[meta/ooi-profile-index]]
> OpenClaw稼働状況 → [[dashboards/openclaw-activity]]

---

## 🌅 Today（2026-05-27 朝の作戦）

**絶対やる1個**: 夢AWARD 応募骨子を書く（残11日・今週末デッドライン）
**一言**: 骨子の30分が残11日の全部を動かす。

## ☀️ Midday（12:30 昼チェック）

**日付**: 2026-05-29
**進捗**: 夢AWARD骨子 ❌未着手（14:00予定） / 静岡財団TEL ❌未着手 / Workspace設定 ❌未着手
**PDCA**: inbox 0件昇格・3件削除（BG系全滅：qwen3:8bがooi profileを誤出力する根本バグ確認）
**午後**: ①14:00 夢AWARD骨子セッション（大井）②静岡財団TEL（054-254-4511）③Workspace設定（Claude）④BG-Entities promptを qwen3.6:latest に昇格して再設計
**詳細**: [[_routines/midday-20260529]]

## 🌙 Tomorrow（2026-05-30）

**最優先**: **夢AWARD応募骨子を書く** — 6/7締切・残**8日**。5日連続未着手。今日こそ骨子30分。大井のみ（Claudeは「骨子出して」で叩き台即生成）
**サブ①**: 静岡産業振興財団 TEL（054-254-4511）— 最大200万・残8日。午前中に電話1本。大井のみ。
**サブ②**: Mac obsidian-git 自動push設定（[[00_YUEI/工場-使い方]]）— 大井1クリック → 外出先から工場フル稼働
**詳細**: [[_routines/evening-20260529]]

---

## 📍 今ここ (Live State)

**Last session**: 2026-05-29 夜 — 夜ルーティン (工場ブリッジ/git復旧/夜メモ生成)
**Last touched files**:
- `brain/wiki/_routines/evening-20260529.md` (夜メモ生成)
- `brain/wiki/_tasks/done.md` (今日の完了5件 archive)
- `brain/wiki/hot.md` (Tomorrow section 5/30更新)

**現在の Mode**: 夜ルーティン完了
**完了**: 工場ブリッジ/git同期/queue heal/280ファイル復旧/再起動耐性 — 全部Claude
**未完**: 夢AWARD骨子（6日連続・明日絶対）/ 静岡財団TEL / Mac obsidian-git自動push

---

## 🚨 今日 (2026-05-27) 必ずやる

> 期限が近い / 大井の手が必要 / 放置すると損失。

| # | やること | 期限 | 担当 | 状態 |
|---|---|---|---|---|
| 1 | 夢AWARD骨子 (5日連続未着手) | 5/29 14時 (Calendar済) | 大井のみ | ❌ 持ち越し |
| 2 | AIpaX 5社目クロージング状況確認 | 5/28 (昨夜20時 Calendar) | 大井 | ⏳ 5/28へ |
| 3 | AIpa Web inbox 9件昇格判定 | ✅完了 | Claude | ✅ 完了 |
| 4 | SFC AO論点メモ | 5/28 19時 (Calendar済) | 大井+Claude | ⏳ ドラフト完成済み |
| 5 | queue/inbox 1521件滞留解消 | ✅完了 | Claude | ✅ 完了 (archive+AutoReview停止) |
| 6 | 会社インフラ確立 | ✅完了 | 大井 | ✅ 完了 (ドメイン+G Suite+Slack+Notion) |

---

## 💡 Claude からの先回り提案 (3案)

> 大井から指示が来てない時、Claude が「これやっとこ」と能動的に提案する候補。

### A. AIpa Web inbox 5件昇格判定 (推奨)
- 5/26 着弾済み: 商工会メール3パターン・静岡企業10社リスト・LP最適化3案・X広告コピー5案・月10万モニター契約書テンプレ
- Claude が `wiki/_inbox/_reviews/marketing/` か `newbiz/` を読んで PROMOTE/KEEP/ARCHIVE 判定 → 該当ファイルを `wiki/{正式パス}/` へ移動
- 効果: 5/26 の成果物が今日中に正式蓄積、AIpa Web の営業準備が一段進む
- 工数: 15-30分

### B. 大井プロファイル統合の品質チェック
- [[meta/ooi-profile-index]] を作ったが、各 ooi-* ファイル間の矛盾チェックは未実施
- ooi-deep-synthesis-2026-05-20 を最新マスターとして、矛盾点があれば旧文献に「過去の認識」タグ
- 効果: 大井クローン応答の精度向上

### C. シンコード/森岡素材のスキル化
- 5/26 取り込んだ森岡続編・AIコーディング教科書・シンコードraw が `_inbox/` 5件
- スキル化候補: 「明日使う1人」フレーム、「絶対に買う1人」フレーム、F1ストーリーテリング雛形等
- 効果: 営業文・LP・X投稿で常時呼び出せるテンプレ完成

---

## 📥 新着インテリ (取り込み待ち)

> `.raw/` `_inbox/` に届いてるが未消化のもの。

- `wiki/_inbox/ingest/2026-05-27-0540-manifest.md` — `.raw/` 15件の取り込み manifest (新規生成)
- `wiki/_inbox/aipa-web/` (5/26時点で5件) — 契約書テンプレ・X広告・LP案・企業リスト・商工会メール
- ChatGPT 履歴系: notion-export-2026-05-19 (ファイル名 cp932 化け、対処要)

---

## 🎯 直近30日の太線 (shincoder-actions より)

- 期限: **2026-06-21** までに月収100万円 (残25日、現在 AIpaX 約20万/月)
- ギャップ: **80万/月**
- 主戦場: AIpaX 5社目クロージング + AIpa Web モニター獲得 + 中規模ビジコン入賞
- 詳細: [[meta/shincoder-actions-for-ooi-2026-05-25]]

---

## 🎚️ 認知プロファイル (Claude 対話で常に意識)

- 大井の WISC: 言語理解150・視空間140・流動性推理135 / WM110・処理速度115
- 「アイデア生成 >> 実装処理」 → 外部臓器 (Obsidian/Claude/相方) に流す方が早い
- 「努力不足」って感じる時は実は「処理キャパオーバー」。Claude は dispatch で受け止める
- 詳細: [[meta/ooi-deep-synthesis-2026-05-20]]

---

## 📂 入口リスト (Claude が引くべき主要ファイル)

| 用途 | 入口 |
|---|---|
| 全体地図 | [[index]] |
| 静的事業スナップショット | [[dashboards/business-snapshot]] |
| 大井プロファイル統合 | [[meta/ooi-profile-index]] |
| OpenClaw 稼働 | [[dashboards/openclaw-activity]] |
| 部署フロー | [[_routines/department-flow]] |
| 3本柱戦略 | [[meta/three-pillars]] |
| 直近の優先順位 (アクション) | [[meta/shincoder-actions-for-ooi-2026-05-25]] |

---

## 🛠️ hot.md 保守ルール (Claude へ)

1. セッション開始 = まず読む
2. 「今ここ」「今日必ずやる」「先回り提案」「新着インテリ」の4セクションは **動的**。毎セッションで更新する責任あり
3. 太線セクション (`認知プロファイル` 以降) は **準静的**。週1で見直す
4. ファイルが400行超えたら、過去情報を `dashboards/business-snapshot.md` に圧縮
5. 静的詳細は `dashboards/` か `meta/` に外出し
