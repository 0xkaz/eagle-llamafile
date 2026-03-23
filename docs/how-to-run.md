# llamafile の実行方法

このプロジェクトで生成した `.llamafile` ファイルの使い方。

---

## 基本的な実行方法

### 1. サーバーモード（推奨）

```bash
./models/falcon-h1r-7b-Q4_K_M.llamafile -m /zip/Falcon-H1R-7B-Q4_K_M.gguf
```

実行すると自動的に Web UI と OpenAI 互換 API が起動する：
- **Web UI**: http://127.0.0.1:8080 （ブラウザで開く）
- **API**: http://127.0.0.1:8080/v1 （OpenAI 互換）

### 2. CLI モード（1問1答）

```bash
./models/falcon-h1r-7b-Q4_K_M.llamafile \
  -m /zip/Falcon-H1R-7B-Q4_K_M.gguf \
  --cli \
  -p "What is the capital of UAE?" \
  -n 100 \
  --nothink
```

オプション：
- `-p TEXT` — プロンプト（必須）
- `-n N` — 生成するトークン数（デフォルト: 512）
- `--nothink` — `<think>...</think>` の思考ブロックを非表示
- `-ngl 0` — GPU を使わず CPU のみで実行（Metal OOM 回避）

---

## モデルごとの実行コマンド

### Falcon-H1R 7B（推論特化）

```bash
# サーバーモード
./models/falcon-h1r-7b-Q4_K_M.llamafile -m /zip/Falcon-H1R-7B-Q4_K_M.gguf

# CLI モード
./models/falcon-h1r-7b-Q4_K_M.llamafile \
  -m /zip/Falcon-H1R-7B-Q4_K_M.gguf \
  --cli -p "Your prompt here" -n 200 --nothink
```

### Jais 13B（アラビア語-英語バイリンガル）

```bash
# サーバーモード
./models/jais-13b-Q4_K_M.llamafile -m /zip/jais-13b-Q4_K_M.gguf

# CLI モード（アラビア語例）
./models/jais-13b-Q4_K_M.llamafile \
  -m /zip/jais-13b-Q4_K_M.gguf \
  --cli -p "ما هي عاصمة الإمارات؟" -n 100
```

### Jais Family 30B 16K（30B アラビア語-英語）

```bash
# サーバーモード（CPU 専用 — Metal OOM 回避）
./models/jais-30b-Q4_K_M.llamafile -m /zip/jais-family-30b-16k-chat.Q4_K_M.gguf -ngl 0

# CLI モード
./models/jais-30b-Q4_K_M.llamafile \
  -m /zip/jais-family-30b-16k-chat.Q4_K_M.gguf \
  --cli -p "What is UAE known for?" -n 100 --nothink -ngl 0
```

> **注意:** 27GB のモデルのため RAM 32GB 以上を推奨。Metal GPU は OOM のため `-ngl 0`（CPU 専用）で実行。

### ALLaM 7B Instruct（サウジアラビア製）

```bash
# サーバーモード
./models/allam-7b-Q4_K_M.llamafile -m /zip/allam-7b-instruct-preview-q4_k_m.gguf

# CLI モード
./models/allam-7b-Q4_K_M.llamafile \
  -m /zip/allam-7b-instruct-preview-q4_k_m.gguf \
  --cli -p "What is Saudi Arabia known for?" -n 200 --nothink
```

---

## 重要な注意点

### llamafile 0.10.0 での埋め込みモデル指定

llamafile 0.10.0 以降、埋め込みモデルは **`-m /zip/<ファイル名>`** で明示的に指定する必要がある。

```bash
# ✅ 正しい
./falcon-h1r-7b-Q4_K_M.llamafile -m /zip/Falcon-H1R-7B-Q4_K_M.gguf --cli -p "..."

# ❌ 動かない（-m 省略）
./falcon-h1r-7b-Q4_K_M.llamafile --cli -p "..."
```

### Mac M4 Pro 以前の GPU について

Falcon-H1（Mamba-2 SSM ハイブリッド）は Metal GPU の **M5 / A19 以降**が必要。
M4 Pro 以前では以下のエラーが出るが、**CPU では正常動作する**：

```
ggml_metal_device_init: tensor API disabled for pre-M5 and pre-A19 devices
```

CPU 強制実行：
```bash
./models/falcon-h1r-7b-Q4_K_M.llamafile -m /zip/Falcon-H1R-7B-Q4_K_M.gguf -ngl 0
```

> Jais / ALLaM（Dense Transformer）は M4 Pro でも Metal GPU 使用可能。

---

## API 利用例（OpenAI 互換）

サーバー起動後、OpenAI SDK や curl で使える：

```bash
curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "local",
    "messages": [{"role": "user", "content": "What is UAE known for?"}],
    "max_tokens": 200
  }'
```

---

## モデルファイル一覧

| ファイル | サイズ | モデル | アーキ |
|---------|--------|--------|--------|
| `falcon-h1r-7b-Q4_K_M.llamafile` | 5.0 GB | Falcon-H1R 7B | Mamba-2+Transformer |
| `jais-13b-Q4_K_M.llamafile` | 12.2 GB | Jais 13B | Dense Transformer |
| `allam-7b-Q4_K_M.llamafile` | 4.7 GB | ALLaM 7B Instruct | Dense Transformer |
| `jais-30b-Q4_K_M.llamafile` | 27 GB | Jais Family 30B 16K | Dense Transformer |
