{
  version ? "18.1.2_20240815",
  hash ? "sha256-TXcRjte97bTskPqoS4RzbXapYmEY2z0k+hO62+tXJ+8=",
  stdenv,
  lib,
  fetchurl,
  makeWrapper,
  buildFHSEnv,
}: let
  fhsEnv = buildFHSEnv {
    name = "llvm-env";
    targetPkgs = pkgs: with pkgs; [zlib libxml2];
    runScript = "";
  };
in
  assert stdenv.system == "x86_64-linux";
    stdenv.mkDerivation rec {
      pname = "llvm";
      inherit version;
      src = fetchurl {
        url = "https://github.com/espressif/llvm-project/releases/download/esp-${version}/clang-esp-${version}-x86_64-linux-gnu.tar.xz";
        inherit hash;
      };

      buildInputs = [makeWrapper];

      phases = ["unpackPhase" "installPhase"];

      installPhase = ''
        cp -r . $out
        for FILE in $(ls $out/bin); do
          FILE_PATH="$out/bin/$FILE"
          if [[ -x $FILE_PATH && $FILE != *lld* ]]; then
            mv $FILE_PATH $FILE_PATH-unwrapped
            makeWrapper ${fhsEnv}/bin/${fhsEnv.name} $FILE_PATH --add-flags "$FILE_PATH-unwrapped"
          fi
        done
      '';

      meta = with lib; {
        description = "Xtensa LLVM tool chain";
        homepage = "https://github.com/espressif/llvm-project";
        license = licenses.gpl3;
      };
    }
