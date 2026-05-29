---
type: yuei-inbox
updated: 2026-05-27
managed_by: Claude-CEO (取り込み待ち管理)
---

# 取り込み待ち素材 INBOX

> **`.raw/` `_inbox/ingest/` `Gmail添付` `Slack共有` 等から「Claude がまだ消化してない素材」をリストアップ。**
>
> 大井がここを開いて「これ取り込んで」と言うか、Claude-CEO が定期スキャンして自動取り込みを開始する。
> 詳細フロー: `brain/CLAUDE.md` の「素材取り込みフロー (.raw → wiki → skill)」

---

## 📥 未消化リスト (新しい順)

| 着弾日 | 素材 | 場所 | サイズ | 部署 | 優先度 |
|---|---|---|---|---|---|
| 2026-05-27 | `.raw/` 15件 (ingest manifest) | `_inbox/ingest/2026-05-27-0540-manifest.md` | - | 横断 | normal |
| 2026-05-19 | ChatGPT 履歴 notion-export | `(notion-export-2026-05-19)` | - | 横断 | low (cp932 化け要対処) |

---

## ✅ 取り込み完了 (アーカイブ済み)

> Claude が消化したものは `09_knowledge/learnings/` か該当部署の inbox へ移動。

### 2026-05-27
- **シンコーダー 11ステップ動画** (大井提供文字起こし) → `sources/2026-05-27-shincoder-11steps-roadmap.md` + フレームワーク化 `09_knowledge/frameworks/shincoder-11steps-roadmap.md` + PMF/CPA 2記事 + 主力5事業適用案 + スキル化 (`09_knowledge/skills/shincoder-pipeline/SKILL.md`)
- **AIpa Web 5件 inbox** (5/26着弾) → 4件 PROMOTE (04_sales_mkt_cs/leads, lp / 05_corp/legal / 02_newbiz/pitch-eemus) + 2件 再dispatch

### 2026-05-26 (既取り込み)
- 森岡確率思考続編 deep (4パート) → `sources/morioka-deep/`
- AIコーディング教科書 deep (9パート) → `sources/ai-coding-textbook-deep/`
- シンコードキャンプ raw (7本) → `sources/shincoder-raw/`

---

## 関連

- 取り込みフロー: `brain/CLAUDE.md` ⭐ 素材取り込みフロー
- ingest スクリプト: `_system/scripts/ingest_raw.py`
- 取り込み済み素材: `sources/`
