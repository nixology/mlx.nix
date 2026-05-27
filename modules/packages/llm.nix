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
            llm-ollama
            llm-gguf
            config.packages.llm-mlx
          ]
        );
      };
    };
}
