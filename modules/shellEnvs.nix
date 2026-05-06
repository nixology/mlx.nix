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
      default = {
        mkShellOverrides = {
          #inherit (inputs'.xcode.packages) stdenv;
          stdenv = pkgs.stdenvNoCC;
        };
        shellHook =
          let
            venvDir = "./.venv";
          in
          ''
            #DEVELOPER_DIR=${inputs'.xcode.packages.xcode}/Contents/Developer
            DEVELOPER_DIR=/Applications/Xcode_26.4.1.app/Contents/Developer
            SDKROOT=$DEVELOPER_DIR/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
            TOOLCHAIN_DIR=$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain
            PATH=$PATH:$DEVELOPER_DIR/usr/bin:$TOOLCHAIN_DIR/usr/bin
            export DEVELOPER_DIR SDKROOT PATH

            if [ -d ${venvDir} ]; then
              echo "Skipping venv creation, ${venvDir} already exists."
            else
              echo "Creating new venv environment in path: '${venvDir}'"
              ${pkgs.python3Packages.python.interpreter} -m venv "${venvDir}"
            fi

            source "${venvDir}/bin/activate"
          '';
        packages = with pkgs; [
          (python3.withPackages (
            ps: with ps; [
              setuptools
              pip
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
