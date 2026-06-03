{ inputs, ... }:
let
  flakeLib = inputs.flake.lib;
  metadata = flakeLib.metadataForFlakeInput inputs.self inputs.mlx-lm;
in
{
  perSystem =
    { config, pkgs, ... }:
    let
      inherit (metadata) pname;
      python = pkgs.python3;
    in
    {
      packages = {
        ${pname} = config.legacyPackages.python3.pkgs.${pname};
      };

      overlayAttrs = {
        python3 = python.override {
          packageOverrides = pythonFinal: pythonPrev: {
            ${pname} = pythonPrev.${pname}.overrideAttrs (_oldAttrs: {
              inherit (metadata) src version;

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
