# Why I Made llamafiles for UAE and Saudi Arabia's LLMs

*Personal research / 0xkaz — March 2026*

---

There's a gap in the local LLM ecosystem that nobody seems to have noticed.

UAE and Saudi Arabia have been quietly shipping serious open-source language models — Falcon, Jais, ALLaM — with Apache 2.0 licenses, strong benchmarks, and native Arabic support. Some of these models outperform models twice their size on math and reasoning. Yet if you go to the llamafile ecosystem, you'll find hundreds of Llama and Mistral variants, and almost nothing from the Gulf.

I decided to fix that.

---

## What is llamafile?

[llamafile](https://github.com/mozilla-ai/llamafile) is a project from Mozilla that bundles an LLM's weights + llama.cpp inference engine + Cosmopolitan Libc into a **single executable file**. No Python, no Docker, no CUDA setup. You download one file, double-click it (or `chmod +x` and run it), and you get a local web UI and an OpenAI-compatible API on port 8080.

It works on macOS, Linux, Windows, and ARM — all from the same binary.

The core idea is compelling: LLMs should be distributable like software, not like research artifacts. A `.llamafile` is to an LLM what a `.app` is to a Mac application.

---

## The Gap I Found

When I looked at the llamafile ecosystem (~769 models as of early 2026), the pattern was clear: almost everything was Llama, Mistral, or Phi variants. Models from the Gulf region — despite being genuinely capable and open-source — had zero llamafile coverage.

Here's the specific gap:

| Model | Origin | License | llamafile |
|-------|--------|---------|-----------|
| Falcon 3 (1B/3B/7B) | TII, UAE | Apache 2.0 | **none** |
| Falcon-H1 (7B/34B) | TII, UAE | Apache 2.0 | **none** |
| Jais (13B/30B) | G42/MBZUAI, UAE | Apache 2.0 | **none** |
| ALLaM 7B | SDAIA/HUMAIN, Saudi | Apache 2.0 | **none** |

All of these had GGUF files available (either official TII releases or community quantizations). The conversion toolchain — llama.cpp's `convert_hf_to_gguf.py` and `zipalign` — existed. The only missing step was someone actually bundling them.

So I did.

---

## What I Built

Over a few days I created llamafiles for nine models:

| llamafile | Size | Model |
|-----------|------|-------|
| `falcon3-1b-Q4_K_M.llamafile` | 1.7 GB | Falcon3 1B Instruct (TII, UAE) |
| `falcon3-3b-Q4_K_M.llamafile` | 2.6 GB | Falcon3 3B Instruct (TII, UAE) |
| `falcon3-7b-Q4_K_M.llamafile` | 5.0 GB | Falcon3 7B Instruct (TII, UAE) |
| `falcon-h1r-7b-Q4_K_M.llamafile` | 5.0 GB | Falcon-H1R 7B Reasoning (TII, UAE) |
| `falcon-h1-7b-Q4_K_M.llamafile` | 5.0 GB | Falcon-H1 7B Instruct (TII, UAE) |
| `falcon-h1-34b-Q4_K_M.llamafile` | 20 GB | Falcon-H1 34B Instruct (TII, UAE) |
| `jais-13b-Q4_K_M.llamafile` | 12 GB | Jais 13B Chat (G42/MBZUAI, UAE) |
| `jais-30b-Q4_K_M.llamafile` | 27 GB | Jais Family 30B 16K (G42/MBZUAI, UAE) |
| `allam-7b-Q4_K_M.llamafile` | 4.7 GB | ALLaM 7B Instruct (SDAIA/HUMAIN, Saudi) |

All Apache 2.0. All working. All runnable with a single command.

---

## What I Learned

### 1. The toolchain is more mature than I expected

llama.cpp's PR #14534 added Falcon-H1 support. TII published official GGUFs. The community had already quantized Jais. By the time I started, literally every prerequisite was in place — nobody had just connected the dots.

### 2. llamafile 0.10.0 has one quirk

In older llamafile versions, the embedded model loaded automatically. In 0.10.0, you need to explicitly reference it:

```bash
# This doesn't work (0.10.0)
./falcon-h1r-7b-Q4_K_M.llamafile --cli -p "prompt"

# This works
./falcon-h1r-7b-Q4_K_M.llamafile -m /zip/Falcon-H1R-7B-Q4_K_M.gguf --cli -p "prompt"
```

The `/zip/` prefix refers to the embedded ZIP archive inside the llamafile. Small thing, cost me 30 minutes.

### 3. Falcon-H1's SSM hybrid doesn't work on M4 Pro GPU

Falcon-H1 uses a Mamba-2 SSM hybrid architecture. The Metal GPU kernel for Mamba-2 requires M5/A19 chips or newer. On M4 Pro, you get:

```
ggml_metal_device_init: tensor API disabled for pre-M5 and pre-A19 devices
```

CPU inference works fine, but GPU acceleration requires newer Apple Silicon. Not a blocker — just something to document.

### 4. Dense Transformer models (Jais, ALLaM, Falcon3) just work

No special handling needed. Download GGUF, bundle, run. Jais 30B needs `-ngl 0` on M4 Pro due to memory, but that's a size issue, not an architecture issue.

### 5. Jais 30B only had Q8_0 and F16 in the community GGUF repo

No Q4_K_M. I re-quantized from Q8_0 using `llama-quantize --allow-requantize`. The quality difference from re-quantizing Q8_0→Q4_K_M vs FP16→Q4_K_M is minimal (Q8_0 is very close to FP16 in precision).

---

## Why These Models Matter

The Falcon series (by TII, Abu Dhabi) has 55M+ downloads on HuggingFace. Falcon3-7B is among the most downloaded 7B models. Jais is the leading Arabic-English bilingual model. ALLaM is Saudi Arabia's national AI initiative model.

These aren't niche academic projects. They're real, production-quality models with strong adoption — just underrepresented in the local-inference ecosystem.

If you're building anything that touches Arabic, or you need a solid open-source 7B that you can run on a laptop without API costs, these are worth knowing about.

The llamafiles are on HuggingFace at [huggingface.co/kaz321](https://huggingface.co/kaz321).

---

*Next post: A deeper look at Falcon-H1's architecture — why an SSM hybrid beats models 4x its size.*

---

**Repo:** [github.com/0xkaz/eagle-llamafile](https://github.com/0xkaz/eagle-llamafile)
