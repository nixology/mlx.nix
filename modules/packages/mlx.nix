{ inputs, ... }:
let
  _mlx_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.mlx;
in
{
  perSystem =
    { final, lib, ... }:
    let
      python = final.python3;
      pythonVersionMajorMinorCompact =
        lib.versions.major python.version + lib.versions.minor python.version;
      pythonVersionMajorMinor =
        lib.versions.major python.version + "." + lib.versions.minor python.version;
      pythonVersionMajor = lib.versions.major python.version;

      format = "wheel";
      platform = "macosx_26_0_arm64";

      backend = python.pkgs.buildPythonPackage {
        pname = "${_mlx_.pname}_metal";
        inherit (_mlx_) version;
        inherit format;

        src = python.pkgs.fetchPypi {
          pname = "${_mlx_.pname}_metal";
          inherit (_mlx_) version;
          inherit
            format
            platform
            ;
          hash = "sha256-hP+2DuUD8D62hPX7Fo1c/zHioWt/J8FzHq92Yr1um0Y=";
          python = "py${pythonVersionMajor}";
          dist = "py${pythonVersionMajor}";
        };

        dontStrip = true;
        doCheck = false;
      };
    in
    {
      packages = {
        ${_mlx_.pname} = python.pkgs.buildPythonPackage rec {
          inherit (_mlx_) pname version;
          inherit format;

          src = final.fetchPypi {
            inherit
              pname
              version
              format
              platform
              ;
            hash = "sha256-wFmBaEJ5qJNdWLDd4+pbAtIQw7rTMZqg6ZNOwt8WV1I=";
            python = "cp${pythonVersionMajorMinorCompact}";
            dist = "cp${pythonVersionMajorMinorCompact}";
            abi = "cp${pythonVersionMajorMinorCompact}";
          };

          nativeBuildInputs = [
            final.fixDarwinDylibNames
          ];

          # After pip installs the mlx wheel, copy backend libraries
          # NOTE: This is not copying any other file, e.g. headers.
          postInstall = ''
            libdir=${backend}/lib/python${pythonVersionMajorMinor}/site-packages/${pname}
            cp -r "$libdir/lib" "$out/lib/python${pythonVersionMajorMinor}/site-packages/${pname}/"
          '';

          postFixup = lib.optionalString final.stdenv.isDarwin ''
            libdir="$out/lib/python${pythonVersionMajorMinor}/site-packages/${pname}"

            if [ -f "$libdir/lib/libmlx.dylib" ]; then
              for so in "$libdir"/*.so; do
                if [ -f "$so" ] && [ "$so" != "$libdir/core.cpython-${pythonVersionMajorMinorCompact}-darwin.so" ]; then
                  install_name_tool -add_rpath "$libdir/lib" "$so" 2>/dev/null || true
                  install_name_tool -change @rpath/libmlx.dylib "$libdir/lib/libmlx.dylib" "$so" 2>/dev/null || true
                fi
              done
              exit 0
            fi

            echo "ERROR: libmlx.dylib not found after copying backend libraries."
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
            broken = !final.stdenv.isDarwin || !final.stdenv.isAarch64;
          };
        };
      };
    };
}
