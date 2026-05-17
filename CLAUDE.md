# 大井湧瑛 — ビジネス第2の脳

**Plugin:** claude-obsidian  
**Vault path:** ~/business/brain/  
**Owner:** 大井湧瑛 / ooiyuei@gmail.com

## このVaultの目的

大井の事業活動に関する知識・意思決定・プロジェクト情報を複利で蓄積する。
手動でメモを書かなくても、Claude との会話が自動でWikiになる。

## Vault構造

```
.raw/           ← 取り込むソース（PDF・記事・メモ）を放り込む場所
wiki/           ← Claude が生成・更新するWikiページ群
  hot.md        ← セッション間コンテキストキャッシュ（~500語）
  index.md      ← 全ページのマスターカタログ
  concepts/     ← 概念・フレームワーク
  entities/     ← 人物・企業・プロダクト
  sources/      ← 取り込んだソースの要約
_templates/     ← Obsidian Templaterテンプレート
_attachments/   ← 画像・PDF
10_projects/    ← プロジェクト別ページ（既存）
20_areas/       ← 営業・財務・HR（既存）
30_resources/   ← リソース（既存）
40_daily/       ← 日報（既存）
```

## プロジェクト一覧（Wiki参照優先度）

主力: Testall / Gymee / EEMUS / OMNI / Agents-of-Flag  
準主力: IPAK-darts / EcoKan / AIpa-Web / AIpaX-school

## WikiへのアクセスルーティNG

他プロジェクトのClaude Codeからこのwikiを参照する場合:
1. `wiki/hot.md` を先に読む（直近コンテキスト）
2. 次に `wiki/index.md`（全体カタログ）
3. ドメイン固有情報は `wiki/<domain>/_index.md`
4. 個別ページは必要な時だけ読む

## コマンド

| コマンド | 使い方 |
|---------|--------|
| `/wiki` | Vault初期化・状態確認 |
| `/save` | 今の会話をWikiノートとして保存 |
| `/autoresearch [topic]` | 自律リサーチ → Wiki自動蓄積 |
| `/canvas` | ビジュアルナレッジマップ生成 |
| `ingest [file]` | .raw/のファイルを取り込む |
| `lint the wiki` | Vault健全性チェック |

## 運用ルール

- PDFや記事を `.raw/` に入れたら `ingest [filename]` を打つだけ
- 価値ある会話の後は `/save` を打つ
- 10〜15回ingest後に `lint the wiki` でメンテ
- hot.md は500語以内に保つ（自動管理）
