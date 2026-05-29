---
type: source-deep
title: 非エンジニアのためのAIコーディングの教科書 Part2 (pages 21-40)
created: 2026-05-26
source_pages: 21-40
related: [[sources/ai-coding-textbook-deep/INDEX]]
tags: [ai-coding, claude-code, education, deep-read, antigravity, nodejs, setup]
---

# Part 2: pages 21-40 完全ノート

## 📑 このページ範囲のセクション構成

このページ範囲は **第2章「開発環境のセットアップ」** の前半。Antigravity（Google製のAIコーディングIDE）のインストール、初期設定、日本語化、Node.js環境構築、最初のJavaScriptプログラム作成までを扱う。

| 範囲 | セクション | 主題 |
|---|---|---|
| p.21 | Antigravityインストール（OS別） | .exe / .dmg のダウンロード→実行 |
| p.22 | 既存エディター設定の読み込み | VSCode/Cursor設定の引き継ぎ判定 |
| p.23 | エディターテーマ選択 | Tokyo Night等 |
| p.24 | AIエージェントの振る舞いモード | Review-driven development推奨 |
| p.25 | キーボード・拡張機能設定 | デフォルト推奨 |
| p.26 | Googleログイン | 個人アカウント推奨の理由 |
| p.27 | 利用規約同意 | 最終ステップ |
| p.28 | 初期プロジェクトフォルダ作成 | js_practice / Open Folder |
| p.29 | 【任意】Antigravity日本語化① | 拡張機能でUI日本語化 |
| p.30 | 拡張機能のインストール承認 | Trust Publisher & Install |
| p.31 | 【任意】Antigravity日本語化② | AI応答を日本語にするRule設定 |
| p.32 | Customizations / Rules / Global vs Workspace | スコープの違い |
| p.33 | GEMINI.mdの編集 | 「日本語で応答してください」 |
| p.34 | Node.jsダウンロード | LTS版選択 |
| p.35 | Node.jsインストール / ターミナル起動 | .msi/.pkg / Ctrl+J / Cmd+J |
| p.36 | バージョン確認 | node --version / npm --version |
| p.37 | npmが見つからない時の対処（切り分け） | which/where/Get-Command |
| p.38 | Node.js再インストール / npm単独インストール | sudo rm / install.sh |
| p.39 | Node.jsとは何か（コラム） | JavaScript実行環境の解説 |
| p.40 | 最初のJSファイル作成 | hello.js / console.log |

---

## セクション別詳細

### p.21 ─ Antigravityインストール（ステップ2：実行）

ダウンロード済みインストーラーの実行手順:

- **Windows**: `.exe` ファイルをダブルクリック
- **Mac**: `.dmg` ファイルを開いて、Antigravityアイコンを「アプリケーションフォルダ」にドラッグ

インストール完了後、Antigravityを起動。最初の画面で「**Next**」をクリックして次へ。

> 「Next をクリックしてください」

---

### p.22 ─ 既存エディター設定の引き継ぎ

次の画面で「既にインストールしたことがあるエディターから設定を読み込むか」を選択。

- **VSCodeやCursorを使ったことがなければ** → そのまま「Next」を押す
- 既存エディターのキーバインドや拡張機能設定を継承できる仕組み

---

### p.23 ─ エディターテーマの選択

エディターのテーマを選ぶ画面。著者は **「Tokyo Night」** を選択していると明記。
ユーザーは好みで自由に選択可能。

---

### p.24 ─ AIエージェントの振る舞いモード（最重要）

> 「ちょっと難しいところなのですが、Antigravity の AI エージェントにどのように振る舞って欲しいかを選択します」

**推奨設定: Review-driven development**

- このモードでは **AIがターミナルのコマンドなどを実行するときに逐一レビューを求めてくる**
- 「エージェントに全てお任せモードのようなものもありますが、危険な場合もある」
- 危険性については **8章のガードレール** で詳述
- → **必ず Review-driven development を選択して Next**

---

### p.25 ─ キーボード・拡張機能設定

キーボードショートカットや拡張機能の設定について聞かれるが、**特に意思がなければデフォルトのまま Next**。

---

### p.26 ─ Googleログイン

最後の手順として **「Sign in with Google」** をクリック → ブラウザでGoogleログイン画面が立ち上がる。

#### 重要な注意事項（個人アカウント推奨の理由）

> 「現状 Google は個人アカウント（@gmail.com）でのログインを推奨していますが、Google Workspace に紐づいたアカウントでも動作はします。ただ、組織のセキュリティポリシーで Gemini API アクセスが制限されているとエラーが出る可能性がある点はご注意ください」

→ **個人Gmailを使うのが安全**。Workspaceアカウントは組織ポリシーでGemini APIブロックの可能性。

---

### p.27 ─ 利用規約同意

ログイン完了後、利用規約に同意して **Next** をクリック。

---

### p.28 ─ 初期プロジェクトフォルダ作成

セットアップ完了直前の画面に到達後:

1. 自分のPC内に **`js_practice`** という名前のフォルダーを作成
2. Antigravityで **「Open Folder」** をクリック
3. 作成したフォルダーを選択

→ 次の画面に辿り着いたら準備万端。

これでAntigravity本体の準備は完了。次セクションでJavaScript実行のためのNode.jsインストールへ進む。

---

### p.29 ─ 【任意】Antigravityを日本語で使う ①UI日本語化

> 「Antigravity は完全にではないですが日本語で使うことも可能です」

二つの対応が必要:
1. 拡張機能で UI を日本語化
2. Rule設定で AI 応答を日本語に

#### 手順 ①UI日本語化（拡張機能）

1. 左のバーの**一番下のアイコン**をクリック（拡張機能タブ）
2. 検索窓に **`japanese`** と入力
3. **地球マークの拡張機能**を選択
4. **インストール**をクリック

---

### p.30 ─ 拡張機能の信頼確認

インストールボタンを押すと、 **「この拡張機能の開発者を信頼しますか？」** と聞かれる。

→ 青い **「Trust Publisher & Install」** ボタンをクリック。

左下に **「Antigravity の設定言語を日本語にして再起動しますか？」** とポップアップが出る → このボタンを押して再起動。

---

### p.31 ─ ②AI応答の日本語化（Rule設定）

UI が諸々日本語になる。ただし **右のエージェントと話すチャット欄などは日本語にならない** という制約あり。

> 「AI 機能を使ったときに、Antigravity はプロンプトを日本語で入力しても英語で返してくることがあります」

→ AIに日本語応答させるためのRule設定が必要。

#### 手順
1. チャットの右上の **「・・・」** をクリック
2. **Customizations** をクリック

---

### p.32 ─ Rules: Global vs Workspace

> 「この Rules では AI が毎回従うプロンプトを設定することができます」

**スコープの違い**:

| スコープ | 適用範囲 |
|---|---|
| **Global** | どんなフォルダーを開いても効くルール |
| **Workspace** | フォルダー毎の設定 |

→ 常にどんなプロジェクトでも日本語対応してもらうため **「+Global」** をクリック。

---

### p.33 ─ GEMINI.md の編集

「+Global」をクリックすると **`GEMINI.md`** というファイルが開かれる。

#### 内容を書き込む

```markdown
日本語で応答してください
```

#### 保存

- **Windows**: `Ctrl + S`
- **Mac**: `Command + S`

#### 注意（教科書の正直な記述）

> 「これでAIが日本語で応答してくれるようになります。 ただ、英語で返してくることもまあまああるので 100%ではありません。(もっと強めの書き方にしたら守りやすくなってくれるかも)」

→ 100%ではない。より強いプロンプト記述で改善余地あり。

---

### p.34 ─ Node.jsをインストールしよう

> 「Node.js は、JavaScript を PC 上で実行するための環境です。これがないと、ターミナルから JavaScript プログラムを動かすことができません」

#### ステップ 1：公式サイトからダウンロード

公式サイトURL（脚注として明記）:

```
https://nodejs.org/ja/download
```

選択方法:
- ご利用のOSを選んでインストーラーをダウンロード
- バージョンは **デフォルトで選択されている LTS と付いたもの**
- **LTS = Long Term Support（安定版）**

下の方にダウンロードボタンがあるので、それをクリック。

---

### p.35 ─ Node.jsインストール ステップ2&3

#### ステップ 2：インストーラーを実行

- **Windows**: `.msi` ファイル
- **Mac**: `.pkg` ファイル

ダブルクリックして実行 → **画面の指示に従って進める** → 特に設定変更は不要。

#### ステップ 3：インストール確認

Antigravityを起動して、ターミナルを開く。

**ターミナルを開く方法（2通り）**:

1. メニューから: **画面上部 → Terminal → New Terminal** → 画面下部にターミナル表示
2. ショートカット:
   - **Windows**: `Ctrl + J`
   - **Mac**: `Command + J`

---

### p.36 ─ バージョン確認コマンド

#### Node.jsバージョン確認

```bash
node --version
```

→ Node.jsのバージョン番号が表示されればOK（数字はインストールしたバージョンによって異なる）。

#### npm（Node Package Manager）バージョン確認

```bash
npm --version
```

これもバージョン番号が表示されれば **インストール成功**。

---

### p.37 ─ npmが見つからない場合の対処（切り分けセクション）

> 「通常、Node.js をインストールすると npm も一緒に導入されます。 ただし、環境によっては npm が未導入、または PATH 未設定で見つからないことがあります」

#### 1) まずは切り分け（npmが無いのか／見つからないだけか）

**Node.jsの確認**:
```bash
node --version
```

**npmの確認**:
```bash
npm --version
```

#### エラーメッセージのパターン

`npm --version` で以下が出る場合は **npmが見つかっていない**:

- **Mac/Linux**: `npm: command not found`
- **Windows**: `'npm' は、内部コマンドまたは外部コマンド…として認識されていません。`

#### 場所確認コマンド（OS別）

| OS | コマンド |
|---|---|
| Mac/Linux | `which npm` |
| Windows | `where npm` |
| Windows (PowerShell) | `Get-Command npm` |

```bash
# Mac/Linux
which npm

# Windows (cmd)
where npm

# Windows (PowerShell)
Get-Command npm
```

#### パスは出るのに実行できない場合（PATH/権限/シェル設定の問題）

順番に試す:

1. **ターミナルを閉じて開き直す** ：設定が反映されていないだけのことがある
2. **PCを再起動する** ：環境変数の変更が反映されていない場合に有効
3. **それでもダメな場合**：エラーメッセージをそのまま **AI チャット（ChatGPT や Gemini など）** に貼り付けて「このエラーを解決したい」と聞く
   - 環境によって原因が異なるため、AIに状況を説明しながら解決するのが最短

---

### p.38 ─ npm未導入時の解決方法

#### 2) 方法 1：Node.jsを再インストール（推奨）

> 「npm まで含めて確実に揃えるなら、Node.js の入れ直しが最短です」
> 「npm 公式も、可能なら Node のバージョン管理ツール（nvm 等）での導入を推奨しています」

**Windowsのアンインストール手順**:
1. 「設定」→「アプリ」→「インストールされているアプリ」を開く
2. 「Node.js」を検索して「アンインストール」をクリック

**Macのアンインストール手順**（ターミナルで実行、管理者パスワード必要）:

```bash
sudo rm -rf /usr/local/bin/node /usr/local/bin/npm /usr/local/lib/node_modules
```

アンインストール後、本章の「Node.js をインストールしよう」の手順に従って再インストール → `npm --version` を再確認。

#### 3) 方法 2：npmを個別にインストール

Node.jsはそのままで、npmのみ導入する方法。npm公式が `install.sh` を提供。

```bash
curl -qL https://www.npmjs.com/install.sh | sh
```

**制約**:
- `sh`が使える環境向け（Mac/Linux、またはWindowsなら WSL/Git Bash 等）
- **Windowsの方は方法1（再インストール）を使う**

---

### p.39 ─ コラム：Node.jsって何？

> 「ひとまず動かすためにはそんなに重要でないので触れませんでしたが、もうちょっと詳しく知りたい人向けに Node.js とは何なのかについて解説します」

#### Node.jsの定義

**Node.js（ノードジェーエス）**:
- JavaScript を **ブラウザの外（サーバーサイドや PC 上）で実行できるようにするための実行環境**
- もともと JavaScript はブラウザ上でしか動かない言語だった
- Node.js の登場で、JavaScript でサーバーサイドプログラムや PC上で動くスクリプトも書けるようになった

#### Node.jsをインストールするとできること

- ターミナルから JavaScript プログラムを実行できる
- ファイルの読み書きや、システム操作ができる
- パッケージマネージャー（npm）が使えるようになる
- 多くの開発ツールが使えるようになる

#### 一言まとめ

> 「Node.js をインストールすることで、JavaScript が『ブラウザ専用の言語』から『どこでも動く汎用言語』に変わるのです」

---

### p.39-40 ─ Antigravityでプログラムを書いて実行しよう

#### 新しいファイルを作成する

- 先ほど開いた **`js_practice`** フォルダーを使う
- フォルダ名の横にある **「新規ファイル」アイコン（＋マークや書類のアイコン）** をクリック
- 新しいファイルを作成
- ファイル名: **`hello.js`**

#### `.js`拡張子の意味

> 「`.js` という拡張子は『JavaScriptのプログラムファイルですよ』という意味です」

#### コードを書く

`hello.js` ファイルに以下を入力:

```javascript
console.log("Hello Antigravity");
```

#### 保存

- **Windows**: `Ctrl + S`
- **Mac**: `Command + S`

→ 続きはp.41以降（次のパートで実行コマンドへ）。

---

## 🛠️ 抽出したコマンド・プロンプト一覧

### バージョン確認コマンド

```bash
# Node.jsバージョン確認
node --version

# npmバージョン確認
npm --version
```

### npm場所確認コマンド（OS別）

```bash
# Mac/Linux
which npm

# Windows (cmd)
where npm

# Windows (PowerShell)
Get-Command npm
```

### npm未導入の解決コマンド

```bash
# Macでnode/npm完全削除
sudo rm -rf /usr/local/bin/node /usr/local/bin/npm /usr/local/lib/node_modules

# npm単独インストール（Mac/Linux/WSL/Git Bash）
curl -qL https://www.npmjs.com/install.sh | sh
```

### 最初のJavaScriptコード

```javascript
// hello.js
console.log("Hello Antigravity");
```

### GEMINI.md（Antigravity Global Rule）の初期内容

```markdown
日本語で応答してください
```

### ショートカット早見表

| 操作 | Windows | Mac |
|---|---|---|
| ファイル保存 | `Ctrl + S` | `Command + S` |
| ターミナルを開く | `Ctrl + J` | `Command + J` |

---

## 💡 抽出したTips・原則

### Tip 1: AIエージェントは「Review-driven development」モードで始める
- 全自動モードは便利だが危険
- 各コマンド実行前にレビューを挟むモードが推奨
- 8章のガードレールで詳述される伏線
- → **「最初は人間レビュー必須」が初心者の鉄則**

### Tip 2: Googleログインは個人@gmail.comを使う
- Workspaceアカウントは動くが、組織ポリシーでGemini APIブロックの可能性
- セキュリティポリシーは見えない場所で動くため、エラーの原因特定が困難
- → **個人アカウントが「環境変数の地雷」を踏まない最短ルート**

### Tip 3: 日本語化は「UI拡張機能」+「GEMINI.md Rule」の2段構え
- UIは日本語化拡張で対応
- AIの応答言語は **GEMINI.md（Global Rule）** で別途指定
- どちらか片方では不十分

### Tip 4: GEMINI.md = Antigravityの「常時プロンプト」
- Globalスコープ: 全プロジェクトで効く
- Workspaceスコープ: そのフォルダーだけで効く
- Claude Codeの `CLAUDE.md` と同じ役割
- → **AIの振る舞いはRule設定で恒常的に固定できる**

### Tip 5: Node.jsはLTS版を選ぶ
- LTS = Long Term Support（安定版）
- 最新版より安定版を優先
- → **初心者は「枯れた技術」を選ぶ**

### Tip 6: バージョン確認は「インストール確認」の唯一の正解
- `node --version` と `npm --version` の2つで切り分け
- 出ない/エラーが出る → 切り分けフロー（PATH？権限？シェル？）

### Tip 7: トラブル解決は「再起動→AI相談」の順
- 環境変数の反映待ちで動かないケースが最頻
- 1. ターミナル再起動 → 2. PC再起動 → 3. エラーをAIにコピペ
- → **初心者の最強の武器: AIへのエラーメッセージ丸投げ**

### Tip 8: コラムは「動かす方法 → 仕組みの説明」の順
- p.34-38で動かす方法を先に教える
- p.39でNode.jsとは何かを後から説明
- → **動いた後に理解が深まる。動かないうちに概念を教えない**

### Tip 9: 「Antigravityの日本語化は任意」
- 完璧ではない
- 100%守られない（教科書の正直な記述）
- → **完璧さより「動くこと」を優先**

### Tip 10: Review-driven developmentの危険性は伏線
- 8章のガードレールで詳述
- 初心者には「危険」を最初に体験させない設計
- → **段階的開示の教育設計**

---

## 🎓 AIpaX school 適用案

### カリキュラム化（中高生向け）

#### モジュール「環境構築の地獄を最短で抜ける」

**狙い**: 中高生にとって最大の挫折ポイント = 環境構築。ここを30分で抜けさせる。

**コア教材**:

1. **【ライブ】Antigravity 0→1セットアップ（30分）**
   - 教師が画面共有してインストールを見せる
   - 「Review-driven development」を選ぶ理由を体験で示す
   - **Googleログインで個人アカウントを使う重要性** を強調
   - 失敗パターンも見せる（Workspaceでブロックされる例）

2. **【演習】GEMINI.md / CLAUDE.md / 「AIに性格を持たせる」**
   - GEMINI.mdに「あなたは中学生にもわかる言葉で説明する先生です」と書かせる
   - Global vs Workspace の使い分け
   - 「AIに性格を仕込める」ことの感動体験
   - **CEO ルール、デザイナールール、コードレビュアールールを切り替えるデモ**

3. **【ハンズオン】Node.js + Hello Antigravity（15分）**
   - `node --version` でハマる人を意図的に作る
   - エラーメッセージをそのままGeminiに貼ってもらう
   - **「エラーは恥ずかしくない、AIに聞けばいい」** を体験で刷り込む

4. **【補助】「pathが通らない」謎の解決**
   - `where npm` / `which npm` / `Get-Command npm` の3コマンドを暗記項目に
   - 再起動→AI相談の手順を「習慣化テンプレ」として配布

#### 評価ルーブリック

| レベル | 状態 |
|---|---|
| Lv0 | インストールが完了している |
| Lv1 | `node --version` と `npm --version` が通る |
| Lv2 | hello.js を作って `node hello.js` が動く |
| Lv3 | GEMINI.md に独自ルールを書ける |
| Lv4 | エラーメッセージを自力でAIに渡して解決できる |

#### 配布物テンプレ

- **「環境構築チェックリスト」PDF**
  - スクショ付きの全手順
  - エラー時の3コマンド
  - 「困ったらコピペするプロンプト」

- **GEMINI.md サンプル集**
  ```
  - 中高生バージョン（「中学生にもわかる言葉で」）
  - 起業家バージョン（「コードレビューは厳しく」）
  - クリエイターバージョン（「デザインの観点も入れて」）
  ```

---

## 🚀 大井自身のAI改善適用

### 1. GEMINI.md / CLAUDE.md の階層化

現状の `~/.claude/CLAUDE.md` は全体統括ルーチンが書かれているが、**Antigravityでも同等のGlobal/Workspace分離**を作る。

**提案構成**:

```
~/AppData/Roaming/Antigravity/GEMINI.md    # Global
business/.antigravity/GEMINI.md             # Workspace (business全体)
business/アプリ/testall/.antigravity/GEMINI.md  # Workspace (Testall専用)
```

各層の責務:
- **Global**: 日本語応答、TodoList、敬語不要、効率優先
- **business Workspace**: ORGANIZATION.mdを参照、CEO起動条件
- **プロジェクトWorkspace**: そのプロジェクト固有のドメイン知識

### 2. Review-driven development を Claude Code でも徹底

`~/.claude/settings.json` の `allowedTools` を絞り込んで、 **重要操作は必ずレビューが入る** ようにする。

具体: 
- `rm -rf` 系
- `git push --force`
- `npm install --global`
- `.env` への書き込み
→ いずれも `ask` モードに固定

### 3. 「環境構築コマンド早見表」を Obsidian に固定

`brain/wiki/Setup-CheatSheet.md` を新規作成:

```markdown
# 環境構築 早見表

## Node.js
- インストール確認: `node --version` / `npm --version`
- どこにある？: `where npm` (Win) / `which npm` (Mac)
- PowerShell: `Get-Command npm`

## トラブル時
1. ターミナル再起動
2. PC再起動
3. エラーメッセージをAIにコピペ

## 完全削除（Mac）
sudo rm -rf /usr/local/bin/node /usr/local/bin/npm /usr/local/lib/node_modules
```

### 4. 「エラーをAIに丸投げ」のテンプレ化

エラーメッセージ用のプロンプトテンプレを作っておく:

```markdown
# プロンプトテンプレ: エラー解決

【環境】
- OS: Windows 11 / Mac
- 使っているツール: Antigravity / Claude Code / Cursor
- 直前にやった操作: （具体的に）

【発生したエラー】
（エラーメッセージをそのままコピペ）

【目的】
（何をしたかったか）

→ 解決策を、原因の説明 → 具体的な手順 の順で教えてください
```

これを **キーボードショートカット (`!err`) で展開** できるようにIDE側に登録。

### 5. 「最初の3コマンド」の習慣化

新規環境では必ず:
1. `node --version`
2. `npm --version`
3. `git --version`

を最初に叩く習慣を `~/.bashrc` / `~/.zshrc` のwelcomeメッセージに組み込み。

### 6. AIpaX schoolカリキュラムの「設計テンプレ」として吸収

p.21-40の構成パターンは **「動かす→失敗→修正→理解」** の順序設計が秀逸。

これをAIpaX schoolの全モジュール設計テンプレに採用:

```
モジュール構成テンプレ:
1. 完成形を見せる（5分）
2. 一緒に手を動かす（15分）
3. わざと失敗させる（5分）
4. AIに聞いて修正（10分）
5. 概念の解説（5分）  ← 必ず最後
```

→ 「理解してから動かす」ではなく **「動かしてから理解する」** で挫折率を下げる。

### 7. 「Tokyo Night テーマ」の意義 = ブランディング

著者が **Tokyo Night** を選択したことを明記している → **「自分の道具をカスタマイズすることそのものが学習の一部」** という思想。

AIpaX schoolでも「自分のIDEの見た目を作る」を最初のワークに入れる。
→ **道具への愛着 = 継続率**

---

## 🔑 このパートの最大のテイクアウト

1. **環境構築の「正解パス」を完全に固定して教える** — 選択肢を増やさない
2. **Review-driven development** は安全装置として最初から強制
3. **GEMINI.md / CLAUDE.md** = AIの常時プロンプト = 教育で最重要の概念
4. **エラーをAIに丸投げ** が初心者の最強の武器
5. **動かしてから理解** の順序設計（コラムは必ず後ろ）
6. **個人Googleアカウント推奨** = 組織ポリシーの地雷を避ける
7. **LTS版を選ぶ** = 初心者は「枯れた技術」優先
8. **日本語化は不完全** と正直に書く誠実さが信頼を生む

---

## 📌 次パートへの引き継ぎ事項

- p.40で `hello.js` を保存したところで終了
- 次パート（p.41以降）: ターミナルで `node hello.js` を実行する場面が来るはず
- 第2章はおそらくp.50前後まで続く
- 第3章は「最初のAIコーディング体験」と推測（要確認）
