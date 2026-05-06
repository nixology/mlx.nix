{ inputs, ... }:
let
  module = {
    imports = with inputs.flake.components; map (component: component.module) [
      nixology.environments.nix
      nixology.extra.shellEnvs
      nixology.flake.packages
      nixology.channels.unfree
      nixology.systems.default-darwin
      nixology.tools.treefmt
    ];
  };
in
module
