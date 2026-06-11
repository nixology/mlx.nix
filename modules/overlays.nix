{
  perSystem =
    {
      config,
      final,
      pkgs,
      ...
    }:
    {
      overlayAttrs = {
        python3 = pkgs.python3.override {
          packageOverrides = _pythonFinal: _pythonPrev: {
            mlx = config.packages.mlx;
            mlx-lm = config.packages.mlx-lm;
          };
        };
        python3Packages = final.python3.pkgs;
      };
    };
}
