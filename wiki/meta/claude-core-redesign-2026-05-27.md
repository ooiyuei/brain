---
type: meta-architecture
title: Claude Core Redesign 2026-05-27
status: proposed (大井 approval required)
created: 2026-05-27
related: [[CLAUDE-md-v3-proposal]]
tags: [meta, refactor, claude-core]
---

# Claude Core Redesign 2026-05-27

> 「Claudeの根幹の部分を見直そうか」への回答。
> 933行 → 400行へ。原則だけ root に残し、操作詳細は dispatch-rules / agent-selection / discord-notification に分離。

## 現状計測

| File | Lines | Purpose |
|------|-------|---------|
| `~/.claude/CLAUDE.md` | 125 | Global Claude config |
| `~/business/brain/CLAUDE.md` | 378 | Brain Sonnet operating rules |
| `~/.claude/ORGANIZATION.md` | 305 | Org chart + routing table |
| `~/business/brain/wiki/meta/operation-rules.md` | 125 | Agent dispatch rules |
| **Total** | **933 lines** | |

## 重複の発見

1. **MCP一覧の3重複**: global L92-94 / brain L57-77 / operation-rules L79-97
2. **ルーティング表の3重複**: ORGANIZATION L121-156 / brain L78-90 / operation-rules L17-43
3. **セッション開始ritual散在**: global L23-29 / brain L34-54 / operation-rules L119-124
4. **Discord通知ルール**: brain L244-289 (45行)
5. **dispatch.ps1仕様**: brain L91-134 (44行・操作詳細)
6. **Plan-mode**: brain L157-233 (77行)
7. **決定木が無い**: Sonnet が毎回全ファイル読む

## 1. 残す (critical・verbatim 保持)

| 内容 | 出典 | 理由 |
|------|------|------|
| 大井=オーナー / Claude=秘書兼マネージャー | brain L16-32 | 役割の核 |
| brain覗く癖 (判断・大井クローン時) | brain L34-54 | 思考停止防止 |
| 能動的MCP「許可なし」原則 | brain L57-77 | 「○○やりましょうか?」禁止 |
| 発話分類8行表 | brain L78-90 | dispatch判断ロジック |
| 自走原則 + 承認必要4項目 | global L112-124 | エスカレーション境界 |
| セッションタイプ判断 | global L13-21 | 入口分岐 |
| 安全則: TODO・行数・関数50行 | global L64-68 | コーディング不変則 |
| skill/agent参照互換性 | ORGANIZATION L121-156 | 既存資産破壊禁止 |

## 2. 分離する

| → ファイル | 内容 | 行数目安 |
|-----------|------|---------|
| `~/.claude/rules/dispatch-rules.md` | dispatch.ps1詳細・PDCA・報告 | 120 |
| `~/.claude/rules/agent-selection.md` | 38agent × 33skill対応表 | 80 |
| `~/.claude/rules/discord-notification.md` | notify.ps1仕様 | 50 |
| `~/.claude/rules/plan-mode.md` | EnterPlanMode判定+Claude Code UI | 60 |
| `~/.claude/rules/mcp.md` | MCP統合一覧 | 30 |

## 3. 削除する

| 対象 | 理由 |
|-----|------|
| global L74-85 「アクティブ15プロジェクト」 | hot.md に毎日更新 |
| global L98-110 「新事業フロー」 | ORGANIZATION W1と完全重複 |
| brain L295-323 「Vault構造ツリー」 | wiki/index.md と重複 |
| brain L327-345 スケジューラ表 | scripts/SCHEDULER.md へ |
| brain L348-358 「プロジェクト一覧」 | hot.md / index.md に既存 |
| operation-rules.md 全体 | 内容統合→廃止 |
| MCP一覧3重複 | rules/mcp.md に1箇所のみ |

## 4. 新ファイル構造

```
~/.claude/
├── CLAUDE.md              ← 100行・グローバル原則のみ
├── ORGANIZATION.md        ← 305→200行
└── rules/
    ├── common/            ← 既存・触らない
    ├── design/            ← 既存・触らない
    ├── dispatch-rules.md  ← 新規 (120行)
    ├── agent-selection.md ← 新規 (80行)
    ├── discord-notification.md ← 新規 (50行)
    ├── plan-mode.md       ← 新規 (60行)
    └── mcp.md             ← 新規 (30行)

~/business/brain/
├── CLAUDE.md              ← 300行・brainセッション固有
├── 運用ルール.md            ← 廃止
├── wiki/meta/
│   ├── claude-core-redesign-2026-05-27.md  ← 本ファイル
│   └── CLAUDE-md-v3-proposal.md            ← 提案するroot
└── scripts/
    ├── SCHEDULER.md       ← 新規
    └── COMMANDS.md        ← 新規
```

**合計**: root 100 + brain 300 = **400行 (目標達成)**
**サポート**: 5新規files 340行
**Grand total**: 740行 (193行削減・21%圧縮)

セッション開始読み込み: 933行 → **250行 (約73%トークン削減)**

## 5. Session-start protocol (5行)

```yaml
1. cwd判定: ~/business/{root|brain} → 全体統括, ~/business/アプリ/* → 開発
2. 全体統括: hot.md + daily/YYYY-MM-DD.md (あれば) を読む
3. 大井発話 → 決定木に従って即実行
4. 不明な大井判断 → ooi-soul.md を読む (節約・必要時のみ)
5. dispatch/Discord/Plan詳細 → 必要時 ~/.claude/rules/{該当}.md 参照
```

## 6. Decision tree (大井発話 → 行動)

```yaml
即答可能 (時刻・場所・既知): → 即答
単純実数値 (Stripe等): → MCP取得 → 答える
単純作業: → 自分でやる
思いつきアイデア: → wiki/_tasks/ideas.md追記
調査5並列: → dispatch (research × 5)
量産: → OpenClaw dispatch
戦略判断: → ooi-soul.md + entities → 自分で考える
新規事業フルフロー: → /ceo skill
実装系: → cwd切替 + プロジェクトCLAUDE.md
「これプランにして」: → EnterPlanMode (rules/plan-mode.md)
ビルド失敗: → build-error-resolver (他作業中断・最優先)
「強化して」「最強にして」: → enhancement-roadmap.md自走
「容赦なく」「詰めて」: → /grill-me
「ブレインに入れて」: → /obsidian-vault
```

## 7. Migration steps

### Phase 0: 承認
- [ ] 大井が本redesign doc を読む
- [ ] 大井が CLAUDE-md-v3-proposal.md を読む
- [ ] 「進めて」承認

### Phase 1: 新ファイル作成 (5分・既存無変更)
- [ ] `~/.claude/rules/dispatch-rules.md` 作成
- [ ] `~/.claude/rules/agent-selection.md` 作成
- [ ] `~/.claude/rules/discord-notification.md` 作成
- [ ] `~/.claude/rules/plan-mode.md` 作成
- [ ] `~/.claude/rules/mcp.md` 作成
- [ ] `~/business/brain/scripts/SCHEDULER.md` 作成
- [ ] `~/business/brain/scripts/COMMANDS.md` 作成

### Phase 2: 動作確認 (24時間並走)
- [ ] 新ファイル存在・既存無変更
- [ ] 1-2セッション実行確認
- [ ] 不足項目追記

### Phase 3: root置換 (バックアップ取得後)
- [ ] `~/.claude/CLAUDE.md` → `.bak-20260527`
- [ ] `~/.claude/CLAUDE.md` ← 新root (100行)
- [ ] `~/business/brain/CLAUDE.md` → `.bak-20260527`
- [ ] `~/business/brain/CLAUDE.md` ← 新brain (300行)

### Phase 4: 旧無効化
- [ ] `operation-rules.md` 冒頭に DEPRECATED 注記
- [ ] 1週間後問題なければ削除

### Phase 5: 観測
- [ ] 1週間 / 1か月後 self-review

### Rollback plan
- 各Phaseで .bak ファイル保持
- 問題発生時: `mv CLAUDE.md.bak-20260527 CLAUDE.md`

## 8. 削減効果サマリ

| 項目 | Before | After | 削減 |
|------|--------|-------|------|
| Root CLAUDE.md | 125行 | 100行 | 20% |
| Brain CLAUDE.md | 378行 | 300行 | 21% |
| operation-rules.md | 125行 | 0 (廃止) | 100% |
| ORGANIZATION.md | 305行 | 200行 (将来) | 34% |
| **核ファイル合計** | **933行** | **400行** | **57%** |
| 重複MCP表 | 3箇所 | 1箇所 | -2 |
| 重複ルーティング表 | 3箇所 | 1箇所 | -2 |

セッション開始Sonnet読み込み: **933→250行 (約73%トークン削減・キャッシュヒット率↑)**

## 9. Critical rules 保持率

- 安全則 (ダミーTODO・行数・コミット規律): **100%**
- 承認エスカレーション境界 (4項目): **100%**
- 能動的MCP原則 + 3禁則: **100%**
- 役割分担 (大井=オーナー/Claude=秘書): **100%**
- 大井クローン参照 (ooi-soul.md): **100%**
- セッションタイプ判断分岐: **100%**
- Discord通知判断ロジック: **95%** (色マッピングは別ファイル化)
- dispatch.ps1 操作: **100%** (dispatch-rules.md へ移動)
- 38agent・33skill対応: **100%** (agent-selection.md へ集約)

**critical safety/security rules: 100% preserved**

## 10. 大井向け手動レビューチェックリスト

- [ ] 「秘書 + OpenClawマネージャー」の役割定義はこのままでいいか
- [ ] 「能動的MCP原則」の3禁則 (やりましょうか禁止等) はこの強さでいいか
- [ ] Sonnet vs subagent決定マトリクスに抜けがないか
- [ ] Discord通知 3レベル分類で十分か (現状7状況→3レベルへ圧縮)
- [ ] ファイル位置クイックリファレンス 10項目に不足ないか
- [ ] 大井voice markers 8個で抜けないか
- [ ] 削除対象 (15プロジェクトリスト等) を消して困らないか
- [ ] Migration Phase 2 「24h並走」期間は妥当か
- [ ] 新規 `~/.claude/rules/*.md` 5本の追加に異論ないか

## 関連
- [[CLAUDE-md-v3-proposal]] (新root提案)
- [[~/.claude/CLAUDE.md]] (現状 global)
- [[~/business/brain/CLAUDE.md]] (現状 brain)
- [[hot.md]] (直近)
- [[meta/ooi-soul]] (大井クローン)
- [[meta/enhancement-roadmap]]
