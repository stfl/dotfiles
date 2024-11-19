{
  pkgs,
  emacs-overlay,
  ...
}: {
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      substituters = [
        "https://stfl-dotfiles.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "stfl-dotfiles.cachix.org-1:ey4Zr5BgT0cUbmMZ+pWlmA51e795UfMvv37/L2ATp0s="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      # allowBroken = true;
      permittedInsecurePackages = [
        "freeimage-unstable-2021-11-01"
      ];
    };
    overlays = [
      emacs-overlay.overlays.default
    ];
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  # get completion for system packages
  environment.pathsToLink = [
    "/share/zsh"
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  environment.systemPackages = with pkgs; [
    wget
    dig
    git
    neovim
    htop
    killall
    rsync
    cachix
  ];

  programs.mtr.enable = true;
}
