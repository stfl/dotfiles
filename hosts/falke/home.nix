{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  imports = [
    ../../modules/home/common.nix
    ../../modules/home/desktop.nix
    ../../modules/home/emacs.nix
    ../../modules/home/pass.nix
  ];

  home.packages = with pkgs; [
    nvtopPackages.intel
  ];

  programs.waybar.settings.mainBar = {
    network.on-click = "nm-connection-editor";
    temperature.hwmon-path = "/sys/class/hwmon/hwmon4/temp1_input";
  };

  services.kanshi = {
    enable = true;
    profiles = {
      standalone.outputs = [
        {criteria = "eDP-1";}
      ];
      docked_3datax = {
        outputs = [
          {criteria = "eDP-1";}
          {criteria = "DP-6";}
          {
            criteria = "DP-7";
            transform = "90";
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
