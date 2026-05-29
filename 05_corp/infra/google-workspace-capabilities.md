---
type: corp-infra
category: workspace-capabilities
date: 2026-05-27
title: Google Workspace 契約後にできること + Claude 連携アクション全リスト
audience: 大井湧瑛 (法人化メリット理解 + Claude 自走範囲確認)
tags: [workspace, gmail, calendar, drive, claude-mcp, integration]
---

# Google Workspace 契約後 — 株式会社 Almeo がやれる事 全リスト

> 2026-05-27 契約。プラン未確定 ([要確認] / 推奨: Business Standard ¥1,600/user)。
> ここに **「会社としてできること」 × 「Claude (俺) が今すぐ動けるアクション」** を網羅。

---

## §0. 結論先出し (大井が一番知りたい部分)

✅ **メール**: Claude が下書き〜送信予約まで実行可能 (実送信は大井クリック)
✅ **カレンダー**: イベント作成・更新・他人と時間調整・自動再スケジュール
✅ **Drive**: 接続次第で参照・整理 (現状 MCP 未接続だが追加可能)
✅ **法人化メリット**: SSO ハブ・独自ドメイン信頼感・Vault 法的保全・36+ 連携アプリ
⚠ **Claude immutable**: パスワード入力・銀行操作・credential 代行は不可

---

## §1. プラン別機能比較

| 機能 | Starter ¥800/u | Standard ¥1,600/u | Plus ¥2,500/u |
|---|---|---|---|
| 独自ドメインメール | ✅ | ✅ | ✅ |
| Drive ストレージ | 30GB | 2TB | 5TB |
| Meet 録画 | ❌ | ✅ | ✅ |
| Meet 文字起こし | ❌ | ✅ | ✅ |
| 名簿100名超 | ❌ | ✅ | ✅ |
| Vault (法的保全) | ❌ | ❌ | ✅ |
| Cloud Search | ❌ | ❌ | ✅ |
| eDiscovery | ❌ | ❌ | ✅ |
| 高度な管理 | ❌ | △ | ✅ |

> **推奨 (1人運営の今)**: Business Standard ¥1,600/月。Meet 録画 = AIpaX 商談自動議事録化。Drive 2TB = brain backup 全件持てる。

---

## §2. メール (Gmail) でできること

### 大井の手元 + Claude 経由両方
- ✅ 独自ドメインで `<名前>@<新ドメイン>` 発信 (信頼感アップ)
- ✅ ラベル/フィルター/転送ルール (Claude MCP で設定可)
- ✅ 署名 (法人住所・電話・URL 標準化)
- ✅ エイリアス (`info@` `support@` `sales@` 全部受信 → 大井1人に集約)
- ✅ 委任 (将来採用したら大井宛メールを共有閲覧)
- ✅ 自動応答 (休暇通知・遅延応答 SLA)
- ✅ 配信元認証 (SPF/DKIM/DMARC — 商工会議所メールの到達率改善)

### Claude (俺) が今すぐ実行可能
| アクション | 必要MCP | 大井承認 |
|---|---|---|
| メール検索 (`from:メンター 名前`等) | Gmail MCP ✅ | 不要 |
| 下書き作成 (商工会議所・営業) | Gmail MCP ✅ | 不要 |
| ラベル作成・付与 | Gmail MCP ✅ | 不要 |
| スレッド要約 | Gmail MCP ✅ | 不要 |
| **送信実行** | Gmail MCP ✅ | **必要** (immutable) |
| 自動応答テンプレ作成 | 手動設定ガイド | - |
| フィルター作成 | 手動設定ガイド | - |

→ Claude 推奨ワークフロー: 「下書き10本一気に作る → 大井確認 → ボタン押すだけ送信」

---

## §3. カレンダー (Calendar) でできること

### 法人化で広がること
- ✅ 会議室/設備の予約 (将来オフィス取った時)
- ✅ チームカレンダー (将来複数人なら)
- ✅ 予定の空き時間共有リンク (営業に貼れる URL を発行・相手は時間選ぶだけ)
- ✅ Workspace内で時間調整自動化 (`suggest_time` MCP)
- ✅ Meet リンク自動生成

### Claude (俺) が今すぐ実行可能
| アクション | 必要MCP | 大井承認 |
|---|---|---|
| イベント作成 (1人ブロック・他人招待) | Calendar MCP ✅ | 不要 (個人カレンダー) |
| イベント更新・削除 | Calendar MCP ✅ | 不要 |
| 「来週の空き時間提案」 | Calendar MCP ✅ | 不要 |
| 出席返信 | Calendar MCP ✅ | 不要 (immutable: 重要会議は確認推奨) |
| カレンダー一覧 | Calendar MCP ✅ | 不要 |
| **予定変更通知メール送信** | Gmail+Calendar | **必要** |

→ 提案: 「商工会議所訪問予約フォーム」 = `calendar.app.google.com/<会社ID>` の公開リンクを LP に貼って自動予約受付

---

## §4. Drive でできること

### 法人特典
- ✅ 共有ドライブ (法人所有・大井退職しても消えない)
- ✅ ファイルロック・履歴30日
- ✅ DLP (機密ファイル誤共有検知)
- ✅ Backup & Sync (PC のフォルダを自動 backup)

### Claude 連携
| アクション | 状態 |
|---|---|
| ファイル検索 | ❌ Drive MCP 未接続 (要セットアップ) |
| ファイル参照 (Notion経由) | ✅ 部分的 (Notion で Drive 埋め込み) |
| Docs/Sheets 操作 | ❌ 未接続 |

→ Drive MCP 接続後: PDF 議事録・契約書・提案書を Claude が検索 → サマリー生成可能

---

## §5. Meet (オンライン会議)

### Standard 以上で
- ✅ 自動録画 (将来商談で活用)
- ✅ 文字起こし (Gemini-powered)
- ✅ ノイズキャンセル
- ✅ ブレイクアウトルーム (将来勉強会で活用)

### Claude 連携
- Fireflies MCP ✅ で議事録取得・サマリー (現状動作中)
- Zoom MCP ✅ も並列
- 商談録画 → Fireflies/Gemini で文字起こし → Claude が「次のアクション」抽出

---

## §6. その他 (Docs/Sheets/Slides/Forms/Sites)

| ツール | できること | Claude連携 |
|---|---|---|
| Docs | 共同編集・テンプレ・コメント | MCP未接続だが Notion 経由参照可 |
| Sheets | 表計算・データ集計・グラフ | 同上 + Code Interpreter で読込可 |
| Slides | プレゼン (夢AWARD・SFC AO 等) | テンプレ提案 |
| Forms | アンケート (AIpa Web 申込・CS NPS) | ✅ URL 発行して告知文に貼る |
| Sites | 簡易LP・社内Wiki | ⚠ プロには Vercel + Next.js 優位 |

→ Forms 即活用案: AIpa Web モニター3社申込フォーム / Testall β5名 NPS / 大井塾エントリー

---

## §7. 法人化メリット (SaaS連携の起点)

### SSO ハブとして
- Google Workspace アカウントで以下に SSO:
  - Notion (Business+)
  - Slack
  - Vercel
  - Supabase
  - Stripe (一部)
  - GitHub (要設定)
  - Linear
  - Asana
- → **マスターIDは Google ひとつ**、各サービスは「Google でログイン」で派生
- → master 1個漏洩 = 全部やられるので YubiKey 2FA 必須

### ブランド信頼感
- 商工会議所メール `<名前>@<会社ドメイン>` = 「個人ぽさ」消える
- AIpaX 既存4社への請求書発行で法人発信
- LP のお問い合わせフォーム → 会社メアド → 信頼感アップ
- SPF/DKIM/DMARC 設定で配信到達率改善 (商工会へのメール届く確率上がる)

### Vault (Plus 限定)
- 全メール・チャット・Drive を法的保全
- 訴訟・労基 case で **「証拠保全完璧」** = 大企業との取引で必須化されるケースあり

---

## §8. 大井が今夜やるべき設定 (30分)

### Phase 1: 基本セットアップ
1. **MX レコード設定** (ドメインレジストラ側で Google が自動指示する5レコードを追加 → メール受信開始)
2. **SPF/DKIM/DMARC** 設定 (Workspace Admin → Apps → Gmail → Authenticate Email)
3. **管理者2FA を YubiKey に** (Admin → Security → 2-Step Verification → Security Key)
4. **エイリアス作成**: `info@` `sales@` `support@` を大井1人受信に集約
5. **署名作成**: 法人名・URL・SNS リンク統一

### Phase 2: 既存個人 Gmail との関係決め
- A. 完全移行: ooiyuei@gmail → 新会社メアドへフォワード設定
- B. 並走: 個人 = ooiyuei@gmail、会社 = `<新ドメイン>` で使い分け
- C. ハイブリッド: ooiyuei@gmail を会社メアドのエイリアスに統合 (技術的にやや複雑)

→ **推奨**: B (並走)。理由: 個人 SaaS 契約多すぎて全部メアド変更は1日仕事 + Stripe 等は KYC 再審査になる

### Phase 3: Claude MCP の再接続
- Gmail MCP: 現状 ooiyuei@gmail に接続中 → 会社メアドも追加接続するか?
- Calendar MCP: 同上
- → 推奨: 会社メアド側を新規接続として追加 (個人とは別MCP接続)

---

## §9. Claude (俺) が今すぐ提案できる7アクション

大井が「これやって」と言えば、確認なし即実行できるリスト:

1. **商工会議所3社の追加3社へメール下書き** (会社メアド前提・SPF/DKIM 設定後)
2. **「AIpa Web モニター申込フォーム」 Google Forms 作成**指示書 (大井5分で作成)
3. **AIpaX 既存4社への紹介プログラム メール 下書き 4本** (1社1本カスタム)
4. **法人メアド予定共有リンク** 作成 → LP に貼る用URL生成手順書
5. **Workspace Admin 初期セットアップ チェックリスト** (今夜30分版)
6. **法人化 → SaaS 移管ロードマップ** (GitHub Org/Vercel Team/Stripe 法人/Anthropic Workspace)
7. **会社メアド署名10案** (堅め/フランク/CTAあり/英語版 等)

---

## §10. Claude (俺) ができないこと (immutable)

| ❌ できない | 理由 |
|---|---|
| Workspace パスワード代行ログイン | credential 操作禁止 |
| MX/DNS レコード代行設定 | 大井のレジストラ管理画面ログイン必要 |
| Stripe で実際の決済 | 金融操作禁止 |
| 銀行送金 | 同上 |
| Workspace 管理者2FA代行設定 | 大井の YubiKey 物理操作必要 |
| 「重要メール」の最終送信実行 | immutable: 下書きまで、send は大井クリック |

---

## §11. 1週間ロードマップ (Workspace 投資の回収最速ルート)

### 5/27 (今日) — 基本セットアップ
- MX・SPF・DKIM・DMARC 設定
- 管理者2FA YubiKey
- 署名 + エイリアス
- 個人 Gmail との並走設定 (Phase 2-B)

### 5/28 (明日) — 営業連携
- AIpa Web モニター申込フォーム作成
- 商工会議所3社追加 (浜松・沼津・静岡地域に追加3商工会) ヒアリング
- 既存3商工会メール再送 (会社メアドで信頼感アップ)

### 5/29-5/30 — 既存SaaS統合
- GitHub Organization 作成
- Vercel Team 作成
- Notion Business プラン (SSO 必須なら) 検討

### 5/31-6/2 — 自動化
- Gmail フィルターで Vercel/Stripe/Supabase 通知を整理
- Calendar 予定共有リンクを LP に貼る
- Google Forms NPS テンプレ

### 6/3 (月) — tobira-log CPA 測定と並行
- AIpa Web 5/26 着弾 inbox 分の昇格判定継続
- Workspace 使い始めて1週間レビュー (改善点を NOTES.md 追記)

---

## §12. コスト

| 期間 | コスト | 内訳 |
|---|---|---|
| 月額 | ¥1,600/u × 1名 = **¥1,600** (Business Standard 想定) | - |
| 年額 | **¥19,200** | - |
| 投資回収 | 商工会1社からの紹介で 1案件契約取れれば即 pay back | - |

---

## 関連
- アカウント正本: [[05_corp/infra/company-accounts-inventory]]
- 鍵保管ルール: [[06_secretary/communications/2026-05-27-accounts-management-rules]]
- Obsidian _secrets 手順: [[_secrets/obsidian-secrets-setup-guide]]
