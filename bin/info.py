#!/usr/bin/env python3

from pathlib import Path
import os
import json
import argparse
import mlx.core as mx

parser = argparse.ArgumentParser()
parser.add_argument(
    "repo_id",
    help="Hugging Face repo ID, e.g. unsloth/Qwen3.6-35B-A3B-8bit"
)
args = parser.parse_args()

repo_id = args.repo_id

hf_cache = Path(
    os.environ.get("HF_HUB_CACHE", Path.home() / ".cache/huggingface/hub")
)

model_cache_dir = hf_cache / f"models--{repo_id.replace('/', '--')}" / "snapshots"

if not model_cache_dir.exists():
    raise FileNotFoundError(
        f"Model not found in cache: {repo_id}\n"
        f"Expected snapshots under: {model_cache_dir}"
    )

snapshots = sorted(
    model_cache_dir.iterdir(),
    key=lambda p: p.stat().st_mtime,
    reverse=True,
)

if not snapshots:
    raise RuntimeError(f"No snapshots found for {repo_id}")

model_dir = snapshots[0]

print(f"Using model dir: {model_dir}")

config = json.loads((model_dir / "config.json").read_text())

quant = config.get("quantization") or config.get("quantization_config") or {}
bits = quant.get("bits")
group_size = quant.get("group_size")

stored_elements = 0
logical_params_estimate = 0

for f in model_dir.glob("*.safetensors"):
    weights = mx.load(str(f))

    for tensor in weights.values():
        stored_elements += tensor.size

        # MLX packed quantized weights often use uint32 containers.
        # Each uint32 has 32 bits, so it stores 32 / bits logical weights.
        if bits and str(tensor.dtype) in {"uint32", "mlx.core.uint32"}:
            logical_params_estimate += tensor.size * (32 // bits)
        else:
            logical_params_estimate += tensor.size

print(f"repo: {repo_id}")
print(f"quant bits: {bits}")
print(f"group size: {group_size}")
print(f"stored tensor elements: {stored_elements:,}")
print(f"estimated logical parameters: {logical_params_estimate:,}")
