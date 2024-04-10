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
  };

  wayland.windowManager.sway.extraOptions = lib.mkForce [
    "--verbose"
    "--debug"
    "--unsupported-gpu"
  ];
}
