{ config, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      legacyPackages = import pkgs.path {
        inherit (pkgs.stdenv.hostPlatform) system;
        config = { };
        overlays = [ config.flake.overlays.default ];
      };
    };
}
