#!/usr/bin/env python3
"""
quantize_qwen3.py — INT8 Quantization for Qwen3-TTS ONNX Model
================================================================

Converts the Qwen3-TTS-12Hz-0.6B-Base model to ONNX format and applies
INT8 dynamic quantization to reduce model size for mobile deployment.

No official Qwen3-TTS quantization script exists as of 2026-02.
This script uses ONNX Runtime's built-in quantization tools.

Prerequisites:
    pip install onnxruntime onnx optimum transformers torch

Usage:
    python scripts/quantize_qwen3.py

Output:
    assets/tts/qwen3/qwen3_int8.onnx
"""

import os
import sys
import argparse
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="Export and quantize Qwen3-TTS to ONNX INT8"
    )
    parser.add_argument(
        "--model-name",
        default="Qwen/Qwen3-TTS-12Hz-0.6B-Base",
        help="HuggingFace model name or local path",
    )
    parser.add_argument(
        "--output-dir",
        default=None,
        help="Output directory (default: assets/tts/qwen3/)",
    )
    parser.add_argument(
        "--skip-export",
        action="store_true",
        help="Skip ONNX export, quantize an existing model",
    )
    parser.add_argument(
        "--onnx-input",
        default=None,
        help="Path to existing ONNX model (use with --skip-export)",
    )
    args = parser.parse_args()

    # Resolve output directory
    project_root = Path(__file__).resolve().parent.parent
    output_dir = Path(args.output_dir) if args.output_dir else project_root / "assets" / "tts" / "qwen3"
    output_dir.mkdir(parents=True, exist_ok=True)

    onnx_path = output_dir / "qwen3_fp32.onnx"
    quantized_path = output_dir / "qwen3_int8.onnx"

    # --- Step 1: Export to ONNX (if not skipped) ---
    if not args.skip_export:
        print(f"[1/2] Exporting {args.model_name} to ONNX...")
        try:
            from optimum.onnxruntime import ORTModelForSpeechSeq2Seq
            from transformers import AutoConfig
        except ImportError:
            print("ERROR: Required packages not installed.")
            print("  pip install optimum[onnxruntime] transformers torch")
            sys.exit(1)

        try:
            # Use optimum's export pipeline
            os.system(
                f"optimum-cli export onnx "
                f"--model {args.model_name} "
                f"--task text-to-audio "
                f"{output_dir}"
            )
            # Find the exported model
            exported = list(output_dir.glob("*.onnx"))
            if exported:
                onnx_path = exported[0]
                print(f"  Exported to: {onnx_path}")
            else:
                print("ERROR: ONNX export produced no .onnx files.")
                print("  Qwen3-TTS may require manual export.")
                print("  Check https://github.com/QwenLM/Qwen3-TTS for updates.")
                sys.exit(1)
        except Exception as e:
            print(f"ERROR: Export failed: {e}")
            print("  Qwen3-TTS architecture may not be supported by optimum yet.")
            print("  Try using a pre-exported ONNX model from:")
            print("    https://huggingface.co/zukky/Qwen3-TTS-ONNX-DLL")
            sys.exit(1)
    else:
        if args.onnx_input:
            onnx_path = Path(args.onnx_input)
        if not onnx_path.exists():
            print(f"ERROR: ONNX model not found at {onnx_path}")
            sys.exit(1)

    # --- Step 2: INT8 Dynamic Quantization ---
    print(f"[2/2] Applying INT8 dynamic quantization...")
    try:
        from onnxruntime.quantization import quantize_dynamic, QuantType
    except ImportError:
        print("ERROR: onnxruntime not installed.")
        print("  pip install onnxruntime")
        sys.exit(1)

    quantize_dynamic(
        model_input=str(onnx_path),
        model_output=str(quantized_path),
        weight_type=QuantType.QInt8,
    )

    # Report sizes
    orig_size = onnx_path.stat().st_size / (1024 * 1024)
    quant_size = quantized_path.stat().st_size / (1024 * 1024)
    reduction = (1 - quant_size / orig_size) * 100

    print(f"\nDone!")
    print(f"  Original:   {orig_size:.1f} MB")
    print(f"  Quantized:  {quant_size:.1f} MB")
    print(f"  Reduction:  {reduction:.1f}%")
    print(f"  Output:     {quantized_path}")


if __name__ == "__main__":
    main()
