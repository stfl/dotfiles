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
      steamtinkerlaunch
      # openssl_1_1
    ];
  };

  programs.gamemode.enable = true;
  # programs.gamemode.settings.general.inhibit_screensaver = 0;

  # packages = with pkgs; [
  # win64
  # wine64Packages.waylandFull
  # ];
}
