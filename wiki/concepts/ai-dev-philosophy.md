---
type: concept
title: AI開発の哲学・運用ルール（新人向け統合版）
created: 2026-05-14
updated: 2026-05-14
tags: [framework, ai-development, methodology, onboarding, runbook]
related: [[concepts/ai-dev-flow]]
---

# AI開発の哲学・運用ルール

> 「AIアプリ開発マニュアル」＋「AIアプリ開発手順書」を統合した、新人が再現できる開発OS。

## 0. 基本スタンス

AIを使う目的は、ただ楽をすることではない。

**試行回数を増やして、速く正しい方向に寄せること**が目的。

進め方は「人が全部考えてからAI」ではなく、次のループを回す：

```
人が方向を決める
  → AIに思考整理させる
  → AIに実装させる
  → 人が確認して次の方向を決める
```

## 1. ツールの役割分担

| ツール | 役割 | ひとことで |
|--------|------|-----------|
| **ChatGPT（チャッピー）** | 思考整理・設計・壁打ち・PM・文章化 | 考える・まとめる・指示を書く |
| **Claude + Cursor** | 実装・修正・多ファイル変更・連続開発 | 作る・直す・前に進める |
| **Notion** | 記録・共有・再利用（記憶装置） | 残す・共有する・再利用する |

### Notionに残すもの

- プロジェクト方針 / 仕様 / スプリントログ / 運用ルール / AIに投げるテンプレ / 振り返り / 新人マニュアル

## 2. 超基本ルール（最重要）

1. **ChatGPT に考えさせてから、Claude + Cursor に作らせる**
   - いきなり Cursor で作り始めない
   - 先に固めるべきこと: 何が問題か / 何を優先するか / 何を作るか / 何は作らないか / 成功条件は何か

2. **Claude + Cursor には、曖昧な指示を出さない**
   - 悪い例: 「なんか改善して」「いい感じにして」「UI直して」
   - 良い例: 「`/executive` を経営AIの主役画面として改善する。上部のメモを件数報告ではなく経営解釈に変える。2時間自走で5バッチ以上進めて production まで持っていく」

3. **1回のセッションで1テーマに絞る**
   - Billing なら Billing だけ / 経営AI精度ならそれだけ

4. **実装後は必ず ChatGPT にレビューさせる**
   - Claudeのレポートをそのまま信じない
   - 確認: 方向は合っているか / 次に何をやるべきか / まだ弱いところは何か

5. **できるだけ本番URLで確認**

## 3. 開発の基本フロー（6ステップ）

| Step | 内容 |
|------|------|
| 1 | ChatGPT に雑に相談（頭の中をそのまま投げる） |
| 2 | ChatGPT に整理させる（問題・優先・主役・画面構造・prompt） |
| 3 | Cursor + Claude に runner prompt を投げる（**スプリント単位**） |
| 4 | 実装する（dev → build → commit → deploy） |
| 5 | 結果を ChatGPT にレビューさせる |
| 6 | Notion に残す（やったこと・改善点・次の一手・prompt） |

### スプリント単位の意味

- 1機能ではなく**1テーマ**で進める
- 2〜3時間自走 / 5バッチ以上 / API・UI・validation を含める / production-safe / レポート形式指定

## 4. プロンプトテンプレ

### ChatGPT に投げるテンプレ

```text
今の状況:
-
-

困っていること:
-
-

聞きたいこと:
- 何が問題か
- 次にやるべき最適な一手
- Claude / Cursor に投げる runner prompt を作って
```

### Cursor + Claude に投げるテンプレ

```text
今回の目的:
-

やること:
-
-

やらないこと:
-
-

条件:
- 2〜3時間自走
- permissionを都度聞かない
- API / UI / validation を含める
- production-safe に進める
- 最後に変更内容 / リスク / 検証 / URL をレポートする
```

## 5. 必要な準備（環境構築）

### 必須アカウント
ChatGPT / Cursor / Claude / GitHub / Vercel / Notion

### 必須アプリ
ChatGPT app / Cursor / Git / Node.js / Chrome

### 初回セットアップ
```bash
git clone <repo-url>
cd <repo-name>
npm install
npm run dev

# Vercel連携
npm i -g vercel
vercel login
vercel link
```

## 6. 新人がやりがちな失敗

- いきなり Cursor で作り始める → 方向がズレる
- ChatGPT に雑に終わる → prompt が弱い
- Claudeの短いレポートで満足 → 実際は浅い
- 1回で色々やろうとする → 深まらない
- production 反映まで見ない → 使える状態か不明

## 7. トラブル対応

| 症状 | 対応 |
|------|------|
| Cursor が動かない | 再起動・ログイン確認・Node/Git確認 |
| Claudeの実装が浅い | promptを重くする・完了条件を増やす・tuning pass必須にする |
| ChatGPT がふわっとしてる | 問いを具体化・「次の一手を断定して」・「code blockで prompt 出して」 |
| デプロイできない | env確認・Vercel project link確認・build error優先で直す |

## 8. 1日の使い方（毎日のルーティン）

### 朝
1. 今日触るテーマを1つ決める
2. ChatGPT に現状と課題を投げる
3. スプリント用 prompt を作る

### 昼
1. Cursor + Claude で2〜3時間開発
2. 途中で build / lint / local 確認
3. デプロイまで持っていく

### 夕方
1. レポートを ChatGPT に渡す
2. 次の一手を決める
3. Notion に残す

## 9. 結論

```
ChatGPT  → 考える・整理する・決める・レビューする
Claude   → 作る・直す・進める・デプロイする
Notion   → 残す・共有する・再利用する
```

**全部を人がやる**でも、**全部をAIに丸投げ**でもない。

**人が方向を決め、ChatGPTで整理し、Cursor + Claude で実装し、また ChatGPT で評価する。**

---

*出典: `.raw/2026-05-14-session-5/01-ai-dev-procedure.md` + `.raw/2026-05-14-session-5/02-ai-dev-manual.md`*
