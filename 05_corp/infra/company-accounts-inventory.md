---
type: corp-infra
category: accounts-inventory
date: 2026-05-27
updated: 2026-05-27
managed_by: コーポレート部 (cfo / legal / hr-recruiter) + 秘書室 (secretary)
contains_secrets: false
note: このファイルには鍵そのものを書かない。「どこに保管されているか」のみを書く。
tags: [infra, accounts, security, sso, ownership]
---

# 株式会社 Almeo — 全アカウント正本

> **このファイルは「どのサービスを契約しているか・誰の所有か・鍵がどこにあるか」の正本。**
> 鍵そのものは **`brain/_secrets/accounts.md.encrypted`** (Obsidian Meld Encrypt 暗号化) に保管 (こちらには書かない)。
> Claude が読むファイル = 平文 LLM 送信リスクがあるため、鍵そのものは絶対に書かない。
> 大井方針 (2026-05-27): Slack = 連絡 / Notion = 進捗管理 / **Obsidian = 情報集積・会社の知能 + 鍵保管**

---

## 🔐 鍵保管ルール (絶対遵守)

| 鍵の場所 | 用途 | 推奨度 |
|---|---|---|
| **Obsidian Meld Encrypt (大井選択)** | パスワード・APIキー・リカバリーコード | ⭐⭐⭐ Obsidian内 AES-256・master password・Mac/Win/iPhone Obsidian同期で暗号化のまま転送・Claude読込禁止ゾーン |
| **Notion DB の secret-like property** | 共有・組織で見るパスワード | ⭐⭐ ただし Notion に「Password 型」なし。Text + 権限制限で運用 |
| **YubiKey / Titan Key** | Google Workspace 管理者 2FA / GitHub 2FA / AWS root | ⭐⭐⭐ 物理キー、フィッシング耐性 |
| **brain (Obsidian) ファイル** | **絶対書かない** | ❌ Mac同期 + Claude読込で漏洩 |
| **Gmail / Slack DM** | **絶対送らない** | ❌ サーバー保管・検索可能・スクショ漏洩 |
| **`.env` / `.env.local`** | 開発時のみ・gitignore必須 | ⚠ コミット禁止、本番は Vercel env vars 経由 |

---

## §1. 会社の根幹 (Identity)

### 法人情報
| 項目 | 値 | 鍵保管場所 |
|---|---|---|
| 法人名 | 株式会社 Almeo | - |
| 設立日 | [要確認] | - |
| 法人番号 | [要確認] | - |
| 代表者 | 大井湧瑛 (Yuei Ooi) | - |
| 事業内容 | AI/SaaS 開発・コンサルティング | - |
| 本店所在地 | [要確認・静岡] | - |

### ドメイン
| ドメイン | 用途 | レジストラ | 更新日 | 鍵保管 |
|---|---|---|---|---|
| `almeo.jp` (本日取得) | 会社メイン・Google Workspace | [要確認 (お名前.com / Cloudflare / etc)] | 1年後 | Obsidian `_secrets/` |
| `ooiyuei.com` (推測) | 個人ブランド | [要確認] | [要確認] | Obsidian `_secrets/` |

---

## §2. Google Workspace (今日契約)

| 項目 | 値 | 鍵保管場所 |
|---|---|---|
| プラン | [要確認 (Business Starter / Standard / Plus)] | - |
| 管理者メアド | `yuei.oi@almeo.jp` | Obsidian `_secrets/` |
| 月額 | [要確認 (Starter: ¥800/user, Standard: ¥1,600/user)] | - |
| ユーザー数 | 1 (大井) | - |
| 2FA | YubiKey 強く推奨 | Obsidian `_secrets/` (バックアップコード) |
| ストレージ | Drive (Starter 30GB / Standard 2TB) | - |

### Workspace 内サービス
- Gmail (`@almeo.jp`)
- Google Drive
- Google Calendar
- Google Meet
- Google Docs / Sheets / Slides

### 旧 Gmail との関係
- **個人**: `ooiyuei@gmail.com` (現在 Claude MCP 接続中)
- **会社**: `yuei.oi@almeo.jp` (今日取得)
- 切替戦略: [要判断] 完全移行 or 個人+会社並走

---

## §3. Slack (今日作成)

| 項目 | 値 | 鍵保管場所 |
|---|---|---|
| ワークスペース名 | [要確認] | - |
| URL | `[要確認].slack.com` | - |
| プラン | [要確認 (Free / Pro / Business+)] | - |
| 管理者メアド | `yuei.oi@almeo.jp` | Google Workspace 経由 |
| Slack App | Claude MCP 接続済 (個人 Slack に対して) → 新ワークスペースに切替必要 | - |

### チャンネル設計 (推奨)
- `#general` — 全社告知
- `#01-ceo` — 経営判断ログ
- `#02-newbiz` — 新規事業
- `#03-dev` — 開発 (Testall / Vercel deploy 通知 / GitHub PR)
- `#04-sales-marketing-cs` — 営業マーケCS
- `#05-corp` — コーポレート
- `#06-secretary` — 秘書 (Calendar・Gmail通知)
- `#07-research` — リサーチ
- `#08-openclaw` — OpenClaw 進捗
- `#claude-alerts` — Claude → Discord と並列で Slack にも投げる候補
- `#bots` — bot 通知

---

## §4. Notion (今日作成・会社ワークスペース)

| 項目 | 値 | 鍵保管場所 |
|---|---|---|
| ワークスペース名 | [要確認] | - |
| URL | `notion.so/[要確認]` | - |
| プラン | [要確認 (Free / Plus / Business / Enterprise)] | - |
| 管理者メアド | `[要確認]@<新ドメイン>` | Google Workspace SSO 推奨 |
| Notion MCP | 旧ワークスペースで接続中 → **新ワークスペースに再認証必要 (現状 401 unauthorized)** | - |

### 主要ページ (推奨構造)
- 🏠 **株式会社 Almeo** (ルート)
  - 📊 **事業一覧 DB** (既存・移行)
  - 🔐 **アカウント管理 DB** (今日大井作成・本ファイルの相棒)
  - 💰 **財務 DB** (P/L・キャッシュ・売上)
  - 👥 **人物 DB** (メンター・取引先・候補者)
  - 📅 **議事録 DB** (Fireflies / Zoom 連携)
  - 📋 **タスク DB** (今日のTODO・週次OKR)
  - 📚 **Wiki** (社内ナレッジ)

---

## §5. 開発インフラ (既存・正本確認)

| サービス | 用途 | アカウント | プラン | 鍵保管 |
|---|---|---|---|---|
| **GitHub** | コード管理 | ooi-yuei (or `[要確認]`) | [要確認] | Obsidian `_secrets/` (PAT) |
| **Vercel** | デプロイ | ooiyuei@gmail.com | Hobby (or Pro?) | Vercel CLI token は Obsidian `_secrets/` |
| **Supabase** | DB+Auth | ooiyuei@gmail.com | Free × 38プロジェクト [監査で発覚] | service_role keyはObsidian `_secrets/` |
| **Anthropic** | Claude API | ooiyuei@gmail.com | Pay-as-you-go | API key は Obsidian `_secrets/` |
| **OpenAI** | GPT API | [要確認] | [要確認] | API key は Obsidian `_secrets/` |
| **Stripe** | 課金 | [要確認 (個人 or 法人)] | 本番 | secret/restricted keyはObsidian `_secrets/` |
| **Cloudflare** | DNS+CDN | [要確認] | Free | API token は Obsidian `_secrets/` |

---

## §6. SaaS インフラ (既存)

| サービス | 用途 | 月額 | 鍵保管 |
|---|---|---|---|
| Notion (個人) | brain | $10 (推測) | - |
| Notion (会社・今日) | 会社運営 | [要確認] | - |
| Obsidian Sync | brain Mac/Win 同期 | $10/月 | アカウント情報Obsidian `_secrets/` |
| Discord | 通知 (個人) | Free | webhook URLは brain/scripts/config.json |
| Slack (会社・今日) | 社内 | [要確認] | - |
| Fireflies | 議事録 | [要確認] | MCP 接続済 |
| Zoom | ミーティング | Free? | - |
| Linear | タスク管理 | [要確認] | MCP 接続済 |
| Asana | タスク管理 | [要確認] | MCP 接続済 |
| Canva | デザイン | [要確認 (Free / Pro)] | MCP 接続済 |
| Figma | デザイン | Free? | MCP 接続済 |
| Sentry | エラー監視 | Free | MCP 接続済 |

---

## §7. 営業・マーケ

| サービス | 用途 | 鍵保管 |
|---|---|---|
| X (Twitter) | 発信 | Obsidian `_secrets/` |
| note | 記事 | Obsidian `_secrets/` |
| LinkedIn | ビジネス発信 | Obsidian `_secrets/` |
| Instagram | 個人発信 | Obsidian `_secrets/` |
| TikTok | (もし運用) | Obsidian `_secrets/` |
| 商工会議所 各種 | 法人会員 | [要確認] |

---

## §8. AI ツール

| サービス | 用途 | プラン | 鍵保管 |
|---|---|---|---|
| Claude (Anthropic) | 主力 | Pro × Claude Max + API | API key Obsidian `_secrets/` |
| ChatGPT | サブ | Plus (推測) | - |
| Cursor | IDE | Pro (推測) | API key Obsidian `_secrets/` |
| Codeium / GitHub Copilot | (もし) | - | - |
| Perplexity | リサーチ | Pro (推測) | - |
| Suno / Udio | (もし) | - | - |
| Midjourney | (もし) | - | - |

---

## §9. 金融

| 項目 | 用途 | 鍵保管 |
|---|---|---|
| 法人銀行口座 | [要開設 (GMOあおぞらネット銀行 / 楽天銀行ビジネス推奨)] | Obsidian `_secrets/` |
| 個人銀行 | 既存 | Obsidian `_secrets/` |
| 法人クレカ | [要発行 (三井住友BizPlatinum推奨)] | Obsidian `_secrets/` |
| 個人クレカ | 既存 | Obsidian `_secrets/` |
| freee / マネーフォワード | 会計 | [要契約] | アカウント情報Obsidian `_secrets/` |

---

## §10. 物理キー・ハードウェア

| 項目 | 用途 | 保管場所 |
|---|---|---|
| YubiKey #1 | Google Workspace 管理者 / GitHub 2FA メイン | 大井所持 |
| YubiKey #2 | バックアップ (金庫 or 信頼できる場所) | [要購入] |
| MacBook | 大井メインPC | 大井所持 |
| WindowsPC | brain 運用 | 大井所持 |
| iPhone | 通信 + 2FA Authenticator | 大井所持 |

---

## §11. 鍵管理運用フロー (推奨)

```
1. 新しい SaaS アカウント作成
   ↓
2. Obsidian `_secrets/` に保存 (パスワード + 2FA + リカバリーコード)
   ↓
3. brain/05_corp/infra/company-accounts-inventory.md に「[要確認] → [契約済]」更新
   ↓ ※鍵そのものは書かない
4. Notion「アカウント管理 DB」に1行追加 (サービス名 / 用途 / 大井のみ閲覧)
   ↓
5. 2FA を Yubikey + iPhone Authenticator にバックアップ
   ↓
6. 月次レビュー (毎月1日に Calendar で 30分): 棚卸し・未使用解約
```

---

## §12. 大井の判断ポイント (今日中)

### 🔥 緊急
1. **ドメイン名 + Google Workspace 管理者メアド + Slack URL + Notion URL** を本ファイルに記載
2. **Obsidian `_secrets/` (or Bitwarden) 契約**: Family/Teams プランで Mac/Win/iPhone 同期
3. **YubiKey 2本注文** (バックアップ用)

### 今週中
4. **法人銀行口座開設** (GMOあおぞらネット銀行 → Stripe接続用)
5. **freee or マネーフォワード 契約** (会計)
6. **Notion アカウント管理 DB を確定** (構造は §13 参照)

---

## §13. Notion「アカウント管理 DB」推奨スキーマ

> **大井が手動で作成 (Claude は鍵を入れない immutable rule)**

| プロパティ名 | 型 | 用途 |
|---|---|---|
| サービス名 | Title | "GitHub" "Vercel" "Stripe" |
| カテゴリ | Select | 開発/SaaS/金融/AI/営業/物理 |
| 用途 | Text | 何に使ってるか1行 |
| アカウント (メアド) | Text | 例: ooiyuei@gmail.com |
| プラン | Select | Free / Pro / Team / Business |
| 月額 | Number | ¥0-¥30000+ |
| 契約日 | Date | YYYY-MM-DD |
| 更新日 | Date | YYYY-MM-DD |
| ステータス | Select | 契約中 / 解約済 / 検討中 |
| 2FA有無 | Checkbox | true/false |
| 2FA方法 | Select | Yubikey / Authenticator / SMS |
| 鍵保管場所 | Select | **Obsidian `_secrets/`** / Notion / .env / 物理 |
| 鍵参照名 | Text | 例: "AIpaX-Stripe-Restricted" (Obsidian `_secrets/` 内の項目名) |
| 担当部署 | Multi-select | 経営企画/新規事業/開発/営業マーケCS/コーポレート/秘書/リサーチ |
| メモ | Text | 注意事項 |

> ⚠ **「パスワード」「APIキー」「Secret」プロパティを Notion に作らない**
> → Notion DB 全体に「平文の機密情報」が混在するとリスク。鍵は Obsidian `_secrets/` で外部参照。

---

## §14. Claude (俺) のアクセス境界 (immutable)

| Claude ができる | Claude ができない |
|---|---|
| ✅ このファイルの読み書き (鍵以外) | ❌ パスワード・APIキー・credentials の入力 |
| ✅ Notion DB の構造設計 | ❌ 大井の credential を使ってログイン |
| ✅ アカウント棚卸し・命名整理 | ❌ Obsidian `_secrets/` にアクセス |
| ✅ 月次レビューのリマインド | ❌ Stripe で実際の決済 |
| ✅ 2FA 設定手順の説明 | ❌ 銀行送金・投資判断 |
| ✅ 解約候補リストの提案 | ❌ 鍵をスクリーンショットや brain に書く |

→ **鍵は常に大井の手作業。Claude は構造と運用フローを設計する。**

---

## §15. 関連ファイル

- 運用ルール: [[06_secretary/communications/2026-05-27-accounts-management-rules]]
- Notion DB テンプレ: [要作成・大井手作業]
- セキュリティ監査履歴: [[01_ceo/decisions/]] (今後)
- Supabase RLS 警告: [[06_secretary/communications/2026-05-27-supabase-restore-handoff]]
