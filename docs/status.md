# プロジェクト状況レポート

> 最終更新: 2026-03-24

---

## 完成済み llamafile 一覧

| # | llamafile ファイル | サイズ | モデル | 開発元 | アーキ | CPU | Metal GPU |
|---|------------------|--------|--------|--------|--------|-----|-----------|
| 1 | `falcon-h1r-7b-Q4_K_M.llamafile` | 5.0 GB | Falcon-H1R 7B Instruct | TII (UAE) | SSM Hybrid | ✅ | ❌ M5以降必要 |
| 2 | `falcon3-1b-Q4_K_M.llamafile` | 1.7 GB | Falcon3 1B Instruct | TII (UAE) | Dense | ✅ | ✅ |
| 3 | `falcon3-3b-Q4_K_M.llamafile` | 2.6 GB | Falcon3 3B Instruct | TII (UAE) | Dense | ✅ | ✅ |
| 4 | `falcon3-7b-Q4_K_M.llamafile` | 5.0 GB | Falcon3 7B Instruct | TII (UAE) | Dense | ✅ | ✅ |
| 5 | `jais-13b-Q4_K_M.llamafile` | 12.2 GB | Jais 13B Chat | G42/MBZUAI (UAE) | Dense | ✅ | ✅ |
| 6 | `jais-30b-Q4_K_M.llamafile` | 27 GB | Jais Family 30B 16K | G42/MBZUAI (UAE) | Dense | ✅ | ❌ OOM |
| 7 | `allam-7b-Q4_K_M.llamafile` | 4.7 GB | ALLaM 7B Instruct | SDAIA/HUMAIN (Saudi) | Dense | ✅ | ✅ |
| 8 | `falcon-h1-7b-Q4_K_M.llamafile` | 5.0 GB | Falcon-H1 7B Instruct | TII (UAE) | SSM Hybrid | ✅ | ❌ M5以降必要 |
| 9 | `falcon-h1-34b-Q4_K_M.llamafile` | 20 GB | Falcon-H1 34B Instruct | TII (UAE) | SSM Hybrid | ✅ | ❌ M5以降必要 |

**🔄 = 作業中 / ✅ = 確認済み**

---

## フェーズ進捗

### Phase 1 — 検証・初号機 ✅ 完了
- [x] リポジトリ骨格作成
- [x] llama.cpp ビルド・Falcon-H1R GGUF 動作確認（CPU）
- [x] Falcon-H1R 7B Q4_K_M llamafile 作成（5.0 GB）
- [x] HuggingFace 初回公開 (`kaz321/Falcon-H1R-7B-llamafile`)

### Phase 2 — UAE / Saudi コアモデル網羅 ✅ 完了
- [x] Jais 13B llamafile（12.2 GB）
- [x] Jais 30B llamafile（27 GB）
- [x] ALLaM 7B Instruct llamafile（4.7 GB）
- [x] Falcon3 1B / 3B / 7B llamafile（1.7 / 2.6 / 5.0 GB）

### Phase 3 — ハイブリッドアーキ対応 🔄 進行中
- [x] Falcon-H1R 7B（Phase 1 で実施済み）
- [x] Falcon-H1 7B Instruct llamafile（5.0 GB、CPU動作確認済み）
- [x] Falcon-H1 34B Instruct llamafile（20 GB、CPU動作確認済み）
- [ ] Falcon-H1-Arabic（GGUF 未公開 — TII リリース待ち）
- [ ] 長文脈ベンチマーク（256K token テスト）

### Phase 4 — RWKV 系
- [ ] RWKV-7 "Goose" 2.9B / 7.2B llamafile

---

## 環境メモ

| ツール | バージョン / 場所 |
|--------|-----------------|
| llamafile | 0.10.0 — `~/llamafile/llamafile` |
| zipalign | 0.10.0 — `~/llamafile/zipalign` |
| llama.cpp | PR #14534 マージ済み — `~/llama.cpp/` |
| Python gguf | 0.18.0 |

### llamafile 0.10.0 の実行方法

```bash
# 埋め込みモデルを参照するには -m /zip/<ファイル名> が必要
./model.llamafile -m /zip/<gguf_filename> --cli -p "prompt" -n 100 --nothink

# 30B 以上は Metal OOM のため CPU 専用
./model.llamafile -m /zip/<gguf_filename> -ngl 0
```

### Metal GPU 制約まとめ

| アーキ | M4 Pro | M5 以降 |
|--------|--------|---------|
| Dense Transformer（Falcon3 / Jais 13B / ALLaM） | ✅ | ✅ |
| SSM Hybrid（Falcon-H1 系）| ❌ tensor API 無効 | ✅ |
| Dense 大容量（Jais 30B、34B 以上） | ❌ OOM | ❌ OOM（VRAM不足）|

---

## HuggingFace 公開状況

| リポジトリ | 公開状態 | 内容 |
|-----------|---------|------|
| `kaz321/Falcon-H1R-7B-llamafile` | 🌐 Public | Falcon-H1R 7B Q4_K_M |
| 残モデル | 未公開 | ローカルのみ |

---

## GGUF ファイル場所（ローカル）

| モデル | GGUF パス |
|--------|----------|
| Falcon-H1R 7B Q4_K_M | `~/models/falcon-h1r-7b/Falcon-H1R-7B-Q4_K_M.gguf` |
| Falcon-H1 7B Q4_K_M | `~/models/falcon-h1-7b/Falcon-H1-7B-Instruct-Q4_K_M.gguf` |
| Falcon-H1 34B Q4_K_M | `~/models/falcon-h1-34b/Falcon-H1-34B-Instruct-Q4_K_M.gguf` |
| Falcon3 1B Q4_K_M | `~/models/falcon3-1b/Falcon3-1B-Instruct-q4_k_m.gguf` |
| Falcon3 3B Q4_K_M | `~/models/falcon3-3b/Falcon3-3B-Instruct-q4_k_m.gguf` |
| Falcon3 7B Q4_K_M | `~/models/falcon3-7b/Falcon3-7B-Instruct-q4_k_m.gguf` |
| Jais 13B Q4_K_M | `~/models/jais-13b/jais-13b-Q4_K_M.gguf` |
| Jais 30B Q4_K_M | `~/models/jais-30b/jais-family-30b-16k-chat.Q4_K_M.gguf` |
| ALLaM 7B Q4_K_M | `~/models/allam-7b/allam-7b-instruct-preview-q4_k_m.gguf` |
