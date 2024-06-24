{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.steam = {
    enable = true;
    # gameScopeSession.enable = true;
    extraPackages = with pkgs; [
      # gamescope
      # gamemode
      mangohud
      # openssl_1_1
    ];
  };

  programs.gamemode.enable = true;
  # programs.gamemode.settings.general.inhibit_screensaver = 0;

  # packages = with pkgs; [
  # steam-run
  # mangohud
  # ];
}
