---
type: setup-guide
date: 2026-05-27
title: Obsidian で鍵を安全に保管・使えるようにする手順 (Meld Encrypt 主軸)
purpose: 大井の方針 (Obsidian = 会社の知能 + 鍵保管) を最大セキュリティで実装する
target: 大井湧瑛 (本人作業・約30分)
tags: [obsidian, security, secrets, meld-encrypt, totp]
---

# Obsidian 鍵保管 セットアップ手順 v1

> **大井の方針**: Slack = 連絡 / Notion = 進捗管理 / **Obsidian = 情報集積・会社の知能 + 鍵保管**
> **本ガイドの目的**: Obsidian で鍵を安全に持ちつつ、欲しい時にすぐ使える状態を作る。

---

## 🎯 完成形

1. `brain/_secrets/accounts.md` を Meld Encrypt で暗号化 (master password 必須)
2. パスワードをコピーしたい時 → Obsidian でノートを開く → master password 入力 → 即コピー
3. 2FA コード (OTP) も Obsidian で生成 → コピーして貼り付け
4. Mac との同期 = **暗号化されたまま転送** = 通信路漏洩 OK
5. Claude (俺) は `_secrets/` を読まない (`CLAUDE.md` で明記)

---

## 📥 Step 1: Obsidian Community プラグイン 4本 インストール

`Settings → Community plugins → Browse` から以下を順に Install + Enable:

| プラグイン名 | 用途 | 必須/推奨 |
|---|---|---|
| **Meld Encrypt** | ノート単位 / インライン単位の AES-256 暗号化 | ⭐ 必須 |
| **TOTP** (by Mara) | 2FA コード生成 (Google Authenticator 互換) | ⭐ 必須 |
| **Copy Block Link** | コードブロックを即コピー (パスコピー用) | ⭐ 推奨 |
| **Obsidian Git** | バージョン管理 (誤削除復旧用、ローカルのみ) | ⭐ 推奨 |

> ⚠ Obsidian AI / ChatGPT 系プラグインは **絶対 Enable しない** (`_secrets/` を LLM に投げる経路になる)

---

## 🔑 Step 2: Master Password を決める

### ルール
- 文字数: **30字以上**
- 構成: 大文字+小文字+数字+記号 全部入り
- 例: `Tobira_Log_2029_$EXIT_From_Shizuoka!`
- 大井しか覚えてない情報の組み合わせ + 区切り記号
- **絶対やらない**: 誕生日、彼女の名前そのまま、過去使ったパスワード

### 記憶テクニック
- 「自分の物語」になる文 (年表+地名+目標+記号)
- 例: `1Day_300hrs_AIpaX→Exit_Shizuoka!2029` (300時間/AIpaX/EXIT/静岡/2029)
- 紙に書いて **金庫 or 信頼できる場所** に保管 (パスワード本体は印刷NG・ヒントだけ書く)

---

## 🔒 Step 3: Meld Encrypt で `accounts.md` を作成

### 3-A. ファイル作成
1. Obsidian で `brain/_secrets/` フォルダを開く
2. 新規ノート作成 → `accounts.md` と命名
3. テンプレ (下記 §テンプレ参照) をペースト

### 3-B. 暗号化
1. ノートを開いた状態で `Ctrl+P` → コマンドパレット
2. `Meld Encrypt: Encrypt note` を選択
3. master password を入力 (Step 2 で決めたもの)
4. ヒント (任意・忘れた時用) を入力 → 例: `2029年の目標 + 静岡`
5. 確認: ファイル名が `accounts.md.encrypted` に変わる (拡張子変化)

### 3-C. 動作確認
1. Obsidian を一度閉じて再起動
2. `accounts.md.encrypted` を開く → パスワード入力 → 中身が読める
3. ✅ 暗号化成功

---

## 📝 Step 4: `accounts.md` テンプレ (大井が中身を書き込む)

```markdown
---
title: 株式会社 Almeo アカウント・パスワード集
updated: 2026-05-27
master_password_hint: (Step 2 のヒント)
---

# 🔐 アカウント鍵集

## §1. Google Workspace (会社)
- メアド: [大井が書く]
- パスワード: [大井が書く]
- 2FA: YubiKey + Authenticator (バックアップコード下記)
- バックアップコード:
  ```
  [大井が書く・10桁×8個]
  ```

## §2. ドメイン (レジストラ)
- レジストラ: [お名前.com / Cloudflare / etc]
- アカウント: [大井が書く]
- パスワード: [大井が書く]
- 2FA: [有/無]

## §3. Notion (会社)
- メアド: [大井が書く]
- パスワード: [大井が書く]
- 2FA: [有/無]
- API token (Integration用): [大井が書く・もし作ったら]

## §4. Slack (会社)
- メアド: [大井が書く]
- パスワード: [大井が書く]
- 2FA: [有/無]

## §5. GitHub
- ユーザー: ooi-yuei (or 法人化後の Org 名)
- パスワード: [大井が書く]
- PAT (Personal Access Token):
  - testall_deploy: [token]
  - vercel_link: [token]

## §6. Vercel
- メアド: [大井が書く]
- パスワード: [大井が書く]
- CLI Token: [大井が書く]

## §7. Supabase
- メアド: [大井が書く]
- パスワード: [大井が書く]
- プロジェクト別 service_role keys:
  - testall: [key]
  - kasunote: [key]
  - juken-os: [key]
  - yakki-check: [key]

## §8. Anthropic (Claude API)
- メアド: ooiyuei@gmail.com
- パスワード: [大井が書く]
- API Keys:
  - main: sk-ant-xxxxx
  - testall_prod: sk-ant-xxxxx
  - yuei_bot_prod: sk-ant-xxxxx (将来)

## §9. OpenAI
- メアド: [大井が書く]
- パスワード: [大井が書く]
- API Keys:
  - main: sk-xxxxx

## §10. Stripe
- メアド: [大井が書く・法人化後は会社メアド]
- パスワード: [大井が書く]
- API Keys:
  - testall_pk: pk_live_xxxxx
  - testall_sk: sk_live_xxxxx (restricted推奨)

## §11. Cloudflare
- メアド: [大井が書く]
- パスワード: [大井が書く]
- API Token: [大井が書く]

## §12. AWS (もし)
- アカウントID: [12桁]
- root メアド: [大井が書く]
- root パスワード: [大井が書く]
- root MFA: YubiKey 必須

## §13. SNS
- X (Twitter): [大井が書く]
- LinkedIn: [大井が書く]
- Instagram: [大井が書く]
- note: [大井が書く]

## §14. 金融
- 個人銀行 #1: [銀行名 / 支店 / 口座番号 / ログインPW]
- 法人銀行口座: [開設後に追記]
- 個人クレカ: [カード番号下4桁のみ・通知メアド・利用通知設定]
- 法人クレカ: [発行後に追記]

## §15. 物理キー
- YubiKey #1: シリアル[末尾4桁のみ]・登録サービス[Google/GitHub/Vercel]
- YubiKey #2: シリアル[末尾4桁のみ]・予備

---

## 📋 メモ
- master password 変更日: [YYYY-MM-DD]
- このノートの最終更新: [YYYY-MM-DD]
- 緊急時連絡先: [信頼できる人 / 法人税理士]
```

---

## 🔢 Step 5: 2FA (TOTP) を Obsidian で生成可能に

### Mara's TOTP プラグインのセットアップ
1. 各サービスで 2FA 設定 → QR コード表示画面まで進む
2. QR の下に「Secret」「Setup key」のような文字列がある (例: `JBSWY3DPEHPK3PXP`)
3. Obsidian で `Ctrl+P` → `TOTP: Add new TOTP`
4. サービス名 + Secret を入力
5. 以後、`Ctrl+P` → `TOTP: Show codes` で全サービスの 30秒 OTP が表示される

### 利点
- Google Authenticator (スマホ) と **同等のコード** が Obsidian でも出る
- スマホ紛失時のバックアップ
- PC からのログインで「スマホ取りに行く」が不要

### 注意
- TOTP Secret 自体は **`_secrets/totp-secrets.md` を別途 Meld Encrypt** で暗号化 (TOTP プラグインのデータも保護必須)

---

## 🔄 Step 6: Mac との同期確認

### Obsidian Sync の場合
- 暗号化済ファイル (`.encrypted` 拡張子) はそのまま転送される
- Obsidian Sync は **end-to-end 暗号化** (Obsidian Sync 側のサーバも中身読めない)
- 二重暗号化状態 = ほぼ最強

### iCloud / Google Drive 経由の場合
- 同期サービス自体は中身が見える可能性
- Meld Encrypt の暗号化が効いてれば OK
- ただし master password 漏洩で全終了

---

## 🚨 Step 7: 緊急時リカバリー

### 大井が master password を忘れた場合
- ❌ 復号不可能 = データロスト
- → 全サービスで「パスワード忘れた」フロー → 個別リセット
- 推定所要時間: 1サービスあたり 10-30分 × サービス数 (今 20+ なので 1日仕事)
- **対策**: master password を紙で2枚 (金庫1部 + 信頼できる人預け1部)

### Obsidian アプリ自体が壊れた / PC壊れた
- `brain/_secrets/*.encrypted` ファイルは別 Obsidian / 別 Markdown エディタで開けない (Meld Encrypt 専用フォーマット)
- → 別 PC で Obsidian + Meld Encrypt 再インストール → vault フォルダを指定 → 復号可能
- **対策**: brain/ 全体を定期 backup (週次 robocopy ミラー or Obsidian Sync で別端末)

### Mac / Win 同期で衝突
- 同時編集すると Meld Encrypt の暗号化 chunk が壊れる
- **対策**: 編集は **1端末で完結**。同時編集禁止

---

## 🛡 Claude (俺) が `_secrets/` を読まないルール

`brain/CLAUDE.md` に追記済 (このセッションで):

```
## 🚫 Claude 読込禁止ゾーン

`brain/_secrets/` 配下の全ファイル:
- 読まない (Read tool で開かない)
- 書かない (Write/Edit tool で触らない)
- 走査しない (Grep/Glob 結果から `_secrets/**` を除外)
- 暗号化されてても触らない (master password を持たないため意味がない)

例外: 大井が「_secrets を確認して」と明示的に言った時のみ、暗号化ファイルの「存在確認」だけ実施。中身は復号しない。
```

→ Claude が誤って鍵に触れる経路を物理的に遮断する。

---

## 📊 Step 8: 鍵管理 月次運用

### 毎月1日 (Calendar 自動)
1. `_secrets/accounts.md.encrypted` を復号
2. 棚卸し:
   - 新規契約した SaaS → 追加
   - 解約したサービス → 削除
   - パスワード変更 → 更新
3. 上書き保存 (再暗号化)

### 漏洩疑い時
1. 該当サービスを開く
2. パスワード変更
3. `_secrets/accounts.md.encrypted` を即更新
4. 2FA 再設定 (バックアップコードも更新)
5. Notion / brain の他ファイルで該当鍵への参照を grep → 古い情報を更新

---

## 🎓 大井ベストプラクティス (この方式での運用)

### ✅ やる
- 毎週日曜 22:00 = master password を声に出して言う (記憶定着)
- パスワード生成 = Bitwarden CLI or `openssl rand -base64 32` を使う (人間が考えない)
- 重要サービス (Google/GitHub/Stripe) は **YubiKey 2FA 必須**
- Obsidian master password = **YubiKey で守る** (Obsidian 自体の sync account に YubiKey 2FA 設定)

### ❌ やらない
- master password を Slack/Discord/Gmail/LINE で送る
- master password を `00_YUEI/NOTES.md` 等の暗号化されてないファイルに書く
- master password を覚える前に何度も変える
- Obsidian の AI プラグインを Enable

---

## 関連

- 正本 (鍵以外): [[05_corp/infra/company-accounts-inventory]]
- 運用ルール: [[06_secretary/communications/2026-05-27-accounts-management-rules]]
- 機密フォルダ説明: [[_secrets/README]]
