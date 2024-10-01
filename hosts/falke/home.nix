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

  services.kanshi = {
    enable = true;
    settings = let
      rotated_output = "Dell Inc. DELL U2518D 3C4YP8AV547L";
      center_output = "Dell Inc. DELL U2518D 3C4YP8AV590L";
    in [
      {
        output.criteria = "eDP-1";
        output.alias = "builtin";
      }
      {
        output.criteria = "${rotated_output}";
        output.transform = "90";
        output.alias = "rotated";
      }
      {
        output.criteria = "${center_output}";
        output.transform = "normal";
        output.alias = "center";
      }
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
        profile.exec = [
          "${pkgs.sway}/bin/swaymsg workspace 1,  move workspace to eDP-1"
          "${pkgs.sway}/bin/swaymsg workspace 2,  move workspace to eDP-1"
          "${pkgs.sway}/bin/swaymsg workspace 3,  move workspace to output '\"${rotated_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 4,  move workspace to output '\"${rotated_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 5,  move workspace to output '\"${center_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 6,  move workspace to output '\"${center_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 7,  move workspace to output '\"${center_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 8,  move workspace to output '\"${center_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 9,  move workspace to output '\"${center_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 10, move workspace to output '\"${center_output}\"'"
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
          "${pkgs.sway}/bin/swaymsg workspace 1,  move workspace to eDP-1"
          "${pkgs.sway}/bin/swaymsg workspace 2,  move workspace to eDP-1"
          "${pkgs.sway}/bin/swaymsg workspace 3,  move workspace to output '\"${rotated_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 4,  move workspace to output '\"${rotated_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 5,  move workspace to output '\"${rotated_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 6,  move workspace to output '\"${rotated_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 7,  move workspace to output '\"${rotated_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 8,  move workspace to output '\"${rotated_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 9,  move workspace to output '\"${rotated_output}\"'"
          "${pkgs.sway}/bin/swaymsg workspace 10, move workspace to output '\"${rotated_output}\"'"
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
