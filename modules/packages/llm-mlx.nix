{ inputs, ... }:
let
  getNode =
    input:
    let
      lock = builtins.fromJSON (builtins.readFile "${inputs.self}/flake.lock");
      node = builtins.getAttr "${input}" lock.nodes;
    in
    node;

  getOriginalNode = input: (getNode input).original;

  inputName =
    input: builtins.head (builtins.filter (name: inputs.${name} == input) (builtins.attrNames inputs));

  pname = inputName src;

  src = inputs.llm-mlx;

  version =
    let
      ref = (getOriginalNode pname).ref;
    in
    if builtins.substring 0 1 ref == "v" then
      builtins.substring 1 ((builtins.stringLength ref) - 1) ref
    else
      ref;
in
{
  perSystem =
    { config, pkgs, ... }:
    let
      python = pkgs.python3;
    in
    with python.pkgs;
    {
      packages.${pname} = buildPythonPackage {
        inherit pname src version;
        pyproject = true;

        patches = [
          (pkgs.fetchurl {
            url = "https://github.com/simonw/llm-mlx/pull/20.patch";
            hash = "sha256-J3+Y55MQpNaIuFOvcZL9huWQ/n8W2zEmo/9IkMClAUU=";
          })
        ];

        pythonImportsCheck = [ "llm_mlx" ];

        build-system = [
          setuptools
          setuptools-scm
        ];

        dependencies = [
          llm
          config.packages.mlx-lm
        ];
      };
    };
}
