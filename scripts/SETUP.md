# 大井湧瑛 Brain System — セットアップガイド

> このシステムは「**Claudeが秘書として大井の発話を分解し、OpenClawに振って24時間ぶん回し、wikiに育てる**」を実現する。

---

## 🔔 Discord通知 セットアップ（外出中の監視に必須）

PCが裏で動いてる時、何か起きたらスマホのDiscordに通知が飛ぶようにする。**10分で設定完了**。

### 手順（5ステップ）

#### Step 1. Discordサーバー作成（既にあれば飛ばす）
1. Discord アプリ起動
2. 左サイドバー一番下の `+` → 「自分で作る」→ 「自分と友達のため」
3. 名前: `Brain` などお好みで
4. デフォルトで `#general` チャンネルが作られる

#### Step 2. チャンネル分け（任意・推奨は1チャンネル）
個人運用なら `#brain` 1つでOK。分けたい場合：
- `#brain-alerts` — 失敗・健全性異常（赤系）
- `#brain-daily` — 朝/夜のサマリー
- `#brain-completed` — OpenClaw成果物（オプション・うるさい）

#### Step 3. Webhook URL取得
1. 通知を受けたいチャンネル名横の **⚙ 編集ボタン** クリック
2. 左メニュー「**連携サービス**」→「**ウェブフック**」
3. 「**新しいウェブフック**」をクリック
4. 名前: `Brain Bot` などお好みで
5. アイコン: 任意（🧠絵文字でも貼れる）
6. **「ウェブフックURLをコピー」** をクリック
7. URLは `https://discord.com/api/webhooks/xxxxxxx/yyyyyyyy` 形式

#### Step 4. config.json に貼る
`C:\Users\Owner\business\brain\scripts\config.json` を開いて：

```json
{
  "discord": {
    "webhook_url": "ここにペースト",
    "notify_on_success": false,
    "notify_on_failure": true,
    "notify_health_issue": true,
    "notify_on_dispatch": false
  }
}
```

#### Step 5. テスト通知
PowerShellで以下を実行：

```powershell
& "C:\Users\Owner\business\brain\scripts\notify.ps1" `
    -From Claude `
    -Title "🧠 Brain通知 セットアップ完了" `
    -Body "今からDiscord通知が届きます" `
    -Color green
```

Discordに通知が来れば成功 ✅

---

## 📲 通知が飛ぶタイミング

| 状況 | 送信元 | 色 | 設定 |
|---|---|---|---|
| OpenClaw失敗（3回リトライ後） | Worker ⚙️ | 🔴 red | `notify_on_failure: true` |
| 健全性異常（毎朝07:55） | Health 🩺 | 🟡 yellow / 🔴 red | `notify_health_issue: true` |
| Claudeから大井への重要報告 | Claude 🧠 | 状況に応じ | （手動で都度） |
| OpenClaw重要成果物まとめ | OpenClaw 🦞 | 🔵 blue | （Claudeが判断） |
| 全AIタスク完了通知 | Worker | 🟢 green | `notify_on_success: false` ← うるさいのでデフォルトOFF |

---

## ⏰ ルーティン設定（既にやってあれば飛ばす）

### Anthropicリモートルーティン（コネクター使う）
**朝07:00 morning-catchup** だけリモート。Claude Code UIの「スケジュール」画面で：
- 指示文: `C:\Users\Owner\business\brain\routines\morning-catchup.md` の内容
- コネクター: Gmail / Google Calendar / Slack / Notion / Stripe / Sentry / Linear ON
- スケジュール: 毎日 07:00

### Claude Code ローカルルーティン4本
1. **morning 09:00** — 今日の作戦
2. **midday 12:30** — 進捗 + PDCAレビュー
3. **evening 22:00** — 振り返り + 明日仕込み
4. **weekly 日曜21:00** — 棚卸し

各指示文は `brain/ルーティーン.md` 参照。

---

## 🩺 健全性チェック

毎朝07:55 `BrainHealth` スケジューラが自動実行 → `wiki/_routines/health-{今日}.md` レポート生成。
問題があれば Discord 通知。

手動実行: `& "C:\Users\Owner\business\brain\scripts\health.ps1"`

---

## 🛠 トラブル時

| 症状 | 対応 |
|---|---|
| OpenClawが処理しない | `ollama list` で `qwen3.6:latest` 確認 → 無ければ `ollama pull qwen3.6:latest` |
| BrainWorker停止 | タスクスケジューラで「BrainWorker」右クリック → 実行 |
| ロック残ってる | `Remove-Item C:\Users\Owner\business\brain\queue\.worker.lock` |
| wiki/_inbox/ 溜まりすぎ | 「inbox整理して」とClaudeに言う（midday/eveningで処理） |
| Discord通知来ない | `webhook_url` 確認 → Step 5 のテスト実行 |
| 健全性異常 | `wiki/_routines/health-{今日}.md` 確認 |

## 📁 主要ファイル

- `brain/CLAUDE.md` — Claude動き方原則（最重要）
- `brain/routines/` — 5ルーティン指示書
- `brain/scripts/` — 自動化スクリプト
- `wiki/hot.md` — 直近コンテキスト
- `wiki/_tasks/today.md` — 今日のタスクボード
- `wiki/_routines/` — 朝/夜/週の履歴
- `wiki/_monitor/` — 朝の監視結果
- `wiki/_inbox/` — OpenClaw成果物の昇格待ち

## 📚 参照

- [[../CLAUDE]] — Claude動き方原則
- [[../routines/]] — ルーティン指示書5本
- [[../wiki/_routines/_MOC]] — ルーティン索引
- [[../wiki/_tasks/_MOC]] — タスク索引
