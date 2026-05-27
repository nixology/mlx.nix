{ inputs, ... }:
let
  module = {
    imports =
      with inputs.flake.components;
      map (component: component.module) [
        nixology.core.debug
        nixology.core.schemas
        nixology.environments.nix
        nixology.extra.easyOverlay
        nixology.extra.shellEnvs
        nixology.flake.overlays
        nixology.flake.packages
        nixology.flake.legacyPackages
        nixology.systems.default-darwin
        nixology.tools.treefmt
      ];
  };
in
module
