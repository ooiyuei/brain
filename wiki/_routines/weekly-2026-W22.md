---
type: weekly
week: 2026-W22
period: 2026-05-25〜2026-05-31
tags: [routine, weekly]
created: 2026-06-01
---

# 週次棚卸し [[2026-W22]] (2026-05-25〜2026-05-31)

> **注**: 本来は日曜21:00実行だが、月曜朝の自動週次タスクで実行。前週 (5/25-31) の動きを棚卸し、今週 (6/1-6/7) の打ち手3個を決める。
> 5月最終週 = 月初の総括も兼ねる。

## 一週間サマリー (3行)

1. **会社インフラ・組織構造を物理化した週** — 5/27 一日でドメイン+Google Workspace+Slack+Notion 同日契約、Phase 2 (9部署+大井ホーム) 構造化、Remote Control CLI整備。一日で別の会社になった。
2. **OpenClaw工場が完全稼働に乗った** — 5/29 工場ブリッジ+headless git同期+再起動耐性。5/25深夜のOvernight 100件投入 → 5/31時点で1067 git commit (BrainGitSync 4分毎)。質も上がり、夢AWARD骨子v3・AIpaX 80万提案書・クロージング想定問答15選など実用級成果物が複数昇格。
3. **大井の最深層が言語化された週** — Almeo MVV「熱狂を、つくる。」確定、大井クローン v4 spec (JSONL 36例・46KB)、コメダ事件パニック発作 → 7.5h完全復帰プロトコル化、「血統が違う・ウマ娘論」整理。SFC AO論点も連動して固まった。

## 動いた事業

- [[entities/aipax|AIpaX]]: クロージング想定問答15選・80万提案書フル版・QA15選・既存4社アップセル提案 — 5社目クロージング素材完備。月20万→100万の最後の橋。
- [[entities/eemus|EEMUS]]: 夢AWARD骨子v3 + ストーリー骨子 + 60秒ピッチ台本v3 — 応募素材が二重に揃った状態で6/7締切に突入。
- [[entities/aipa-web|AIpa Web]]: 5/26 5件inbox + 5/27 9件PROMOTE (LP案/契約書/X広告/企業リスト/商工会メール)。モニター獲得への商談材料が揃った。
- [[entities/almeo|Almeo]]: **MVV「熱狂を、つくる。」確定**。Digital AI補助金 第1次 (5/31) は逃したが第2次 (8月末) 切替判断。
- [[entities/testall|Testall]]: Studyplus比較・βX投稿 (清水×鈴木蓮太郎ペルソナ) ・教育者連携アプローチ素材生成。
- **新規3案**: [[entities/tobira-log|tobira-log]] (78点GO・1週間検証可能) / [[entities/aisho-check|aisho-check]] (82点有望) / [[entities/senbatsu-lp|senbatsu-lp]] (80点有望) / 大井塾 (78点有望) — Notion事業DBに+4登録。
- **インフラ系** (事業ではないが重要): Phase 2 物理化 / 会社インフラ4種同日契約 / 工場ブリッジ稼働 / brain git 12日分push復旧 / Remote Control CLI。

## 1週間動きなし (要判断)

- [[entities/gymee|Gymee]]: 3週連続停止。**判断: 寝かす継続。再起動条件 = ピボット仮説3行 + Stripe設定機運**
- [[entities/omni|OMNI]]: 2週連続停止。**判断: 寝かす継続。月末でも触らず、来月再評価**
- [[entities/aipax-school|AIpaX school]]: 教材m4-w1未着手・体験会2h設計のまま停滞。**判断: AIpaX本体に統合検討開始 (独立事業として薄い)**
- [[entities/agents-of-flag|AOF]]: 5/25時点で「来年Q1・PoC前」のまま今週言及ゼロ。**判断: 寝かす継続**
- IPAK系 (fishing / darts / おふろかふぇ / Cafe): 全停滞。**判断: fishing は FishOps Agent ピボット後の次手未定 — 月末再評価で「やめる」も視野**
- [[entities/fruits-sauce|フルーツソース]] / [[entities/wa-kouchai|和コウチャイ]]: プロジェクトカードのみ。**判断: 寝かす**

→ **15事業中 6事業がアクティブ・9事業が停滞。**「やめる/寝かす」明示が必要なフェーズ。

## 今週の数字 (取れる範囲で)

- **AIpaX 月商**: 約20万/月 (変動なし、5社目クロージング待ち)
- **月収100万ギャップ**: 80万/月 (6/21まで残20日)
- **brain git commits**: 1067件 (BrainGitSync 4分毎稼働の効果。実質作業commitは内数十件)
- **wiki inbox**: 5/28時点544件 → 5/31時点約848件残 (削除分: ハルシネ19+重複Studyplus7+ペルソナ15+Stripe11+EEMUS1+shincoder197+portfolio11+80man14 = **計275件以上削除**)
- **昇格 (PROMOTE)**: 計4件以上 (夢AWARD骨子v3 / AIpaXクロージング想定問答15選 / AIpaX80万提案書 / EEMUS応募ストーリー骨子)
- **Notion 事業DB**: +4案 (tobira-log / aisho-check / senbatsu-lp / 大井塾)
- **wiki総ページ**: 不明 (前週27→今週は数百規模、ただしOpenClaw inbox含む)
- **OpenClaw完了タスク**: 推定100件以上 (Overnight 100件投入+日次dispatch)
- **新規顧客**: 0 / 解約: 0 / API・SaaSコスト: 不明 (Stripe MCP未取得)

## OpenClaw品質振り返り (PDCA)

**評価軸:**
- 良品質 (昇格): 4件以上 (夢AWARD骨子v3・AIpaXクロージング想定問答15選・AIpaX80万提案書・EEMUSストーリー骨子)
- 微妙 (再dispatch): 0件 (今週は再投入判断なし、即削除へ)
- ダメ (削除): **275件以上** (前週比10倍以上)

**ハルシネが多かった部署:**
- **research**: 静岡中堅企業リスト19件 (大企業混入)・Stripe架空数字11件
- **newbiz**: shincoder S1/S9 系で日本語文字化け197件 (CP932→UTF-8変換失敗)
- **marketing**: Studyplus比較重複7件・Testallペルソナ複製15件

**フォーマット崩れ:**
- shincoder S1/S9 タスクで Win コンソール文字化けが量産 → CP932環境変数依存。**改善: shincoder系は qwen3.6:latest UTF-8強制 or worker側でencoding検査追加**
- 80man系で14件重複 → AutoReview停止後の手動dispatch重複問題が継続。**改善: dispatch時にtitle/promptハッシュでdedupe**

**prompt-prefix.md 追加すべきガードレール:**
- 「企業リストを出す時は『中堅 = 売上10-300億』を明示・想像で大企業を混入しない」
- 「価格・売上数字を出す時は『仮説』を明記し、出典がない数字は出さない」

## 大井の脳汁マップ更新

- 🔥 **脳汁出てる**:
  - **AIpaX** (80万ギャップ・5社目接触一押し)
  - **EEMUS / 夢AWARD** (締切6日・追い込みフェーズの集中)
  - **Almeo「熱狂を、つくる。」** (MVV確定で全事業の縦串候補に昇格)
  - **tobira-log** (78点GO・1週間検証可能の速さ)
  - **大井クローンv4** (JSONL 36例・自己定義の完成)

- 💧 **冷めた**:
  - **Digital AI補助金 第1次** (5/31終了で実質ロスト・第2次=8月末へ後退)
  - **Gymee** (3週連続停止・テーマ懸念)
  - **AIpaX school** (独立事業として薄い・AIpaX統合候補)
  - **OMNI** (継続停滞)
  - **IPAK全般** (停滞継続)

- 💡 **新アイデア**:
  - 「熱狂を、つくる。」を**全15事業の縦串MVV**として再構築できる可能性 (Almeo発・横展開)
  - 「血統が違う・ウマ娘論」を大井ブランド (note・SFC AO・採用) の中核narrativeに
  - **15事業の優先順位再評価** をAIpaX school統合判断と一緒にやる必要性 (queue に既に1件あり)

## 来週の打ち手3個 (W23 6/1-6/7)

### 1. 🔥 攻める

**夢AWARD 応募骨子完成 → 提出** — [[entities/eemus]]
- やること: `_promoted/newbiz/eemus-dream-award-骨子v3-2026-05-27.md` + `eemus-dream-award-story-2026-05-31.md` の2本を読んで、大井が30分肉付け → 応募フォーム入力
- 期限: **2026-06-07 (日)**・残**6日**
- 成功基準: 応募完了 (フォーム送信スクショ or 受付メール)
- なぜこれ: 叩き台2本が揃ってる・大井の30分だけが律速・これ以上の先延ばしは手遅れ。脳汁出てる。締切ある。やらない理由がない。

### 2. 🌱 種まき

**AIpaX 5社目クロージング接触** — [[entities/aipax]]
- やること: 想定問答15選 (`_promoted/newbiz/aipax-closing-qa-5th-client-2026-05-31.md`) と80万提案書フル版 (`_promoted/newbiz/aipax-proposal-80man-2026-05-31.md`) を持って、大井が直接1社にクロージング接触
- 期限: 来週中 (6/7まで)
- 成功基準: 商談1件実施 (受注/非受注問わず接触完了)
- なぜこれ: 月収80万ギャップ (6/21まで残20日) の最速手。素材は完備。大井の連絡1本だけ。種まき扱いだが攻めと変わらないインパクト。

### 3. 🪦 やめる/寝かす

**AIpaX school を独立事業から外し、AIpaX 教育コースとして統合判断** — [[entities/aipax-school]]
- 判断: **来週中に統合 or 完全休眠の判断を確定する**
- 理由:
  - 第1期5名・教材m4-w1・体験会2h設計 全部停止
  - 独立事業として「親FAQ 30問」「カリキュラム詳細」を量産しても刺さらない
  - AIpaX本体に「中高生向け教育コース」として吸収すれば営業導線が一本化される
  - 「やめる」が今週ゼロだと事業数が増え続けて大井の脳メモリを食う
- 再起動条件: AIpaX本体が月100万到達後 (=6/21以降) に再評価
- 補足: **Digital AI補助金 第1次は別途明確に「完了」扱い** (第2次=8月末は別タスク化、TODAY/今週には載せない)

## 来週末までに見るべきもの

- 夢AWARD応募完了スクリーンショット (6/7)
- AIpaX 5社目商談議事録 (Fireflies)
- OpenClaw shincoder文字化け再発有無 (encoding修正効果)
- inbox件数の減少カーブ (848件 → 目標500件以下)

## 大井への問い (自分で振り返り用)

1. **今週、最も「話しながら考える」状態が出たのはどの瞬間？** — コメダ事件後の7.5h回復、「血統が違う・熱狂を、つくる。」が連結した瞬間が最深ヒットだったはず。記録に残す価値あり。
2. **来週、絶対に避けたい状況は？** — 夢AWARD骨子を「叩き台のままで応募する/応募しない」のどちらか以外。中途半端な肉付けで出すならブランド毀損なので「出さない」が正解。
3. **AIpaX school を切る判断に違和感ある？** — 大井が「学校形態に思い入れがある」なら統合判断は無理。なら「3ヶ月寝かす」に変更。

## 関連リンク

- 先週: [[_routines/weekly-2026-W20]] (W21は飛ばし)
- 今週の朝メモ: [[_routines/morning-20260527]] [[_routines/morning-20260530]] [[_routines/morning-20260531]] [[_routines/morning-20260601]]
- 今週の夜メモ: [[_routines/evening-20260526]] [[_routines/evening-20260527]] [[_routines/evening-20260528]] [[_routines/evening-20260529]] [[_routines/evening-20260530]] [[_routines/evening-20260531]]
- 今週の昼メモ: [[_routines/midday-20260526]] [[_routines/midday-20260527]] [[_routines/midday-20260528]] [[_routines/midday-20260529]] [[_routines/midday-20260530]] [[_routines/midday-20260531]]
- ホットキャッシュ: [[hot]]
- 大井ホーム: [[00_YUEI/TODAY]] [[00_YUEI/WEEK]]
- 直近30日アクション: [[meta/shincoder-actions-for-ooi-2026-05-25]]
- 5月総括 (月初実行・軽め): なし (月末日曜=5/31 weekly実行されず・今回の週次に内包)
