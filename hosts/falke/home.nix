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
    settings = [
      {
        output.criteria = "eDP-1";
        output.alias = "builtin";
      }
      {
        output.criteria = "Dell Inc. DELL U2518D 3C4YP8AV547L";
        output.transform = "90";
        output.alias = "rotated";
      }
      {
        output.criteria = "Dell Inc. DELL U2518D 3C4YP8AV590L";
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
