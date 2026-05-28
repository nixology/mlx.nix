{ inputs, ... }:
{
  perSystem =
    { lib, pkgs, ... }:
    with pkgs;
    let
      flakeLib = inputs.flake.lib.forFlake inputs.self;
      metadata = flakeLib.metadataForInput inputs.mlx;

      python = pkgs.python3;
      pythonVersionMajorMinorCompact =
        lib.versions.major python.version + lib.versions.minor python.version;
      pythonVersionMajorMinor =
        lib.versions.major python.version + "." + lib.versions.minor python.version;
      pythonVersionMajor = lib.versions.major python.version;

      format = "wheel";
      platform = "macosx_26_0_arm64";

      backend = python.pkgs.buildPythonPackage {
        pname = "${metadata.pname}_metal";
        inherit (metadata) version;
        inherit format;

        src = fetchPypi {
          pname = "${metadata.pname}_metal";
          inherit (metadata) version;
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
        ${metadata.pname} = python.pkgs.buildPythonPackage rec {
          inherit (metadata) pname version;
          inherit format;

          src = fetchPypi {
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
            fixDarwinDylibNames
          ];

          # After pip installs the mlx wheel, copy backend libraries
          # NOTE: This is not copying any other file, e.g. headers.
          postInstall = ''
            libdir=${backend}/lib/python${pythonVersionMajorMinor}/site-packages/${pname}
            cp -r "$libdir/lib" "$out/lib/python${pythonVersionMajorMinor}/site-packages/${pname}/"
          '';

          postFixup = lib.optionalString stdenv.isDarwin ''
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
            broken = !stdenv.isDarwin || !stdenv.isAarch64;
          };
        };
      };
    };
}
