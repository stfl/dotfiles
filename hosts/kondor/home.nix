{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  home_beamer_output = "Sanyo Electric Co.,Ltd. SANYO Z3000 0x01010101";
  home_receiver_output = "Yamaha Corporation RX-V4A Unknown";
  home_output = "HannStar Display Corp HC284UFB Unknown";
in {
  imports = [
    ../../modules/home/emacs.nix
    ../../modules/home/pass.nix
  ];

  home.packages = with pkgs; [
    nvtopPackages.amd
  ];

  programs.fancontrol-gui.enable = true;

  services.kanshi = {
    enable = true;
    settings =
      [
        {
          output.criteria = home_output;
          output.transform = "normal";
          output.alias = "hannstar";
          output.scale = 1.0;
          output.status = "enable";
        }
        {
          output.criteria = home_beamer_output;
          output.alias = "beamer";
          output.scale = 1.4;
          output.status = "enable";
        }
        {
          output.criteria = home_receiver_output;
          output.alias = "receiver";
          output.scale = 1.4;
          output.status = "disable";
        }
      ]
      ++ (
        map (profile:
          profile
          // {
            profile =
              profile.profile
              // {
                exec =
                  (profile.profile.exec or [])
                  ++ [
                    "${pkgs.libnotify}/bin/notify-send --expire-time=5000 \"Kanshi\" \"Profile ${profile.profile.name} applied\""
                  ];
              };
          })
      )
      [
        {
          profile.name = "home";
          profile.outputs = [
            {
              criteria = "$hannstar";
              position = "0,0";
            }
          ];
        }
        {
          profile.name = "home_beamer";
          profile.outputs = [
            {
              criteria = "$hannstar";
              position = "0,0";
            }
            {
              criteria = "$beamer";
              position = "3840,0";
            }
          ];
        }
        {
          profile.name = "home_receiver";
          profile.outputs = [
            {
              criteria = "$hannstar";
              position = "0,0";
            }
            {
              criteria = "$receiver";
            }
          ];
        }
      ];
  };

  wayland.windowManager.sway.config.workspaceOutputAssign =
    # Worksapces 1-7 and 9, 0 are always preferred to the external output
    (map (x: {
      workspace = toString x;
      output = [home_output];
    }) (lib.lists.range 1 7 ++ [9 0]))
    # Workspace 8 is preferred to the beamer output
    ++ [
      {
        workspace = "8";
        output = [
          home_beamer_output
          home_receiver_output
          home_output
        ];
      }
    ];
}
