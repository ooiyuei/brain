---
tags: [meta, workflow, mac, mobility]
related: [[ooi-soul]] [[hot]]
updated: 2026-05-27
---

# 外出時の Mac Workflow

> このVaultをMacBookで使う時の運用マニュアル。家のPC（Windows）と同期しながら外で動く方法。

## ⭐ Remote Control 経由でセッション共有 (2026-05-27 追加)

**家のPCで動かしてる Claude Code セッションを、Mac/iPhone から直接触る方法。**

### 動作モデル
- セッションは Windows ローカルで動き続ける (= brain・MCP・ファイルすべてローカル)
- Mac/iPhone は「窓」になるだけ。Anthropic API 経由で会話が双方向同期される
- Windows 側で `cmd` 閉じたら切れる。立ち上げっぱなし運用が前提

### 必須条件
- Claude Code CLI v2.1.51+ (Desktop アプリとは別物。`irm https://claude.ai/install.ps1 | iex` でインストール)
- claude.ai OAuth ログイン (API key じゃダメ)
- `ANTHROPIC_API_KEY` 環境変数が未設定

### Windows 側セットアップ (初回1回)
```powershell
irm https://claude.ai/install.ps1 | iex          # CLI インストール
$p = "$env:USERPROFILE\.local\bin"
[Environment]::SetEnvironmentVariable("PATH","$([Environment]::GetEnvironmentVariable('PATH','User'));$p","User")
$env:PATH += ";$p"
claude --version                                  # 2.1.51+ なら OK
cd $env:USERPROFILE\business
claude                                            # 起動
# → 初回 /login で claude.ai を選んでブラウザで承認
```

### 毎日の起動 (Windows)
```powershell
cd $env:USERPROFILE\business
claude remote-control --name "AIpaX-brain"        # サーバーモード
# URL と QR が出る。スペースキーで QR トグル
```

### Mac から接続
- Safari/Chrome で `https://claude.ai/code` を開く
- サイドバーに `AIpaX-brain` セッションが緑インジケータで出てる → クリック
- 会話入力欄にそのまま打つだけ。brain も MCP も Windows のままアクセス可能

### iPhone から接続
- Claude app (iOS/Android) を同じアカウントでログイン
- Code タブ → セッション一覧から `AIpaX-brain` を選ぶ
- QR 撮るのが一番早い
- Push 通知 ON: `/config` → "Push when Claude decides" を `true`

### 注意
- Desktop アプリ (Windows Store の Claude 1.9255.0.0) と CLI は別物。Desktop アプリ内 Code タブのセッションは Remote Control 不可 (Agent SDK harness のため `/login` が無効化されてる)
- Remote Control 経由で使う場合は CLI 起動が必須
- ネットが10分以上落ちるとセッション切れる → 再起動
- Ultraplan を使うと Remote Control が切れる (排他)

詳細: [公式ドキュメント](https://code.claude.com/docs/en/remote-control)

---

## 前提構成（既に設定済み）

| 何が | どう同期 |
|---|---|
| `brain/` 全体 | **Obsidian Sync**（リアルタイム双方向） |
| `~/.claude/` 設定（agents/commands/skills/rules/CLAUDE.md） | **GitHub private repo** `ooiyuei/claude-config` |
| `apps/*` のコード | 各プロジェクトの **GitHub repo** |
| MCP認証情報 | **マシン固有**（Mac側で再認証必要） |
| `wiki/_log/*.jsonl` (自動ログ) | Obsidian Sync で家のPCにも届く |

---

## 起動の仕方（外出先で）

### 朝の立ち上げ（カフェ・移動先）

```bash
cd ~/business
claude
```

これだけ。立ち上がると Claude が自動で以下を読む：

1. `~/.claude/CLAUDE.md`（グローバルルール・組織図）
2. `~/business/brain/CLAUDE.md`（brain 運用原則・秘書ルール）
3. `brain/wiki/hot.md`（直近コンテキスト）

→ 即座に「秘書モード」に入る。

### 起動直後の儀式

最初のメッセージで以下を聞ける：

- 「今日のフォーカスは何だっけ？hot.md と daily の昨日分から教えて」
- 「昨日の続きから再開する。何が残ってる？」
- 「外で●時間あるから、◯◯案件を進めたい。brain見て準備して」

---

## 外出時の典型シナリオ

### ① ヒアリング・商談前の30分

```
顧客名 で brain を引いて、過去のやり取りと現状をまとめて。
あと AIpaX school の事業計画書から、提案できそうな構成を3案出して。
```

→ Claude が `entities/{顧客名}.md` `sources/` `10_projects/AIpaX-school.md` を読んで統合回答。

### ② 思いつきアイデアを溜める

```
今思いついた：高校生向けの〇〇サービス。
brain/00_inbox/ に放り込んでおいて。あとで idea-judge で評価する。
```

→ Claude が `brain/00_inbox/YYYY-MM-DD-{slug}.md` を作成。Sync で家のPCに即届く。

### ③ 議事録・打ち合わせ後の整理

```
今 ◯◯ さんと話した内容、口頭で言うから整理して wiki/sources/ に保存して。
あと entities/{相手名}.md も更新して。
```

→ Claude が `sources/YYYY-MM-DD-{topic}.md` 作成 + `entities/{name}.md` 更新。

### ④ コード書きたいけどPCサーバー触れない

家のPC側のサーバー (testall localhost:3010 等) は触れない。なので：
- **読む系・書く系**：問題なし（コードはMacにclone済み）
- **動かす系**：難しい。`vercel dev` などローカルで立てて確認、本番は家に戻ってから or Vercel preview

### ⑤ 移動中・電車内（オフライン可能性あり）

- Obsidian だけなら **オフライン書き込みOK** → 戻ったら自動同期
- Claude Code は **API 接続必要**（オフライン不可）→ 機内 wifi なければ Obsidian だけで作業

---

## brain への書き込みは Claude が自動でやる

`brain/CLAUDE.md` のルールにより、Mac側のClaude も以下を**自動でやる**：

1. **セッション終了プロトコル**：作業終わる前に `wiki/daily/YYYY-MM-DD.md` に追記
2. **プロジェクト活動ログ**：触ったプロジェクトの `10_projects/*.md` の `## 活動ログ` に追記
3. **MCP使用ログ**：呼んだMCPの結果を `wiki/_inbox/mcp/` に記録
4. **自動 hook**：`~/.claude/settings.local.json` の Stop/PostToolUse hook が `wiki/_log/sessions.jsonl` `operations.jsonl` に機械ログを残す

→ **家のPCで朝起きたら、Macで何をやったか全部 brain で確認できる。**

---

## 同期されない・注意すべきこと

### MCP 認証は Mac で別途やる

Macで初めて使う時に1回だけ：

```
/mcp list   ← 接続済みMCP確認
/mcp connect stripe  ← 各MCP1個ずつログイン
```

Stripe / Supabase / Notion / Slack / Gmail / Calendar / Linear / Sentry / Vercel / Asana / Fireflies / Zoom / Google Drive — 計13個。初回 30-60分。

### ~/.claude/ の更新は git pull/push 必要

Macで agent や skill 触ったら：

```bash
cd ~/.claude
git add . && git commit -m "update: <内容>" && git push
```

家のPCで反映：

```powershell
cd C:\Users\Owner\.claude
git pull
```

### Obsidian Sync の競合

両PCで同時に同じファイルを編集すると `.sync-conflict` ファイルが生まれる。
→ Obsidianアプリで該当ファイル開いて、手動で merge or 片方削除。

ただし基本的に競合はほぼ起きない（Mac で書いてる時間帯は家のPC で書かないので）。

### Discord通知・Windows Task Scheduler は Mac で動かない

家のPCに常駐している以下は **Mac側では動かない**：
- BrainWorkerLight / BrainWorkerHeavy (1分おき queue 処理、レーン分離。qwen3:8b と qwen3.6:latest)
- BrainMonitor (朝08:30)
- BrainHarvest (1時間おき)
- BrainAutoReview (2026-05-27 から Disabled・手動運用へ。5/25 に 1500件超を一気投入して滞留させた事故が原因)
- DailyBrainOllama (Disabled)

→ これらは家のPCを立ち上げっぱなしにしておけば動き続ける。Mac で外作業中も家のPCが裏で回ってる前提。

---

## トラブルシューティング

### Q: Mac で claude 起動したが brain を読んでない感じがする

A: 起動した cwd を確認。`~/business/` の中で立ち上げてないと `brain/CLAUDE.md` を読まない。

```bash
pwd   # /Users/{username}/business のはず
ls -la  # brain/ apps/ が見えれば OK
```

### Q: brain に書き込んでも家のPCに届かない

A: Obsidian Sync が動いてるか確認。
- Macで Obsidian 開いてる → ステータスバーに同期マークがある
- 開いてない → Obsidian起動して数秒待つ
- それでも来ない → Sync設定タブで「再同期」

### Q: hook が動いてない（daily/ に自動追記されない）

A: `~/.claude/settings.local.json` が存在するか確認。
Mac セットアップ時に `brain/scripts/settings.local.json.mac.template` をコピーする必要あり：

```bash
cp ~/business/brain/scripts/settings.local.json.mac.template ~/.claude/settings.local.json
```

### Q: ~/business/ がそもそも Mac にない

A: ホームフォルダ直下に `business` ディレクトリ作って、その中で：
- Obsidian Sync で brain/ を受信
- 必要なら git clone で apps/ を持ってくる

---

## まとめ：外出時の合言葉

> 「**家を出ても秘書は連れて行く**」

- 移動中：思いつきを brain に溜める（Obsidian単体でもOK）
- カフェ：Mac で claude → brain見ながら壁打ち・PRD書き・提案準備
- 帰宅：自動ログで「外で何やったか」全部 wiki に残ってる
