# Whisper（音声→テキスト）セットアップ

> ローカル無料の音声起こし。議事録自動化・大井のメモ起こしに使う。
> このシステムが完成すると：録音ファイルをフォルダに置く → 自動で議事録mdが生成 → OpenClawが要約 → wiki/_inbox/secretary/

## 1. インストール（10分・1回だけ）

### Option A: Whisper.cpp（推奨・Windows向け）

```powershell
# Ollama類似のローカル実行可能なC++版
# Download: https://github.com/ggerganov/whisper.cpp/releases
# Windows用 whisper-blas-bin-x64.zip をダウンロード
# C:\Users\Owner\AppData\Local\Whisper に展開

# モデルダウンロード（large-v3-turbo ~1.5GB・日本語精度高い）
# https://huggingface.co/ggerganov/whisper.cpp/blob/main/ggml-large-v3-turbo.bin
# C:\Users\Owner\AppData\Local\Whisper\models\ に配置
```

### Option B: faster-whisper（Python版・GPU加速）

```powershell
pip install faster-whisper

# 初回実行時にモデル自動DL
```

## 2. 自動起こしシステム

### 監視フォルダ
```
C:\Users\Owner\business\brain\.audio_inbox\
```

ここに録音ファイル（.mp3 / .wav / .m4a / .ogg）を置くと、5分以内に自動で処理される。

### 処理フロー
```
.audio_inbox/{filename}.mp3
   ↓ BrainAudioWatch (5分おき)
   ↓ Whisper で文字起こし
.audio_inbox/_transcribed/{filename}.txt
   ↓ dispatch.ps1 で OpenClaw に要約依頼
queue/inbox に投入
   ↓ worker.ps1 (qwen3.6) 処理
wiki/_inbox/secretary/audio-{filename}.md
   ↓ 議事録要約として整形済
```

## 3. 実装スクリプト

完了したら以下が動く：

- `scripts/transcribe.ps1` — 単発ファイル文字起こし
- `scripts/bg_audio_watch.ps1` — 監視フォルダのバッチ処理
- BrainAudioWatch スケジューラ（5分おき）

## 4. 大井の使い方

1. **会議録音**: スマホ・Zoom・任意ツール
2. **PCに転送**: AirDrop / クラウド経由 / USB
3. **`.audio_inbox` に置く**
4. **数分後**: Discord通知「議事録要約できたよ」
5. **wiki/_inbox/secretary/** で確認

## 5. 使うシーン

- 商談・パートナーミーティング後の議事録
- 大井が「ながら録音」した思考メモ起こし
- ポッドキャスト・YouTube動画の文字化
- 講演・セミナーの記録化

---

**注: Whisper.cpp はWindows用バイナリのDLが必要（私は代行できないファイルDL）**

大井がDL完了したら教えてくれれば、私が残り全部組む。
