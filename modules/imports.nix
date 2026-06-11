{ inputs, ... }:
let
  module = {
    imports =
      with inputs.flake.components;
      map (component: component.module) [
        nixology.environments.nix
        nixology.extra.easyOverlay
        nixology.extra.shellEnvs
        nixology.flake.packages
        nixology.flake.legacyPackages
        nixology.systems.default-darwin
      ];
  };
in
module
