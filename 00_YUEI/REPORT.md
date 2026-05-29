---
type: yuei-report
date: 2026-05-29
updated: 2026-05-29 09:40
managed_by: Claude-CEO
---

# Claude-CEO 日次レポート（2026-05-29）

> 「今日 brain で何が動いたか」を1分で。

---

## 🏭 今日の主役：工場（OpenClaw）を Mac から動かせるようにした

大井の指示「Mac の Obsidian で brain を触って工場を動かしたい・分断しないように・再起動から復旧」に対応。

### 作ったもの（2本の自走スクリプト）
1. **`scripts/factory_bridge.ps1`**（`BrainFactoryBridge` 3分毎）
   - `00_YUEI/工場.md` の箇条書きを読んで OpenClaw queue に自動投入
   - `@部署` `!優先度` タグ対応・**ハッシュ台帳で二重投入防止**・`工場-受付.md` にレシート
   - テスト済み: Mac想定の1行 → dispatch → idempotent（再実行で new=0）確認
2. **`scripts/sync_brain.ps1`**（`BrainGitSync` 4分毎）
   - **Obsidian を閉じていても** Mac↔Windows を git で同期（commit→pull --rebase→push）
   - 競合時は自動マージせず安全中断＋Discord通知

### 直した分断
- **GitHub remote が5/17で止まっていた（12日間 push ゼロ）** = Mac/Winが割れる寸前
- → brain 12日分・280ファイルを本日 commit+push。**local == remote == 最新** に復旧
- → `.gitignore` に queue/・node_modules/・per-machine .obsidian UI を追加（同期衝突の根を断つ）
- 同期の正体は **obsidian-git プラグイン**（Obsidian Sync ではない）と判明

### 大井がやる1アクション
- Mac の obsidian-git を「自動 commit + 自動 push」に（[[00_YUEI/工場-使い方]]）。これで外から工場フル稼働。

---

## 🩹 工場のヘルス回復（再起動後）

- failed 10件・processing ゾンビ2件（5時間放置）をアーカイブ → queue クリーン
- heavy/light worker 稼働確認（qwen3:8b ロード中、light は昨夜 "Ollama not reachable" で落ちてたが ollama 復帰済→自己回復）
- 全同期タスクに `StartWhenAvailable`（スリープ/再起動からの取りこぼし防止）

---

## 📊 工場の稼働状況（正直版）

| 項目 | 状態 |
|---|---|
| Ollama | 🟢 qwen3:8b 稼働 |
| Brain スケジューラ | 🟢 37タスク Ready（worker/monitor/filler 群） |
| queue inbox | 約70件処理中（X投稿・想定問答・助成金 等） |
| **wiki/_inbox 未昇格** | 🟡 **544件**（marketing237 / newbiz195 / corp75 / research23 / dev13） |

**結論**: 生産は十分回ってる。ボトルネックは**「作った成果物のレビュー・昇格」が追いついてない**こと。
工場をこれ以上ぶん回すより、まず **544件から価値あるものを選別・昇格**するほうが効く。「重要なやつ昇格して」と言えば着手する。

---

## 📌 持ち越し（前回 5/27 REPORT から未消化）

- ❌ **夢AWARD 骨子**（6/7・最優先・今日14時ブロック）
- 🔥 **Supabase Testall pause / RLS無効**（5/22〜）— 大井のクリック必要・未確認なら今日対応
- 💰 AIpaX 5社目クロージング・既存4社 紹介プログラム

---

## 🔮 次に Claude が回せること（指示があれば）
1. 夢AWARD 骨子の叩き台生成
2. wiki/_inbox 544件の選別・昇格（部署別バッチ）
3. 最優先デリバラブル5本を並列生成（静岡TELスクリプト・AIpaX想定問答 等）

---

## 関連
- 今日: [[00_YUEI/TODAY]] / 工場: [[00_YUEI/工場]] / 使い方: [[00_YUEI/工場-使い方]]
- ホット: [[wiki/hot]]
