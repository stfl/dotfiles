{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  # main_out = "HannStar Display Corp HC284UFB";
  main_out = "Samsung Electronic Complany Odyssey G91F";
  # beamer = "Sanyo Electric Co.,Ltd. SANYO Z3000";
  beamer = "Sanyo Electric Co.Ltd. SANYO Z3000";
  receiver = "Yamaha Corporation RX-V4A";
in
{
  imports = [
    ../../modules/home/shell.nix
    ../../modules/home/emacs.nix
    ../../modules/home/pass.nix
  ];

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    nvtopPackages.amd
  ];

  # Hyprland monitor and workspace configuration (replaces kanshi)
  wayland.windowManager.hyprland.settings = {
    monitor = [
      # Main monitor - primary display
      "desc:${main_out}, preferred, auto, 1"
      # Beamer - positioned to the right of main monitor (1.5 scale - Hyprland doesn't support 1.4)
      "desc:${beamer}, preferred, auto-right, 1"
      # Receiver - disabled by default
      "desc:${receiver}, disable"
    ];

    workspace = [
      # Workspaces 8 and 9 preferred to beamer output
      "8, monitor:${beamer}, default:true"
      "9, monitor:${beamer}, default:true"
      # All other workspaces preferred to main monitor
      "1, monitor:${main_out}"
      "2, monitor:${main_out}"
      "3, monitor:${main_out}"
      "4, monitor:${main_out}"
      "5, monitor:${main_out}"
      "6, monitor:${main_out}"
      "7, monitor:${main_out}"
      "10, monitor:${main_out}"
    ];
  };
}
