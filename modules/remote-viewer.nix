{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    remmina
    rustdesk-flutter
    # teamviewer
  ];
}
