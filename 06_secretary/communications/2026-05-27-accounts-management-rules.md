---
type: secretary-rules
category: security-operations
date: 2026-05-27
updated: 2026-05-27
managed_by: 秘書室 (secretary) + コーポレート部 (cfo)
applies_to: 株式会社 Almeo 全アカウント
tags: [security, accounts, operations, password]
---

# アカウント・鍵管理 運用ルール v1

> 今日: Google Workspace + Slack + Notion (会社) + ドメイン取得 = 会社インフラ完成。
> このルールに従って鍵を管理する。**Claude は鍵そのものに触れない (immutable)**。

---

## 🔐 鍵管理 4原則 (大井選好: Obsidian 主・2026-05-27 確定)

### 役割分担 (大井宣言)
- **Slack** = 連絡用
- **Notion** = 進捗管理
- **Obsidian (brain/)** = 情報集積・会社の知能・**鍵保管** ← 鍵はここ

### 原則1: Obsidian Meld Encrypt で `_secrets/` を暗号化保管
- 全パスワード・APIキー・リカバリーコード・ライセンスキー → **`brain/_secrets/*.encrypted`** に保管
- Meld Encrypt プラグインで AES-256 暗号化 (master password 必須)
- ❌ Notion / Slack / Gmail / .env / Claude チャットには **鍵そのものを書かない**
- ❌ `_secrets/` 以外の brain ファイルにも鍵そのものを書かない

> **Claude (俺) からの安全装置**:
> `_secrets/` 配下を Claude は **物理的に読まない** ルールを `brain/wiki/CLAUDE.md` に明記済 (2026-05-27 追加)。
> 大井のみが master password で復号可能。Mac同期でも暗号化状態のまま転送される。
> セットアップ手順: [[_secrets/obsidian-secrets-setup-guide]]

### 原則2: 2FA 強制 (Yubikey 主・Authenticator 副)
- Google Workspace 管理者 = **YubiKey 必須** (フィッシング耐性最強)
- GitHub / Vercel / Stripe / AWS = YubiKey
- それ以外 = iPhone Authenticator (Authy / 1Password 統合 OTP)
- バックアップコードは1Passwordに保存 + 物理印刷 (金庫)

### 原則3: 共有しない (会社1人の今、共有需要ゼロ)
- 「ちょっと貸して」も含めて鍵は他人に渡さない
- 共有必要時 = 1Password の Share Link (24-48h 期限付き)
- Slack DM / Gmail / LINE で鍵を送らない (絶対)

### 原則4: 棚卸し月次 (毎月1日 / Calendar 設定)
- 未使用 SaaS → 解約 (月 ¥1000 でも年 ¥12000 のリーク)
- パスワード変更 = 漏洩疑い時のみ。定期変更は逆に弱体化 (NIST 2017 ガイドライン)
- アカウント棚卸し = `brain/05_corp/infra/company-accounts-inventory.md` 更新

---

## 🛡 Obsidian Meld Encrypt 運用 7条 (Obsidian 主選択時の必須)

### 1. master password を強くする
- 30字以上、大小英数記号全部
- 「自分の物語」になる文 (年表+地名+目標+記号)
- 紙に書く時は **ヒントのみ**、本体は記憶
- 例: `Tobira_Log_2029_$EXIT_From_Shizuoka!`

### 2. Meld Encrypt プラグイン必須
- `Settings → Community plugins → Browse → Meld Encrypt`
- ノート単位/インライン単位 AES-256 暗号化
- セットアップ手順: [[_secrets/obsidian-secrets-setup-guide]]

### 3. `_secrets/` フォルダの隔離
- このフォルダは Claude 読込禁止 (`brain/wiki/CLAUDE.md` 末尾セクションで明記)
- Obsidian AI 系プラグインは **絶対 Enable しない** (LLM経路漏洩リスク)
- このフォルダだけは Mac の Obsidian でも触らない (master password 別端末入力でレイヤー追加)

### 4. 2FA TOTP は Mara's TOTP プラグインで Obsidian 内生成
- スマホ紛失時のバックアップ
- TOTP secret 自体も `_secrets/totp-secrets.md.encrypted` に保管

### 5. Obsidian アカウント自体の 2FA
- Settings → Account → 2-Step Verification = ON
- Authenticator アプリ + バックアップコード保管

### 6. バックアップ
- 毎週日曜 22:00: `brain/_secrets/` を別端末/USB に robocopy ミラー
- master password 紙に2枚 (金庫1 + 信頼できる人預け1)
- Obsidian Sync の暗号化が二重防御として効く

### 7. 漏洩疑い時の即応
- master password を即変更 (旧vs新の差分Meld暗号化)
- 全サービスのパスワードを順次更新 (1日仕事)
- アクセスログを確認 (Notion / Google Workspace activity log)

---

## ⚠ 旧 Notion 主前提セクション (大井 → Obsidian 主に方針変更で破棄)

旧版 (2026-05-27 早朝) では Notion 主前提だったが、同日昼に大井が
**「Obsidian = 情報集積・会社の知能・鍵保管」** に方針確定したため Notion 主前提は無効化。
Notion アカウント管理 DB を作る場合は「鍵そのもの」を入れず、**サービス名・用途・契約日のみ** とする。

参考: 旧 Notion 主前提セクションは git 履歴 (or `_system/archive/`) で参照可能。

---

## 🛡 旧 Notion 主前提セクション (削除予定・記録のみ)

### 1. ページ階層を分離
- 「アカウント管理」ページを **会社ルートから直接の子ページにしない**
- 推奨階層: `🏠 株式会社 Almeo` → `🔒 機密 (大井のみ)` → `🔐 アカウント管理 DB`
- 親ページ「🔒 機密」を **大井のみ閲覧** に権限制限

### 2. ページ共有を完全に閉じる
- ページ右上「共有」 → **「公開」を OFF**
- 「ゲストを追加」 = ゼロ
- ワークスペース内メンバー = 大井のみ (現状1名なので OK、将来採用時は **絶対共有しない**)

### 3. Notion アカウント自体の 2FA 強制
- Notion → Settings → Security → **2-step verification 有効化**
- 認証アプリ (Google Authenticator / Authy / 1Password OTP) を必須に
- ❌ SMS 2FA (SIM swap 攻撃に弱い)

### 4. Notion 連携アプリの最小化
- Settings → Connections で **不要な接続を全削除**
- 残すのは Slack (通知のみ) / Google Drive (画像参照) 程度
- ❌ AI 接続 (ChatGPT/Claude/Gemini Notion connector) → **アカウント管理ページが LLM 学習対象になりうる**

### 5. 「鍵そのもの」プロパティの命名規則
- プロパティ名は **`secret_*`** プレフィックス (例: `secret_password`, `secret_api_key`)
- これで API クエリ時に `secret_*` を除外する pre-filter を実装可能 (将来の Claude/MCP 連携時)
- Notion DB 自体は `notion-search`/`notion-fetch` MCP で読めるので、誤接続防止が肝心

### 6. エクスポートと暗号化バックアップ
- 毎週日曜 22:00: Notion → ワークスペース全エクスポート (Markdown & CSV)
- ダウンロード後 7zip で AES-256 暗号化 (パスワード長 32字+)
- 暗号化 zip を Google Drive (会社) + 物理USB 2本に複製
- 復旧テスト: 月1回 (Notion ダウンや誤削除に備える)

### 7. アクセスログ監視
- Notion → Workspace → Activity log を毎週日曜にチェック
- 不審な閲覧 (深夜・知らない端末) があれば即座にパスワード変更
- 「アカウント管理 DB」へのアクセスを抜き出して `brain/05_corp/infra/notion-access-log-YYYY-MM.md` に追記

---

## ⚠ Claude からの追加リスク警告 (大井の選択を尊重した上で)

| リスク | 影響 | 緩和策 |
|---|---|---|
| Notion パスワードが漏れた瞬間に全鍵が一気に流出 | 致命的 | 強い master password 30字+ + YubiKey 2FA |
| Notion 招待を間違って共有 → 即流出 | 致命的 | §2 「ページ共有完全閉鎖」徹底 |
| Notion AI/ChatGPT 連携で鍵が LLM 学習対象に | 致命的 | §4 「AI 連携を OFF」 |
| Notion 社が侵入された (低確率だが過去事例あり) | 致命的・対処不能 | §6 「定期暗号化バックアップ」で復旧経路確保 |
| 大井が iPad / 公共 Wi-Fi で Notion 開く → 漏洩 | 中 | VPN 経由 + 端末暗号化必須 |
| Notion アプリの auto-fill が他サービスに鍵を吹かす | 中 | auto-fill 無効 |
| Gmail に Notion ページ URL が来て検索可能 | 低 | Gmail フィルタで `notion.so` を専用ラベル |

→ **Notion 主は「楽だが脆い」。将来 (チームが2人以上になった瞬間) には必ず 1Password 移行を検討すべき。**

---

## 🚨 やらかし防止リスト

### ❌ 絶対やらない
- パスワードを Slack / Gmail / LINE / Discord で送る
- パスワードを Claude チャット (ここ) に貼る
- `.env` を git commit (gitignore チェック)
- API key を GitHub public リポにコミット → push → 即漏洩
- ブラウザのパスワード保存機能を信頼する (Win+Macで分断、漏洩時の影響大)
- 1パスワードを複数サービスで使い回す
- 2FA SMS をメインにする (SIM swap 攻撃のリスク)
- 物理 YubiKey を1本しか持たない (紛失時 = 詰む)

### ⚠ 要注意
- 公衆 Wi-Fi で管理者ログイン (VPN 経由推奨)
- スクリーンショットに鍵が映る (送信前確認)
- Claude / ChatGPT に鍵を貼る (学習・ログ保存リスク)
- Browser extension に過剰権限 (個別レビュー)

---

## 📋 新サービス契約時 5ステップ

```
[1] 申込前: 本当に必要か? 既存ツールで代替可能か?
       ↓ 5分考えてから契約
[2] 申込: メアド = <会社ドメイン>@... を基本 (個人と分離)
       ↓
[3] パスワード: 1Password Generator で 20文字以上ランダム生成
       ↓ 自動入力
[4] 2FA 設定: Yubikey(優先) or Authenticator
   バックアップコード → 1Password に保存
       ↓
[5] 記録: 
   - 1Password に保存 (鍵本体)
   - Notion「アカウント管理 DB」に1行追加 (棚卸し用・鍵以外の情報)
   - brain/05_corp/infra/company-accounts-inventory.md 更新 (正本)
```

---

## 🔄 旧個人アカウントからの移行ロードマップ

### Phase 1: 今日 (会社インフラ確立)
- ✅ ドメイン取得
- ✅ Google Workspace 契約
- ✅ Slack ワークスペース作成
- ✅ Notion 会社ワークスペース作成
- ✅ アカウント管理ページ準備
- 🟡 Claude (このファイル) で正本テンプレ作成 → **今ここ**
- ⏳ 1Password 契約 (今夜)
- ⏳ YubiKey 注文 (今夜)

### Phase 2: 今週 (重要 SaaS 移行)
- GitHub: 個人 ooi-yuei → 法人組織 (Organization) 作成 → リポ転送
- Vercel: Team 作成・既存プロジェクト転送
- Supabase: Org 作成・プロジェクト移管
- Anthropic: Workspace 移行 or 個人継続
- Stripe: 個人アカウント → 法人アカウント (KYC再審査必要)

### Phase 3: 月内 (周辺 SaaS 統合)
- Fireflies / Zoom / Linear / Asana → 会社メアドに切替
- Notion 旧個人 → 会社ワークスペースに必要DBコピー
- Discord 通知 → Slack #claude-alerts に並走
- 各種 X / LinkedIn → 会社メアド連携追加

### Phase 4: 来月 (会計・税務)
- 法人銀行口座開設 (GMOあおぞらネット銀行 推奨)
- 法人クレカ申込 (3-4週間)
- freee / マネーフォワード 契約
- 顧問税理士 検討

---

## 🎯 Claude (秘書室相当) の動き方

### 大井が言ってきたら自動でやる
- 「新サービス契約した」 → `company-accounts-inventory.md` に追加候補を質問
- 「パスワード変えた」 → 1Password 更新確認のリマインド
- 「2FAなくした」 → リカバリー手順を即提示 (鍵そのものは扱わない)
- 「解約したい」 → 解約手順 + 残データのエクスポート手順

### Claude が能動的にやる
- 月初 1日 Calendar 自動投入: アカウント棚卸し 30分
- Vercel / Supabase / GitHub の通知 (Gmail に来てる) を要約
- 不要 SaaS の解約候補を月次レポートで提案
- セキュリティ警告 (RLS無効・pause通知等) を発見次第即報告

### Claude がやらない (immutable)
- 鍵の入力・保存・転送・スクリーンショット
- 大井名義での新規アカウント作成
- 銀行・決済の実行
- 2FA リカバリーコードの代行入力

---

## 📞 緊急時連絡 / リカバリー手順

### Google Workspace 管理者アカウント乗っ取られた
1. 即座に他端末から `https://admin.google.com` でパスワード変更
2. YubiKey で 2FA 再認証
3. 全セッションをログアウト
4. ログ確認: 管理者コンソール → セキュリティ → ログ
5. 監査履歴を1週間スキャン

### 1Password マスターパスワード忘れた
1. リカバリーキー (印刷済) を取り出す
2. iPhone / Mac の生体認証で復元
3. リカバリーキーがない = 全データロスト (これだけは絶対避ける)

### スマホ紛失
1. Find My iPhone でリモートロック・ワイプ
2. Google Workspace → セキュリティ → 端末から該当端末を除外
3. YubiKey を新端末で再登録
4. 1Password アカウントから紛失端末を除外
5. 各サービスの 2FA を Authenticator から YubiKey に再設定

---

## 📂 関連

- 正本: [[05_corp/infra/company-accounts-inventory]]
- セッション履歴: [[01_ceo/decisions/]]
- 開発インフラ Supabase 警告: [[06_secretary/communications/2026-05-27-supabase-restore-handoff]]

---

## 🆕 大井への確認事項 (このルール承認用)

1. 1Password vs Bitwarden 選好? (推奨: 1Password Family $4.99/月 + YubiKey × 2本)
2. YubiKey 注文 OK? (Amazon で2本 ¥10,000 弱)
3. 法人銀行口座どこ? (GMOあおぞらネット銀行 ≈ Stripe 親和性高)
4. 顧問税理士 必要? (年商 3000万円 目前なら早めに動く価値あり)
5. このルールに加筆・修正したい部分?

---

## バージョン履歴

- v1 2026-05-27 Claude (Phase 2 + 会社インフラ確立時に新規作成)
