{
  config,
  lib,
  pkgs,
  ...
}: {
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    qt5.qtwayland
    wayland-utils
    wlr-protocols
  ];
}
