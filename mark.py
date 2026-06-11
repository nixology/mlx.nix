from pathlib import Path
import json
import mlx.core as mx

model_dir = Path("./result")  # change this

config = json.loads((model_dir / "config.json").read_text())

quant = config.get("quantization") or config.get("quantization_config") or config
bits = quant.get("bits")
group_size = quant.get("group_size")

stored_elements = 0
logical_params_estimate = 0

for f in model_dir.glob("*.safetensors"):
    weights = mx.load(str(f))

    for name, tensor in weights.items():
        stored_elements += tensor.size

        # MLX packed quantized weights often use uint32 containers.
        # Each uint32 has 32 bits, so it stores 32 / bits logical weights.
        if bits and str(tensor.dtype) in {"uint32", "mlx.core.uint32"}:
            logical_params_estimate += tensor.size * (32 // bits)
        else:
            logical_params_estimate += tensor.size

print(f"quant bits: {bits}")
print(f"group size: {group_size}")
print(f"stored tensor elements: {stored_elements:,}")
print(f"estimated logical parameters: {logical_params_estimate:,}")
