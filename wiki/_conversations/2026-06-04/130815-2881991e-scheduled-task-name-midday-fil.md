---
ts: 2026-06-04T13:08:15+09:00
session_id: 2881991e-0540-4f46-99c1-6ee6ecc6347f
cwd: C:\Users\Owner\business
host: 大井
event: UserPromptSubmit
chars: 1164
tags: [conversation, raw-prompt]
---

# 発話 2026-06-04 13:08

```
<scheduled-task name="midday" file="C:\Users\Owner\.claude\scheduled-tasks\midday\SKILL.md">
This is an automated run of a scheduled task. The user is not present to answer questions. For implementation details, execute autonomously without asking clarifying questions — make reasonable choices and note them in your output. "write" actions (e.g. MCP tools that send, post, create, update, or delete), only take them if the task file asks for that specific action. When in doubt, producing a report of what you found is the correct output.

昼の進捗チェック + PDCAレビューを15分で実行してください。

# 手順
1. C:\Users\Owner\business\brain\routines\midday-check.md の手順に従う

# 概要
1. 朝のフォーカス3項目の進捗を判定（完了/進行中/着手/未着手）
2. wiki\_inbox\ の全部署フォルダを巡回しOpenClaw成果物をレビュー：
   - 良品質 → wiki\<正式パス>へ移動
   - 微妙 → 改善版promptで再dispatch
   - ダメ → 削除
3. 統合できそうなら、まとめページをwiki\<domain>\に新規作成
4. 午後の調整案を出す（優先度入替・追加dispatch等）
5. 出力:
   - wiki\_routines\midday-{今日YYYYMMDD}.md
   - wiki\_tasks\today.md「✅ 完了済み」セクション更新
   - wiki\hot.md「Midday」セクション更新

# レビューチェックリスト
- 出力フォーマット指示通りか
- 実在しないwikilink作ってないか
- 日付正しいか
- ハルシネーション数字ないか
- AI臭くないか

確認は不要。自走してOK。完了したら「進捗 X/3完了 / PDCA: 昇格Y件・再dispatch Z件」と1行で報告。
</scheduled-task>
```
