# UAE / Saudi LLM llamafile プロジェクト企画書

> UAE・サウジアラビア発の LLM および llamafile 空白地帯のモデルを、単一実行ファイル（llamafile）として配布するハブを作る

---

## 1. 背景と目的

### llamafile とは
Mozilla.ai が開発した配布フォーマット。**GGUF モデル + llama.cpp + Cosmopolitan Libc** を 1 ファイルの実行ファイルにまとめ、インストール不要・依存なし・Windows/macOS/Linux/ARM すべてで動く。OpenAI 互換 API サーバーとしても機能する。

### 課題：地域特化 LLM の llamafile 空白

UAE・サウジアラビアの主要 LLM は、技術的には llamafile 化が可能な状態（GGUF 対応アーキテクチャ）にあるにもかかわらず、llamafile 配布物が存在しない。

| モデル | 開発元 | 国 | アーキ | llamafile |
|--------|--------|-----|--------|-----------|
| **Falcon** (3 / H1 系) | TII | UAE アブダビ | Dense / SSM Hybrid | **なし** |
| **Falcon-H1-Arabic** | TII | UAE アブダビ | SSM Hybrid | **なし** |
| **Jais** (13B / 30B) | G42 / MBZUAI | UAE | Dense (GPT-3 系) | **なし** |
| **ALLaM** (7B / 34B) | SDAIA / HUMAIN | サウジアラビア | Dense (LLaMA 系) | **なし** |

また、Mistral・Llama 系が中心の llamafile エコシステムにおいて、**SSM ハイブリッドアーキテクチャ**（Falcon-H1）は希少であり、技術的な差別化にもなる。

---

## 2. ターゲットモデル

### 主要ターゲット（優先度順）

| 優先 | モデル | パラメータ | ライセンス | 特徴 |
|------|--------|-----------|-----------|------|
| ★★★ | Falcon 3 (1B / 3B / 7B) | 1B〜7B | Apache 2.0 | TII UAE, 55M+ DL |
| ★★★ | Jais 13B / 30B | 13B, 30B | Apache 2.0 | アラビア語-英語バイリンガル |
| ★★★ | ALLaM 7B Instruct | 7B | Apache 2.0 | サウジ国家 AI 機関製 |
| ★★ | Falcon-H1 (7B / 34B) | 7B, 34B | Apache 2.0 | Mamba-2 + Transformer ハイブリッド |
| ★★ | Falcon-H1-Arabic | 3B / 7B | Apache 2.0 | アラビア語特化 SSM ハイブリッド |
| ★ | RWKV-7 "Goose" | 2.9B / 7.2B | Apache 2.0 | 旧 Eagle 系の後継、最新 RWKV アーキ |

> **Eagle 7B（RWKV-v5, 2024-01）は旧世代**。後継の RWKV-7 "Goose"（2025-03）を対象とする。

### アーキテクチャ補足：3 モデルはすべて Dense

Jais・ALLaM・Falcon 標準系はすべて **Dense Transformer**（MoE ではない）。

#### MoE 化（Sparse Upcycling）について
Dense モデルを MoE に変換する "Sparse Upcycling" は研究レベルでは可能だが、**初期学習コストの約 50% の追加学習**が必要。コミュニティの変換プロジェクトとしては現実的でなく、**本プロジェクトのスコープ外**とする。

---

## 3. Falcon-H1 が注目される理由

> **論文:** arXiv:2507.22448（2025-07-31 公開、80+ ページ）
> **開発元:** TII（Technology Innovation Institute）, アブダビ UAE
> **ライセンス:** Apache 2.0 ベースの permissive ライセンス、商用利用可

---

### 3-1. アーキテクチャの革新：「並列ハイブリッド」

Falcon-H1 は各ブロック内で **Mamba-2 SSM と Transformer Attention を同時並列に動かし、出力を結合する**設計。
これは先行する Jamba（AI21 Labs）との根本的な違いで、重要なポイントになる。

```
【Jamba（逐次ハイブリッド）】
  Block 1: Attention
  Block 2: Mamba
  Block 3: Attention  ← 交互に並べるだけ

【Falcon-H1（並列ハイブリッド）】
  Block N: [Attention ヘッド] ┐
                              ├─ concat → 出力
           [SSM ヘッド    ] ┘  ← 同じブロック内で並列実行
```

この並列設計により：
- SSM と Attention の**比率を独立して調整**できる（Jamba は 1:7 固定）
- 計算の重複が減り、同パラメータ数でより効率的
- モデルサイズごとに最適な比率に調整（7B は Attention:SSM ≒ 1:8+）

---

### 3-2. 推論効率：Transformer の根本問題を解決

**Transformer の問題：KV キャッシュの二乗爆発**

```
Transformer の KV キャッシュメモリ: O(L²)  ← シーケンス長の二乗
Mamba-2 SSM のメモリ:              O(L)   ← 線形
```

長文脈になるほど差が開く。**Falcon-H1-34B vs Qwen2.5-32B の実測値（128K+ tokens）：**

| 指標 | 倍率 |
|------|------|
| 入力スループット（長文脈） | **4× 高速** |
| 出力スループット（長文脈） | **8× 高速** |
| 短文脈（1K 以下） | Transformer が若干有利 |

→ **4K〜8K tokens を超えると Falcon-H1 が有利になり、長くなるほど差は指数的に拡大する。**

---

### 3-3. llamafile との相性：ローカル実行の現実解

llamafile は「普通のマシンで動く」ことを前提とした配布形式。Falcon-H1 はここにフィットする：

| 課題 | 純 Transformer | Falcon-H1 |
|------|----------------|-----------|
| 256K 文脈をローカルで | VRAM 爆発、実質不可 | 線形メモリ、現実的 |
| 7B モデルの RAM 使用 | 通常量子化と同等 | SSM ヘッド分さらに削減 |
| Apple Silicon など CPU/GPU 混在 | KV キャッシュがボトルネック | SSM で緩和 |

**Falcon-H1-0.5B が 2024 年の 7B モデル相当の性能**、**1.5B-Deep が 7B〜10B 相当**という異常なパラメータ効率も、ローカル配布に直結する強みになる。

---

### 3-4. 性能：サイズを超えた実力

**Falcon-H1R-7B（Reasoning バリアント）のベンチマーク（2026-01 リリース）：**

| タスク | Falcon-H1R-7B | 比較対象 |
|--------|--------------|---------|
| AIME 2025 | **83.1%** | Apriel-15B: 82.7%、OLMo 3 Think-32B: 73.7% |
| Mathematics | **73.96%** | Qwen3-32B: 63.66%、Nemotron-H-47B: 49.72% |
| Code & Agentic | **33.95%** | Qwen3-32B: 33.40% |
| 推論速度 | **~1,500 tok/s/GPU** (batch 64) | Qwen3-8B の約 2 倍 |

→ 7B が 32B〜47B モデルを数学・推論で上回る。

**Falcon-H1-34B の位置づけ：**
Qwen3-32B、Qwen2.5-72B、Llama3.3-70B と同等〜以上の性能を **半分以下のパラメータ数**で達成。

---

### 3-5. バリアント一覧

| モデル | 特徴 |
|--------|------|
| H1-0.5B / 1.5B / 3B / 7B / 34B | 標準サイズ展開 |
| **H1-1.5B-Deep** | 幅を削り深さを増加、7B〜10B 相当の性能 |
| **H1R-7B** | 推論特化、数学・論理で 32B+ を超える |
| **H1-Arabic-3B / 7B / 34B** | アラビア語特化（同一ハイブリッドアーキ） |
| H1-Tiny (0.6B / 0.09B) | 超軽量、多言語対応 |

18 言語ネイティブ対応（アラビア語・日本語・中国語・ヒンディー語含む）。

---

### 3-6. llamafile 化の技術的現実

**現状（2026-03 確認済み）：**
- **GGUF：TII 公式リリース済み**（tiiuae/Falcon-H1R-7B-GGUF）
- **community：** unsloth・prithivMLmods 等の量子化バリアント（Q2_K〜F32）多数あり
- **llama.cpp upstream：PR #14534 がマージ済み** ← TII フォーク不要、公式版で動く
- **llamafile（単一実行ファイル）：なし ← ここが空白**

→ **すべての下地が揃っている。llamafile へのバンドルだけが未着手。**
→ TII フォークを使う必要はなく、公式 llama.cpp で変換・推論可能。

---

### 3-7. llamafile エコシステムでの希少性

llamafile 769 件のうち **SSM ハイブリッドはほぼゼロ**。
Falcon-H1 を llamafile 化すると：
- 「SSM ハイブリッド llamafile」というカテゴリを事実上独占
- **アラビア語 × SSM ハイブリッド**は世界初
- TII の公式承認・コラボの可能性（GGUF は公式リリース済みのため協力関係が作りやすい）

---

## 4. 変換フロー

```
[1] HuggingFace から weights をダウンロード
        ↓  convert_hf_to_gguf.py (llama.cpp)
[2] GGUF FP16
        ↓  llama-quantize
[3] 量子化 GGUF（Q4_K_M / Q5_K_M / Q8_0）
        ↓  llamafile bundle ツール
[4] 単一実行ファイル (.llamafile)
        ↓  HuggingFace Repo / GitHub Releases
[5] 配布
```

### 量子化バリアント方針

| バリアント | サイズ目安 (7B) | 用途 |
|-----------|---------------|------|
| Q4_K_M | ~4 GB | 標準推奨（品質とサイズのバランス） |
| Q5_K_M | ~5 GB | 品質重視 |
| Q8_0 | ~7.5 GB | 精度最優先 |

---

## 5. 実施フェーズ

### Phase 1 — 検証・初号機作成

**目標:** Falcon-H1 7B の llamafile を 1 本作り切り、変換プロセスを確立する

**前提確認済み（2026-03）：**
- llama.cpp PR #14534 マージ済み → 公式版で Falcon-H1 が動く
- Falcon-H1 GGUF は TII 公式・community 両方で存在
- Jais GGUF：community 版あり（dormosh/jais-13b-GGUF 等）
- ALLaM GGUF：community 版あり（Omartificial-Intelligence-Space/ 等）

**タスク：**
- [x] リポジトリ骨格作成（`scripts/convert.sh`, `README.md`, `models/manifest.json`）
- [ ] llama.cpp をビルドし Falcon-H1 GGUF の動作確認
- [ ] llamafile ツールで Falcon-H1 7B Q4_K_M をバンドル
- [ ] 動作テスト（macOS / Linux / Windows）
- [ ] HuggingFace リポジトリに初回公開

### Phase 2 — UAE / Saudi コアモデルの網羅

**目標:** Falcon / Jais / ALLaM の主要バリアントを揃える

- [ ] Jais 13B / 30B llamafile（各量子化）
- [ ] ALLaM 7B Instruct llamafile（各量子化）
- [ ] Falcon 3 全サイズ（1B / 3B / 7B）
- [ ] ベンチマーク比較表の作成
- [ ] CI/CD 整備（GitHub Actions による自動変換）

### Phase 3 — ハイブリッドアーキ対応

**目標:** Falcon-H1 の SSM ハイブリッドを llamafile 化し、エコシステムの希少性を確立

- [ ] Falcon-H1 7B の llama.cpp 動作確認（Mamba-2 サポート検証）
- [ ] Falcon-H1 7B / 34B llamafile 生成
- [ ] Falcon-H1-Arabic llamafile（アラビア語特化）
- [ ] 長文脈性能のベンチマーク（256K token テスト）

### Phase 4 — RWKV 系・その他空白地帯

- [ ] RWKV-7 "Goose" 2.9B / 7.2B llamafile
- [ ] 追加モデルの選定（日本語特化など）

---

## 6. リスクと対策

| リスク | 可能性 | 対策 |
|--------|--------|------|
| Falcon-H1 Mamba-2 が llama.cpp で未対応 | 中 | Phase 1 を Dense の Falcon 3 で先行、H1 は Phase 3 に切り離す |
| ファイルサイズが大きすぎて配布困難 | 高 | HuggingFace LFS を主配布、GitHub Releases はメタデータのみ |
| ALLaM のライセンス確認が必要 | 低〜中 | Apache 2.0 を確認済みだが再配布条件を精読する |
| TII / G42 が公式 llamafile を先にリリース | 低 | 出現した場合は協力・統合を優先、変換ガイドとしての価値は残る |

---

## 7. 成果物構成

```
(repo)/
├── PLAN.md                    # 本ドキュメント
├── README.md                  # 利用者向けドキュメント（Phase 1 後に作成）
├── scripts/
│   ├── convert.sh             # HF weights → GGUF → llamafile 変換スクリプト
│   ├── quantize.sh            # 量子化バリアント一括生成
│   └── test.sh                # 動作確認スクリプト
├── models/
│   └── manifest.json          # 生成済み llamafile の管理リスト
├── benchmarks/                # 各モデルのベンチマーク結果
└── .github/
    └── workflows/
        └── build.yml          # 自動変換 CI
```

---

## 8. 関連リンク

- [TII Falcon モデル一覧](https://falconllm.tii.ae/falcon-models.html)
- [Jais — HuggingFace](https://huggingface.co/core42/jais-30b-chat-v3)
- [ALLaM — HuggingFace](https://huggingface.co/ALLaM-AI/ALLaM-7B-Instruct-preview)
- [Falcon-H1 論文](https://arxiv.org/abs/2507.22448)
- [llamafile GitHub](https://github.com/mozilla-ai/llamafile)
- [llama.cpp GitHub](https://github.com/ggml-org/llama.cpp)
- [RWKV-7 "Goose" 論文](https://openreview.net/forum?id=soz1SEiPeq)

---

*最終更新: 2026-03-24*
