---
type: source-deep
title: 非エンジニアのためのAIコーディングの教科書 Part12 (pages 221-240)
created: 2026-05-27
source_pages: 221-240
related: [[sources/ai-coding-textbook-deep/INDEX]]
tags: [ai-coding, deep-read, cli, git, github, gemini-cli, antigravity, claude-code, codex]
---

# Part 12: pages 221-240 完全ノート

## 概要

第10章「CLIコーディング」の末尾（p221-225）と、第11章「Git + GitHub 入門」（p226-240）にまたがるパート。

CLIエージェントの導入（Gemini CLI / Antigravity）と、AIコーディングの土台となる「コードのバージョン管理（Git）」「リモート共有（GitHub）」のメンタルモデルを、非エンジニアでも分かるように噛み砕いて説明している。

特に重要なのは「AIコーディングを本気でやるならGit/GitHubの理解は避けられない」という宣言と、Linus Torvalds が Git を作った経緯のミニコラムで、ツールへの敬意と必然性を植え付けてくる構成になっている点。

---

## 📑 セクション構成

| ページ | セクション | 種別 |
|---|---|---|
| 221 | 第10章 CLIコーディング - インストール承認の続き | 手順 |
| 222 | CLIで何ができるか / Gemini CLI と Antigravity の比較 | 解説 |
| 223 | Gemini CLI のインストール手順 | 手順 |
| 224 | コラム「AI時代のCLI習熟」 | コラム |
| 225 | CLIまとめ / Git・GitHub への接続 | ブリッジ |
| 226 | **第11章 Git + GitHub 入門** 章扉 | 章扉 |
| 227 | Gitの位置づけ（Google Docsの差分管理に例える） | 概念 |
| 228 | コラム「Git と Linux と Linus Torvalds」 | コラム |
| 229 | Gitの基本動作（コミット・履歴） | 概念 |
| 230 | AIコーディングにおけるGitの役割 | 概念 |
| 231 | Git と GitHub の役割分担 | 概念 |
| 232 | GitHub × AI（Jules / Codex / Claude Code Web） | 概念 |
| 233 | Repository（リポジトリ）とは | 用語 |
| 234 | GitHub Projects / ローカル vs リモート | 用語 |
| 235 | Branch（ブランチ）と main | 用語 |
| 236 | Pull / Push / Merge の流れ | 用語 |
| 237 | Git のインストール（Windows 手順） | 手順 |
| 238 | Git のインストール（Mac 手順 / Xcode・Homebrew） | 手順 |
| 239 | GitHub アカウント作成 / Sign Up | 手順 |
| 240 | Create Repository / gemini-chat リポジトリ作成 | 手順 |

---

## セクション別詳細

### p221 — 第10章 CLI継続：インストール承認

直前ページ（p220）からの続き。Gemini CLI / Antigravity のインストール時に出る承認プロンプトについて。

- 「1 (Yes, allow once) Enter」と入力して **一度だけ許可** を出すパターン
- Antigravity の README に従ってAPIキー設定 → 起動
- CLIを抜けるときは `Ctrl + C` または `/quit` Enter

### p222 — Gemini CLI と Antigravity の比較

- Gemini CLIは **3章** で扱った Antigravity と同じ Google の AI コーディング製品
- CLIは **第8章** で軽く触れたが、本格的に使うのは第10章
- 「CLIに慣れておくと、他のAI CLIにも応用が効く」というメッセージ

### p223 — Gemini CLI インストール

```bash
npm install -g @google/gemini-cli
```

- グローバルインストール（`-g`フラグ）
- これ1コマンドでCLIが使えるようになる前提

### p224 — コラム「AI時代のCLI習熟」

非エンジニアにとっての CLI 学習の意義を語るコラム。

**要旨:**
- AI（Claude Code, Codex 等）の登場で **CLIが再評価されている**
- Anthropic の Claude（Claude Code）も Cursor（IDE）も、本質はCLI操作
- 第9章で触れたように、AIに任せるパートは増えるが、 **指示と確認はCLIで行うのが最速**
- 「CLIだから難しい」のではなく、AIが対話してくれるので **逆に初心者の味方**
- Claude Code や Codex のような AI CLI は、CLIに **慣れる入口** として最適

### p225 — CLIまとめ / Git・GitHubへの接続

- 第6章相当の cd / ls / mkdir / mv / cp / rm を再掲（CLIの基本コマンド）
- AIに任せると Antigravity 等が補完してくれる
- CLIで PDF を扱う実用例の示唆
- 「CLI を理解したら、次は Git と GitHub」へのブリッジ
- 「Git は AI コーディングの土台」「GitHub は AI が成果物を置く場所」という導入

### p226 — 第11章扉「Git + GitHub入門」

章タイトル: **第11章: Git + GitHub**

CLIの次は Git + GitHub の2つを学ぶ。Git を理解しないと GitHub を理解できないので **Git から**。

**学ぶ理由（要約）:**
- Git は時間を巻き戻せる
- AIコーディングは試行錯誤の連続 → 巻き戻しが必須
- Google Docs の編集履歴に例えると分かりやすい
- Git は AI と相性が良い

### p227 — Gitの位置づけ

Git = **コードのバージョン管理システム**。

例え:
- Google Docs の編集履歴 ≒ Git のコミット履歴
- ただし Git の方が **明示的に「ここで保存」と宣言する** スタイル

### p228 — コラム「Gitと Linux と Linus Torvalds」

Git の誕生秘話コラム。

**要旨:**
- Git は Linux カーネルの開発者 **Linus Torvalds** が **2005年** に作った
- Linux 開発で使っていた **BitKeeper** が商用化（無料利用不可に）
- BitKeeper 開発元と揉めて利用停止
- Linux コミュニティで「自分たちで作る」と決断
- 数週間で Git のプロトタイプ完成
- Git は Linux と同じく **オープンソース**
- 当初は Linus が Linux のために作ったが、いまや世界中のあらゆるプロジェクトで使われる

### p229 — Gitの基本動作

- Git の操作 = コミット（保存）→ 履歴を蓄積
- 「Git は AI コーディングと相性が良い」を繰り返し強調

### p230 — AIコーディングにおけるGitの役割

- AI が暴走しても Git で巻き戻せる
- AI に「何をどう変えたか」を Git の履歴で説明できる
- Git の履歴が AI コーディングの **セーフティネット**

### p231 — Git と GitHub の役割分担

- **Git** = ローカルでの履歴管理
- **GitHub** = Git の履歴を **クラウドに共有** する場所
- GitHub があるから複数人で開発できる
- 個人でも GitHub を使うとバックアップ・ポートフォリオになる

### p232 — GitHub × AI

GitHub と連携するAI製品の紹介:

- **Jules**（Google）
- **Codex**（OpenAI）
- **Claude Code Web**（Anthropic）

これらは **GitHubの中で動くAI** で、リポジトリのコードを読んで自動でPR（プルリクエスト）を作る。

→ Git・GitHub を理解していないと、これらのAIの便利さを享受できない。

### p233 — Repository（リポジトリ）

- Repository = Git の単位
- 1プロジェクト = 1リポジトリが基本
- GitHub では Repository を作って公開/非公開を選ぶ

### p234 — GitHub Projects / ローカル vs リモート

- GitHub Projects = GitHub 上のタスク管理機能（Notion/Trello 的）
- ローカルリポジトリ（自分のPC）と リモートリポジトリ（GitHub上）の **2層構造**
- Git で **ローカルとリモートを同期** する

### p235 — Branch（ブランチ）と main

- Branch = 並行作業のための分岐
- Web 上では2人で同じファイルを編集できないが、Git なら **ブランチ** で可能
- メインのブランチ = **main**（昔は master だった）
- main から派生 → 編集 → 戻す（マージ）
- Git の最大の発明は **3-way merge**（2つの変更を賢く統合）

### p236 — Push / Pull / Merge

- 2つのブランチで同じ場所を変えたら **コンフリクト**
- Push = ローカル → GitHub
- Pull = GitHub → ローカル
- Merge = ブランチを統合

### p237 — Git インストール（Windows）

手順:

1. Git の公式サイトにアクセス → `https://git-scm.com/`
2. 「Download for Windows」をクリック
3. インストーラーをダウンロード
4. 「Next」を連打して進める
5. ターミナルで `git --version` で確認

### p238 — Git インストール（Mac）

Mac での確認:

1. ターミナルを開く
2. `git --version` を実行
3. インストール済みなら表示される
4. なければ Xcode Command Line Tools か Homebrew で入れる

```bash
# Xcode 経由
xcode-select --install

# Homebrew 経由
brew install git
```

### p239 — GitHub アカウント作成

- `https://github.com` にアクセス
- 「Sign Up」からアカウント作成
- メールアドレス / パスワード / ユーザー名（任意のID）

### p240 — Create Repository

- GitHub にログイン後、「Create Repository」ボタン
- 例として **gemini-chat** という名前のリポジトリを作成
- 「Choose Visibility」で Public / Private を選択

---

## 🛠️ コマンド・プロンプト一覧

### CLIインストール系

```bash
# Gemini CLI インストール
npm install -g @google/gemini-cli
```

### CLIセッション操作

```bash
# CLI 終了
Ctrl + C
# または
/quit
```

### インストール確認

```bash
git --version
```

### Git インストール（Mac）

```bash
# Xcode Command Line Tools
xcode-select --install

# Homebrew
brew install git
```

### ファイル操作（CLI基本）

```bash
cd       # ディレクトリ移動
ls       # ファイル一覧
mkdir    # ディレクトリ作成
mv       # 移動
cp       # コピー
rm       # 削除
```

### Gemini CLI / Antigravity 承認プロンプト応答

```
1 (Yes, allow once)
```

---

## 💡 Tips・原則

### CLI関連

1. **CLIに慣れる第一歩はAI CLI**
   - Claude Code / Codex / Gemini CLI は対話してくれるので初心者向き
   - 「CLI = 難しい」は古い認識

2. **CLIの基本コマンドは6つ覚えれば足りる**
   - `cd / ls / mkdir / mv / cp / rm`
   - その他は AI が補完してくれる

3. **CLIの抜け方を覚える**
   - `Ctrl + C` か `/quit`
   - 知らないと「閉じ方が分からない恐怖」で挫折する

### Git関連

4. **GitはAIコーディングのセーフティネット**
   - AIが暴走しても巻き戻せる
   - 心理的安全性が試行回数を増やす

5. **Google Docsの編集履歴がメンタルモデル**
   - 非エンジニアでもイメージしやすい
   - 違いは「明示的に保存（コミット）する」点

6. **Linus Torvalds の Git 誕生秘話を知っておくと愛着が湧く**
   - 2005年、BitKeeper 騒動 → 数週間で自作
   - Linux と同じくオープンソース

### GitHub関連

7. **Git と GitHub は別物**
   - Git = ローカルのバージョン管理
   - GitHub = クラウド共有プラットフォーム

8. **GitHub × AI の3製品を覚える**
   - Jules（Google）/ Codex（OpenAI）/ Claude Code Web（Anthropic）
   - これらは「GitHub の中で動くAI」

9. **個人でもGitHubを使う理由**
   - バックアップ
   - ポートフォリオ
   - AIエージェント（Codex, Jules等）への入口

### ブランチ・マージ

10. **main は神聖視するな、ただのデフォルト名**
    - 昔は master だった（言葉の歴史を知る）
    - 派生 → 戻す が基本サイクル

11. **3-way merge が Git の発明品**
    - 2つの変更を賢く統合
    - これがあるから並列開発できる

12. **コンフリクトは敵じゃない**
    - 「同じ場所を2人が変えた」というシグナル
    - AIに頼んで解決させてOK

---

## 🎓 AIpaX school 適用案

### モジュール構成案（このパートから抽出できる教材）

#### モジュール「CLI入門 — AI時代の必須スキル」

**講義時間**: 45分

**内容:**
1. CLIへの誤解を解く（5分）
   - 「黒い画面が怖い」を AI CLI で克服
   - Claude Code / Gemini CLI / Codex のデモ
2. 基本6コマンド体験（15分）
   - cd / ls / mkdir / mv / cp / rm をハンズオン
3. CLI の抜け方を覚える（5分）
   - Ctrl+C / /quit
4. AI CLI で自然言語コマンド体験（20分）
   - 「このフォルダにあるファイル一覧を見せて」を AI に頼む

**ゴール:** 受講後に CLI 恐怖症がなくなる。

---

#### モジュール「Git/GitHub 非エンジニア入門」

**講義時間**: 60分 × 2回

**第1回: Gitの心構え（60分）**
- Google Docs 編集履歴の例えから入る
- Linus Torvalds の誕生秘話（モチベ）
- コミット = セーブポイント体験
- 「AIが暴走しても戻せる」の安心感をハンズオンで体験

**第2回: GitHubと AI 連携（60分）**
- アカウント作成 → リポジトリ作成
- Jules / Codex / Claude Code Web のデモ
- 「GitHubに置くだけでAIが働く」体験
- ポートフォリオとしての GitHub

**ゴール:** 受講後に自分の GitHub アカウントが1つできて、AI 経由でPRが立つところまで体験。

---

### 教材のメタ原則

1. **非エンジニアの心理的ブロックを先に潰す**
   - 「黒い画面が怖い」→ AI CLI で対話できると見せる
   - 「Gitは難しい」→ Google Docs と同じと言い切る

2. **誕生秘話で愛着を作る**
   - Linus Torvalds のコラムを必ず入れる
   - 「ツールに人格がある」と思わせると学習継続率が上がる

3. **AI連携を最初に見せる**
   - Git 単独だと退屈
   - 「Git があるから AI が働ける」と最初に示す

---

## 🚀 大井AI改善適用

### 1. 教科書の構造をAIpaX school 全体に応用

このパートは **「導入 → 例え → コラム → 手順 → AI連携」** という流れが完璧。

AIpaX school の全モジュールでこの構造をテンプレ化する:

```markdown
1. なぜ学ぶか（恐怖の解除）
2. メンタルモデル（既知のものに例える）
3. 誕生秘話・人物コラム（愛着）
4. ハンズオン手順
5. AI連携で開花する瞬間を見せる
```

### 2. 大井自身のGit/GitHub習熟度の見直し

このパートを読んで自分の理解レベルを再確認:
- Branch / Merge / 3-way merge の説明を自分の言葉で言える？
- Jules / Codex / Claude Code Web のそれぞれの強み・弱みを言える？
- GitHub Projects を Notion 代替として使う発想はあるか？

→ 大井自身が **「教える側」として詰まる場所**を洗い出すPDCAを回す。

### 3. Claude（私）のオンボーディングフロー改善

新しい人（受講者・スタッフ）が AI コーディング環境に入る時の **チェックリスト** を作る:

- [ ] CLI 抜け方を知っている（Ctrl+C / /quit）
- [ ] git --version で確認できる
- [ ] GitHub アカウントある
- [ ] 1リポジトリ作った経験ある
- [ ] Claude Code / Codex / Gemini CLI のどれか1つ動かした

これを Notion テンプレ化して、AIpaX school 受講前提として配布する。

### 4. dispatchプロンプト改善: 「教科書スタイル」を導入

OpenClawに教材を作らせる時、以下のメタ指示を追加:

```
出力スタイル:
1. 冒頭で「なぜ学ぶか」を1段落
2. 既知のものへの例えを必ず入れる
3. 関連人物・誕生秘話があれば1コラム
4. 手順は番号付きで明示
5. 末尾で「AIと組み合わせると何ができるか」を見せる
```

これでOpenClaw製の教材品質が上がる。

### 5. 大井クローンの「Gitを通した試行錯誤」哲学を強化

このパートで強調されている「AI コーディング = 試行錯誤の連続 → 巻き戻しが必須」は、大井の事業哲学（実験回数で勝つ）とも整合する。

[[meta/ooi-soul]] に追記候補:
- 「Git は試行錯誤の保険」
- 「保険があるから試行回数を増やせる」
- 「事業も同じ。撤退可能性を担保して挑戦する」

---

## 関連リンク

- [[sources/ai-coding-textbook-deep/INDEX]]
- [[sources/ai-coding-textbook-deep/part11-pages-201-220]]（前パート）
- [[sources/ai-coding-textbook-deep/part13-pages-241-260]]（次パート / 想定）
- [[entities/aipax-school]]
- [[meta/ooi-soul]]
- [[concepts/ai-economy-2026-structure]]

---

## メモ

このパートは **PDFのページに画像（スクリーンショット）が多く含まれている**ため、pdftotextで抽出できる本文テキストは少なめ。実際の教材で重要なのは:

- インストール画面のスクリーンショット
- Git公式サイトの見た目
- GitHub の Create Repository 画面
- 各CLIの起動画面

これらは画像として埋め込まれており、テキスト抽出では取得できない。

→ AIpaX school で実教材を作る場合は、**スクリーンショットを別途用意する必要**がある。原著の構成を真似るなら画像撮影リストも作るべき。
