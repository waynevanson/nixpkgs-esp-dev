{
  version ? "18.1.2_20240815",
  hash ? "sha256-x22RE9UMGSInHRB8npcfeDEBJ5UdAqAS4QwKvRdWJ6s=",
  stdenv,
  lib,
  fetchurl,
  makeWrapper,
}:
assert stdenv.system == "x86_64-linux";
  stdenv.mkDerivation rec {
    pname = "libllvm";
    inherit version;
    src = fetchurl {
      url = "https://github.com/espressif/llvm-project/releases/download/esp-${version}/libs-clang-esp-${version}-x86_64-linux-gnu.tar.xz";
      inherit hash;
    };

    buildInputs = [makeWrapper];

    phases = ["unpackPhase" "installPhase"];

    installPhase = ''
      cp -r . $out
    '';

    meta = with lib; {
      description = "Xtensa LLVM tool chain libraries";
      homepage = "https://github.com/espressif/llvm-project";
      license = licenses.gpl3;
    };
  }
