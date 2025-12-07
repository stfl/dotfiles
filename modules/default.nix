{
  pkgs,
  determinate,
  emacs-overlay,
  USER,
  ...
}:
{
  imports = [
    ./shell.nix
    determinate.nixosModules.default
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      download-buffer-size = 268435456; # 256 MiB
      lazy-trees = true;
      eval-cores = 0; # use all available cores
      substituters = [
        "https://install.determinate.systems"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
      ];
      trusted-substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      trusted-users = [
        "root"
        "${USER}"
      ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
      ];
    };
    overlays = [
      emacs-overlay.overlays.default
    ];
  };

  # https://fzakaria.com/2025/02/26/nix-pragmatism-nix-ld-and-envfs
  programs = {
    nix-ld = {
      enable = true;
      # put whatever libraries you think you might need
      # nix-ld includes a strong sane-default as well
      # in addition to these
      libraries = with pkgs; [
        # stdenv.cc.cc.lib
        # zlib
      ];
    };
  };

  services = {
    envfs = {
      enable = true;
    };
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };
}
