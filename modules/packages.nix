{ inputs, self, ... }: {
  perSystem = { lib, pkgs, system, ... }:
    let
      builder = pkgs.writeShellScript "builder" ''
        set -x

        # unpack phase
        ${lib.getExe' pkgs.coreutils "cp"} -r ${inputs.MLX}/* .

        # configure phase
        DEVELOPER_DIR=${xcode}/Contents/Developer
        SDKROOT=$DEVELOPER_DIR/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
        TOOLCHAIN_DIR=$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain
        PATH=$DEVELOPER_DIR/usr/bin:$TOOLCHAIN_DIR/usr/bin:/usr/bin:/bin
        export DEVELOPER_DIR SDKROOT PATH

        SRC_DIR=$(pwd)
        BUILD_DIR=$(${lib.getExe' pkgs.coreutils "mktemp"} -d)
        pushd $BUILD_DIR

        ${lib.getExe' pkgs.cmake "cmake"} $SRC_DIR -DCMAKE_INSTALL_PREFIX=$out

        ${lib.getExe' pkgs.gnumake "make"} -j

        ${lib.getExe' pkgs.gnumake "make"} test

        ${lib.getExe' pkgs.gnumake "make"} -j install
      '';

      xcode = pkgs.darwin.xcode_26_2_Apple_silicon;
    in
    {
      packages.default = builtins.derivation {
        name = "mlx";
        inherit builder system;
        __noChroot = true;
      };
    };
}
