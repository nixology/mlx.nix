{ config, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      legacyPackages = import pkgs.path {
        inherit system;
        config = { };
        overlays = [ config.flake.overlays.default ];
      };
    };
}
