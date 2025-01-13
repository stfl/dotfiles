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
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixgl,
    emacs-overlay,
    agenix,
    nixos-hardware,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    USER = "stefan";

    mkStandaloneHomeConfig = username: homeModule: system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "${system}";
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "freeimage-unstable-2021-11-01"
            ];
          };
        };
        modules = [
          {
            home = {
              inherit username;
              homeDirectory = "/home/${username}";
              stateVersion = "23.11";
            };
          }
          {
            nixpkgs.overlays = [
              nixgl.overlay
              emacs-overlay.overlays.default
            ];
          }
          ./modules/home/common.nix
          homeModule
        ];
      };
  in rec {
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    homeConfigurations = {
      "stefan@amsel" = mkStandaloneHomeConfig "stefan" ./hosts/amsel/home.nix "${system}";
      "slendl@leah" = mkStandaloneHomeConfig "slendl" ./hosts/leah/home.nix "${system}";
    };

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
        modules = [./hosts/pirol];
      };
    };

    iso = nixosConfigurations.iso.config.system.build.isoImage;
  };
}
