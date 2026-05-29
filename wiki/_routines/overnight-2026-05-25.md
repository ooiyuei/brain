---
type: routine
title: Overnight ぶん回しサマリ (2026-05-25 深夜)
created: 2026-05-25
status: running
related: [[meta/three-pillars]], [[hot]]
tags: [overnight, dispatch, mass-production]
---

# Overnight ぶん回しサマリ (2026-05-25 深夜)

> 大井「今から寝る・ぶん回して・GPU/CPU/RAM全部使う」指示。

## 今後の方針 (明確化)

### 主力5事業 進捗
| 事業 | 期限 | 状態 |
|---|---|---|
| **AIpaX** (金) | 6/21までに月100万 | 4社契約済 月20万・5社目営業中 |
| **Testall** (名) | 9月MVP | JUDGE 75点・課金未着手・データモデル設計中 |
| **AIpa Web** (補助線) | 月315万シナリオ | モニター3社獲得目標 |
| **AIpaX school** (補助線) | 第1期5名 | カリキュラムv2・体験会2h設計済 |
| **EEMUS** (補助線) | 夢AWARD 6/7 | 骨子v3作成中・連携企業20社接触前 |
| **AOF** (夢) | 来年Q1 | 仕様完全化・PoC前 |

### 戦略軸 (4本立て)
1. **緊急収益**: AIpaX 5社目契約 (6/21月収100万に向けて)
2. **応募**: 夢AWARD 6/7 + 公庫グランプリ 9/24 (SFC AO直結)
3. **モニター獲得**: AIpa Web 3社・Testall β100名
4. **ブランド**: 大井「世界のユウエイ」物語の段階構築

---

## Overnight 投入タスク (100件)

### Research (30件) - 競合・市場・業界
- AIpaX 競合6社徹底比較
- Testall 競合5社2026最新
- AIpa Web 競合5社比較
- EEMUS 競合4サービス
- 2026年AI関連市場規模5領域
- 静岡県中堅企業100社デジタル化状況
- 2024年問題後物流業界AI導入率
- インバウンド観光客の行動データ2026
- 士業デジタルツール市場調査
- 中小製造業ベテラン退職リスク調査
- Z世代起業家2026年トレンド
- ... 他19件

### Writing (25件) - LP/note/X/SEO/メール
- AIpaX note記事『AIで月20万削減』
- Testall note記事『塾に行けない受験生』
- EEMUS note記事『静岡71%流出』
- AIpa Web SEO『中小企業 採用 失敗』
- X投稿 大井キャラ30本
- TikTok台本 受験あるある15本
- 夢AWARD ピッチ60秒台本 + 3分プレゼン台本
- LinkedIn 営業文5パターン
- ... 他17件

### Coding (15件) - 仕様・API・設計
- Testall データモデル仕様
- Testall API仕様 v1
- AIpa Web Googleフォーム→DBスキーマ
- AIpaX 保存庫コア技術仕様
- AOF アプリ仕様 v1
- Stripe決済設定 5事業ロードマップ
- ... 他9件

### Newbiz (15件) - 戦略・ピッチ・提案
- 主力5事業 90日進捗ロードマップ
- 6/21月収100万達成 緊急シナリオ
- 夢AWARD後の次5ビジコン応募戦略
- SFC AO エッセイ骨子v3 30000字
- 2026 Q3/Q4 採用計画
- ... 他10件

### Corp (10件) - 財務・契約・整理
- AIpaX 業務委託契約書 5社目用
- AIpa Web モニター契約書
- Testall β顧客 利用規約
- 主力5事業 月次キャッシュフロー予測
- 主力5事業 補助金活用マップ
- ... 他5件

### Secretary (5件) - 整理・テンプレ
- 議事録テンプレ 5パターン
- 日報テンプレ 大井向け1分版
- 週次レビューテンプレ
- メール下書きテンプレ集 大井キャラ
- メンター連絡ルール 5層

---

## 稼働構成 (2026-05-25 深夜時点)

### Workers (4基並列・GPU/CPU/RAM 全力)
- heavy×2: 長文 (3000字+) 専用
- any×2: 短〜中文 (汎用)

### 自動化Schedulers
- BrainWorkerHeavy/Light (1分): queue処理
- BrainAutoReview (30分): 15件レビュー → high priority
- BrainAutoPromote (30分): PROMOTE/ARCHIVE判定
- BrainBrushupPipeline (30分): _promoted → _final 90点化
- BrainRecurrentPipeline (20分): KEEP再書き直し
- BrainTaskBankFiller (15分): inbox<30 で random投入

### Filler一時停止中 (queue膨張防止)
- BrainBizFiller / BrainAipaWebFiller / BrainSchoolContentFiller
- BrainSalesFiller / BrainMoneyFiller / BrainWritingFiller

→ 朝起きたら再有効化判断

---

## 朝起きたら確認

1. `wiki/_final/` の新規ファイル数
2. `wiki/_promoted/` の蓄積
3. queue/done 件数 (8h目標: 80件以上)
4. failed=0 維持できてるか
5. GPU/CPU/RAM 使用率推移
