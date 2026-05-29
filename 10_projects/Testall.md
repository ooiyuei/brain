# Testall

> **一言**: テスト結果を、次の45分でやるべき勉強に変える。受験戦略OS。
> 「勉強は才能よりマネジメント」

## 現状 (2026-05-27 更新)
- フェーズ: **v0.6+ 本番運用可能レベル** (HANDOFF_AUTH.md / dev-plan.md より)
- スタック: Next.js 16.2.6 + React 19.2.4 + Supabase (ssr) + Anthropic SDK 0.95 + Sentry + Tailwind v4
- アプリ実体: `C:\Users\Owner\business\apps\testall\` (日本語パス `アプリ/testall` は空フォルダ・名残)
- リポ: github.com/ooiyuei/testall (public, main, 直 main 運用、PR/Issue 0件)
- Vercel deploy: prj_rVwl6zmRFWhsJOURnEW8HMuzlzu6 / team_3HJIyzwuV3Jou9KUAwoi5W2B 自動デプロイ稼働中
- 本番 URL: testall-git-main-ooiyuei-4097s-projects.vercel.app (branch alias)
- localhost:3010 dev
- **別 Claude Code セッション (`session_01LHsTLTpRMK5mUXkbGF9yx4`) で現在 a11y 改善コミット連投中** — 干渉禁止

## 完了済み (v0.5-0.6)
- ✅ Supabase Auth (Google OAuth, magic link, ゲストモード)
- ✅ 全データ Supabase 同期 (profile/tests/blockLogs/tasks/events/dailyMoodLogs/planning/weeklyGoals/fixedSlots)
- ✅ RLS (user_id = auth.uid())
- ✅ Claude Vision で画像入力 (`/api/diagnose-from-image` 4MB制限・mediaType検証)
- ✅ dnd-kit で計画ドラッグ&ドロップ
- ✅ TodaySuggestion (AI提案)
- ✅ AIチャット Sara (Anthropic SDK + 音声入力)
- ✅ PWA + GuideTour + Service Worker + InstallPrompt
- ✅ 参考書DB 2,888冊 (NDL+openBD + community_textbooks UGC + ISBNバーコード読取)
- ✅ ダークモード + Cmd+K 検索パレット + Onboarding + StreakHeatmap + LoginBonus
- ✅ Sentry 統合 (DSN設定待ち)
- ✅ 共通テスト予想・偏差値自動補正・週次振り返り・固定スロット

## 残課題 (優先順)
1. **Sentry DSN セット** (`.env.local` + Vercel 環境変数)
2. **Stripe 課金** (無料:テスト1件 / 有料:無制限+画像入力)
3. **Phase B AI深掘り 200冊** (`scripts/enrich-textbooks.ts` + ANTHROPIC_API_KEY、5-10分で完了)
4. Apple OAuth (Apple Developer $99/年 + Service ID 設定)
5. 通知 (Web Push)
6. E2E テスト (Playwright)
7. (v0.7+) 主要200冊の目次手書きレビュー、AI チャット会話履歴 RAG 化

## β5名リリース (シンコーダー 11ステップ Step 5 適用)
- 期限: **2026-06 中** (大井の方針)
- 必要機能: Supabase Auth ✅ + 画像入力 ✅ + Stripe ❌ ← Stripe 完成すれば β リリース可能

---

## プロダクト概要

### ターゲット
高校生・浪人生（スマホメイン）

### コアバリュー
テスト返却 → 弱点を特定 → **今日の45分の勉強タスク** に自動変換

「何を勉強すべきか」という意思決定を排除し、実行率を上げる。

### 解決する課題
- テストを受けても何を復習すべきか分からない
- 勉強計画が続かない
- やる気ではなく「仕組み」で成績を上げたい層にリーチできていない

---

## 機能設計

### メイン機能
1. **テスト追加** — 科目・点数・分野別ミスを入力
2. **AI診断** — Claude APIが弱点分析・優先度付け
3. **集中モード** — 今日やるべき45分タスクを提示 + タイマー
4. **週計画** — 週単位の学習スケジュール管理
5. **マイページ** — 成長記録・連続学習日数

### アプリ構造
```
src/app/
├── page.tsx          ← LP
├── app/              ← スマホUI（下部5タブ）
│   ├── page.tsx      ← ホーム
│   ├── test/         ← テスト一覧・追加
│   ├── plan/         ← 週計画
│   ├── focus/        ← 集中モード
│   └── me/           ← マイページ
├── api/
│   ├── diagnose/     ← Claude AI診断
│   └── waitlist/     ← 先行登録
└── start/            ← /app へリダイレクト
```

---

## 事業計画 v1.5

### 料金設計
| プラン | 価格 | 内容 |
|--------|------|------|
| Free | 無料 | テスト3回まで、基本診断 |
| スタンダード | 500円/月 | 無制限テスト、AI診断、集中モード |
| プレミアム | 1,500円/月 | 全機能 + 詳細分析 + 優先サポート |

### 市場規模
- TAM: 2,160億円（受験市場全体）
- SAM: スマホで勉強管理したい高校生・浪人生層
- SOM: 先行登録からのバイラル獲得

### GTM戦略（Go-to-Market）
1. **TikTok** — 「テスト結果→AI診断」のビフォーアフター動画
2. 受験期（夏〜秋）に集中投下
3. 先行登録 → 無料体験 → 有料転換

### 競合との差別化
- 既存の学習アプリ: 「何を勉強するか」は自分で決める必要がある
- Testall: テスト結果を入力するだけで「今日やること」が決まる
- AIが診断 → **実行まで一貫**

---

## AI設計

### Claude API活用
- モデル: claude-sonnet-4-6（速度重視）→ 深い分析はopus
- エンドポイント: `/api/diagnose`
- プロンプト: `src/lib/prompts/` に集約

### 診断ロジック
テスト結果（科目・点数・分野別ミス）→ 弱点優先度マトリクス → 45分タスク生成

---

## 開発ルール（CLAUDE.md より）
- ダミーデータは `// TODO: 実データに置き換え` コメント必須
- Supabase接続前はsessionStorageで仮実装OK
- 1機能動いたらコミット（ビルドが通る状態で）
- mainブランチは動くものだけ

## メモ


---

## 活動ログ

<!-- セッション終了プロトコル: ここに `### YYYY-MM-DD HH:MM` 形式で Claude が自動追記する -->
