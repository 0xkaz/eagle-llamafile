# モデル比較ベンチマーク

> 測定環境: Apple M4 Pro, macOS, CPU 推論（`-ngl 0`）, llamafile 0.10.0
> 測定日: 2026-03-24

---

## llamafile 一覧・スペック比較

| モデル | サイズ | アーキ | llamafile | CPU 推論 | Metal GPU |
|--------|--------|--------|-----------|----------|-----------|
| Falcon3-1B | 1.7 GB | Dense | ✅ | ✅ | ✅ |
| Falcon3-3B | 2.6 GB | Dense | ✅ | ✅ | ✅ |
| Falcon3-7B | 5.0 GB | Dense | ✅ | ✅ | ✅ |
| Falcon-H1R-7B | 5.0 GB | SSM Hybrid | ✅ | ✅ | ❌ M5以降 |
| Falcon-H1-7B | 5.0 GB | SSM Hybrid | ✅ | ✅ | ❌ M5以降 |
| Falcon-H1-34B | 20 GB | SSM Hybrid | ✅ | ✅ | ❌ M5以降 |
| Jais-13B | 12.2 GB | Dense | ✅ | ✅ | ✅ |
| Jais-30B | 27 GB | Dense | ✅ | ✅ | ❌ OOM |
| ALLaM-7B | 4.7 GB | Dense | ✅ | ✅ | ✅ |

---

## 公開ベンチマーク参照値

> 注: 以下は各モデルの公式・コミュニティ報告値。本環境での直接測定値ではない。

### Falcon-H1R-7B（推論特化）

| タスク | Falcon-H1R-7B | 比較対象 |
|--------|--------------|---------|
| AIME 2025 | **83.1%** | Apriel-15B: 82.7% / OLMo 3 Think-32B: 73.7% |
| Mathematics | **73.96%** | Qwen3-32B: 63.66% / Nemotron-H-47B: 49.72% |
| Code & Agentic | **33.95%** | Qwen3-32B: 33.40% |
| 推論速度 | **~1,500 tok/s/GPU** (batch 64) | Qwen3-8B の約 2× |

→ **7B が 32B〜47B モデルを数学・推論で上回る**

### Falcon-H1-34B

| 比較 | 結果 |
|------|------|
| vs Qwen3-32B | 同等〜以上の性能を**半分以下のパラメータ**で達成 |
| vs Qwen2.5-72B | 同等性能 |
| vs Llama3.3-70B | 同等性能 |
| 長文脈スループット（128K+ tokens） | Qwen2.5-32B 比 **入力4×、出力8× 高速** |

### Falcon3-7B（Dense, 標準モデル）

| タスク | Falcon3-7B | 備考 |
|--------|-----------|------|
| MMLU | ~75% | 7B クラストップレベル |
| HumanEval | ~65% | |
| DL: 累計 55M+ | — | HF 最多 DL 7B モデルの一つ |

### Jais-13B / 30B（アラビア語-英語バイリンガル）

| 評価 | Jais-30B |
|------|---------|
| Arabic NLP ベンチ | アラビア語 LLM でトップクラス |
| 英語 | GPT-3.5 相当 |
| コンテキスト長 | 16K tokens（Jais Family 版） |

---

## 速度測定（本環境 / Apple M4 Pro CPU）

> `./model.llamafile -m /zip/<model> --cli -p "What is UAE?" -n 100 --nothink -ngl 0`

| モデル | トークン/秒（CPU） | 備考 |
|--------|-------------------|------|
| Falcon3-1B | 測定予定 | |
| Falcon3-3B | 測定予定 | |
| Falcon3-7B | 測定予定 | |
| Falcon-H1R-7B | 測定予定 | CPU では GPU より低速 |
| ALLaM-7B | 測定予定 | |
| Jais-13B | 測定予定 | |

*TODO: 実測値を追記する*

---

## 用途別推奨

| 用途 | 推奨モデル | 理由 |
|------|-----------|------|
| 最軽量・組み込み | **Falcon3-1B** (1.7 GB) | RAM 4GB でも動作 |
| 日常タスク・バランス | **Falcon3-7B / ALLaM-7B** (~5 GB) | 品質と速度のバランス |
| 数学・推論 | **Falcon-H1R-7B** (5 GB) | 32B+ 超え性能 |
| アラビア語 | **Jais-13B** (12 GB) | アラビア語-英語バイリンガル |
| 高品質・大容量 | **Falcon-H1-34B** (20 GB) | 70B 相当性能 |
