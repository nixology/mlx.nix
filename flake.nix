{
  description = "MLX - Machine Learning eXperiments";

  inputs.flake.url = "github:nixology/flake.nix";
  inputs.xcode.url = "github:nixology/xcode.nix";
  inputs.MLX.url = "github:ml-explore/mlx";
  inputs.MLX.flake = false;

  outputs = inputs: with inputs.flake.lib;
    mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}
