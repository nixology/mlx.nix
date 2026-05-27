{ inputs, ... }:
{
  perSystem =
    { lib, pkgs, ... }:
    with pkgs;
    let
      python = pkgs.python3;
      pythonVersionMajorMinorCompact =
        lib.versions.major python.version + lib.versions.minor python.version;
      pythonVersionMajorMinor =
        lib.versions.major python.version + "." + lib.versions.minor python.version;
      pythonVersionMajor = lib.versions.major python.version;

      getNode =
        input:
        let
          lock = builtins.fromJSON (builtins.readFile "${inputs.self}/flake.lock");
          node = builtins.getAttr "${input}" lock.nodes;
        in
        node;

      getOriginalNode = input: (getNode input).original;

      inputName =
        input: builtins.head (builtins.filter (name: inputs.${name} == input) (builtins.attrNames inputs));

      pname = inputName src;

      src = inputs.mlx;

      version =
        let
          ref = (getOriginalNode pname).ref;
        in
        if builtins.substring 0 1 ref == "v" then
          builtins.substring 1 ((builtins.stringLength ref) - 1) ref
        else
          ref;

      format = "wheel";
      platform = "macosx_26_0_arm64";

      backend = python.pkgs.buildPythonPackage {
        pname = "${pname}_metal";
        inherit version format;

        src = fetchPypi {
          pname = "${pname}_metal";
          inherit
            version
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
        ${pname} = python.pkgs.buildPythonPackage rec {
          inherit pname;
          inherit version format;

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
