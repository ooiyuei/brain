---
type: source-deep
title: 非エンジニアのためのAIコーディングの教科書 Part6 (pages 101-120)
created: 2026-05-26
source_pages: 101-120
related: [[sources/ai-coding-textbook-deep/INDEX]]
tags: [ai-coding, claude-code, education, deep-read]
---

# Part 6: pages 101-120 完全ノート

## 範囲

- **pages 101-103**: 第4章まとめ + 次章への橋渡し + 推薦図書（リーダブルコード / リファクタリング第2版）
- **pages 104-120**: 第5章「APIでAI活用の幅を広げよう」の前半
  - APIとは何か（HTTP基本、404エラー、開発者スラング「叩く」）
  - API のありがたみ（自動化）vs ブラウザ自動化（Playwright/Puppeteer/Selenium）
  - 認証と API キー（OAuth との比較、漏洩対策）
  - APIキー管理3原則（ハードコード禁止 / .env / .gitignore）
  - APIドキュメントの読み方
  - fetch を使った直接 Gemini API 呼び出しコード解説
  - HTTPステータスコード（200 / 400 / 403 / 429 / 500）
  - 料金とトークン（Gemini 3 Flash 1日20リクエスト無料、日本語＝ひら1文字＝1トークン、漢字1文字＝2-3トークン）

---

## 📑 セクション構成

### page 101: 第4章まとめ
- 変数、データ型、条件分岐、ループ、関数の4本柱を学んだ
- 「特に重要なのは配列とオブジェクト」
- データ構造を正確に説明し、エラーメッセージ全文を共有することで AI とのやり取りが劇的に改善
- スキルは「タスク管理、顧客データ分類、売上集計」など実務に直結

### page 101: 次の章へ
- 次章は API について
- 「変数、条件分岐、ループ、関数」+「外部サービス連携」で新しい武器

### pages 102-103: コラム「より高度なプログラミングができるようになりたい方へ」
- 著者の体験：「社会人になりたての頃、自力で大きなWebシステムを作りました。数ヶ月後、そのメンテナンスの難しさに直面し、『良い設計とは何か』を身をもって学びました」
- 痛みこそが最良の学び
- **推薦図書1**: 『リーダブルコード ―より良いコードを書くためのシンプルで実践的なテクニック』
  - URL: https://amzn.asia/d/4DCZhAR
  - 「読みやすいコード」の名著。変数名、コメント、関数分割
- **推薦図書2**: 『リファクタリング（第2版）』
  - URL: https://amzn.asia/d/h4fLdaQ
  - 第2版はコード例が JavaScript に変更されたため本章と直結
  - 「動くコード」から「良いコード」へステップアップ

### page 104: 第5章タイトル + APIとは何か
- API = Application Programming Interface
- 「『なんだか難しそう』『お金がかかりそうで不安』と感じられる技術かもしれません」
- しかし基本的な使い方はそれほど複雑ではない
- 章末で「JavaScriptでAPIを呼び出して、AIサービスを自分のプログラムから使える」状態を目指す

### page 104: APIの定義
- 「あるソフトウェアが持つ機能を、別のソフトウェアから使うための公式なルールブック」
- 「このやり方でお願いすれば、うちのサービスを使えますよ」という取扱説明書

### page 105: ChatGPT を例にした説明 + 現代のAPIはHTTPが基本
- 普段の ChatGPT 使用：「ブラウザでサイトを開いてチャット画面で『こんにちは』と入力」
- API 経由：「自分で作った JavaScript プログラムから直接 ChatGPT に『おはよう！今日の予定を整理して』と送って、回答をもらう」
- 現代のウェブサービスは API のやり取りの大部分が「HTTP」
- 参考リンク: https://developer.mozilla.org/ja/docs/Web/HTTP/Guides/Overview
- 「404エラー」は HTTP の仕組みの一つで「指定されたものは存在しない」を数字のコードで伝えている

### page 106: コラム「APIを叩く」+ なぜAPIがあると嬉しいのか
- 開発者スラング：「API叩いたらエラーが出た」「このAPI叩くと重い」
- **本書では「呼び出す」「実行する」を使う**
- 「複数のECサイトで自社商品の価格を毎日チェック」例で価値を説明
- API がない場合の5ステップ（手動）：
  1. Amazon を開いて商品を検索し、価格を Excel に記録
  2. 楽天市場を開いて同じ商品を検索し、価格を記録
  3. Yahoo! ショッピングでも同様に検索して記録
  4. 自社サイトの価格と比較して、高い場合は報告書を作成
  5. これを10商品について繰り返す

### page 107: ブラウザ自動化との違い
- ブラウザ自動化ツール: **Playwright、Puppeteer、Selenium**
- 問題点：
  - **遅い**（ブラウザ起動 → ページ読込 → 要素探し）
  - **不安定**（ウェブサイトのデザインが少し変わっただけで動かなくなる）
  - **変更に弱い**（ボタン位置・文言が変わると壊れる）

### page 108: APIは「公式な約束事」
- ウェブサイトの見た目が変わっても、API 仕様は簡単には変更されない
- 変更時は事前に「○月○日に仕様が変わります」とお知らせ
- 結果：非常に安定的で信頼性の高い自動化が実現
- 「一度作った自動化が長期間動き続けてくれるというのは、大きなメリット」

### page 108: 認証とAPIキー
- 認証 = 正当なユーザーであることの証明
- 「API は誰でも自由に使えるわけではありません。許可されたユーザーだけが利用できる仕組み」

### page 109: 完全パブリックなAPIリスト + APIキーの解説
- パブリック API リスト: https://github.com/public-apis/public-apis
- API キー = サービスにユーザー登録すると発行される、専用の識別コード
- 「会員証のようなものと考えると分かりやすい」

### page 110: コラム「OAuthという認証方式もある」
- OAuth = 「Google でログイン」「Twitter でログイン」のような仕組み
- 「ユーザーが明示的に『このアプリにデータへのアクセスを許可します』と承認する方式」
- OAuth はセキュリティ面で優れている（Webアプリ・モバイル広く使われる）
- **しかし自動化には向いていない**
  - トークン取得・更新でユーザー手動承認が必要
  - 定期的な再認証が求められる
- **本書では API キー方式中心**

### page 110: APIキーの重要性と管理
- API キーは「自分のアカウントに直結している非常に重要な情報」
- 漏洩したら「なりすました誰かが勝手にAPIを使って、高額な請求が来る可能性」
- **「パスワードと同じか、それ以上に大切に管理してください」**

### page 111: 漏洩時の対応
- 「API キーを漏らしてしまった...」となった場合の手順：
  1. 即座にそのAPIキーをサービス管理画面で無効化
  2. 新しいキーを発行し直し（「キーのローテーション」と呼ぶ）
- Gemini の API キーは「API キーの画面 → キーの右の『…』をクリック → 削除」

### pages 112-113: APIキー安全管理の3つのコツ
1. **コードに直接書かない（ハードコーディング禁止）**
2. **環境変数（.env）を使う**
3. **`.gitignore` に `.env` を追加する**

### pages 113-114: APIドキュメントを読んで機能を知る
- 「サービス名 api document」で検索
- 英語が多いが Google 翻訳でOK
- **Gemini API のドキュメントは日本語**: https://ai.google.dev/gemini-api/docs?hl=ja
- ドキュメントには「Gemini では思考レベルの設定ができる」のような説明がコードとともに掲載

### page 115: ライブラリ vs 直接APIコール
- Gemini のようなライブラリ提供サービスは詳細仕様を把握せずとも扱える
- 「ライブラリについては次の章で解説」
- @google/genai リポジトリ: https://github.com/googleapis/js-genai
- ここからは「ライブラリを使わずに直接 HTTP リクエストを送るコード」を見て API の仕組みを理解する

### pages 115-117: fetch を使った Gemini API 呼び出しコード全文 + 4分解
- リクエストURL
- リクエストボディ（contents → parts → text）
- 認証情報（headers の x-goog-api-key）
- レスポンス処理（result.candidates[0].content.parts[0].text）

### page 118: ライブラリがやっていること
- @google/genai は「複雑なコードを内部で処理してくれている」
- 「ライブラリがない API を使う場面で役立つ」ので裏側を知っておく

### pages 118-119: HTTP ステータスコード
- 200 = 成功
- 400 = Bad Request（リクエストの形式が間違っている）
- 403 = Forbidden（APIキー無効、権限なし）
- 429 = Too Many Requests（上限到達。少し待って再試行）
- 500 = Internal Server Error（サーバー側問題）
- 「400番台はこちら側、500番台はサーバー側」

### page 119: APIの料金体系
- 「使った分だけお金がかかる従量課金制」
- AI の API は大抵トークン単位で料金設定
- Gemini 3 Flash：「1日20リクエスト」無料

### page 120: トークンとは何か
- 「AI がテキストを処理する時の最小単位」
- 「こんにちは」→「こ」「ん」「に」「ち」「は」と細かく分割
- 目安：
  - 英語: 1単語が1トークンくらい
  - 日本語: ひらがな1文字が1トークン、**漢字1文字が2-3トークンくらい**
- 「Tokenizer」というツールで事前確認可能（全AIサービスが提供しているわけではない）
- 「普段使いなら日本語はだいたい文字数の5-70％くらい」（※本文ママ、実際は1.5-2倍が一般的）
- OpenAI Tokenizer: https://platform.openai.com/tokenizer

---

## セクション別詳細

### § 第4章まとめ（page 101）

> 「変数、条件分岐、ループ、関数という基本的な道具に加えて、外部サービスとの連携という新しい武器を手に入れましょう」

**章学習成果のおさらい**:
- 4本柱 = 変数とデータ型 / 条件分岐 / ループ / 関数
- 重要な発展 = 配列とオブジェクト
- AI協業の改善条件 = 「データ構造を正確に説明 + エラーメッセージ全文を共有」
- 実務適用 = タスク管理 / 顧客データ分類 / 売上集計

### § 推薦図書コラム（pages 102-103）

著者は「**痛みこそが最良の学び**」と強調。社会人初期に自分でWebシステムを作り、メンテナンスで苦しみ「良い設計とは何か」を学んだエピソードを共有。

| 書名 | リンク | 特徴 |
|---|---|---|
| リーダブルコード | https://amzn.asia/d/4DCZhAR | 変数名・コメント・関数分割の実践テクニック |
| リファクタリング（第2版） | https://amzn.asia/d/h4fLdaQ | 第2版コード例が JavaScript。本章と直結 |

→ **AIpaX school 中高生カリキュラム** には「リーダブルコード」が極めて良い副読本。

### § APIとは何か（pages 104-105）

**定義**: 「あるソフトウェアが持つ機能を、別のソフトウェアから使うための公式なルールブック」

**身近な比較**:
- 普段のChatGPT: ブラウザで開く → チャット画面 → 「こんにちは」入力
- API経由: 「自分で作ったJavaScriptプログラムから直接ChatGPTに『おはよう！今日の予定を整理して』と送って、回答をもらう」

**HTTPの位置づけ**:
- 「現代のウェブサービスでは、このソフトウェア同士のやり取りの大部分が『HTTP』という共通ルール」
- 404エラーも HTTP の仕組み
- 参考: MDN HTTPガイド https://developer.mozilla.org/ja/docs/Web/HTTP/Guides/Overview

### § 開発者の言葉「API を叩く」（page 106）

開発者スラング：「API 叩いたらエラーが出た」「このAPI叩くと重い」

**著者の方針**: 「本書では『呼び出す』『実行する』という表現を使います」

### § なぜAPIがあると嬉しいのか — EC価格チェック例（pages 106-107）

**APIなしの手動5ステップ（毎日）**:
1. Amazon を開いて商品を検索し、価格を Excel に記録
2. 楽天市場を開いて同じ商品を検索し、価格を記録
3. Yahoo! ショッピングでも同様に検索して記録
4. 自社サイトの価格と比較して、高い場合は報告書を作成
5. これを10商品について繰り返す

**APIありの場合**:
- プログラムが自動で全サイトの価格を取得・比較・報告書作成
- 「寝ている間に処理が完了します」

### § ブラウザ自動化との違い（page 107）

3大ブラウザ自動化ツール:
- **Playwright**
- **Puppeteer**
- **Selenium**

**問題点（3つ）**:
1. **遅い** — ブラウザ起動 → ページ読込 → 要素探し
2. **不安定** — ウェブサイトのデザインが少し変わっただけで動かなくなる
3. **変更に弱い** — ボタン位置・文言が変わると壊れる

著者の体験: 「『また動かなくなった』と修正作業に追われることが多かった」

### § APIは「公式な約束事」（page 108）

- 見た目が変わってもAPIは安定
- 仕様変更時は事前告知
- 「非常に安定的で信頼性の高い自動化が実現」
- 「一度作った自動化が長期間動き続けてくれるというのは、大きなメリット」

### § 認証とAPIキー（pages 108-110）

**認証の必要性**:
- 「誰がどのくらい使っているのかを把握したい」
- 「不正利用も防ぐ必要がある」

**完全パブリックAPIリスト**: https://github.com/public-apis/public-apis

**APIキー定義**: 「サービスにユーザー登録すると発行される、専用の識別コード」「会員証のようなもの」

### § OAuthという認証方式もある（コラム page 110）

| 方式 | 自動化適性 | 用途 |
|---|---|---|
| API キー | 高い | 本書中心 |
| OAuth | 低い（手動承認・再認証が必要） | Webアプリ・モバイル提供時 |

「もし皆さんが将来 Web アプリを外部に提供する機会が訪れれば学ぶことになるでしょう」

### § APIキーの重要性と漏洩対応（pages 110-111）

**重要性**:
- 「自分のアカウントに直結している非常に重要な情報」
- 漏洩 → なりすまし → 高額請求
- 「パスワードと同じか、それ以上に大切に管理してください」

**漏洩時の対応**:
1. 即座にそのAPIキーをサービス管理画面で無効化
2. 新しいキーを発行し直し（**キーのローテーション**）

Gemini 操作: 「API キーの画面 → キーの右の『…』をクリック → 削除」

### § APIキー安全管理3つのコツ（pages 112-113）

#### コツ1: ハードコーディング禁止

```javascript
// ❌ 悪い例：APIキーを直接書いている
const apiKey = "AIzaSyDXXXXXXXXXXXXXXXXXXXXXXX";
```

「コードに API キーを直接書いてしまうと、そのコードを誰かに見せたり、GitHub に公開したりした時に、API キーが丸見え」

#### コツ2: 環境変数（.env）を使う

```javascript
// ⭕ 良い例：環境変数から読み込む
import dotenv from 'dotenv';
dotenv.config();

const apiKey = process.env.GEMINI_API_KEY;
```

`.env` ファイル:
```
GEMINI_API_KEY=AIzaSyDXXXXXXXXXXXXXXXXXXXXXXX
```

「第3章のハンズオンでも、この方法で API キーを管理しました」

#### コツ3: .gitignore に .env を追加

`.gitignore` ファイル例:
```
.env
node_modules/
```

→ 第11章で Git を学ぶが、ここで先に伝える

### § APIドキュメントを読んで機能を知る（pages 113-114）

- 「サービス名 api document」で検索
- 英語が多いが Google 翻訳でOK
- **Gemini API ドキュメント（日本語）**: https://ai.google.dev/gemini-api/docs?hl=ja
- ドキュメントには「Gemini では思考レベルの設定ができる」など機能解説がコード付き

### § ライブラリ vs 直接APIコール（pages 114-115）

- ライブラリ提供サービスはライブラリのドキュメントだけで済むことが多い
- @google/genai リポジトリ: https://github.com/googleapis/js-genai
- ここからは「ライブラリを使わずに直接 HTTP リクエストを送るコード」を見る

### § fetch を使った Gemini API 呼び出しコード（pages 115-117）

#### 全体コード（pages 115-116 を整形）

```javascript
// APIキー
const apiKey = import.meta.env.VITE_GEMINI_API_KEY;

// リクエストURL
const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

// リクエストボディ（送信するデータ）
const data = {
  contents: [
    {
      parts: [
        {
          text: "こんにちは！今日の天気はどうですか？"
        }
      ]
    }
  ]
};

// APIを呼び出し
fetch(url, {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "x-goog-api-key": apiKey
  },
  body: JSON.stringify(data)
})
.then(response => {
  if (response.ok) {
    return response.json();
  } else {
    throw new Error(`エラーが発生しました: ${response.status}`);
  }
})
.then(result => {
  console.log("AIの回答:", result.candidates[0].content.parts[0].text);
})
.catch(error => {
  console.error("エラー:", error.message);
});
```

#### 4分解（page 116-117）

**1. 送信先のURL**

```javascript
const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";
```

→ 「これが Gemini API の『住所』」

**2. 送信するデータ（リクエストボディ）**

```javascript
const data = {
  contents: [
    { parts: [{ text: "こんにちは！今日の天気はどうですか？" }] }
  ]
};
```

→ 「contents の中に parts があり、その中に text として質問文が入るという構造」

**3. 認証情報を含めて送信**

```javascript
fetch(url, {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "x-goog-api-key": apiKey  // ここでAPIキーを渡している
  },
  body: JSON.stringify(data)
})
```

→ 「headers の中に API キーを含めている部分がポイント。これにより、Google は『このリクエストは正規のユーザーからだ』と判断」

**4. 返ってきた回答を処理**

```javascript
.then(result => {
  console.log("AIの回答:", result.candidates[0].content.parts[0].text);
})
```

→ 「Gemini から返ってきた回答は、`result.candidates[0].content.parts[0].text` という場所に入っています」

### § ライブラリがやっていること（page 118）

- 「@google/genai ライブラリは、上記のような複雑なコードを内部で処理してくれている」
- 「私たちが書いた数行のコードの裏側では、このような HTTP リクエストが送られていた」
- 裏側知識の効用：「エラーが出たときの原因特定」「ライブラリがない API を使う場面で役立つ」

### § エラーとHTTPステータスコード（pages 118-119）

| コード | 意味 | 対処 |
|---|---|---|
| 200 | 成功 | リクエスト正常処理 |
| 400 Bad Request | リクエスト形式が間違い | 送信データを確認 |
| 403 Forbidden | APIキー無効/権限なし | APIキー確認 |
| 429 Too Many Requests | 上限到達 | 少し待って再試行 |
| 500 Internal Server Error | サーバー側問題 | 待って再試行 |

**ざっくり判別法**:
- 400番台 = こちら側の問題 → APIキーや送信データを確認
- 500番台 = サーバー側の問題 → 少し待ってから再試行

「他にどんなステータスコードがあるか知りたい方は、こちらのリンクから一覧を眺めてみてください。かなりの種類があるので、結構面白いです」

### § API の料金体系（pages 119-120）

#### 従量課金制が基本

- 多くのAPI は「使った分だけお金がかかる従量課金制」
- AI の API は大抵トークン単位
- **Gemini 3 Flash**: 「1日20リクエスト」無料

#### トークンとは（page 120）

- 「AI がテキストを処理する時の最小単位」
- 「こんにちは」→「こ」「ん」「に」「ち」「は」と細かく分割

**目安**:
- 英語: 1単語 ≒ 1トークン
- 日本語: ひらがな1文字 ≒ 1トークン、漢字1文字 ≒ 2-3トークン

**確認ツール**: 「Tokenizer」（各AIサービスが提供）
- ※全ての AI サービスが提供している訳ではない
- OpenAI Tokenizer: https://platform.openai.com/tokenizer

**実用ガイド**: 「普段使いなら日本語はだいたい文字数の5-70％くらい」（※原文ママ・誤記の可能性。実際は文字数の1.5-2倍程度がトークン数の目安）

---

## 🛠️ コマンド・プロンプト一覧

### dotenv の使い方（page 112）

```javascript
import dotenv from 'dotenv';
dotenv.config();

const apiKey = process.env.GEMINI_API_KEY;
```

### .env ファイル形式（page 112）

```
GEMINI_API_KEY=AIzaSyDXXXXXXXXXXXXXXXXXXXXXXX
```

### .gitignore に .env を追加（page 113）

```
.env
node_modules/
```

### Vite 環境変数アクセス（page 116）

```javascript
const apiKey = import.meta.env.VITE_GEMINI_API_KEY;
```

→ Vite では `VITE_` プレフィックス必須（推測補足）

### fetch で API を叩く基本構造（pages 116-117）

```javascript
fetch(url, {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "x-goog-api-key": apiKey
  },
  body: JSON.stringify(data)
})
.then(response => {
  if (response.ok) return response.json();
  throw new Error(`エラー: ${response.status}`);
})
.then(result => { /* 成功処理 */ })
.catch(error => { /* エラー処理 */ });
```

### Gemini API リクエストボディ構造（page 117）

```javascript
const data = {
  contents: [
    { parts: [{ text: "質問内容" }] }
  ]
};
```

### Gemini API レスポンスからテキスト取得（page 117）

```javascript
result.candidates[0].content.parts[0].text
```

### Gemini API エンドポイント（page 116）

```
https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent
```

### Gemini API 認証ヘッダー（page 117）

```
x-goog-api-key: <APIキー>
```

---

## 💡 Tips・原則

### 1. ハードコーディング絶対禁止

> 「コードに API キーを直接書いてしまうと、そのコードを誰かに見せたり、GitHub に公開したりした時に、API キーが丸見え」

**3層防御**:
1. ハードコード禁止
2. .env で分離
3. .gitignore で Git 管理対象外

### 2. API キーは「パスワード以上」に重要

> 「パスワードと同じか、それ以上に大切に管理してください」

→ 漏洩リスク = なりすまし → 高額請求

### 3. キーのローテーション

> 「即座にそのAPIキーをサービス管理画面で無効化 → 新しいキーを発行し直し」

→ これを「キーのローテーション」と呼ぶ（業界用語）

### 4. API vs ブラウザ自動化

**APIを優先する3つの理由**:
- 速い（ブラウザ起動オーバーヘッドなし）
- 安定（仕様が公式で変更されにくい）
- 変更に強い（事前告知あり）

**Playwright / Puppeteer / Selenium が必要な場面**:
- そもそも API が提供されていないサービス
- 一般ユーザーUIにしか機能がない場合

### 5. HTTPステータスコードでエラー切り分け

- 400番台 → こちら側（リクエスト/認証）の問題
- 500番台 → サーバー側の問題（少し待つ）

### 6. トークン計算の現実的目安

- 日本語：文字数の約1.5-2倍がトークン数（漢字多いほど多い）
- 英語：単語数 ≒ トークン数
- 不安なら Tokenizer ツール

### 7. ライブラリと裏側のHTTPリクエストの両方を知る

> 「ライブラリを使えば簡潔に書けますが、裏側の仕組みを知っておくと、エラーが出たときの原因特定や、ライブラリがない API を使う場面で役立ちます」

### 8. 開発者スラングは知っておくが使わない

「API を叩く」は通じるが、本書では「呼び出す」「実行する」を使う
→ 非エンジニアとの会話/ドキュメントでは丁寧語を選ぶ

### 9. ドキュメントは「サービス名 api document」で検索

- 英語でも Google 翻訳で十分
- Gemini は日本語ドキュメントあり: https://ai.google.dev/gemini-api/docs?hl=ja

### 10. パブリックAPI集を知っておく

GitHub: https://github.com/public-apis/public-apis
→ 認証不要や軽い認証で使えるAPIが大量にカタログ化されている

---

## 🎓 AIpaX school 適用案

### Module: 「API入門 — 外の世界とつながる」（90分授業×3コマ）

#### コマ1: APIとは何か（座学）
- **教材**: page 104-108 を再構成
- **狙い**: 「自分の作ったプログラムが外部サービスと話せる」体感
- **デモ**: 講師が事前に作ったプログラムから天気APIを叩いて、生徒の前で実行
- **演習**: EC価格チェック5ステップを手動でやってみる（10分）→ APIで一瞬で終わるデモを見せる

#### コマ2: APIキーと安全管理（実践）
- **教材**: page 108-113
- **狙い**: 「お金が絡む情報を扱う責任感」
- **失敗例ワーク**: わざと GitHub に .env をプッシュした「悪い例リポジトリ」を見せて何が起きるか議論
- **演習**: Gemini で API キー発行 → .env 作成 → .gitignore 設定（30分）
- **重要**: 中高生でも「無効化 → ローテーション」を手で体験

#### コマ3: fetch で叩く（実装）
- **教材**: pages 114-120
- **狙い**: 「ライブラリの裏側はHTTPだ」を理解
- **演習1**: @google/genai ライブラリ版（10行）
- **演習2**: 同じ動作を fetch 版で書く（30行）
- **比較**: 「ライブラリ便利だが、エラー時は裏側を知ってないと困る」
- **エラー演習**: わざと API キー間違える（403）/ レート上限を超える（429）

### 中高生向け「絶対これだけは」3原則
1. **APIキー = パスワード以上**
2. **コードに直接書かない**
3. **GitHub にあげる前は .gitignore チェック**

### 副読本
- リーダブルコード（高1以上）
- リファクタリング第2版（高3以上、JavaScript版がある）

### 評価ルーブリック案
| 評価軸 | レベル1 | レベル2 | レベル3 |
|---|---|---|---|
| API理解 | APIとは何か説明できる | サンプルを動かせる | 別APIに応用できる |
| 安全管理 | .env を使える | .gitignore に追加できる | ローテーション手順を実演できる |
| エラー対応 | HTTPステータス名前を言える | 400/500の切り分けができる | デバッグまでできる |

---

## 🚀 大井AI改善適用

### Claude/OpenClaw への適用

#### 1. 「API キー漏洩監視」の自動化
- 大井のすべての wiki / scripts に対し、定期的に「ハードコード API キーが入っていないか」を OpenClaw に検査させる
- dispatch.ps1 で月1回の自動レビュー
- 検出した場合は **red 通知** で即時連絡

#### 2. .env / .gitignore チェックハブ
- 全プロダクト（Testall / Gymee / EEMUS / OMNI ...）に対し、.gitignore が .env を含むか確認する一括スクリプト
- 不備があれば自動で追加するか、Claude が「足りない」と通知

#### 3. ブラウザ自動化撤退戦略
- Chrome MCP（mcp__claude-in-chrome）を使う場面と、各 SaaS の公式 MCP（Stripe / Supabase / Notion / Slack / Gmail / Calendar / Linear / Sentry / Vercel / Asana / Fireflies / Zoom）を使う場面の明確な切り分け
- **原則**: 公式 MCP が存在する場合は Chrome MCP を使わない（page 107 の「不安定・変更に弱い」リスク回避）

#### 4. APIコスト管理ダッシュボード
- 大井が使う全 AI API（Anthropic / OpenAI / Gemini ...）のトークン消費を Stripe MCP と連動して可視化
- Gemini 3 Flash の「1日20リクエスト無料枠」のような枠を逃さない設計
- 月次レビューに自動組み込み

#### 5. HTTPステータスコード自動仕分け
- OpenClaw worker.ps1 / dispatch.ps1 のエラーハンドリング強化
- 400系 → 即時 red 通知（こちら側の問題）
- 500系 → 自動リトライ3回（待機+再試行）
- 429 → 待機時間を指数バックオフで調整

#### 6. AIpaX school 開発用「API学習リポジトリ」テンプレート
- ~/business/アプリ/aipax-school-api-template/ に：
  - `.env.example`（中身は空、変数名のみ）
  - `.gitignore`（.env と node_modules を含む）
  - README.md に page 112-113 のコツ3つを引用
  - 演習用 fetch コード（pages 115-117 ベース）
- 生徒が clone するだけで安全な状態でスタートできる

#### 7. 「ライブラリの裏側知識」のドキュメント化
- 大井が使うすべての API (Stripe / Gemini / Anthropic / etc) について、
  - ライブラリ版コード
  - fetch 直接版コード
  - 対応関係マッピング
  をブレイン wiki/concepts/api-libraries-vs-fetch.md に蓄積
- エラー時に裏側を見られる状態を維持

#### 8. APIドキュメント自動取り込み
- 新規 API 利用時、Claude が自動で「サービス名 api document」を WebSearch → 公式ドキュメントを wiki/sources/api-docs/{service}.md に要約保存
- 後から参照すれば即理解できる状態に

#### 9. プロンプト改善
- OpenClaw への dispatch.ps1 prompt に「**HTTPステータスコードの意味を必ず明記してエラー報告する**」を追加
- これによりエラー時の対応速度が上がる

#### 10. 「教えて中高生」モード
- AIpaX school カリキュラム検証用に、大井が中高生役で Claude に API を質問するシミュレーションを月1回実施
- 教科書の表現がそのまま使えるか・追加説明が必要かをチェック
- 結果を sources/aipax-spec-v1-* に蓄積

---

## メタ情報

- **元PDF**: C:\Users\Owner\Downloads\非エンジニアのためのAIコーディングの教科書v1.0.1.pdf
- **抽出方法**: `pdftotext -f 101 -l 120 -enc UTF-8`
- **本範囲の特徴**:
  - 第4章の幕引き（コラム2本含む）+ 第5章前半（APIの基礎・認証・fetch直叩き・ステータス・料金）
  - 非エンジニア向けに「APIは怖くない」「自動化が劇的に変わる」「ただしキーは漏らすな」の3メッセージが核
  - コード例は環境変数とfetchの2点が中心
  - 次のパート（121-140）はおそらくライブラリ・SDKの本格利用へ進む
