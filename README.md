# UAE / Saudi LLM llamafile

[English](./README.md) | [日本語](./README.ja.md)

A project to distribute UAE- and Saudi Arabia-origin LLMs as **llamafiles** — single-file executables that require no installation.

## Target Models

| Model | Developer | Architecture | Status |
|--------|-----------|--------------|--------|
| Falcon-H1 7B / 34B | TII (UAE) | Mamba-2 + Transformer | Ready |
| Falcon-H1-Arabic 7B | TII (UAE) | Mamba-2 + Transformer | Waiting for GGUF release |
| Jais 13B / 30B | G42 / MBZUAI (UAE) | Dense Transformer | Ready |
| ALLaM 7B | SDAIA / HUMAIN (Saudi Arabia) | Dense Transformer | Ready |

## What is llamafile?

A single-file format that lets you run LLMs locally with no installation and no dependencies.
Works on Windows, macOS, Linux, and ARM. For details, see [docs/what-is-gguf.md](docs/what-is-gguf.md).

## Running a llamafile

See [docs/how-to-run.md](docs/how-to-run.md) for model-specific commands and API examples.

## Conversion (for developers)

```bash
# Set environment variables before running
export LLAMA_CPP_DIR=~/llama.cpp
export LLAMAFILE_DIR=~/llamafile

./scripts/convert.sh tiiuae/Falcon-H1-7B-Instruct falcon-h1-7b Q4_K_M
```

For details, see the comments in [scripts/convert.sh](scripts/convert.sh).

## Development

This repository includes a `Makefile` for common tasks:

```bash
make help   # Show all available commands
make lint   # Lint shell scripts (shellcheck, or bash -n fallback)
make test   # Run repository validation tests
make clean  # Remove temporary work/ directory
```

To build a llamafile via Make:

```bash
make convert ARGS="tiiuae/Falcon-H1-7B-Instruct falcon-h1-7b Q4_K_M"
```

## CI

`.github/workflows/build.yml` provides a manual GitHub Actions workflow that downloads an official GGUF file and bundles it into a llamafile. It requires a `HF_TOKEN` repository secret for HuggingFace uploads.

## Documentation

- [PLAN.md](PLAN.md) — Project planning document
- [docs/what-is-gguf.md](docs/what-is-gguf.md) — Explanation of the GGUF format
- [docs/how-to-run.md](docs/how-to-run.md) — How to run the generated llamafiles
