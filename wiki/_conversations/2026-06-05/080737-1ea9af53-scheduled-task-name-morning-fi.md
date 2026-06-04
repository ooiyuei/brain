---
ts: 2026-06-05T08:07:37+09:00
session_id: 1ea9af53-1c11-40a3-8af7-c245decffc82
cwd: C:\Users\Owner\business
host: 大井
event: UserPromptSubmit
chars: 1425
tags: [conversation, raw-prompt]
---

# 発話 2026-06-05 08:07

```
<scheduled-task name="morning" file="C:\Users\Owner\.claude\scheduled-tasks\morning\SKILL.md">
This is an automated run of a scheduled task. The user is not present to answer questions. For implementation details, execute autonomously without asking clarifying questions — make reasonable choices and note them in your output. "write" actions (e.g. MCP tools that send, post, create, update, or delete), only take them if the task file asks for that specific action. When in doubt, producing a report of what you found is the correct output.

朝の作戦会議を10分で実行してください。

# 手順
1. C:\Users\Owner\business\brain\wiki\hot.md を読む
2. 昨夜のメモ wiki\_routines\evening-{昨日YYYYMMDD}.md があれば読む
3. 今朝08:30にOpenClawが処理済みの監視結果3本を読む：
   - wiki\_monitor\competitor-{今日}.md（競合動向）
   - wiki\_monitor\deadlines-{今日}.md（ビジコン締切）
   - wiki\_monitor\grill-{今日}.md（朝の問い3つ）
4. wiki\_tasks\inbox.md の振り分け待ちタスクを確認

5. C:\Users\Owner\business\brain\routines\morning-simple.md の手順に従って、
   今日の打ち手「絶対やる1個 + できれば2-3個」を決める

6. 出力先:
   - C:\Users\Owner\business\brain\wiki\_routines\morning-{今日YYYYMMDD}.md（朝メモ）
   - C:\Users\Owner\business\brain\wiki\_tasks\today.md（今日のタスクボード上書き）
   - C:\Users\Owner\business\brain\wiki\hot.md「Today」セクション更新

# Claudeの動き方原則（CLAUDE.md参照）
- 大井は書かない。あなたが秘書として全部書く
- 重い量産タスクは dispatch.ps1 で並列OpenClawに投げる
- prompt は scripts/prompt-prefix.md が自動付与されるので指示は本題のみ
- 会社員ぽさNG、1人起業家のリアル

確認は不要。自走してOK。完了したら「今日: <絶対やる1個>」と1行で報告。
</scheduled-task>
```
