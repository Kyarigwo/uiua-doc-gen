{
  description = "A command line tool to document Uiua libraries";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, crane, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        craneLib = crane.mkLib pkgs;
        commonArgs = {
          src = ./.;
        };
        cargoArtifacts = craneLib.buildDepsOnly commonArgs;
      in
    {
      packages.default = craneLib.buildPackage commonArgs // {
        inherit cargoArtifacts;

        # Add extra inputs here or any other derivation settings
        # doCheck = true;
        # buildInputs = [];
        # nativeBuildInputs = [];
      };
      devShells.default = pkgs.mkShell {
        inputsFrom = builtins.attrValues self.packages.${system};
        packages = with pkgs; [
          clippy
          rust-analyzer
          rustfmt
          cargo
          rustc
        ];
      };
    });
}
