---
type: department-log
dept_code: 06_secretary
updated: 2026-05-27
managed_by: secretary (every session)
---

# 06_secretary 活動ログ

> **時刻付きで部署アクション・判断を残す。**

---

### 2026-05-27 06:00-07:30 RC環境構築 + queue整理
- 大井指示「queue滞留・Mac リモコン」を受領
- queue/inbox 1521件を `_archive/inbox-purge-2026-05-27/` に robocopy /MOVE
- BrainWorkerLight/Heavy 再Enable、AutoReview Disabled 維持
- Win に Claude Code CLI v2.1.150 インストール、Mac から Remote Control 接続成功
- ファイル: `~/.local/bin/claude.exe`, `brain/queue/_archive/`, `brain/wiki/meta/mac-workflow.md`
- 次やること: Phase 2-C 実行日に Obsidian Sync 一時停止の運用テスト

---

### 2026-05-27 08:45 Chrome MCP 操作バッチ (Supabase診断 + 3商工会議所連絡先取得)
- Chrome MCP (Browser 2 Win) で Supabase dashboard navigate → Sign in 画面到達 → パスワード入力は immutable rule で禁則のため停止
- Handoff `2026-05-27-supabase-restore-handoff.md` 作成 (大井 OAuth ボタン1クリックで対応依頼)
- 3商工会議所サイト訪問 → 連絡経路確定:
  - 静岡: info@shizuoka-cci.or.jp ✅ 直送可
  - 浜松: フォーム https://www.hamamatsu-cci.or.jp/inquiry/ (会員サービス課 or 経営支援課選択)
  - 沼津: フォーム or TEL 055-921-1000
- 連絡先まとめ `04_sales_mkt_cs/leads/aipa-web/2026-05-27-shoukou-cci-contacts.md`
- Gmail下書き追加: 静岡商工会議所宛て (info@shizuoka-cci.or.jp、Cc: ooiyuei@gmail.com、`r141515670050992925`)

### 2026-05-27 08:35 NOTES.md 大井発信の振り分け
- 大井が NOTES.md に大量メモ投下 (戦闘姿勢 + 大井塾構想)
- 振り分け:
  - 大井塾 (日本一のアクセラ) → `02_newbiz/ideas/2026-05-27-ooi-juku-accelerator.md` (Tier A 推定78点)
  - 戦闘姿勢全文 → `09_knowledge/learnings/2026-05-27-ooi-fighting-spirit.md` (Claude-CEO 大井クローン応答時の追加フィルター)
- NOTES.md 処理済み表に記録、本文は大井が消すまで保持

### 2026-05-27 07:30 MCP 能動使用バッチ (Calendar + Gmail)
- Calendar イベント追加 3件:
  - 🔥 夢AWARD骨子 v1 作業ブロック (5/29 14:00-17:00, color=Tomato, リマインダー24h+1h)
  - 📝 SFC AO論点メモ作成 (5/28 19:00-20:00, color=Peacock)
  - 📞 AIpaX 5社目クロージング進捗確認 (5/27 20:00-20:30, color=Banana, リマインダー30分)
- Gmail 下書き 3件:
  - パターンA 実績訴求型 (`r5592020327077031870`)
  - パターンB 地域貢献型 (`r-7714891049797768012`)
  - パターンC 緊急性訴求型 (`r-2521546961717997397`)
  - 送信先: ooiyuei@gmail.com (本人確認用、実送信は商工会議所宛に大井がBccやり直し)
- 次やること: 大井が下書きレビュー → 静岡/浜松/沼津商工会議所3カ所宛に Bcc 送信
- SFC AO 論点5案ドラフトを `06_secretary/communications/2026-05-27-sfc-ao-5topics-draft.md` に保存

---
