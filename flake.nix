{
  description = "Nix flake for packaging a Lambda layer";

  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in {
      packages = forAllSystems (system:
        (let
          prefix = "/opt/nix";
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                nix = prev.nixFlakes.override {
                  stateDir = "${prefix}/var";
                  storeDir = "${prefix}/store";
                };
              })
            ];
          };
        in rec {
          nix-prefixed = pkgs.nix;
          layer-contents = pkgs.symlinkJoin {
            name = "layer-contents";
            paths = [ pkgs.hello ];
          };
          layer = pkgs.runCommand "layer.zip" { } ''
            ln -s "${layer-contents}/bin" bin
            ${pkgs.zip}/bin/zip -o -X -y "$out" bin
            cd "${prefix}/.."
            cat "${pkgs.buildPackages.referencesByPopularity layer-contents}" | \
                xargs realpath --relative-to="$(pwd)" | \
                ${pkgs.zip}/bin/zip -o -X -r -@ "$out"
          '';
        }));
      defaultPackage = forAllSystems (system: self.packages.${system}.nix-prefixed);
    };
}
