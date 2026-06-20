# UAE / Saudi LLM llamafile

[English](./README.md) | [日本語](./README.ja.md)

UAE・サウジアラビア発の LLM を **llamafile**（インストール不要の単一実行ファイル）として配布するプロジェクト。

## 対象モデル

| モデル | 開発元 | アーキ | ステータス |
|--------|--------|--------|-----------|
| Falcon-H1 7B / 34B | TII (UAE) | Mamba-2 + Transformer | 準備完了 |
| Falcon-H1-Arabic 7B | TII (UAE) | Mamba-2 + Transformer | GGUF 公開待ち |
| Jais 13B / 30B | G42 / MBZUAI (UAE) | Dense Transformer | 準備完了 |
| ALLaM 7B | SDAIA / HUMAIN（サウジアラビア） | Dense Transformer | 準備完了 |

## llamafile とは

インストール不要・依存なしで LLM をローカル実行できる単一ファイル形式。
Windows / macOS / Linux / ARM すべてに対応。詳細: [docs/what-is-gguf.md](docs/what-is-gguf.md)

## llamafile の実行方法

モデル別の実行コマンドや API 利用例は [docs/how-to-run.md](docs/how-to-run.md) を参照。

## 変換方法（開発者向け）

```bash
# 環境変数を設定してから実行
export LLAMA_CPP_DIR=~/llama.cpp
export LLAMAFILE_DIR=~/llamafile

./scripts/convert.sh tiiuae/Falcon-H1-7B-Instruct falcon-h1-7b Q4_K_M
```

詳細は [scripts/convert.sh](scripts/convert.sh) のコメントを参照。

## 開発用コマンド

このリポジトリには共通タスク用の `Makefile` が含まれています。

```bash
make help   # 利用可能なコマンドを表示
make lint   # シェルスクリプトの lint（shellcheck、ない場合は bash -n）
make test   # リポジトリ検証テストを実行
make clean  # 一時ディレクトリ work/ を削除
```

Make 経由で llamafile をビルドする場合:

```bash
make convert ARGS="tiiuae/Falcon-H1-7B-Instruct falcon-h1-7b Q4_K_M"
```

## CI

`.github/workflows/build.yml` は、公式 GGUF をダウンロードして llamafile にバンドルする手動実行型の GitHub Actions ワークフローです。HuggingFace へのアップロードには、リポジトリシークレット `HF_TOKEN` が必要です。

## ドキュメント

- [PLAN.md](PLAN.md) — プロジェクト企画書
- [docs/what-is-gguf.md](docs/what-is-gguf.md) — GGUF フォーマット解説
- [docs/how-to-run.md](docs/how-to-run.md) — 生成した llamafile の実行方法
