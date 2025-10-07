{
  description = "NixOS configuration for my machines";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.1";
    systems.url = "github:nix-systems/x86_64-linux";
    flake-utils.url = "https://flakehub.com/f/numtide/flake-utils/*";
    nixos-hardware.url = "https://flakehub.com/f/NixOS/nixos-hardware/*";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    fenix.url = "https://flakehub.com/f/nix-community/fenix/*";
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      determinate,
      nixgl,
      emacs-overlay,
      fenix,
      agenix,
      nixos-hardware,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      USER = "stefan";
    in
    rec {
      # defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
      packages.x86_64-linux.default = fenix.packages.x86_64-linux.default.toolchain;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
      homeConfigurations = { };

      nixosConfigurations = {
        iso = lib.nixosSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./modules/iso.nix
          ];
        };

        kondor = lib.nixosSystem {
          inherit system;
          specialArgs = inputs // {
            inherit USER;
          };
          modules = [
            ./hosts/kondor
          ];
        };

        pirol = lib.nixosSystem {
          inherit system;
          specialArgs = inputs // {
            inherit USER;
          };
          modules = [
            ./hosts/pirol
            # ({pkgs, ...}: {
            #   nixpkgs.overlays = [fenix.overlays.default];
            #   environment.systemPackages = with pkgs; [
            #     (pkgs.fenix.complete.withComponents [
            #       "cargo"
            #       "clippy"
            #       "rust-src"
            #       "rustc"
            #       "rustfmt"
            #     ])
            #     rust-analyzer-nightly
            #   ];
            # })
          ];
        };
      };

      iso = nixosConfigurations.iso.config.system.build.isoImage;
    };
}
