---
type: source-deep
title: 非エンジニアのためのAIコーディングの教科書 Part5 (pages 81-100)
created: 2026-05-26
source_pages: 81-100
related: [[sources/ai-coding-textbook-deep/INDEX]]
tags: [ai-coding, claude-code, education, deep-read]
---

# Part 5: pages 81-100 完全ノート

第4章「プログラミング基礎」の中盤。条件分岐の応用 → 配列/オブジェクトとの組み合わせ → ループ → 関数 → 組み込み機能 → AIへの相談法 → エラーメッセージの読み方。

## 📑 セクション構成

| Page | セクション |
|---|---|
| 81 | else / else if（複数条件）/ 比較演算子の導入 |
| 82 | 比較演算子一覧 / 優先度判定コード / `==` vs `===`コラム |
| 83 | 論理演算子（`&&` `||` `!`）/ 配列との組み合わせ `includes()` |
| 84 | オブジェクトのキー存在チェック `in` / 実例：緊急タスク抽出 |
| 85 | ループ序論 / for文の基本 |
| 86 | for...of 詳解 / オブジェクトのループ `Object.entries()` |
| 87 | 配列×オブジェクト処理（顧客リスト） / while文 |
| 88 | while実行結果 / 関数：処理をまとめる「道具箱」/ 組み込み機能 |
| 89 | 関数の定義と呼び出し / 引数の概念 |
| 90 | 複数引数 / 戻り値 returnの導入 |
| 91 | return実例（add, calculateTax）/ デフォルト引数 |
| 92 | アロー関数 `=>` の紹介 / function vs アロー |
| 93 | 組み込み機能 console.log / length / reduce / Math.max,min |
| 94 | sort() / 配列メソッド（push, splice, filter）/ 文字列メソッド |
| 95 | 文字列メソッド締め（replace） |
| 96 | 「この世の全ては関数で表現できる」/ 例1:書類作成 例2:会議 例3:データ分析 |
| 97 | 業務を関数化するメリット / AIにコード説明してもらう / Antigravity ショートカット |
| 98 | AI解説の習慣化 / エラーメッセージは敵ではなく味方 |
| 99 | エラーメッセージ基本構造 / なぜ読むことが重要か |
| 100 | AIへのエラー相談テンプレ / 「最初は丸投げでもOK」本音コラム |

---

## セクション別詳細

### P81: else / else if

else は「条件が当てはまらなかった場合の処理」。

```javascript
const weather = "晴れ";
if (weather === "⾬") {
    console.log("傘を持っていきましょう");
} else {
    console.log("良い天気ですね");
}
```

3つ以上の選択肢は `else if`。何個でも追加でき、上から順に条件チェックされ「最初に一致した条件の処理だけ」が実行される。

```javascript
const weather = "曇り";
if (weather === "⾬") {
    console.log("傘を持っていきましょう");
} else if (weather === "曇り") {
    console.log("折りたたみ傘があると安⼼です");
} else if (weather === "晴れ") {
    console.log("良い天気ですね");
} else {
    console.log("天気情報が取得できませんでした");
}
```

### P82: 比較演算子一覧表

| 演算子 | 意味 | 例 |
|---|---|---|
| `==` | 等しい | `age == 25` |
| `!=` | 等しくない | `status != "完了"` |
| `>` | より大きい | `score > 80` |
| `<` | より小さい | `price < 1000` |
| `>=` | 以上 | `age >= 18` |
| `<=` | 以下 | `temperature <= 10` |

優先度判定の実コード：

```javascript
const priority = 9;
if (priority >= 8) {
    console.log("【⾼優先度】すぐに対応してください");
} else if (priority >= 5) {
    console.log("【中優先度】今週中に対応してください");
} else {
    console.log("【低優先度】余裕があれば対応してください");
}
```

**重要コラム：`==` vs `===`**

```javascript
console.log(100 == "100");   // true（型が違っても値が同じならOK）
console.log(100 === "100");  // false（型も値も完全に⼀致しないとNG）
```

「`==`は型の違いを無視して比較するため、予期しない結果になることがある。基本的には`===`を使うことをおすすめします」。本書のコード例も `===` を使用。

### P83: 論理演算子

「18歳以上で、かつ、65歳未満」のような複数条件には論理演算子。

| 演算子 | 意味 | 例 |
|---|---|---|
| `&&` | かつ（両方とも真） | `age >= 18 && age < 65` |
| `||` | または（どちらか真） | `weather === "⾬" || weather === "雪"` |
| `!` | 否定 | `!isCompleted` |

```javascript
const temperature = 5;
const weather = "⾬";
if (temperature < 10 && weather === "⾬") {
    console.log("寒くて⾬です。暖かくして傘を持っていきましょう");
} else if (temperature < 10 || weather === "⾬") {
    console.log("寒いか⾬のどちらかです。準備を");
} else {
    console.log("良いコンディションです");
}
```

**配列との組み合わせ：`includes()`**

```javascript
const tasks = ["メール返信", "資料作成", "会議準備"];
if (tasks.includes("メール返信")) {
    console.log("メール返信がタスクに含まれています");
}
```

`includes()` は true/false を返すので if 文の条件にぴったり。

### P84: オブジェクトのキー存在チェック `in`

```javascript
const user = {
    "名前": "太郎",
    "年齢": 25
};
if ("メール" in user) {
    console.log(user["メール"]);
} else {
    console.log("メールアドレスが登録されていません");
}
```

存在チェックせずアクセスすると JavaScript は `undefined` を返す。事前チェックでエラー予防。

**実例：緊急タスク抽出**

```javascript
const tasks = [
    {"タイトル": "メール返信", "優先度": 5},
    {"タイトル": "資料作成", "優先度": 9},
    {"タイトル": "会議準備", "優先度": 3},
    {"タイトル": "報告書提出", "優先度": 10}
];
console.log("【緊急タスク⼀覧】");
for (const task of tasks) {
    if (task["優先度"] >= 8) {
        console.log(`- ${task['タイトル']} (優先度: ${task['優先度']})`);
    }
}
```

実行結果：
```
【緊急タスク⼀覧】
- 資料作成 (優先度: 9)
- 報告書提出 (優先度: 10)
```

### P85: ループ序論

「プログラムの大きな強みの一つは、同じ処理を何度も繰り返すことが得意」。100件のデータ処理が一瞬。JavaScriptには主に `for` 文と `while` 文の2種類。実用性が高い for を中心に解説。

```javascript
const fruits = ["りんご", "みかん", "ぶどう"];
for (const fruit of fruits) {
    console.log(fruit);
}
```

### P86: for...of の慣例 / `Object.entries()`

「fruit という変数名は自由に決められる」。慣例：配列名が複数形なら単数形（`tasks` → `task`、`users` → `user`）。

オブジェクトのループは `Object.entries()` で「キーと値のペアの配列」に変換。

```javascript
const user = {
    "名前": "太郎",
    "年齢": 25,
    "職業": "営業"
};
for (const [key, value] of Object.entries(user)) {
    console.log(`${key}: ${value}`);
}
// 名前: 太郎
// 年齢: 25
// 職業: 営業
```

### P87: 配列×オブジェクト（顧客リスト）/ while

実務でよくある「配列の中にオブジェクトが入っている」パターン：

```javascript
const customers = [
    {"名前": "⼭⽥太郎", "企業": "A社", "売上": 500000},
    {"名前": "佐藤花⼦", "企業": "B社", "売上": 800000},
    {"名前": "⾼橋次郎", "企業": "C社", "売上": 600000}
];
console.log("【顧客リスト】");
for (const customer of customers) {
    console.log(`${customer['名前']}（${customer['企業']}）- 売上: ¥${customer['売上'].toLocaleString()}`);
}
```

`toLocaleString()` で `500000` → `500,000` のカンマ区切り。

**while文：条件が真の間ループ**

```javascript
let count = 0;
while (count < 3) {
    console.log(`${count+1}回⽬の処理`);
    count += 1;
}
```

「条件が永遠に真のままだと無限ループになってしまうため、注意が必要」。

### P88: while実行結果 / 関数導入

```
1回⽬の処理
2回⽬の処理
3回⽬の処理
```

「日常的な自動化では for 文の方が使い勝手が良い」。

**関数：処理をまとめる「道具箱」**

```javascript
function greet(name) {
    console.log(name + "さん、こんにちは！");
}
greet("⽥中");  // "⽥中さん、こんにちは！"
greet("鈴⽊");  // "鈴⽊さん、こんにちは！"
greet("佐藤");  // "佐藤さん、こんにちは！"
```

組み込み機能の例：
```javascript
console.log("こんにちは");          // 関数
console.log([1, 2, 3].length);     // プロパティ (結果: 3)
console.log(typeof "⽂字列");      // 演算子 (結果: string)
```

### P89: 関数の定義と呼び出し / 引数

「自分で関数を作ることを、プログラミングの世界では定義すると言います」。

```javascript
function greet() {
    console.log("こんにちは！");
    console.log("良い⼀⽇を！");
}
greet();
```

**ポイント3つ：**
- `function 関数名() {}` で関数を定義
- 関数の中身は中括弧 `{}` で囲む
- 関数名に `()` をつけて呼び出す

**引数（ひきすう）= 関数への入力**

### P90: 複数引数 / 戻り値

```javascript
function greet(name) {
    console.log(`こんにちは、${name}さん！`);
    console.log("良い⼀⽇を！");
}
greet("太郎");
greet("花⼦");
```

複数引数：

```javascript
function greet(name, time) {
    console.log(`おはようございます、${name}さん！`);
    console.log(`今は${time}時です。`);
}
greet("太郎", 9);
greet("花⼦", 10);
```

「関数が計算した結果を呼び出し元で使いたい場合」→ return。

### P91: return / デフォルト引数

```javascript
function add(a, b) {
    const result = a + b;
    return result;
}
const total = add(100, 200);
console.log(total);  // 300
```

```javascript
function calculateTax(price, taxRate = 0.1) {
    return price * taxRate;
}
const tax = calculateTax(1000);
console.log(`税額: ¥${tax}`);  // 税額: ¥100
```

「returnを使うと、関数の実行がそこで終了し、結果が呼び出し元に返されます」。

**デフォルト引数：**

```javascript
function greet(name, greeting = "こんにちは") {
    console.log(`${greeting}、${name}さん！`);
}
greet("太郎");                  // デフォルト値を使⽤
greet("花⼦", "おはよう");      // 明⽰的に指定
```

### P92: アロー関数

```javascript
// 従来の書き⽅
function greet(name) {
    return `こんにちは、${name}さん`;
}

// アロー関数の書き⽅
const greet = (name) => {
    return `こんにちは、${name}さん`;
};

// 1行版
const greet = (name) => `こんにちは、${name}さん`;
```

「本書では分かりやすさを優先して function を使っていますが、実際の開発現場ではアロー関数の方が主流」。配列処理で頻出：

```javascript
const numbers = [1, 2, 3, 4, 5];
// 従来
const doubled1 = numbers.map(function(n) {
    return n * 2;
});
// アロー（こちらが主流）
const doubled2 = numbers.map(n => n * 2);
```

### P93: 組み込み機能

```javascript
// console.log
console.log("こんにちは");
console.log(100);
console.log(["りんご", "みかん"]);

// length
const tasks = ["メール返信", "資料作成", "会議準備"];
console.log(tasks.length);  // 3

// reduce
const numbers = [10, 20, 30, 40];
console.log(numbers.reduce((a, b) => a + b, 0));  // 100

// Math.max / Math.min
const scores = [85, 92, 78, 95, 88];
console.log(Math.max(...scores));  // 95
console.log(Math.min(...scores));  // 78
```

### P94: sort / 配列メソッド / 文字列メソッド

```javascript
// sort（昇順）
const numbers = [5, 2, 8, 1, 9];
console.log([...numbers].sort((a, b) => a - b));  // [1, 2, 5, 8, 9]
// 降順
console.log([...numbers].sort((a, b) => b - a));  // [9, 8, 5, 2, 1]
```

```javascript
// 追加
const tasks = ["メール返信", "資料作成"];
tasks.push("会議準備");
// 削除
const index = tasks.indexOf("資料作成");
if (index > -1) tasks.splice(index, 1);
// カウント
console.log(tasks.filter(t => t === "メール返信").length);  // 1
```

**文字列メソッド：**

```javascript
const text = "hello, world";
console.log(text.toUpperCase());           // HELLO, WORLD
console.log(text.toLowerCase());           // hello, world
console.log(text.split(", "));             // ['hello', 'world']
```

### P95

```javascript
console.log(text.replace("world", "JavaScript"));  // hello, JavaScript
```

### P96-97: 「この世の全ては関数で表現できる」（思想セクション）

著者の核となる思考。「実際のところ私たちが日々行う仕事の多くは『関数』として捉えることができる」。

**例1：書類作成**
```javascript
function createDocument(data, template) {
    // データをテンプレートに流し込む処理
    return completedDocument;
}
```
- 入力：元データ、テンプレート
- 処理：データ整形してテンプレートに流し込む
- 出力：完成した書類

**例2：会議**
```javascript
function meeting(agenda, participants) {
    // 議論して意思決定する処理
    return decisions;
}
```
- 入力：議題、参加者
- 処理：議論、意思決定
- 出力：決定事項

**例3：データ分析**
```javascript
function analyzeData(rawData, criteria) {
    // データを分析する処理
    return insights;
}
```

**仕事を関数化する3つのメリット：**
1. 業務の本質が明確になる：何を受け取り、何を返すべきかがはっきり
2. 効率化のポイントが見える：処理部分を自動化できないか考えられる
3. 品質が安定する：同じ入力なら同じ出力が得られるよう標準化

「プログラミングを学ぶことで、このような『分解して考える力』が自然と身につきます。これは、AIに指示を出す時だけでなく、日々の仕事を設計する時にも役立つ思考法です」。

### P97: AIにコードを説明してもらう / Antigravityショートカット

「AIコーディング時代の最大の強みは、『わからないところをすぐにAIに聞ける』こと」。

**Antigravity 操作手順：**
1. 理解したいコードを選択
2. `Ctrl + L` (Windows) または `Command + L` (Mac) を押す
3. 「このコードを初心者向けに説明して」と入力

### P98: AI解説の習慣化 / エラーメッセージは味方

「わからないコードに出会ったら、すぐにAIに聞く習慣をつけましょう。自力で悩む時間を減らし、理解を深めることに時間を使えます」。

「エラーメッセージは敵ではなく、味方です。エラーメッセージには、『どこで』『何が』問題なのかが書かれています」。

### P99: エラーメッセージ基本構造

```
Uncaught ReferenceError: name is not defined
    at script.js:5
```

最初の行に重要情報：
- エラーの種類（`ReferenceError`）
- 原因（`name is not defined`）
- ファイル名と行番号（`script.js:5`）

「『エラーが出ました』とだけAIに伝えても、AIは何が問題なのか分かりません。しかし、エラーメッセージ全体をAIに渡すことで、AIは以下のことができます」：
- エラーの種類から原因を特定
- 問題のある行を確認
- 適切な修正方法を提案

「つまり、エラーメッセージは『AIに正確に状況を伝えるための重要な情報』なのです」。

### P100: AIへのエラー相談テンプレ

**標準テンプレ（最重要）：**

```
以下のJavaScriptコードでエラーが出ました。原因と修正⽅法を教えてください。

【コード】
[エラーが出たコードを貼り付け]

【エラーメッセージ】
[エラーメッセージ全体をコピー＆ペースト]
```

**3つの鉄則：**
1. エラーメッセージを全文コピー（最後の行だけだとAIが状況把握できない）
2. エラーが出たコードも一緒に貼り付け
3. 「何をしようとしていたか」を簡単に説明（例：「ユーザーの年齢を計算しようとしたらエラーが出ました」の一文で回答品質が格段に上がる）

**著者の本音コラム：「最初はとりあえず全部AIに丸投げでも良いです」**

著者の正直な告白：
- 「私は最近エラーメッセージを読んでいません」
- 「多少はどんなエラーか確認はするものの、結局やることはエラーメッセージを全文コピペしてAIに丸投げすることです。大抵これで直ります」
- ただし「エラーメッセージをちゃんと読んで、何が間違っていたのかというフィードバックを得ることは、自分の成長にポジティブなのは間違いありません」
- 「とりあえずは丸投げでポンポンでもいいのですが、心に余裕があるときは一歩立ち止まってエラーメッセージを読んで学んでみることがおすすめです」

---

## 🛠️ コマンド・プロンプト一覧

### Antigravity ショートカット
- `Ctrl + L` (Windows) / `Command + L` (Mac) — 選択コードをAIに質問

### コード解説プロンプト
- 「このコードを初心者向けに説明して」

### エラー相談標準テンプレ
```
以下のJavaScriptコードでエラーが出ました。原因と修正⽅法を教えてください。

【コード】
[コード貼り付け]

【エラーメッセージ】
[エラーメッセージ全文]
```

### キーJavaScript構文（このパートで登場）
- `if / else / else if` — 条件分岐
- `==` / `===` / `!=` / `>` / `<` / `>=` / `<=` — 比較演算子
- `&&` / `||` / `!` — 論理演算子
- `array.includes(value)` — 配列要素チェック
- `"key" in object` — オブジェクトキーチェック
- `for (const x of array)` — 配列ループ
- `for (const [key, value] of Object.entries(obj))` — オブジェクトループ
- `while (condition)` — 条件ループ
- `function name(args) { return value; }` — 関数定義
- `(args) => expression` — アロー関数
- `function name(arg = defaultValue)` — デフォルト引数
- `array.reduce((a, b) => a + b, 0)` — 合計
- `Math.max(...array)` / `Math.min(...array)` — 最大/最小
- `[...array].sort((a, b) => a - b)` — 昇順ソート
- `array.push()` / `array.indexOf()` / `array.splice()` / `array.filter()` — 配列操作
- `string.toUpperCase()` / `toLowerCase()` / `split()` / `replace()` — 文字列操作
- `number.toLocaleString()` — 数値カンマ区切り

---

## 💡 Tips・原則

### プログラミング学習の原則
1. **`==` ではなく `===` を使う** — 型違いによる予期しない結果を防ぐ
2. **複数形→単数形の慣例** — `tasks` ループは `task`、`users` ループは `user`
3. **`undefined` 防御** — オブジェクトキーアクセス前に `in` でチェック
4. **無限ループ警戒** — while使用時はカウンタ更新を必ず確認
5. **アロー関数を読めるように** — AIが返すコードはアロー関数主流

### 関数設計の本質
- 関数 = 「入力 → 処理 → 出力」の単位
- 業務も同じフレームで分解できる（書類作成、会議、データ分析…）
- メリット3つ：本質明確化／効率化ポイント発見／品質安定化

### AI協働の原則
- **わからないコードは即AI** — 自力で悩む時間を減らす
- **エラーメッセージは全文コピペ** — 一部だけは禁物
- **コード+エラー+意図の3点セット** — 「何をしようとしていたか」が回答品質を激変させる
- **丸投げOK** — 著者本人も「最近エラー読んでない」と告白。心に余裕あるときだけ読む

---

## 🎓 AIpaX school 適用案

### 中高生カリキュラム第5回〜第6回想定

**第5回：条件と繰り返し（90分）**

```
[15分] 復習：変数・配列・オブジェクト
[20分] if/else/else if ハンズオン
  - 「テストの点数で判定するプログラム」
  - 80以上：合格、60以上：再テスト、それ以下：補習
[15分] 比較演算子 & 論理演算子のクイズ
[20分] for文ハンズオン
  - クラスメート全員の名前を配列にして全員に挨拶
  - 部活メンバーの出席状況を集計
[15分] 「緊急タスク抽出」を自分の宿題リストでやってみる
[5分] AIで自分のコードを説明してもらう
```

**第6回：関数で「自分の道具」を作る（90分）**

```
[10分] 復習クイズ
[15分] 関数の概念：日常を関数化してみよう
  - 「朝の準備」「学校に行く」を入力→処理→出力で書く
[20分] 関数定義ハンズオン
  - 挨拶関数 → 計算関数 → 税込価格関数
[15分] アロー関数の書き換えチャレンジ
[20分] 「この世の全ては関数」ディスカッション
  - 自分の好きな趣味を関数化してみる
  - 「ゲームをクリアする」「曲を作る」「動画を編集する」
[10分] AIにエラーを相談するテンプレを覚える
```

**第7回（プレ）：エラー上等！AIと一緒に直す（90分）**

```
[15分] 故意にエラーを起こす実験
  - typo / 未定義変数 / 型違い
[25分] エラーメッセージ読解クイズ
  - ReferenceError / TypeError / SyntaxError の見分け
[30分] AI相談テンプレでペア演習
  - ペアでお互いのエラーをAIに投げて比較
[15分] 「丸投げと自学のバランス」をディスカッション
[5分] 振り返り
```

### カリキュラム設計の核
- **「この世の全ては関数」を中高生の言葉で** — 部活、ゲーム、勉強、人間関係全てに当てはめる
- **エラーへの恐怖を最初に取り除く** — 「敵じゃなくて味方」を体験で実感
- **AI相談テンプレを「型」として刷り込む** — コード+エラー+意図の3点セット

---

## 🚀 大井AI改善適用

### 1. AI協働における「3点セット」原則を自分のClaude Code運用に組み込む

著者の「コード+エラー+意図」の3点セットは、自分が普段Claude Codeに投げる時の質をチェックする原則として使える。

**現状の癖：**
- エラーだけ投げてしまうことがある
- 「何をしようとしていたか」を省略しがち

**改善ルール：**
- ビルドエラー報告時は必ず「目的+コード+エラー全文」を貼る
- agent起動時のプロンプトに「context: 何を達成したいか」を入れる
- これを `~/.claude/CLAUDE.md` のセッション開始ルーチンに明示化検討

### 2. 「業務 = 関数」思考を組織運営に適用

著者の核思想「仕事を関数として捉える」は、ORGANIZATION.md の部署設計とそのまま整合する。

**応用：各部署を関数として再定義**
```
function 新規事業部(課題, リソース) {
    // 30案出す → 採点 → 磨く → 穴探す → PRD化
    return 検証済み事業案;
}

function 開発部(PRD, 設計書) {
    // TDD → 実装 → レビュー → デプロイ
    return 動くプロダクト;
}

function 秘書室(オーナー意図, 文脈) {
    // 整理 → 委任 → フォロー
    return 進捗報告;
}
```

→ ORGANIZATION.md の各部署ページに「入力 / 処理 / 出力」を明示化する更新候補。

### 3. 「丸投げと自学のバランス」を自分の学習に適用

著者の正直な告白「最近エラー読んでない、丸投げで直る」は、自分のClaude Code依存パターンに通じる。

**自問チェック：**
- 全てClaude Codeに丸投げしていないか
- たまには立ち止まって「なぜそうなったか」を学んでいるか
- 17歳→18歳の成長期に、AIに溶けすぎていないか

**運用提案：**
- 週1回、「Claudeに頼らず自力で読む日」を設ける（hot.md にルーチン追加検討）
- エラー発生時、まず10秒は自分で読んでから丸投げする

### 4. AIpaX school のコンテンツとして「3点セット」を必修化

第6回〜第7回の核として、「AIへの相談の型」をスキルとして定着させる。
- スライド1枚で覚えられるテンプレ化
- 全教材の演習に「AIにこう聞いてみよう」コラムを差し込む

### 5. 「Antigravity ショートカット」習慣の自分への移植

著者は `Ctrl+L` で選択コードをAIに聞く流れを推奨。
- 自分のClaude Code運用でも、コード片の選択→質問の流れを習慣化
- 該当キーバインドの設定確認 → ~/.claude/keybindings.json 検討

### 6. 「比較演算子の罠」を中高生向け教材に強調

`==` vs `===` の話は、中高生が「型」という抽象概念に触れる絶好の機会。
- 「100 == "100" は true だけど 100 === "100" は false」のような具体例
- AIpaX school のクイズコンテンツとして使えるネタ

---

## 📌 Part 5 まとめ

- **JavaScript条件分岐〜関数までの基礎完了** — `if/else`, `for/while`, `function`, `return`, アロー関数
- **「業務を関数化する」哲学が初登場** — 著者の核思想。書類作成・会議・データ分析全てが関数
- **AI協働の実践フェーズへ移行** — Antigravity ショートカット、コード解説、エラー相談テンプレ
- **エラーメッセージ哲学** — 「敵ではなく味方」「全文コピペ」「丸投げOKでも自学はプラス」
- **AIpaX school 第5-7回相当のコンテンツ密度** — ハンズオン演習がそのまま組める
