{ inputs, ... }:
let
  flakeText = builtins.replaceStrings [ "\n" ] [ " " ] (builtins.readFile "${inputs.self}/flake.nix");

  llmMlxRef = builtins.elemAt (builtins.match ".*inputs\\.llm-mlx\\.url[[:space:]]*=[[:space:]]*\"github:simonw/llm-mlx/([^\"]+)\";.*" flakeText) 0;

  llmMlxVersion =
    if builtins.substring 0 1 llmMlxRef == "v" then
      builtins.substring 1 ((builtins.stringLength llmMlxRef) - 1) llmMlxRef
    else
      llmMlxRef;
in
{
  perSystem =
    { pkgs, ... }:
    with pkgs;
    with python3Packages;
    {
      packages.llm-mlx = buildPythonPackage {
        pname = "llm-mlx";
        version = llmMlxVersion;
        pyproject = true;

        src = inputs.llm-mlx;

        patches = [
          (fetchurl {
            url = "https://github.com/simonw/llm-mlx/pull/20.patch";
            hash = "sha256-J3+Y55MQpNaIuFOvcZL9huWQ/n8W2zEmo/9IkMClAUU=";
          })
        ];

        pythonImportsCheck = [ ];

        build-system = [
          setuptools
          setuptools-scm
        ];

        dependencies = [
          llm
          inputs.self.legacyPackages.${pkgs.stdenv.hostPlatform.system}.python3Packages.mlx-lm
        ];
      };
    };
}
