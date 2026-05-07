{
  perSystem =
    { pkgs, ... }:
    with pkgs;
    with python3Packages;
    let
      version = "0.31.2";
      format = "wheel";
      platform = "macosx_15_0_arm64";

      mlx_metal = buildPythonPackage rec {
        pname = "mlx_metal";
        inherit version format;

        src = fetchPypi {
          inherit
            pname
            version
            format
            platform
            ;
          hash = "sha256-6dTl/ObKEKh6DjiFl/mVGa1ZTQnmdHCLUxK9i9T1mX0=";
          python = "py3";
          dist = "py3";
        };

        dontStrip = true;
        doCheck = false;
      };
    in
    {
      packages = {
        mlx = buildPythonPackage rec {
          pname = "mlx";
          inherit version format;

          src = fetchPypi {
            inherit
              pname
              version
              format
              platform
              ;
            hash = "sha256-NLAXHNnrXEP92CCR9hNdbMxaBlNjpKPmj6xk+05T03w=";
            python = "cp313";
            dist = "cp313";
            abi = "cp313";
          };

          nativeBuildInputs = [
            fixDarwinDylibNames
          ];

          # After pip installs the mlx wheel, extract mlx_metal and copy its lib directory
          # NOTE: This is not copying any other file, e.g. headers.
          postInstall = ''
            libdir=${mlx_metal}/lib/python3.13/site-packages/mlx
            cp -r "$libdir/lib" "$out/lib/python3.13/site-packages/mlx/"
          '';

          postFixup = lib.optionalString stdenv.isDarwin ''
            libdir="$out/lib/python3.13/site-packages/mlx"

            if [ -f "$libdir/lib/libmlx.dylib" ]; then
              for so in "$libdir"/*.so; do
                if [ -f "$so" ] && [ "$so" != "$libdir/core.cpython-313-darwin.so" ]; then
                  install_name_tool -add_rpath "$libdir/lib" "$so" 2>/dev/null || true
                  install_name_tool -change @rpath/libmlx.dylib "$libdir/lib/libmlx.dylib" "$so" 2>/dev/null || true
                fi
              done
              exit 0
            fi

            echo "ERROR: libmlx.dylib not found after copying from mlx_metal"
            exit 1
          '';

          dontStrip = true;
          doCheck = false;

          pythonImportsCheck = [
            "mlx.core"
          ];

          dontCheckRuntimeDeps = true;

          meta = {
            platforms = lib.platforms.darwin;
            broken = !stdenv.isDarwin || !stdenv.isAarch64;
          };
        };
      };
    };
}
