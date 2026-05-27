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

  src = inputs.mlx-lm;

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
    {
      packages = {
        mlx-lm = config.legacyPackages.python3.pkgs.mlx-lm;
      };

      overlayAttrs = {
        python3 = python.override {
          packageOverrides = pythonFinal: pythonPrev: {
            mlx-lm = pythonPrev.mlx-lm.overrideAttrs (_oldAttrs: {
              inherit version;

              src = inputs.mlx-lm;

              # Do not seem to work reliably on GH CI
              doCheck = false;
              doInstallCheck = false;
              disabledTestPaths = [ ];

              propagatedBuildInputs = with pythonFinal; [
                sentencepiece
                mlx
                numpy
                transformers
                protobuf
                pyyaml
                jinja2
              ];

              # NOTE: need metal compiler to check mlx_lm python import
              pythonImportsCheck = [ ];
            });

            mlx = config.packages.mlx;
          };
        };

        # Update python3Packages to use the newly overridden python3
        python3Packages = config.overlayAttrs.python3.pkgs;
      };

    };
}
