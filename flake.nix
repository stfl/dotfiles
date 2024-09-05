{
  description = "My Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
    emacs-lsp-booster = {
      url = "github:slotThe/emacs-lsp-booster-flake";
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
    emacs-lsp-booster,
    agenix,
    nixos-hardware,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
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
              emacs-lsp-booster.overlays.default
            ];
          }
          ./modules/home/common.nix
          homeModule
        ];
      };
  in {
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    homeConfigurations = {
      "stefan@amsel" = mkStandaloneHomeConfig "stefan" ./hosts/amsel/home.nix "${system}";
      "slendl@leah" = mkStandaloneHomeConfig "slendl" ./hosts/leah/home.nix "${system}";
    };

    nixosConfigurations = {
      nixos-vm = lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          ./modules
          ./hosts/nixos-vm
        ];
      };
      kondor = lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          ./modules
          ./hosts/kondor
        ];
      };
      falke = lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          ./modules
          ./hosts/falke
          agenix.nixosModules.default
          {environment.systemPackages = [agenix.packages.${system}.default];}
        ];
      };
    };
  };
}
