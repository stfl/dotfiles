{
  pkgs,
  USER,
  ...
}: {
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--adaptive-sync"
        # "--hdr-enabled"
        "--rt"
        "--mangoapp"
      ];
    };
    gamemode = {
      enable = true;
      enableRenice = true;
      settings.general.renice = 20;
    };
    steam = {
      enable = true;
      gamescopeSession = {
        # to launch with `steam-gamescope``
        enable = true;
        args = [
          "--adaptive-sync"
          "--rt"
          "--mangoapp"

          "--borderless"
          "--scale-to-output 1.0"
          "--scale-to-window 1.0"
          "--session-name steam"

          # todo make this output dependent or something
          # "-W 3840"
          # "-H 2160"
        ];
      };
      extraPackages = with pkgs; [
        gamescope-wsi
        gamemode
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
