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

    outputs = { nixpkgs, home-manager, nixgl, emacs-lsp-booster, ... }:
        # For `nix run .`
        let my-overlays = {
                nixpkgs.overlays = [
                    nixgl.overlay
                    emacs-lsp-booster.overlays.default
                ];
            };
            my-pkgs = import nixpkgs {
                system = "x86_64-linux";
                config.allowUnfree = true;
            };
        in {
            defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

            homeConfigurations = {
                "stefan" = home-manager.lib.homeManagerConfiguration {
                    # Note: I am sure this could be done better with flake-utils or something
                    pkgs = my-pkgs;
                    modules = [
                        ./options.nix
                        ./home-slendl.nix
                        my-overlays
                        emacs-lsp-booster
                    ];
                };
                "slendl" = home-manager.lib.homeManagerConfiguration {
                    pkgs = my-pkgs;
                    modules = [
                        ./options.nix
                        ./home-slendl.nix
                        my-overlays
                        # emacs-lsp-booster
                    ];
                };
            };
        };
}
