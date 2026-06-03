---
ts: 2026-06-03T21:03:46+09:00
session_id: 9c060c83-fe09-45d0-852a-aea7cf2fc99a
cwd: C:\Users\Owner\business
host: 大井
event: UserPromptSubmit
chars: 1209
tags: [conversation, raw-prompt]
---

# 発話 2026-06-03 21:03

```
<scheduled-task name="evening" file="C:\Users\Owner\.claude\scheduled-tasks\evening\SKILL.md">
This is an automated run of a scheduled task. The user is not present to answer questions. For implementation details, execute autonomously without asking clarifying questions — make reasonable choices and note them in your output. "write" actions (e.g. MCP tools that send, post, create, update, or delete), only take them if the task file asks for that specific action. When in doubt, producing a report of what you found is the correct output.

夜の振り返りを10分で実行してください。

# 手順
1. 今朝のメモ wiki\_routines\morning-{今日YYYYMMDD}.md を読む
2. 今日のwiki\_tasks\today.md 達成状況確認
3. 昼ルーティン後に追加で溜まったwiki\_inbox\ の成果物を最終レビュー
4. queue\done\ の今日完了タスク・~/.claude/projects/ の活動時刻・gh CLI git commitを軽く確認

5. C:\Users\Owner\business\brain\routines\evening-simple.md の手順に従って、
   今日のメモ（できたこと/できなかったこと/学び）+ 明日やる1-3個 を決める

6. 出力:
   - wiki\_routines\evening-{今日YYYYMMDD}.md（夜メモ）
   - wiki\_tasks\today.md → done.md アーカイブ（`- [x]` チェック付きを移動）
   - 明日の量産タスクがあれば今夜のうちにdispatch投入
   - wiki\hot.md「Tomorrow」セクション更新

# Claudeの動き方原則
- 形式じゃなく大井が読み返して使えるメモにする
- 明日のOpenClaw投入を仕込めば朝には成果物揃ってる

確認は不要。自走してOK。完了したら「今日 X/Y達成 / 明日: <最優先>」と1行で報告。
</scheduled-task>
```
