# 運用ルール — 大井のブレイン

> このファイルはセッション冒頭に必ず読む。エージェント/スキル/MCP を仕組みで使うためのガイド。
> 「いつ・何を・どう呼ぶか」を明文化。

## セッション分類

| セッション | 目的 | 場所 |
|----------|------|------|
| **ブレイン（このセッション）** | 全体管理・意思決定・PDFインポート・15プロジェクト管理 | `~/business/brain/` |
| **開発セッション** | 1プロジェクトのコード書き | `~/business/アプリ/{project}/` |
| **調査セッション** | 市場リサーチ・競合分析 | ブレインから派生 |

---

## ブレインセッションで使うエージェント

### 自動で呼ぶべきトリガー

| トリガー | エージェント | 何をするか |
|----------|------------|----------|
| 新事業アイデアが浮かんだ | `idea-generator` agent | 仮説を量産・課題ベース選別 |
| アイデアを評価したい | `/idea-judge` skill | 10項目採点 → tier判定（Go/Hold/Kill）|
| 事業案を磨きたい | `business-refiner` agent | 現実成立する案へ再構成 |
| 厳しくレビューしたい | `red-team-reviewer` agent | 弱いまま進ませない |
| 市場・競合を調べたい | `researcher` agent | 根拠付きレポート |
| 毎朝のシグナル収集 | `scout` agent | 競合動向・顧客不満を事実ベース報告 |
| 今日何やるか決めたい | `secretary` agent | 長期目標から逆算 |
| プロジェクト全体統括 | `ceo-orchestrator` agent | フェーズ別チーム起動 |
| 提案書作る | `/team-proposal` skill | 3人チーム起動 |

### 例: 新事業の標準フロー

```
1. /idea-generator で30案出す
2. /idea-judge で各案を10項目採点
3. tier S/A を business-refiner で磨く
4. red-team-reviewer で穴を探す
5. /prd でPRD化
6. /team-design で設計
7. 開発セッションへ渡す
```

---

## 開発セッションで使うエージェント

> 各プロジェクトの CLAUDE.md にも記載。ブレインからは指示を出すだけ。

| 段階 | エージェント/スキル |
|------|----------|
| 新機能の計画 | `planner` agent → `/prd` skill |
| アーキテクチャ決定 | `architect` agent |
| テスト先行で実装 | `tdd-guide` agent |
| MVP切り出し | `/mvp-slicer` skill |
| コード書いた直後 | `code-reviewer` agent |
| セキュリティ確認 | `security-reviewer` agent |
| ビルド失敗時 | `build-error-resolver` agent |
| DB絡み | `database-reviewer` agent |
| デッドコード掃除 | `refactor-cleaner` agent |
| E2Eテスト | `e2e-runner` agent + `/e2e` skill |
| ドキュメント更新 | `doc-updater` agent + `/update-docs` skill |

---

## 専門領域エージェント（必要時に呼ぶ）

| 領域 | エージェント | いつ |
|------|----------|------|
| 財務 | `cfo` agent | 月次/四半期/EXIT試算 |
| 法務 | `legal` agent | 契約書/利用規約レビュー |
| HR | `hr-recruiter` agent | 外注/フリーランス採用 |
| 営業 | `sales-rep` agent | リード/商談/提案 |
| マーケ | `marketer` agent | SEO/広告/SNS/LP |
| CS | `customer-success` agent | 解約防止/アップセル |

---

## 接続済みMCP（積極的に使う）

| MCP | 用途 |
|-----|------|
| **Stripe** | 課金設計・サブスク・請求 |
| **Supabase** | DB設計・マイグレーション・型生成 |
| **Google Drive** | ファイル読み込み・共有 |
| **Figma** | デザインコンテキスト取得 |
| **Notion** | 公開ページ管理・ナレッジ |
| **Slack** | チームコミュニケーション |
| **Gmail** | メール検索・下書き |
| **Calendar** | 予定確認・調整 |
| **Linear** | Issue/PR管理 |
| **Sentry** | エラー監視 |
| **Vercel** | デプロイ・ログ |
| **Asana** | タスク管理 |
| **Fireflies** | 議事録 |
| **Zoom** | 録画検索 |

---

## デザイン関連の鉄則

UIを作る時は必ず:
1. `~/.claude/design-md/STYLE-PICKER.md` を読む
2. プロジェクトに合うStyleを1〜3個選ぶ
3. 選んだ `~/.claude/design-md/{slug}/DESIGN.md` を読み込む
4. **和文フォント優先 / line-height 1.7〜2.0 / palt有効** を必ず守る

---

## 失敗パターン（やらないこと）

- ❌ エージェント呼ばずに自分で全部やる → 並列化できる仕事を直列でやってしまう
- ❌ スキル呼ばずに同じことを毎回ゼロから組み立てる → 品質ブレる
- ❌ MCP接続済なのにWebFetchやBashで代用する → 認証/権限で詰まる
- ❌ デザインを毎回ゼロから考える → STYLE-PICKERから選ぶ

---

## 毎セッション冒頭のルーチン

1. このファイル（運用ルール.md）を読む
2. `40_daily/template.md` から今日の日報を起こす
3. 必要なら `secretary` agent に今日のフォーカスを決めてもらう
4. プロジェクト固有作業なら該当の `10_projects/{name}.md` を読む
