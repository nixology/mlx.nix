root := justfile_directory()

# Auto-detect system architecture
system := `nix eval --impure --raw --expr 'builtins.currentSystem'`

# Default recipe: show help
default:
    @just --list --unsorted

info:
  {{root}}/bin/info.py unsloth/Qwen3.6-27B-MLX-8bit
  echo
  {{root}}/bin/info.py unsloth/Qwen3.6-35B-A3B-MLX-8bit

serve-dense:
  mlx_lm.server --model unsloth/Qwen3.6-27B-MLX-8bit --host 127.0.0.1 --port 8080 --trust-remote-code --max-tokens 32768

serve-moe:
  mlx_lm.server --model unsloth/Qwen3.6-35B-A3B-MLX-8bit --host 127.0.0.1 --port 8080 --trust-remote-code --max-tokens 32768
