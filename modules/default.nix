{
  pkgs,
  emacs-overlay,
  USER,
  ...
}: {
  imports = [
    ./shell.nix
  ];

  nix = {
    package = pkgs.nixVersions.stable;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      download-buffer-size = 268435456; # 256 MiB
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = ["root" "${USER}"];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
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
}
