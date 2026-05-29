# OpenClaw ACPブリッジ — 使い方

## ACPとは
Agent Communication Protocol。Claude Code等のIDE/エディタから「ローカルエージェント」を呼ぶための標準プロトコル。

OpenClaw ACPブリッジを起動すると：
- VSCode / Zed / Claude Code 等から接続可能
- OpenClaw mainエージェント（qwen3.6:latest）を IDE内エージェントとして使える
- ファイル編集・コマンド実行・gitなどローカル操作を qwen3.6 ベースで自動化

## ⚠️ 注意：Gateway接続要件

`openclaw acp --help` を見ると：
```
--url <url>  Gateway WebSocket URL (defaults to gateway.remote.url when configured)
```

つまり ACP は「リモートGateway」経由で動く設計。OpenClawアカウント認証が必要な可能性。
**起動できない場合は、現状OpenClawアカウントが未設定の証拠**。

## 使い方（Gateway設定済みの場合）

```powershell
# 起動
& "C:\Users\Owner\business\brain\scripts\acp_control.ps1" -Action start

# 状態確認
& "C:\Users\Owner\business\brain\scripts\acp_control.ps1" -Action status

# 停止
& "C:\Users\Owner\business\brain\scripts\acp_control.ps1" -Action stop

# 対話クライアント（テスト用）
& "C:\Users\Owner\business\brain\scripts\acp_control.ps1" -Action client
```

## スタートアップ自動起動

スタートアップフォルダに `BrainACP.lnk` 配置済み（PC再起動時に自動起動試行）。
ただし Gateway未設定なら起動失敗するので、必要な時だけ手動起動推奨。

## いつ使う？

- ✅ Testall等のローカルコーディング作業中、IDE補助欲しい時
- ✅ Claude Code のセッション以外でOpenClaw agent使いたい時
- ❌ 普段の dispatch.ps1 経由運用には不要

## Gateway設定が必要な場合

OpenClawアカウント連携が必要。詳細：
- https://docs.openclaw.ai/cli/acp
- `openclaw acp --help` で最新オプション確認
