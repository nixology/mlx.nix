{ config, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      legacyPackages = import pkgs.path {
        inherit (pkgs) system;
        config = { };
        overlays = [ config.flake.overlays.default ];
      };
    };
}
