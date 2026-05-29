---
type: secrets-vault
date: 2026-05-27
classification: CONFIDENTIAL
access: 大井湧瑛 のみ (master password で復号)
encrypted_with: Meld Encrypt (Obsidian community plugin)
do_not_read_by_claude: true
do_not_sync_plaintext: true
tags: [secrets, vault, encrypted, do-not-read]
---

# ⛔ _secrets/ — 機密保管 (Claude 読込禁止ゾーン)

> **このフォルダは Obsidian の Meld Encrypt プラグインで暗号化されたノートを格納する。**
> Claude (俺) はここを読まない・書かない・走査しない (`brain/CLAUDE.md` の禁則条項で明記)。
> 大井のみが master password で復号して閲覧する。

---

## 🔐 中に置くもの

- `accounts.md.encrypted` — 全SaaSのパスワード・APIキー・リカバリーコード (暗号化済)
- `banking.md.encrypted` — 銀行口座・クレカ・税理士関連 (将来)
- `infra-keys.md.encrypted` — サーバ・SSH秘密鍵・GPG秘密鍵 (将来)
- `recovery-codes.md.encrypted` — 2FA バックアップコード集 (将来)

---

## 🚫 入れないもの

- 暗号化されていない平文の鍵
- `.env` ファイル (リポ専用、ここに移動しない)
- 物理的に他人と共有が必要なもの (Notion を使う)

---

## 📋 セットアップ手順 (大井が1回だけ実行)

→ 隣接ファイル [[obsidian-secrets-setup-guide]] を参照
