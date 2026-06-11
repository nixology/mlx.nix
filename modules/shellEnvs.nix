{
  perSystem =
    {
      config,
      inputs',
      lib,
      pkgs,
      ...
    }:
    let
      python = pkgs.python3;

      default = {
        mkShellOverrides = {
          stdenv = pkgs.stdenvNoCC;
        };
        shellHook =
          let
            venvDir = "./.venv";
          in
          ''
            if [ -d ${venvDir} ]; then
              echo "Skipping venv creation, ${venvDir} already exists."
            else
              echo "Creating new venv environment in path: '${venvDir}'"
              ${python.pkgs.python.interpreter} -m venv "${venvDir}"
            fi

            source "${venvDir}/bin/activate"

            export HF_HUB_CACHE=${inputs'.models.packages.cache}
            export TRANSFORMERS_OFFLINE=1
          '';
        packages = [
          config.packages.mlx-lm
          (python.withPackages (
            ps: with ps; [
              huggingface-hub
              jupyterlab
              notebook
              pip
              setuptools
            ]
          ))
        ];
      };
    in
    {
      shellEnvs.default =
        with config.shellEnvs;
        lib.mkMerge [
          default
          nix
        ];
    };
}
