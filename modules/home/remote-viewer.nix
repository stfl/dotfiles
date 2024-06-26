{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    rustdesk-flutter
  ];

  services.remmina = {
    enable = true;
  };
}
