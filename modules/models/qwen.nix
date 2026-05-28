{ inputs, ... }:
let
  flakeLib = inputs.flake.lib.forFlake inputs.self;
  metadata = flakeLib.metadataForInput inputs.unsloth--Qwen3_6-27B-MLX-8bit;
in
{
  perSystem =
    { pkgs, ... }:
    let
      fetchModel =
        { metadata, hash }:
        pkgs.fetchgit {
          inherit (metadata) url rev;
          inherit hash;
          fetchLFS = true;
        };
    in
    {
      packages.${metadata.pname} = fetchModel {
        inherit metadata;
        hash = "sha256-u8j0dNZdjCIqR6+nEKWgY6dSVoSuNAAkf3dcxuKIaAM=";
      };
    };
}
