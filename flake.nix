{
  description = "MLX - Machine Learning eXperiments";

  inputs.flake.url = "github:nixology/flake.nix";

  inputs.mlx.url = "github:ml-explore/mlx/v0.31.2";
  inputs.mlx.flake = false;

  inputs.mlx-lm.url = "github:ml-explore/mlx-lm/v0.31.3";
  inputs.mlx-lm.flake = false;

  inputs.models.url = "github:nixology/models.nix";
  inputs.models.inputs.flake.follows = "flake";

  outputs =
    inputs: with inputs.flake.lib; mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}
