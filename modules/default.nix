{
  config,
  lib,
  pkgs,
  emacs-lsp-booster,
  emacs-overlay,
  home-manager,
  ...
}: {
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
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
      emacs-lsp-booster.overlays.default
      emacs-overlay.overlays.emacs
    ];
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  environment.systemPackages = with pkgs; [
    wget
    dig
    git
    neovim
    htop
    killall
    rsync
    mtr
  ];
}
