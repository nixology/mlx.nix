{
  description = "MLX - Machine Learning eXperiments";

  inputs.flake.url = "github:nixology/flake.nix";

  inputs.xcode.url = "github:nixology/xcode.nix";

  inputs.mlx.url = "github:ml-explore/mlx/v0.31.2";
  inputs.mlx.flake = false;

  outputs =
    inputs: with inputs.flake.lib; mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}
