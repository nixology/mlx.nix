{ inputs, ... }:
let
  flakeText = builtins.replaceStrings [ "\n" ] [ " " ] (builtins.readFile "${inputs.self}/flake.nix");

  mlxLmRef = builtins.elemAt (builtins.match ".*inputs\\.mlx-lm\\.url[[:space:]]*=[[:space:]]*\"github:ml-explore/mlx-lm/([^\"]+)\";.*" flakeText) 0;

  mlxLmVersion = builtins.substring 1 ((builtins.stringLength mlxLmRef) - 1) mlxLmRef;
in
{
  perSystem =
    { config, pkgs, ... }:
    {
      packages = {
        llm = config.legacyPackages.llmWithPlugins;
        mlx-lm = config.legacyPackages.python3.pkgs.mlx-lm;
      };

      overlayAttrs = {
        llmWithPlugins = pkgs.python3.withPackages (
          ps: with ps; [
            llm
            llm-ollama
            llm-gguf
            config.packages.llm-mlx
          ]
        );

        python3 = pkgs.python3.override {
          packageOverrides = pythonFinal: pythonPrev: {
            mlx-lm = pythonPrev.mlx-lm.overrideAttrs (_oldAttrs: {
              version = mlxLmVersion;

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
