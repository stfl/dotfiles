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

  xdg.portal.wlr.enable = true;
  xdg.portal.config.common.default = "*"; # use the first available portal
}
