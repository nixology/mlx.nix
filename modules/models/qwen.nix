{ inputs, ... }:
let
  flakeLib = inputs.flake.lib;
  metadata = flakeLib.metadataForFlakeInput inputs.self inputs.unsloth--Qwen3_6-27B-MLX-8bit;
in
{
  perSystem =
    { pkgs, ... }:
    let
      fetchModel =
        {
          url,
          rev,
          hash,
        }:
        pkgs.fetchgit {
          inherit url rev hash;
          fetchLFS = true;
        };
      fetchModelSparse =
        {
          url,
          rev,
          hash,
          files,
        }:
        pkgs.fetchgit {
          inherit url rev hash;
          fetchLFS = true;
          sparseCheckout = files;
        };
    in
    {
      packages = {
        ${metadata.pname} = fetchModel {
          inherit (metadata) url rev;
          hash = "sha256-u8j0dNZdjCIqR6+nEKWgY6dSVoSuNAAkf3dcxuKIaAM=";
        };
        testpack = fetchModelSparse {
          inherit (metadata) url rev;
          files = [ "model-00001-of-00007.safetensors" ];
          hash = "sha256-u8j0dNZdjCIqR6+nEKWgY6dSVoSuNAAkf3dcxuKIaAM=";
        };
      };
    };
}
