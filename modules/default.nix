{
  pkgs,
  determinate,
  emacs-overlay,
  USER,
  ...
}: {
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
      substituters = [
        "https://install.determinate.systems"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = ["root" "${USER}"];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "libxml2-2.13.8"
        "libsoup-2.74.3"
        "qtwebengine-5.15.19"
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
