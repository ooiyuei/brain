---
type: department-readme
dept_code: 09_knowledge
dept_name: ノウハウ蓄積エリア
director: (none - 全部署共通の保存先)
updated: 2026-05-27
---

# 09_knowledge — ノウハウ蓄積エリア (大井の成長記録)

## 責務
株式会社 Almeoの**学習・成長**を蓄積する場所。失敗・成功・概念・フレームワーク・スキル化を全部ここに集約。

> 大井の方針 (2026-05-27): 「ノウハウを大量に記録する。投げる → 整理する → **原文保存する** → 活かす。失敗・成功も記録して成長する。これが Obsidian」

## サブフォルダ

### `successes/` — 成功事例
- 1ファイル = 1事例
- フォーマット: `YYYY-MM-DD-{slug}.md`
- 内容: 何をやって・なぜ上手くいったか・再現可能な要素・横展開先

### `failures/` — 失敗事例
- 1ファイル = 1事例
- フォーマット: `YYYY-MM-DD-{slug}.md`
- 内容: 何をやって・なぜ失敗したか・避け方・教訓
- **隠さない**。失敗が一番貴重な情報資産

### `learnings/` — 学び・概念整理
- Phase 2-C で旧 `wiki/concepts/` を移動
- 1ファイル = 1概念
- フォーマット: `{slug}.md` (例: `business-revival`, `shincoder-noukou`)

### `frameworks/` — フレームワーク
- 1ファイル = 1フレームワーク
- 既存例: 森岡確率思考、F1ストーリーテリング、F2合意形成4ステップ、F4 CHINTAI型5項目
- スキル化候補

### `skills/` — 完成済みスキル
- Phase 2-C で旧 `brain/skills/` を移動 (or 元の場所に保持してリンク)
- 既存: autoresearch / canvas / defuddle / obsidian-bases / obsidian-markdown / save / wiki / wiki-fold / wiki-ingest / wiki-lint / wiki-query

## 標準フロー (ノウハウのライフサイクル)

```
1. 大井が何か思いつく/学ぶ → 00_YUEI/NOTES.md に書く
2. 取り込み素材 (.raw/) を ingest → sources/ に原文保存
3. Claude が整理 → 09_knowledge/learnings/ に概念化
4. 3回繰り返したパターン → 09_knowledge/skills/ にスキル化 (boilerplate含む)
5. 成功した → 09_knowledge/successes/ に事例として記録
6. 失敗した → 09_knowledge/failures/ に教訓として記録
7. 横展開可能 → 該当部署の handoff/ にリンク追加
```

## 関連
- 取り込みフロー: `brain/CLAUDE.md` の「素材取り込みフロー (.raw → wiki → skill)」
- スキル化ルール: `brain/CLAUDE.md` の「ノウハウ → スキル化 ルール」
- 大井プロファイル: `_system/meta/ooi-profile-index.md`
