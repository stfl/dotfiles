{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.steam = {
    enable = true;
  };

  # packages = with pkgs; [
  #   steam-run
  # ];
}
