{
  description = "IaC using Nix";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    poetry2nix,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ]
    (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        inherit (poetry2nix.legacyPackages.${system}) mkPoetryEnv;
        poetryEnv = mkPoetryEnv {
          projectDir = ./.;
        };
      in {
        devShells.default = with pkgs;
          mkShell {
            nativeBuildInputs = [
              poetryEnv
              poetry
            ];
            shellHook = ''
              pre-commit install --install-hooks
            '';
          };
      }
    );
}
