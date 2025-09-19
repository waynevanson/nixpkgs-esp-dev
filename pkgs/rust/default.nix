{
  version ? "1.88.0.0",
  callPackage,
  rust,
  lib,
  stdenv,
  fetchurl,
  rustcHash ? "sha256-dFNJFHSl9yiyRIFlHUPLzq+S9438q+fLiCxr8h/uBQU=",
  rustSrcHash ? "sha256-m35u//UHO7uFtQ5mn/mVhNuJ1PCsuljgkD3Rmv3uuaE=",
}: let
  # Remove keys from attrsets whose value is null.
  removeNulls = set:
    removeAttrs set
    (lib.filter (name: set.${name} == null)
      (lib.attrNames set));
  # FIXME: https://github.com/NixOS/nixpkgs/pull/146274
  toRustTarget = platform:
    if platform.isWasi
    then "${platform.parsed.cpu.name}-wasi"
    else rust.toRustTarget platform;
  mkComponentSet = callPackage ./mk-component-set.nix {
    inherit toRustTarget removeNulls;
    # src =
  };
  mkAggregated = callPackage ./mk-aggregated.nix {};

  selComponents = mkComponentSet {
    inherit version;
    renames = {};
    platform = "x86_64-linux";
    srcs = {
      rustc = fetchurl {
        url = "https://github.com/esp-rs/rust-build/releases/download/v${version}/rust-${version}-x86_64-unknown-linux-gnu.tar.xz";
        hash = rustcHash;
      };
      rust-src = fetchurl {
        url = "https://github.com/esp-rs/rust-build/releases/download/v${version}/rust-src-${version}.tar.xz";
        hash = rustSrcHash;
      };
    };
  };
in
  assert stdenv.system == "x86_64-linux";
    mkAggregated {
      pname = "rust";
      date = "2024-07-02";
      inherit version;
      availableComponents = selComponents;
      selectedComponents = [selComponents.rustc selComponents.rust-src];
    }
