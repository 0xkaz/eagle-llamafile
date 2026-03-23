# UAEとサウジアラビアのLLMをllamafile化した理由

*個人リサーチ / 0xkaz — 2026年3月*

---

ローカルLLMエコシステムに、誰も気づいていないギャップがある。

UAEとサウジアラビアは、Apache 2.0ライセンスの本格的なオープンソース言語モデルを静かにリリースし続けている。Falcon、Jais、ALLaM——強力なベンチマーク結果を持ち、アラビア語をネイティブでサポートし、倍のパラメータ数を持つモデルを性能で上回るものさえある。それなのに、llamafileエコシステムを見ると、LlamaやMistralのバリアントが何百もある一方で、Gulf地域のモデルはほぼゼロだ。

そのギャップを埋めることにした。

---

## llamafileとは

[llamafile](https://github.com/mozilla-ai/llamafile)はMozillaのプロジェクトで、LLMの重み + llama.cpp推論エンジン + Cosmopolitan Libcを**1つの実行ファイルにまとめる**フォーマット。PythonもDockerもCUDAセットアップも不要。ファイルをダウンロードしてダブルクリック（またはchmod +xして実行）するだけで、ローカルのWebUIとOpenAI互換APIがポート8080で立ち上がる。

macOS、Linux、Windows、ARMすべてで同じバイナリが動く。

コアのアイデアはシンプル：LLMはソフトウェアとして配布できるべきで、研究成果物として扱うべきではない。`.llamafile`は、LLMにとってのMacの`.app`だ。

---

## 見つけたギャップ

llamafileエコシステム（2026年初頭時点で約769モデル）を調べると、パターンは明確だった：ほぼすべてがLlama、Mistral、Phiのバリアント。Gulf地域のモデルは——本当に有能でオープンソースなのに——llamafileのカバレッジがゼロだった。

具体的なギャップ：

| モデル | 出所 | ライセンス | llamafile |
|--------|------|-----------|-----------|
| Falcon 3 (1B/3B/7B) | TII, UAE | Apache 2.0 | **なし** |
| Falcon-H1 (7B/34B) | TII, UAE | Apache 2.0 | **なし** |
| Jais (13B/30B) | G42/MBZUAI, UAE | Apache 2.0 | **なし** |
| ALLaM 7B | SDAIA/HUMAIN, Saudi | Apache 2.0 | **なし** |

これらはすべてGGUFファイルが存在していた（TII公式または community量子化）。変換ツールチェーン——llama.cppの`convert_hf_to_gguf.py`と`zipalign`——も存在していた。欠けていたのは、誰かが実際にバンドルするという一歩だけだった。

---

## 作ったもの

数日間で9つのモデルのllamafileを作成した：

| llamafile | サイズ | モデル |
|-----------|--------|--------|
| `falcon3-1b-Q4_K_M.llamafile` | 1.7 GB | Falcon3 1B Instruct (TII, UAE) |
| `falcon3-3b-Q4_K_M.llamafile` | 2.6 GB | Falcon3 3B Instruct (TII, UAE) |
| `falcon3-7b-Q4_K_M.llamafile` | 5.0 GB | Falcon3 7B Instruct (TII, UAE) |
| `falcon-h1r-7b-Q4_K_M.llamafile` | 5.0 GB | Falcon-H1R 7B Reasoning (TII, UAE) |
| `falcon-h1-7b-Q4_K_M.llamafile` | 5.0 GB | Falcon-H1 7B Instruct (TII, UAE) |
| `falcon-h1-34b-Q4_K_M.llamafile` | 20 GB | Falcon-H1 34B Instruct (TII, UAE) |
| `jais-13b-Q4_K_M.llamafile` | 12 GB | Jais 13B Chat (G42/MBZUAI, UAE) |
| `jais-30b-Q4_K_M.llamafile` | 27 GB | Jais Family 30B 16K (G42/MBZUAI, UAE) |
| `allam-7b-Q4_K_M.llamafile` | 4.7 GB | ALLaM 7B Instruct (SDAIA/HUMAIN, Saudi) |

すべてApache 2.0。すべて動作確認済み。すべて1つのコマンドで実行可能。

---

## 学んだこと

### 1. ツールチェーンは思っていたより成熟していた

llama.cppのPR #14534がFalcon-H1サポートを追加。TIIが公式GGUFを公開。コミュニティはJaisをすでに量子化していた。作業を始めた時点で、すべての前提条件は揃っていた——誰かがただ点と点を繋いでいなかっただけ。

### 2. llamafile 0.10.0 には一つ注意点がある

古いバージョンでは埋め込みモデルが自動でロードされたが、0.10.0では明示的に参照する必要がある：

```bash
# 動かない（0.10.0）
./falcon-h1r-7b-Q4_K_M.llamafile --cli -p "prompt"

# 動く
./falcon-h1r-7b-Q4_K_M.llamafile -m /zip/Falcon-H1R-7B-Q4_K_M.gguf --cli -p "prompt"
```

`/zip/`プレフィックスはllamafile内部の埋め込みZIPアーカイブを参照する。小さな問題だが、30分ほど費やした。

### 3. Falcon-H1のSSMハイブリッドはM4 Pro GPUで動かない

Falcon-H1はMamba-2 SSMハイブリッドアーキテクチャを使用している。Mamba-2のMetal GPUカーネルはM5/A19チップ以降が必要で、M4 Proでは：

```
ggml_metal_device_init: tensor API disabled for pre-M5 and pre-A19 devices
```

CPU推論は問題なく動く。GPU高速化にはより新しいApple Siliconが必要。ブロッカーではなく、ドキュメントに記録すべき事項だ。

### 4. Dense Transformerモデル（Jais、ALLaM、Falcon3）はそのまま動く

特別な処理は不要。GGUFをダウンロードして、バンドルして、実行するだけ。Jais 30Bはメモリの都合でM4 Proでは`-ngl 0`が必要だが、サイズの問題であってアーキテクチャの問題ではない。

### 5. Jais 30BのコミュニティGGUFにはQ4_K_Mがなかった

Q8_0とF16しかなかった。`llama-quantize --allow-requantize`でQ8_0から再量子化した。Q8_0→Q4_K_M vs FP16→Q4_K_Mの品質差は最小限（Q8_0はFP16に非常に近い精度）。

---

## なぜこれらのモデルが重要か

Falconシリーズ（TII、アブダビ）はHuggingFaceで55M+のダウンロード数を持つ。Falcon3-7Bは最もダウンロードされている7Bモデルの一つ。JaisはリーディングなアラビA語-英語バイリンガルモデル。ALLaMはサウジアラビア国家AI機関のモデルだ。

これらはニッチな学術プロジェクトではない。強力な採用実績を持つ、本物のプロダクション品質モデルだ——ただローカル推論エコシステムでの代表が少なかっただけ。

アラビア語に関わるものを作っているなら、あるいはAPIコストなしにラップトップで動かせる優れたオープンソース7Bが必要なら、これらは知っておく価値がある。

llamafileはHuggingFaceの[huggingface.co/kaz321](https://huggingface.co/kaz321)で公開している。

---

*次の記事: Falcon-H1のアーキテクチャ詳解——なぜSSMハイブリッドが4倍のサイズのモデルを打ち負かすのか*

**リポジトリ:** [github.com/0xkaz/eagle-llamafile](https://github.com/0xkaz/eagle-llamafile)
