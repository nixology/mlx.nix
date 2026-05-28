{ ... }:
{
  perSystem =
    { config, pkgs, ... }:
    let
      python = pkgs.python3;
    in
    {
      packages = {
        llm = config.legacyPackages.llmWithPlugins;
      };

      overlayAttrs = {
        llmWithPlugins = python.withPackages (
          ps: with ps; [
            llm
            llm-github-copilot
            config.packages.llm-mlx
          ]
        );
      };
    };
}
