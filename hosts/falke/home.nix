{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  imports = [
    ../../modules/home
    ../../modules/home/emacs.nix
    ../../modules/home/pass.nix
  ];

  home.packages = with pkgs; [
    nvtopPackages.intel

    transmission-gtk
  ];

  programs.waybar.settings.mainBar = {
    temperature.hwmon-path = "/sys/class/hwmon/hwmon4/temp1_input";
  };

  services.kanshi = {
    enable = true;
    profiles = {
      standalone.outputs = [
        {criteria = "eDP-1";}
      ];
      "3datax" = {
        outputs = [
          {
            criteria = "eDP-1";
            position = "0,0";
          }
          {
            criteria = "Dell Inc. DELL U2518D 3C4YP8AV547L";
            position = "1920,0";
            transform = "90";
          }
          {
            criteria = "Dell Inc. DELL U2518D 3C4YP8AV590L";
            position = "3360,0";
            transform = "normal";
          }
        ];
      };
      "3datax_half" = {
        outputs = [
          {
            criteria = "eDP-1";
            position = "0,0";
          }
          {
            criteria = "Dell Inc. DELL U2518D 3C4YP8AV547L";
            position = "1920,0";
            transform = "90";
          }
        ];
      };
      magazin_hdmi = {
        outputs = [
          {
            criteria = "eDP-1";
            # position = "0,2160";
            position = "0,1801"; # 1.2 scaling
          }
          {
            # criteria = "HannStar*HC284UFB*";
            criteria = "HDMI-A-1";
            position = "0,0";
            scale = 1.2;
          }
        ];
      };
    };
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
