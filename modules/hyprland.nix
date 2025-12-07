{ config, lib, pkgs, USER, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM  = true;
  };

  home-manager.users.${USER} =
{ config, lib, pkgs, ... }:

{

  wayland.windowManager.hyprland = {
    enable = true;
    # # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;
    systemd = {
      enable = false; # conflicts with UWSM
      # enable = true;
      # variables = ["--all"];
    };
    settings = {
      "$mod" = "SUPER";
      bind =
        [
          # "$mod, F, exec, firefox"
          # ", Print, exec, grimblast copy area"
        ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
        )
          9)
      );
    };
  };
}
;
}
