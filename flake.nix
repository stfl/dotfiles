{
    description = "My Home Manager Flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixgl.url = "github:guibou/nixGL";
    };

    outputs = { nixpkgs, home-manager, nixgl, ... }: {
        # For `nix run .`
        defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

        homeConfigurations = {
            "stefan" = home-manager.lib.homeManagerConfiguration {
                # Note: I am sure this could be done better with flake-utils or something
                pkgs = import nixpkgs {
                    system = "x86_64-linux";
                    overlays = [ nixgl.overlay ];
                };

                modules = [
                    ./options.nix
                    ./home.nix
                ];
            };
            "slendl" = home-manager.lib.homeManagerConfiguration {
                # Note: I am sure this could be done better with flake-utils or something
                pkgs = import nixpkgs {
                    system = "x86_64-linux";
                    overlays = [ nixgl.overlay ];
                };

                modules = [
                    ./options.nix
                    ./home-slendl.nix
                ];
            };
        };
    };
}
