---
task_id: fa2e2bcf
title: [BG-Entities] juken-os 更新提案
model: qwen3.6:latest
completed: 2026-05-27 10:08:26
---

---
type: entity-refresh-proposal
entity: juken-os
date: 2026-05-27
tags: [refresh, proposal, merge, testall]
---

# [[entities/juken-os]] 更新提案 2026-05-27

## 1. 状態変化チェック
- **現状**: 文書は「Testallに進化済」と記載されているが、[[entities/juken-os]] 自体が独立したエンティティとして残っている。これは「統合の遅れ」または「アーカイブの不完全」を示す。
- **推奨更新**: 
  1. [[entities/juken-os]] のステータスを `archived` または `merged` に変更。
  2. 本文の冒頭に「本プロジェクトは [[entities/testall]] に統合され、開発はそちらで進行中」と明記。
  3. 大井の脳内では「受験OS＝Testall」で統一されているはずなので、wiki上の分離は「情報の断絶」を生む。即時解消する。

## 2. 数字最新化
| 項目 | 既存値 | 推奨更新 | 備考 |
|---|---|---|---|
| 状態 | MVP実装済・有望 | **Testallに統合・開発継続中** | [[entities/testall]] のステータスと連動 |
| 価格 | ¥980/月 → 検討¥2,980 | **¥500/月 (Standard) / ¥1,500/月 (Premium)** | [[entities/testall]] の最新料金設計を参照 |
| TAM | 9,800億円 | **2,160億円** | [[entities/testall]] の再試算値を採用（受験市場全体の定義見直しによる） |
| SOM初年度 | 3,530万円 | **先行登録からのバイラル獲得** | 具体的な数字より、GTM戦略（TikTok等）が優先 |
| JUDGE評価 | 70点 (Tier A) | **75点 (Tier A)** | [[entities/testall]] の評価を継承 |

## 3. 競合状況
- **既存記載**: 競合リストが不明確（「他に見たことない」のみ）。
- **最新動向**: [[entities/testall]] の競合分析をそのまま継承。
  - **Studyplus Planning**: 計画機能を強化中だが、テスト結果起点の自動診断ではTestallが優位。
  - **atama+**: 塾向け・高価格。個人層への参入は依然として隙あり。
  - **スタサプ**: 塾向け終了のチャンス。個人向け代替需要を取り込む。
- **整合性**: [[meta/competitive-intel]] との整合性は取れている。特に「テスト結果→45分タスク」の自動化は既存アプリとの決定的な違い。

## 4. 直近1ヶ月の推奨アクション
1. **[[entities/juken-os]] のアーカイブ処理**: 
   - 独立ページとしての価値がなくなったため、`status: merged` に変更し、[[entities/testall]] へのリンクを強化。
   - 大井の「15事業並走」による混乱を防ぐため、検索時に両方がヒットしないよう整理。
2. **[[entities/testall]] の Stripe 課金実装**: 
   - juken-os の「価格検討」段階を過ぎ、Testall は「課金実装」フェーズに入った。これが次の最重要タスク。
3. **β5名リリース準備**: 
   - 6月中のリリース目標に対し、Supabase接続完了後の最終テスト（特に課金フロー）を相川と連携して進める。

## 5. リスク・ブロッカー
- **統合の遅れ**: juken-os と testall が並存していることで、大井の脳内でも「どっちが本家？」という微かな認知負荷が残っている可能性あり。即時アーカイブで解消。
- **Stripe 本番環境**: [[entities/testall]] にも記載されているが、Stripe 課金が未着手。これが MVP の最終障壁。
- **競合の急成長**: Studyplus が AI 計画機能を強化している場合、差別化ポイント（テスト結果起点）を強調するコンテンツ（LP/動画）の更新が必要。

## 6. その他更新提案
- **メタデータの統合**: [[entities/juken-os]] の `related` フィールドに [[entities/testall]] を明示的に追加。
- **アーカイブ理由の明記**: 「大井自身が受験世代である Founder-Market Fit」は依然として強みだが、プロダクトの進化により名称と機能範囲が Testall に吸収されたため。