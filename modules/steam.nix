{
  pkgs,
  USER,
  ...
}: {
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    gamemode = {
      enable = true;
      enableRenice = true;
      settings.general.renice = 10;
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

  users.users.${USER}.extraGroups = ["gamemode"];

  home-manager.users.${USER} = {
    programs.mangohud.enable = true;
  };
}
