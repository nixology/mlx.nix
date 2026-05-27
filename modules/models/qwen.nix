{ inputs, ... }:
let
  getNode =
    input:
    let
      lock = builtins.fromJSON (builtins.readFile "${inputs.self}/flake.lock");
      node = builtins.getAttr "${input}" lock.nodes;
    in
    node;

  getLockedNode = input: (getNode input).locked;

  inputName =
    input: builtins.head (builtins.filter (name: inputs.${name} == input) (builtins.attrNames inputs));

  pname = inputName inputs.unsloth--Qwen3_6-27B-MLX-8bit;
in
{
  perSystem =
    { pkgs, ... }:
    let
      fetchModel =
        { pname, hash }:
        pkgs.fetchgit {
          inherit (getLockedNode pname) url rev;
          inherit hash;
          fetchLFS = true;
        };
    in
    {
      packages.${pname} = fetchModel {
        inherit pname;
        hash = "sha256-u8j0dNZdjCIqR6+nEKWgY6dSVoSuNAAkf3dcxuKIaAM=";
      };
    };
}
