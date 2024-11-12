{
  config,
  lib,
  pkgs,
  ...
}: let
  office_rotated_output = "Dell Inc. DELL U2518D 3C4YP8AV547L";
  office_center_output = "Dell Inc. DELL U2518D 3C4YP8AV590L";
  home_beamer_output = "Sanyo Electric Co.,Ltd. SANYO Z3000 0x01010101";
  home_receiver_output = "Yamaha Corporation RX-V765 Unknown";
  home_output = "HannStar Display Corp HC284UFB Unknown";
  builtin_output = "eDP-1";
in {
  imports = [
    ../../modules/home
    ../../modules/home/desktop.nix
    ../../modules/home/emacs.nix
    ../../modules/home/pass.nix
    ../../modules/home/dj.nix
    ../../modules/home/remote-viewer.nix
  ];

  home.packages = with pkgs; [
    nvtopPackages.intel
  ];

  programs.waybar.settings.mainBar = {
    temperature.hwmon-path = "/sys/class/hwmon/hwmon4/temp1_input";
  };

  # NOTE swaymsg -t get_outputs
  services.kanshi = {
    enable = true;
    settings =
      [
        {
          output.criteria = builtin_output;
          output.alias = "builtin";
          output.scale = 1.0;
        }
        {
          output.criteria = office_rotated_output;
          output.transform = "90";
          output.alias = "rotated";
          output.scale = 1.0;
        }
        {
          output.criteria = office_center_output;
          output.transform = "normal";
          output.alias = "center";
          output.scale = 1.0;
        }
        {
          output.criteria = home_output;
          output.transform = "normal";
          output.alias = "hannstar";
          output.scale = 1.2;
          # output.resolution =  TODO
        }
        {
          output.criteria = home_beamer_output;
          output.alias = "beamer";
          output.scale = 1.4;
        }
        {
          output.criteria = home_receiver_output;
          output.alias = "receiver";
          output.scale = 1.4;
        }
      ]
      ++
      # Notify on all profiles being applied
      (
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
          profile.name = "standalone";
          profile.outputs = [
            {
              criteria = "$builtin";
              position = "0,0";
            }
          ];
        }
        {
          profile.name = "3datax";
          profile.outputs = [
            {
              criteria = "$builtin";
              position = "0,0";
            }
            {
              criteria = "$rotated";
              position = "1920,0";
            }
            {
              criteria = "$center";
              position = "3360,0";
            }
          ];
        }
        {
          profile.name = "3datax_half";
          profile.outputs = [
            {
              criteria = "$builtin";
              position = "0,0";
            }
            {
              criteria = "$rotated";
              position = "1920,0";
            }
          ];
        }
        {
          profile.name = "home";
          profile.outputs = [
            {
              criteria = "$builtin";
              position = "0,600";
            }
            {
              criteria = "$hannstar";
              position = "1920,0";
            }
          ];
        }
        {
          profile.name = "home_beamer";
          profile.outputs = [
            {
              criteria = "$builtin";
              position = "0,600";
            }
            {
              criteria = "$hannstar";
              position = "1920,0";
            }
            {
              criteria = "$beamer";
              position = "5122,0";
            }
          ];
        }
        {
          profile.name = "home_receiver";
          profile.outputs = [
            {
              criteria = "$builtin";
              position = "0,600";
            }
            {
              criteria = "$hannstar";
              position = "1920,0";
            }
            {
              criteria = "$receiver";
              position = "5122,0";
            }
          ];
        }
      ];
  };

  wayland.windowManager.sway.config.workspaceOutputAssign =
    # Worksapces 1-3 are always preferred to the external output
    # In the office, the center output is preferred
    (map (x: {
      workspace = toString x;
      output = [
        home_output
        office_center_output
        office_rotated_output
        builtin_output
      ];
    }) (lib.lists.range 1 3))
    ++
    # Workspace 4-7 In the office, the rotated output is preferred
    (map (x: {
      workspace = toString x;
      output = [
        home_output
        office_rotated_output
        office_center_output
        builtin_output
      ];
    }) (lib.lists.range 4 7))
    ++ [
      # Workspace 8 is preferred to the beamer output
      {
        workspace = "8";
        output = [
          home_beamer_output
          home_receiver_output
          home_output
          office_rotated_output
          office_center_output
          builtin_output
        ];
      }
    ]
    ++
    # Workspace 9-10 prefers the builtin output
    (map (ws: {
      workspace = toString ws;
      output = [
        builtin_output
        home_output
        office_center_output
        office_rotated_output
      ];
    }) ["9" "0"]);

  programs.git.includes = [
    {
      # apply updated git configuration for every repo inside ~/work/proxmox/<repo>
      condition = "gitdir:${config.home.homeDirectory}/work/3datax/";
      contents = {
        init.defaultBranch = "master";
        user.email = "stefan.lendl@3datax.com";
      };
    }
  ];
}
