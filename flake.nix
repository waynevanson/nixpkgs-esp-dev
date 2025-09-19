{
  description = "Rust toolchains";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        packages = {
          llvm = pkgs.callPackage ./pkgs/llvm.nix {};
          libllvm = pkgs.callPackage ./pkgs/libllvm.nix {};
          rust = import ./pkgs/rust {inherit (pkgs) rust callPackage lib stdenv fetchurl;};
        };
        checks = {
          default = pkgs.mkShell {
            buildInputs = builtins.attrValues self.packages.${system};
          };
        };
      }
    );
}
