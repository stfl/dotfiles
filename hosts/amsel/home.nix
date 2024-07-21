{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  nixGL = import ../../modules/home/nixGL.nix {inherit pkgs config;};
in {
  imports = [
    ../../modules/home/desktop.nix
    ../../modules/home/emacs.nix
    ../../modules/home/pass.nix
    ../../modules/home/dj.nix
    ../../modules/home/syncthing.nix
  ];

  targets.genericLinux.enable = true;
  systemd.user.startServices = "sd-switch";

  nixGLPrefix = getExe pkgs.nixgl.nixGLIntel;

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    nvtopPackages.intel

    (nixGL calibre)

    # -- rust
    # rustup
    yarn
  ];

  programs.waybar.settings.mainBar = {
    network.on-click = "nm-connection-editor";
    backlight.on-scroll-down = mkForce "brightnessctl s 10%-";
    backlight.on-scroll-up = mkForce "brightnessctl s 10%+";
  };

  wayland.windowManager.sway.config.keybindings = mkOptionDefault {
    "XF86MonBrightnessDown" = mkForce "exec --no-startup-id brightnessctl s 10%-";
    "XF86MonBrightnessUp" = mkForce "exec --no-startup-id brightnessctl s 10%+";
  };
}
