{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
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
    settings = let
      office_rotated_output = "Dell Inc. DELL U2518D 3C4YP8AV547L";
      office_center_output = "Dell Inc. DELL U2518D 3C4YP8AV590L";
      home_beamer_output = "Sanyo Electric Co.,Ltd. SANYO Z3000 0x01010101";
      home_receiver_output = "Yamaha Corporation RX-V765 Unknown";
      home_output = "HannStar Display Corp HC284UFB Unknown";
      swaymsg = "${pkgs.sway}/bin/swaymsg";
    in [
      {
        output.criteria = "eDP-1";
        output.alias = "builtin";
        output.scale = 1.;
      }
      {
        output.criteria = "${office_rotated_output}";
        output.transform = "90";
        output.alias = "rotated";
        output.scale = 1.;
      }
      {
        output.criteria = "${office_center_output}";
        output.transform = "normal";
        output.alias = "center";
        output.scale = 1.;
      }
      {
        output.criteria = "${home_output}";
        output.transform = "normal";
        output.alias = "hannstar";
        output.scale = 1.2;
        # output.resolution =  TODO
      }
      {
        output.criteria = "${home_beamer_output}";
        output.alias = "beamer";
        output.scale = 1.4;
      }
      {
        output.criteria = "${home_receiver_output}";
        output.alias = "receiver";
        output.scale = 1.4;
      }

      {
        profile.name = "standalone";
        profile.outputs = [
          {
            criteria = "$builtin";
            position = "0,0";
          }
        ];
        profile.exec = [
          "${pkgs.libnotify}/bin/notify-send --expire-time=5000 \"Kanshi\" \"Profile standalone applied\""
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
        profile.exec = [
          "${swaymsg} workspace 1,  move workspace to output '\"${office_center_output}\"'"
          "${swaymsg} workspace 2,  move workspace to output '\"${office_center_output}\"'"
          "${swaymsg} workspace 3,  move workspace to output '\"${office_center_output}\"'"

          "${swaymsg} workspace 4,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 5,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 6,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 7,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 8,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 9,  move workspace to eDP-1"
          "${swaymsg} workspace 10, move workspace to eDP-1"
          "${pkgs.libnotify}/bin/notify-send --expire-time=5000 \"Kanshi\" \"Profile 3datax applied\""
          # TODO reload waybar
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
        profile.exec = [
          "${swaymsg} workspace 1,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 2,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 3,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 4,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 5,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 6,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 7,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 8,  move workspace to output '\"${office_rotated_output}\"'"
          "${swaymsg} workspace 9,  move workspace to eDP-1"
          "${swaymsg} workspace 10, move workspace to eDP-1"
          "${pkgs.libnotify}/bin/notify-send --expire-time=5000 \"Kanshi\" \"Profile 3datax_half applied\""
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
            position = "5122,1029";
          }
        ];
        profile.exec = [
          # "/bin/sh -c \"
          #   visible=$(jq -r '.[] | select(.visible == true and .focused == false) | .name')
          #   focused=$(jq -r '.[] | select(.focused == true) | .name')

          #   ${swaymsg} workspace 1,  move workspace to output '${home_output}'
          #   ${swaymsg} workspace 2,  move workspace to output '${home_output}'
          #   ${swaymsg} workspace 3,  move workspace to output '${home_output}'
          #   ${swaymsg} workspace 4,  move workspace to output '${home_output}'
          #   ${swaymsg} workspace 5,  move workspace to output '${home_output}'
          #   ${swaymsg} workspace 6,  move workspace to output '${home_output}'
          #   ${swaymsg} workspace 7,  move workspace to output '${home_output}'

          #   ${swaymsg} workspace 8,  move workspace to output '${home_beamer}'
          #   ${swaymsg} workspace 9,  move workspace to eDP-1
          #   ${swaymsg} workspace 10, move workspace to eDP-1

          #   for ws in $visible; do echo $ws; ${swaymsg} workspace $ws; done
          #   ${swaymsg} workspace $focused

          #   ${pkgs.libnotify}/bin/notify-send --expire-time=5000 \\\"Kanshi\\\" \\\"Profile home_beamer applied\\\"
          # \""

          # "mkdir -p /tmp/kanshi"
          # "${swaymsg} -t get_workspaces --raw | jq -r '.[] | select(.visible == true and .focused == false) | .name ' >| /tmp/kanshi/visible_workspaces"
          # "${swaymsg} -t get_workspaces --raw | jq -r '.[] | select(.focused == true) | .name ' >| /tmp/kanshi/focused_workspace"

          "${swaymsg} workspace 1,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 2,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 3,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 4,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 5,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 6,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 7,  move workspace to output '\"${home_output}\"'"

          "${swaymsg} workspace 8,  move workspace to output '\"${home_beamer_output}\"'"
          "${swaymsg} workspace 9,  move workspace to eDP-1"
          "${swaymsg} workspace 10, move workspace to eDP-1"

          # "for ws in `cat /tmp/kanshi/visible_workspaces`; do echo $ws; ${swaymsg} workspace $ws; done"
          # "${swaymsg} workspace `cat /tmp/kanshi/visible_workspaces`"
          # "rm -f /tmp/kanshi/visible_workspaces /tmp/kanshi/focused_workspace"

          "${pkgs.libnotify}/bin/notify-send --expire-time=5000 \"Kanshi\" \"Profile home_beamer applied\""
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
            position = "5122,1029";
          }
        ];
        profile.exec = [
          "${swaymsg} workspace 1,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 2,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 3,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 4,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 5,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 6,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 7,  move workspace to output '\"${home_output}\"'"
          "${swaymsg} workspace 8,  move workspace to output '\"${home_output}\"'"

          "${swaymsg} workspace 9,  move workspace to eDP-1"
          "${swaymsg} workspace 10, move workspace to eDP-1"

          "${pkgs.libnotify}/bin/notify-send --expire-time=5000 \"Kanshi\" \"Profile home_receiver applied\""
        ];
      }
    ];
  };

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
