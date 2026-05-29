---
type: handoff-to-yuei
date: 2026-05-27 08:40
priority: 🔥 HIGH
target: 大井湧瑛 (手作業必要)
reason: パスワード入力は Claude の immutable rule で禁止
---

# Supabase Testall 復旧 — 大井への引き継ぎ

> **Claude-CEO が Chrome MCP で操作試みた結果、ログイン画面に到達。パスワード入力は安全ルールで禁止のため、大井に引き継ぎ。**

## 現状

- Browser 2 (Windows・このPC) で https://supabase.com/dashboard/project/qpckkyjawjmeumnynynt を開いた
- **Welcome back サインイン画面** が表示された (= Windows 側は未ログイン状態)
- メール欄に「testall」が事前入力されてた (大井の過去入力残り、メアドじゃない無効値)
- パスワード欄にプレースホルダ表示

## 大井がやること (5分で完了)

### Step 1: ログイン
1. Chrome タブ (tabId 817400739) は既に開いてる
2. **Continue with GitHub** ボタンをクリック (パスワード不要・OAuth)
   - or メアド入力 + パスワード入力 + Sign in
3. ログイン後、testall プロジェクト dashboard に自動遷移

### Step 2: Unpause
- Dashboard に「Project is paused. Click to restore」的なボタンがあるはず
- クリックして restore (90日以内ならデータ完全復活)

### Step 3: RLS 修正 (Critical 漏洩リスク)
- 左サイドバー → **Advisors → Security**
- `rls_disabled_in_public` の警告ファイルを開く
- 該当テーブルに対し **Enable RLS** + ポリシー設定
  - 推奨: `user_id = auth.uid()` policy で「自分のレコードしか触れない」
- (HANDOFF_AUTH.md / dev-plan.md にも RLS 設計記載あり)

### Step 4: Pro へのアップグレード検討
- 7日間放置で再 pause を防ぐため、Pro プラン (月額 $25) を検討
- ただし開発フェーズなら Free でも OK (毎日触れば pause されない)

## Mac の Chrome (Browser 1) にログイン済の可能性

- 大井が Mac で Supabase に普段アクセスしてるなら、そっちはログイン済かも
- Mac で同じ URL を開いて確認 → unpause クリックがそっちの方が速い可能性

## Claude 側でできなかった理由

- Anthropic Immutable Rule: **「ユーザーのパスワードを Claude が入力するのは禁止」**
- OAuth ボタンクリック (GitHub等 passwordless) はOKだが、その先で 2FA や認証画面が出たら停止する設計
- → 大井の判断・大井の指で実行必要

## 完了後の通知方法

完了したら一言「supabase 復旧した」と俺に言ってくれれば、status-board と REPORT.md を更新する。

## 関連

- Status Board: [[01_ceo/status-board]]
- Testall handoff: [[03_dev/projects/Testall-handoff-2026-05-27]]
- Gmail 元メール: 5/22 「Your Supabase Project testall has been paused」/ 5/20 「Action required: security vulnerabilities」
