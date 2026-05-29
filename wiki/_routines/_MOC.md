---
type: moc
title: Routines MOC
tags: [moc, routines]
updated: 2026-05-18
---

# Routines MOC — 全ルーティン索引

> V3: シンプル5本構成（リモート1本＋ローカル4本）。
> 詳細は [[CLAUDE|Vault運用原則]] 参照。

## ルーティン5本

| 時刻 | 名前 | 場所 | 出力先 | 主な役割 |
|---|---|---|---|---|
| 07:00 | morning-catchup | **リモート** | `wiki/_catchup/{今日}.md` | Gmail/Calendar/Stripe等コネクター取得→MD化 |
| 08:30 | (BrainMonitor) | ローカル自動 | `wiki/_monitor/{種類}-{今日}.md` | OpenClawに3本投入（競合・締切・問い） |
| 09:00 | morning | ローカル | `wiki/_routines/morning-{今日}.md` + `wiki/_tasks/today.md` | catchup＋monitor見て今日の作戦 |
| 12:30 | midday | ローカル | `wiki/_routines/midday-{今日}.md` | 進捗チェック＋PDCAレビュー |
| 22:00 | evening | ローカル | `wiki/_routines/evening-{今日}.md` | 振り返り＋明日仕込み |
| 日21:00 | weekly | ローカル | `wiki/_routines/weekly-{週}.md` (月末日は `monthly-{月}.md` も) | 棚卸し＋tier再判定 |

## 指示書ファイル

| ルーティン | 指示書 |
|---|---|
| morning-catchup | [[routines/morning-catchup\|brain/routines/morning-catchup.md]] |
| morning | [[routines/morning-simple\|brain/routines/morning-simple.md]] |
| midday | [[routines/midday-check\|brain/routines/midday-check.md]] |
| evening | [[routines/evening-simple\|brain/routines/evening-simple.md]] |
| weekly | [[routines/sunday-review\|brain/routines/sunday-review.md]] |

## 関連リンク

- [[CLAUDE|Vault運用原則・Claude動き方]]
- [[_tasks/_MOC|Tasks MOC]]
- [[hot|Hot Cache]]
- [[index|Wiki Index]]
