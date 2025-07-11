{
  description = "My Home Manager Flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/x86_64-linux";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
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
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # home-manager fancontrol module
    fancontrol-gui = {
      url = "github:Maldela/fancontrol-gui";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixgl,
    emacs-overlay,
    fenix,
    agenix,
    nixos-hardware,
    fancontrol-gui,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    USER = "stefan";
  in rec {
    # defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    packages.x86_64-linux.default = fenix.packages.x86_64-linux.default.toolchain;
    homeConfigurations = {};

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
        specialArgs = inputs // {inherit USER;};
        modules = [./hosts/kondor];
      };

      pirol = lib.nixosSystem {
        inherit system;
        specialArgs = inputs // {inherit USER;};
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
