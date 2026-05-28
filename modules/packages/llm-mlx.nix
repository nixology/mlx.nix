{ inputs, ... }:
let
  flakeLib = inputs.flake.lib.forFlake inputs.self;
  metadata = flakeLib.metadataForInput inputs.llm-mlx;
in
{
  perSystem =
    { config, pkgs, ... }:
    let
      python = pkgs.python3;
    in
    with python.pkgs;
    {
      packages.${metadata.pname} = buildPythonPackage {
        inherit (metadata) pname src version;
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
