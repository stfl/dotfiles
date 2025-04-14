{
  config,
  lib,
  pkgs,
  USER,
  ...
}: {
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      extraPackages = with pkgs; [
        gamescope-wsi
        # gamescope
        # gamemode
        mangohud
        steamtinkerlaunch

        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
    };
  };

  home-manager.users.${USER} = {
    programs.mangohud.enable = true;
  };
}
