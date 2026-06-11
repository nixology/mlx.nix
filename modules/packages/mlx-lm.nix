{ inputs, ... }:
let
  _mlx-lm_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.mlx-lm;
in
{
  perSystem =
    { final, pkgs, ... }:
    {
      packages = {
        default = final.python3.pkgs.${_mlx-lm_.pname};

        ${_mlx-lm_.pname} = pkgs.python3.pkgs.${_mlx-lm_.pname}.overrideAttrs (_oldAttrs: {
          inherit (_mlx-lm_) src version;

          propagatedBuildInputs = with final.python3.pkgs; [
            jinja2
            mlx
            numpy
            protobuf
            pyyaml
            sentencepiece
            transformers
          ];

          # NOTE: need metal compiler to check mlx_lm python import
          doInstallCheck = false;
          pythonImportsCheck = [ ];
        });
      };
    };
}
