{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      env = pkgs.buildEnv {
        name = "mlx-env";
        paths = [
          pkgs.coreutils
          pkgs.cmake
          pkgs.gnumake
          (pkgs.python3.withPackages (
            ps: with ps; [
              pip
              setuptools
            ]
          ))
          (pkgs.xcodeenv.composeXcodeWrapper { })
        ];
      };

      builder = pkgs.writeShellScript "builder" ''
        PATH=${env}/bin:/usr/bin:/bin

        # unpack phase
        cp -r ${inputs.mlx}/* .
        chmod -R u+w .

        # install phase
        export PYPI_RELEASE=1
        python -m pip install . \
          --prefix="$out" \
          --no-build-isolation \
          --no-cache-dir
      '';
    in
    {
      packages.default = builtins.derivation {
        name = "mlx";
        inherit builder system;
        __noChroot = true;
      };
    };
}
