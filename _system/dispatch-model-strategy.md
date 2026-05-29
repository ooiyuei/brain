---
type: system-doc
date: 2026-05-28
version: 1.0
title: OpenClaw dispatch モデル最適化戦略
purpose: ローカル常時稼働 + コスト最適化を両立する dispatch.ps1 モデル選択戦略
managed_by: 経営企画室 (Claude-CEO)
tags: [openclaw, dispatch, model-strategy, optimization]
---

# OpenClaw dispatch モデル最適化戦略 v1

> 大井方針 (2026-05-28):
> - **常にローカルでぶん回す** (24h 稼働を止めない)
> - **モデル使い分ける** (タスク種別・優先度で最適化)
> - **基本は late** (遅延 OK・軽量モデル・無料)

---

## 🎯 Priority × Model マッピング

| Priority | プレフィックス | モデル | 用途 | 速度 |
|---|---|---|---|---|
| **super** | 0 | `qwen3.6:latest` (23GB) | 最重要・即実行・大井ブロック中 | 遅い |
| **high** | 1 | `qwen3.6:latest` (23GB) | 締切24h以内・営業出力 | 遅い |
| **normal** | 5 | `qwen3.6:latest` (23GB) | 標準・3日以内に欲しい | 普通 |
| **late** ⭐ | 8 | **`qwen3:8b` (5GB)** | **大井基本方針・1週間以内OK** | 速い |
| **low** | 9 | `qwen3:8b` (5GB) | 重要度低・ぶん回し用 | 速い |

---

## 📦 インストール済モデル (ollama)

| モデル | サイズ | 用途 | 速度 |
|---|---|---|---|
| `qwen3.6:latest` | 23GB | 最強・複雑な推論 | 遅い (1タスク2-5分) |
| `qwen3:8b` | 5GB | 標準・速い | 普通 (1タスク30-90秒) |
| `qwen2.5-coder:7b` | 4.7GB | コード生成特化 | 普通 |
| `phi3:mini` | 2.2GB | 超軽量 | 速い (1タスク10-30秒) |
| `nomic-embed-text:latest` | 274MB | embedding 専用 | - |

---

## 🚦 大井方針による dispatch ルール

### 「基本 late」とは
- 大井: 「基本は late で良い」
- 意味: 急ぎじゃないタスクは **qwen3:8b** で軽量・速く・無料で回す
- Default Priority = `late` (dispatch.ps1 のデフォルト変更済)

### 「super/high」を使うべき場面
- 大井が「今すぐ」と言ったタスク
- 締切24h以内
- 営業送付直前の最終整形
- 投資家プレゼン関連
- 法務契約書ドラフト

### 「late」で十分な場面 (デフォルト)
- 競合リサーチ
- ナレッジ記事生成
- ブログ記事下書き
- アイデア生成 (idea-generator agent)
- 雑記・メモ整理
- バックグラウンド調査

---

## 🔄 24h ぶん回し体制 (Scheduled Tasks)

### Ready (稼働中・25件)
- **BrainWorkerLight/Heavy** (1分毎) - メイン処理
- **BrainHarvest** (15分毎) - inbox 整理
- **BrainDashboard** - ダッシュボード更新
- **BrainQueueGuard** - キュー監視
- **BrainTaskBoard** - タスクボード生成
- **BrainBGAINews/AipaOutreach/AppBattery/Business/Competitive/Contests/Entities** - 各部署 BG タスク
- **BrainBrushupPipeline** - 自動ブラッシュアップ
- **BrainIdeaRevivalLoop** - アイデア再評価
- **BrainShincoderLoop** - シンコーダー実装ループ
- **BrainMoneyLoop** - 売上ループ
- **BrainSelfReview** - 自己レビュー

### Filler 再Enable (2026-05-28 朝)
- ✅ BrainAipaWebFiller - AIpa Web タスク投入
- ✅ BrainBizFiller - 新規事業タスク投入
- ✅ BrainSalesFiller - 営業タスク投入
- ✅ BrainCSFiller - カスタマーサクセスタスク投入
- ✅ BrainMoneyFiller - 売上タスク投入

### Disabled 維持 (意図的)
- ❌ **BrainAutoReview** - 1521件誤投入対策・再発防止
- ❌ BrainCorpFiller / BrainDevFiller / BrainSchoolContentFiller / BrainWritingFiller / BrainIdleFiller / BrainNewbizAdvance / BrainNewbizSeed - Phase 2-D で見直し

---

## 🛠 ollama 復旧手順 (down した時)

```powershell
# 1. 既存プロセス確認
Get-Process -Name "ollama"

# 2. 強制終了 (固まってる場合)
Stop-Process -Name "ollama" -Force

# 3. 再起動 (バックグラウンド)
Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden

# 4. 稼働確認
Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -TimeoutSec 5

# 5. モデル確認
ollama list
```

→ 大井が手作業で起動推奨 (Scheduled Task で起動も可能・Phase 2-D 検討)

---

## 📊 モニタリング

### 日次確認 (Claude-CEO が朝チェック)
- ollama サーバ稼働
- BrainWorkerLight/Heavy LastRun が直近5分以内か
- queue/inbox の溜まり (50件超えたら要対応)
- queue/failed の発生 (>0 件あれば原因調査)

### 警告閾値
- inbox > 50 件: worker 詰まり懸念
- failed > 5 件: モデル/プロンプト不具合疑い
- LastRun > 1h 前: scheduled task 死亡疑い

---

## 🔬 タスク種別別の推奨モデル (将来拡張)

将来 dispatch.ps1 に `-TaskType` パラメータ追加可:

| TaskType | 推奨モデル | 理由 |
|---|---|---|
| `code` | `qwen2.5-coder:7b` | コード生成特化 |
| `embed` | `nomic-embed-text:latest` | embedding 専用 |
| `research` | `qwen3:8b` | 普通の調査整形 |
| `creative` | `qwen3.6:latest` | 創造性が必要 |
| `simple` | `phi3:mini` | 超軽量・分類等 |

---

## 📝 dispatch.ps1 変更履歴

### v1 → v2 (2026-05-28)
- Priority: super/high/normal/low → **super/high/normal/late/low** (late 追加)
- Default Priority: normal → **late** (大井方針)
- Model 自動選択: Priority に応じて自動 (late/low = qwen3:8b)
- 後方互換: 既存呼び出しで明示的に Model 指定してれば優先

---

## 関連
- dispatch.ps1: [[scripts/dispatch.ps1]]
- worker.ps1: [[scripts/worker.ps1]]
- ollama 復旧: 本ファイル §ollama 復旧手順
- Phase 2-D 課題: hook 動作不全 + scheduled task 整理
