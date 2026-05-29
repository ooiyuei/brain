---
type: yuei-readme
updated: 2026-05-27
---

# 00_YUEI/ — 大井湧瑛のホーム

> **「大井 (YUEI) はここだけ見ればOK」エリア。** 普段ここしか開かなくていい。
> 詳細は各部署 (`01_ceo/`〜`09_knowledge/`) と `_system/` に置いてあるが、Claude が代わりに見る。

---

## ファイル一覧と使い方

| ファイル | 何が書いてある | 誰が更新 | いつ見る |
|---|---|---|---|
| **[[TODAY]]** | 今日やること (絶対やる1個 + できれば2個 + 進行中 + 完了) | Claude-CEO が朝/PDCA/夜に自動更新 | 朝起きて1番目、夜寝る前 |
| **[[WEEK]]** | 今週の攻める1個 + 締切リスト + 各部署進捗サマリー | Claude-CEO が日曜21時に週次棚卸しで更新 | 月曜朝、週末 |
| **[[NOTES]]** | 大井の思いつき即書きメモ (タイトル不要) | **大井が書く** (Claude が定期スキャン → 振り分け) | 思いついた瞬間 |
| **[[INBOX]]** | 取り込み待ち素材 (.raw/, Gmail添付, Slack共有等) | Claude-CEO が新着検知して追加、消化済みは削除 | 取り込み判断したい時 |
| **[[REPORT]]** | Claude-CEO の日次サマリー (今日何が動いた・要判断事項・明日の予定) | Claude-CEO が夜22時に生成 | 夜寝る前、外出前 |

---

## 大井がやることだけ抜粋

1. **朝**: TODAY を開く → 絶対やる1個を確認
2. **思いつき**: NOTES に1行書く (タイトルなしOK)
3. **判断**: REPORT を見て「Claude-CEO に上げられた判断事項」に答える (3分以内)
4. **夜**: 「終わった」と Claude に話す → Claude が done.md と REPORT を更新

> ❌ Claude に頼む時 NOTES や TODAY に書かなくていい。**口頭で話すだけでOK** (Claude が自動で適切なファイルに記録)。

---

## 階層構造のマップ

```
YUEI (大井)
  ↓ 喋る・最終承認のみ
Claude-CEO (ceo-orchestrator)
  ↓ 切り分け・Go/No-Go判断
Claude-部長 (各部署のDirector)
  ↓ タスク化・dispatch
OpenClaw社員 (qwen3.6)
  ↓ 量産・整形・要約
Claude-部長レビュー (品質保証)
  ↓
Claude-CEO 集約
  ↓
大井に報告 (REPORT.md)
```

詳細: [[01_ceo/ROLES]]

---

## 何かおかしいと感じたら

- 旧 `wiki/hot.md` `wiki/_tasks/today.md` は Phase 2-C 完了まで併存。混乱したらこの README で確認
- フォルダ構造が分からない: [[brain/CLAUDE]] の「組織図と新フォルダ構造マップ」セクション
- 役職が分からない: [[01_ceo/ROLES]]
