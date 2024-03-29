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
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    emacs-lsp-booster = {
      url = "github:slotThe/emacs-lsp-booster-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixgl,
    emacs-lsp-booster,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    mkHomeConfig = username: machineModule: system:
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
          ./modules/common.nix
          machineModule
        ];
      };
  in {
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    homeConfigurations = {
      "stefan@amsel" = mkHomeConfig "stefan" ./machine/amsel.nix "x86_64-linux";
      "slendl@leah" = mkHomeConfig "slendl" ./machine/leah.nix "x86_64-linux";
    };

    nixosConfigurations = {
      nixos-vm = lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/nixos-vm
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.stefan = {
              home.stateVersion = "23.11";
              imports = [
                ./modules/common.nix
                ./machine/nixos-vm.nix
              ];
            };
          }
        ];
      };
    };
  };
}
