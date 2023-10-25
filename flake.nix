{
  description = "nakamoto: a Privacy-preserving Bitcoin light-client implementation in Rust";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, crane, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        craneLib = crane.lib.${system};
        nakamoto = craneLib.buildPackage {
          src = craneLib.cleanCargoSource (craneLib.path ./.);
          strictDeps = true;
          doCheck = false;

          buildInputs = [
            pkgs.pkg-config
            pkgs.libusb1
            pkgs.libiconv
          ];
        };
      in
      {
        checks = {
          inherit nakamoto;
        };

        packages.default = nakamoto;

        apps.default = flake-utils.lib.mkApp {
          drv = nakamoto;
        };

        devShells.default = craneLib.devShell {
          checks = self.checks.${system};

          packages = [];
        };
      });
}
