{pkgs, USER, ...}:
{
  imports = [
    ./nix.nix
    ./shell.nix
    ./autosuspend.nix
  ];

  nix.settings.trusted-users = [ USER ];

  # https://fzakaria.com/2025/02/26/nix-pragmatism-nix-ld-and-envfs
  programs.nix-ld = {
    enable = true;
    # put whatever libraries you think you might need
    # nix-ld includes a strong sane-default as well
    # in addition to these
    libraries = with pkgs; [
      # stdenv.cc.cc.lib
      # zlib
    ];
  };

  services = {
    envfs = {
      enable = true;
    };
  };
}
