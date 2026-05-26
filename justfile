serve:
  mlx_lm.server --model unsloth/Qwen3.6-27B-MLX-8bit --host 127.0.0.1 --port 8080 --trust-remote-code

serve2:
  mlx_lm.server --model unsloth/Qwen3.6-35B-A3B-MLX-8bit --host 127.0.0.1 --port 8080 --trust-remote-code
