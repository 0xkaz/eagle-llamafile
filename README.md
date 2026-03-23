# UAE / Saudi LLM llamafile

UAE・サウジアラビア発の LLM を **llamafile**（インストール不要の単一実行ファイル）として配布するプロジェクト。

## 対象モデル

| モデル | 開発元 | アーキ | ステータス |
|--------|--------|--------|-----------|
| Falcon-H1 7B / 34B | TII (UAE) | Mamba-2 + Transformer | 準備中 |
| Falcon-H1-Arabic 7B | TII (UAE) | Mamba-2 + Transformer | 準備中 |
| Jais 13B / 30B | G42 / MBZUAI (UAE) | Dense Transformer | 準備中 |
| ALLaM 7B | SDAIA / HUMAIN (Saudi) | Dense Transformer | 準備中 |

## llamafile とは

インストール不要・依存なしで LLM をローカル実行できる単一ファイル形式。
Windows / macOS / Linux / ARM すべてに対応。詳細: [docs/what-is-gguf.md](docs/what-is-gguf.md)

## 企画・背景

[PLAN.md](PLAN.md) を参照。

## 変換方法（開発者向け）

```bash
# 環境変数を設定してから実行
export LLAMA_CPP_DIR=~/llama.cpp
export LLAMAFILE_DIR=~/llamafile

./scripts/convert.sh tiiuae/Falcon-H1-7B-Instruct falcon-h1-7b Q4_K_M
```

詳細は [scripts/convert.sh](scripts/convert.sh) のコメントを参照。

## ドキュメント

- [PLAN.md](PLAN.md) — プロジェクト企画書
- [docs/what-is-gguf.md](docs/what-is-gguf.md) — GGUF フォーマット解説
