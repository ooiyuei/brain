---
type: meta
title: 大井湧瑛 プロファイル統合インデックス — 散在ファイルへのマスター入口
created: 2026-05-27
status: master-index
related: [[ooi-deep-synthesis-2026-05-20]], [[ooi-yuei-root]], [[ooi-soul]], [[shincoder-actions-for-ooi-2026-05-25]]
tags: [meta, master-index, profile, decision-support]
---

# 大井湧瑛 プロファイル統合インデックス

> **このファイルは「大井のことを知るための地図」。**
> 単一の決定的プロファイルは存在しない（多面的に散在）。判断の重さ・場面に応じて適切なファイルを引く。

## ⭐ Claude が使うときのルール

判断・事業評価・新規事業創出・営業文生成・大井クローン応答 など、**「大井ならどう判断するか」を再現する作業**の前に：

1. **最低限読む（S-tier、これ抜きで判断するの禁止）**:
   - [[ooi-deep-synthesis-2026-05-20]] — 最新の深層統合（認知×トラウマ×事業の交点）
   - [[shincoder-actions-for-ooi-2026-05-25]] — 最新アクションリスト（直近30日の意思決定文脈）
   - [[ooi-yuei-root]] — 根本アイデンティティ・基本属性

2. **深い判断時は追加読み（A-tier）**:
   - [[ooi-clone-spec]] — クローン仕様（恐怖の地図・判断軸）25KBの最大ファイル
   - [[ooi-soul]] — 価値観・魂
   - [[ooi-wisc-profile]] — WISC認知特性（言語理解150・視空間140・流動性推理135・WM110・処理速度115）
   - [[ooi-life-story]] — 自伝（父親の暴力→保護→里親→起業）

3. **特化シーン（B-tier、必要なら）**:
   - [[ooi-deep-profile]] — 包括的プロファイル（古いが網羅的）
   - [[ooi-self-mirror]] — 自己反省・内省記録
   - [[ooi-strategy-analysis]] — 事業戦略パターン分析
   - [[ooi-thinking-patterns]] — 思考の型
   - [[ooi-manifesto-2026-05-20]] — マニフェスト

4. **メモリ層（自動読み込み済み、補完用）**:
   - `~/.claude/projects/.../memory/user_ooi_thinking.md` — ChatGPT 789件分析の対話スタイル・思考の癖
   - `~/.claude/projects/.../memory/user_ooi_life_story.md` — 自伝のキー事実

---

## ファイル別 役割マトリクス

| ファイル | サイズ | 更新 | 役割 | 「こういう質問」のとき読む |
|---|---|---|---|---|
| [[ooi-deep-synthesis-2026-05-20]] | 12KB | 5/20 | 認知×トラウマ×事業の交点を統合 | **大井に深い相談・人生レベル判断** |
| [[shincoder-actions-for-ooi-2026-05-25]] | 8KB | 5/26 | 直近アクション50本 | **「次何やる？」「今月の優先順位」** |
| [[ooi-yuei-root]] | 15KB | 5/18 | 根本アイデンティティ | **初対面の説明・基本属性** |
| [[ooi-clone-spec]] | 25KB | 5/17 | クローン仕様 | **大井としてX投稿・営業文・回答** |
| [[ooi-soul]] | 12KB | 5/19 | 魂・価値観 | **やる/やらないの判断軸** |
| [[ooi-wisc-profile]] | 8KB | 5/17 | WISC認知特性 | **「なぜそう感じるか」の構造的説明** |
| [[ooi-life-story]] | 6KB | 5/20 | 自伝・トラウマ | **メンタル文脈・配慮が必要な話** |
| [[ooi-deep-profile]] | 15KB | 5/17 | 包括プロファイル | **網羅的に大井を知りたい** |
| [[ooi-self-mirror]] | 12KB | 5/19 | 自己反省 | **失敗・改善・自己評価** |
| [[ooi-strategy-analysis]] | 7KB | 5/18 | 事業戦略パターン | **意思決定の型を知る** |
| [[ooi-thinking-patterns]] | 6KB | 5/17 | 思考の型 | **会話スタイル・癖** |
| [[ooi-manifesto-2026-05-20]] | 3KB | 5/20 | マニフェスト | **「なぜ起業するか」の言語化** |

---

## 「シーン別 → 必読組み合わせ」

### 🎯 新規事業案を判定するとき
1. `ooi-deep-synthesis` — 認知特性・事業思考の交点
2. `shincoder-actions-for-ooi` — 直近の優先順位（無関係案を弾く）
3. `ooi-strategy-analysis` — 過去の判断パターン
4. + `/idea-judge` skill

### 🎯 大井として何か書くとき（X投稿・営業文・note）
1. `ooi-clone-spec` — 文体・語彙・トーン
2. `ooi-soul` — 価値観のフィルタ
3. + 個別事業 entities (Testall/AIpaX 等)

### 🎯 メンタル・人生相談のとき
1. `ooi-life-story` — トラウマ背景
2. `ooi-deep-synthesis` — 認知×トラウマ交差
3. `ooi-self-mirror` — 内省パターン
4. ⚠️ 父親の話・里親の話は「雑引用禁止」

### 🎯 戦略コーチング・方向性判定
1. `ooi-deep-synthesis` (master)
2. `shincoder-actions-for-ooi` (直近)
3. `ooi-strategy-analysis`
4. `ooi-yuei-root` (根本)

---

## このインデックスの保守

- 新しい `ooi-*` ファイルが追加されたら、このインデックスに必ず追記
- 6ヶ月以上更新されてないファイルは「過去スナップショット」とラベル付け、最新優先
- 矛盾する記述が見つかったら：
  1. 新しいファイルを優先
  2. `ooi-deep-synthesis` を最新版に更新
  3. 古い記述は削除せず「過去の認識」セクションに退避

## 関連入口

- 直近コンテキスト: [[hot]]
- 全体カタログ: [[index]]
- 事業判断スキル: [[/idea-judge]]
- 部署フロー: [[_routines/department-flow]]
