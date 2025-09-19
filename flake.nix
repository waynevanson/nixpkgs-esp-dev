{
  description = "Rust toolchains";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        tests =
          builtins.map (
            case: let
              rust = import ./pkgs/rust {
                inherit (pkgs) rust callPackage lib stdenv fetchurl;
                inherit (case.rust) version rustcHash rustSrcHash;
              };
              llvm = pkgs.callPackage ./pkgs/llvm.nix {
                version = case.llvm.version;
                hash = case.llvm.llvmHash;
              };
              libllvm = pkgs.callPackage ./pkgs/libllvm.nix {
                version = case.llvm.version;
                hash = case.llvm.libllvmHash;
              };
            in {
              name = "${case.rust.version}-${case.llvm.version}";
              value = pkgs.mkShell {buildInputs = [rust llvm libllvm];};
            }
          )
          [
            {
              rust = {
                version = "1.88.0.0";
                rustcHash = "sha256-dFNJFHSl9yiyRIFlHUPLzq+S9438q+fLiCxr8h/uBQU=";
                rustSrcHash = "sha256-m35u//UHO7uFtQ5mn/mVhNuJ1PCsuljgkD3Rmv3uuaE=";
              };

              llvm = {
                version = "18.1.2_20240815";
                llvmHash = "sha256-TXcRjte97bTskPqoS4RzbXapYmEY2z0k+hO62+tXJ+8=";
                libllvmHash = "sha256-x22RE9UMGSInHRB8npcfeDEBJ5UdAqAS4QwKvRdWJ6s=";
              };
            }
            {
              rust = {
                version = "1.89.0.0";
                rustcHash = "sha256-tylP1bsGi+U+ByXHFwAycZGFkWy6G5tXUs/+mrq1hXA=";
                rustSrcHash = "sha256-3Xo1U7fkmtJVWfGCh394Chbet+TBCMo7evxcFeUa7iM=";
              };
              llvm = {
                version = "20.1.1_20250829";
                llvmHash = "sha256-iJEMITUMBqUh8kMwTRo629t4RHEjs/jidJOqt148wH8=";
                libllvmHash = "sha256-ASjiqGsmLj7fzgJgNO3gfi9FcysQxsuKxSLI9Mcr79g=";
              };
            }
          ];
      in {
        packages = {
          llvm = pkgs.callPackage ./pkgs/llvm.nix {};
          libllvm = pkgs.callPackage ./pkgs/libllvm.nix {};
          rust = import ./pkgs/rust {inherit (pkgs) rust callPackage lib stdenv fetchurl;};
        };
        checks = builtins.listToAttrs tests;
      }
    );
}
