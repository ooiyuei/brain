# 🚀 新規事業 ∞ パイプライン

毎朝07時にOpenClawが2件アイデア生成 → 7軸採点 → 磨き → Red Team → PRD化 まで2時間おきに進行。

## フォルダ
- 1_seeded: idea-generator 出力（生案）
- 2_judged: 7軸採点済（S/A/B/C tier）
- 3_refined: business-refiner 磨き済（S/A のみ進む）
- 4_redteam: red-team-reviewer 穴探し済（GO/HOLD/KILL）
- 5_prd: PRD完成（GO のみ進む）→ wiki/10_projects/ に正式登録
- _graveyard: 廃案（tier B/C, verdict KILL）

## スケジューラ
- BrainNewbizSeed: 朝07:00 daily（2件/日 投入）
- BrainNewbizAdvance: 2時間おき（各ステージ進行・graveyard判定）

## 可視化
http://localhost:7777/pipeline
