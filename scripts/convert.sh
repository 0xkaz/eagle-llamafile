#!/usr/bin/env bash
# convert.sh — HuggingFace model → GGUF → llamafile
#
# Usage:
#   ./scripts/convert.sh <hf_model_id> <output_name> [quant_type]
#
# Examples:
#   ./scripts/convert.sh tiiuae/Falcon-H1-7B-Instruct falcon-h1-7b Q4_K_M
#   ./scripts/convert.sh core42/jais-13b-chat jais-13b Q5_K_M
#
# Requirements:
#   - llama.cpp built locally (set LLAMA_CPP_DIR)
#   - llamafile tools in PATH (set LLAMAFILE_DIR)
#   - Python 3.8+ with torch, gguf packages
#   - huggingface-cli logged in (for gated models)

set -euo pipefail

# ── 設定 ──────────────────────────────────────────────────────────────────
LLAMA_CPP_DIR="${LLAMA_CPP_DIR:-$HOME/llama.cpp}"
LLAMAFILE_DIR="${LLAMAFILE_DIR:-$HOME/llamafile}"
MODELS_DIR="${MODELS_DIR:-./models}"
WORK_DIR="${WORK_DIR:-./work}"

# ── 引数チェック ──────────────────────────────────────────────────────────
if [ $# -lt 2 ]; then
  echo "Usage: $0 <hf_model_id> <output_name> [quant_type]"
  echo "  quant_type: Q4_K_M (default) | Q5_K_M | Q8_0 | F16"
  exit 1
fi

HF_MODEL_ID="$1"
OUTPUT_NAME="$2"
QUANT="${3:-Q4_K_M}"

echo "==> モデル: $HF_MODEL_ID"
echo "==> 出力名: $OUTPUT_NAME"
echo "==> 量子化: $QUANT"
echo ""

# ── 作業ディレクトリ準備 ──────────────────────────────────────────────────
mkdir -p "$WORK_DIR" "$MODELS_DIR"
HF_LOCAL="$WORK_DIR/${OUTPUT_NAME}-hf"
GGUF_F16="$WORK_DIR/${OUTPUT_NAME}-f16.gguf"
GGUF_QUANT="$WORK_DIR/${OUTPUT_NAME}-${QUANT}.gguf"
LLAMAFILE_OUT="$MODELS_DIR/${OUTPUT_NAME}-${QUANT}.llamafile"

# ── Step 1: HuggingFace からダウンロード ──────────────────────────────────
echo "[1/4] HuggingFace からダウンロード中..."
huggingface-cli download "$HF_MODEL_ID" --local-dir "$HF_LOCAL"

# ── Step 2: GGUF FP16 に変換 ──────────────────────────────────────────────
echo "[2/4] GGUF (FP16) に変換中..."
python3 "$LLAMA_CPP_DIR/convert_hf_to_gguf.py" \
  "$HF_LOCAL" \
  --outtype f16 \
  --outfile "$GGUF_F16"

# ── Step 3: 量子化 ────────────────────────────────────────────────────────
echo "[3/4] 量子化中 ($QUANT)..."
"$LLAMA_CPP_DIR/build/bin/llama-quantize" \
  "$GGUF_F16" \
  "$GGUF_QUANT" \
  "$QUANT"

# ── Step 4: llamafile にバンドル ──────────────────────────────────────────
echo "[4/4] llamafile にバンドル中..."
cp "$LLAMAFILE_DIR/llamafile" "$LLAMAFILE_OUT"
"$LLAMAFILE_DIR/zipalign" -j0 \
  "$LLAMAFILE_OUT" \
  "$GGUF_QUANT"
chmod +x "$LLAMAFILE_OUT"

echo ""
echo "✓ 完了: $LLAMAFILE_OUT"
echo "  実行: ./$LLAMAFILE_OUT"
echo "  API:  http://127.0.0.1:8080"
