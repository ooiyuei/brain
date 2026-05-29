---
type: secretary-guide
date: 2026-05-29
title: 外出先 (MacBook Air) から Windows の全環境を CLI で触る — リモートアクセス完全ガイド
purpose: 大井が外からでも brain・OpenClaw・ollama・ultracode を同じ環境で使えるようにする
audience: 大井湧瑛 (本人作業)
tags: [remote, cli, mac, windows, tailscale, ssh, remote-control]
---

# 外出先から Windows 全環境を触る — リモートアクセス完全ガイド

> **大井の状況 (2026-05-29)**:
> - 自宅: Windows デスクトップ (brain / OpenClaw / ollama / worker / scheduled task / ultracode 全部ここ)
> - 持ち運び: MacBook Air
> - brain: Obsidian Sync で Win⇔Mac 共有済
> - 現状: Remote Control で何とかしてる
>
> → 「同じ環境で CLI を触りたい」 = Windows をリモート操作する2方式

---

## 🧭 大前提の理解

**OpenClaw (ollama) / worker / Scheduled Task / dispatch.ps1 は Windows 固有**。
MacBook 単体では動かない (brain ファイルは Obsidian Sync で見れるが、ぶん回し機能は Windows のみ)。

→ 外から「同じ環境」= **Windows をリモートで操作する** しかない。2つの方法:

| 方式 | 手軽さ | 安定性 | できること |
|---|---|---|---|
| **A. Remote Control (公式)** | ◎ 設定ゼロ | ○ | 走ってるセッションを Mac/スマホから操作 |
| **B. Tailscale + SSH** | △ 初期設定要 | ◎ | 完全な dev 環境・常時アクセス |

---

## 🔧 共通の前提 (両方式で必須)

### Windows をスリープさせない
リモートアクセス中に Windows が寝ると全部切れる。

```powershell
# 電源プラン: スリープ無効 (管理者 PowerShell)
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change monitor-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
```

または: 設定 → システム → 電源 → 「画面とスリープ」を全部「なし」

### CLI 版 Claude Code を使う (Desktop アプリ不可)
- ✅ `C:\Users\Owner\.local\bin\claude.exe` (純正 CLI・Remote Control 対応)
- ❌ Claude Desktop アプリの Code タブ (Remote Control 不可・Agent SDK harness)

---

## 🅰 方式A: Remote Control (今すぐ・最も楽) ⭐ 推奨スタート

公式機能 (2026-02-25 ship)。Claude Pro/Max で使える。設定ほぼゼロ。

### 手順

**Windows 側 (自宅・出かける前):**
```powershell
# 1. CLI 版 Claude Code 起動 (Desktop アプリじゃない方)
cd C:\Users\Owner\business
claude

# 2. やりたい作業を始める or セッション維持

# 3. Remote Control 起動
/rc
# または /remote-control
```
→ QR コードが表示される

**MacBook 側 (外出先):**
1. Claude アプリ (or claude.ai/code) を開く
2. QR コードをスキャン (or セッションURL を開く)
3. → **Windows の全環境を Mac から操作** (同じファイル・同じ MCP・同じ brain・ultracode も使える)

### 特徴
- ✅ アウトバウンド HTTPS のみ (inbound port 開けない = セキュア)
- ✅ 全通信 Anthropic API 経由 TLS
- ✅ 設定ゼロ・既に大井が使えてる
- ⚠ Windows で claude セッションが起動してることが前提
- ⚠ Mac 側が WiFi→セルラー切替で一瞬切れることあり (再接続で復帰)

### こういう時に使う
- 外出先でちょっと指示出す
- 走ってるタスクを monitor
- brain にメモ追加

---

## 🅱 方式B: Tailscale + SSH (本格・常時アクセス)

「完全な dev 環境・いつでもどこでも」が欲しい時の上位互換。

### セットアップ (1回だけ・30分)

**① Tailscale インストール (Win + Mac 両方)**
- https://tailscale.com/download
- 両方 同じアカウントでログイン
- → Win ⇔ Mac が VPN で同一ネットワーク化 (port 開けない・暗号化)
- Windows の Tailscale IP を確認 (例: 100.x.x.x)

**② Windows に OpenSSH Server 有効化**
```powershell
# 管理者 PowerShell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
# ファイアウォール (Tailscale 経由なので localhost 扱い)
```

**③ MacBook から接続**
```bash
# Mac ターミナル
ssh Owner@100.x.x.x   # Windows の Tailscale IP

# Windows に入ったら
cd C:\Users\Owner\business
claude   # ← Windows の Claude Code が Mac のターミナルで動く
```

### セッション維持 (推奨)
SSH が切れてもセッション続けるため、Windows 側で擬似的に維持:
- Windows は tmux ないので、`claude` を起動したまま放置 OR
- Remote Control と併用 (SSH で起動 → /rc で Remote Control に引き継ぎ)

### 特徴
- ✅ どこからでも・完全な Windows 環境
- ✅ Claude Code 以外も操作可 (git・ファイル・PowerShell 全部)
- ✅ セキュア (Tailscale = port 開けない)
- ⚠ 初期設定30分
- ⚠ SSH は WiFi 切替で切れる (Mosh 入れれば改善)

### こういう時に使う
- 長期出張・カフェで本格作業
- Almeo Web 開発を外でやる
- brain 大規模整理

---

## 🎯 大井への推奨フロー

### 当面 (今日から)
**方式A (Remote Control) を継続**。
- 既に使えてる・設定ゼロ
- 出かける前に Windows で `claude` → `/rc` → QR
- Mac でスキャン

### 本格運用 (時間ある時に30分セットアップ)
**方式B (Tailscale + SSH) を追加**。
- カフェ・出張で「完全な環境」が欲しい時
- 一度入れれば一生使える

### brain だけ見たい時 (軽い)
- MacBook の Obsidian で直接見る (Sync 済)
- OpenClaw 動かさない・ファイル閲覧だけなら Mac 単体でOK

---

## ⚠ 注意点

1. **Windows 常時起動が大前提** (スリープ無効化必須)
2. **Desktop アプリじゃなく CLI 版 claude.exe を使う** (Remote Control 対応)
3. **電気代**: Windows つけっぱなし = 月数百円〜千円 (デスクトップなら)
4. **セキュリティ**: Tailscale も Remote Control も port 開けない設計なので安全
5. **ultracode も使える**: リモート接続先が Windows の Claude Code なので、ultracode (xhigh + dynamic workflow) もそのまま動く

---

## 📊 比較まとめ

| | Remote Control | Tailscale + SSH | Obsidian だけ |
|---|---|---|---|
| 設定 | ゼロ | 30分 | 済 |
| brain 編集 | ✅ | ✅ | ✅ (閲覧主) |
| OpenClaw dispatch | ✅ | ✅ | ❌ |
| ollama / ultracode | ✅ | ✅ | ❌ |
| 開発 (npm/git) | ✅ | ✅ | ❌ |
| Windows 起動必要 | ✅ | ✅ | ❌ |
| 安定性 | ○ | ◎ | ◎ |

---

## 関連
- [[reference_claude_desktop_vs_cli]] (memory・Desktop vs CLI の違い)
- [[01_ceo/daily-operations-protocol]]
- Claude Code Remote Control 公式: v2.1.51+ で /rc

---

## 🆕 大井の次アクション (5/29)

1. **今すぐ**: Windows スリープ無効化 (上記 powercfg)
2. **今日試す**: Windows で `claude` → `/rc` → MacBook でスキャン (Remote Control 確認)
3. **時間ある時**: Tailscale Win+Mac インストール (本格リモート)
