{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  imports = [
    ../../modules/home/desktop.nix
    ../../modules/home/emacs.nix
    ../../modules/home/pass.nix
  ];

  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    nvtop-intel

    mixxx

    # -- rust
    # rustup

    # downloader
    spotdl
    yt-dlp
  ];

  programs.waybar.settings.mainBar = {
    network.on-click = "nm-connection-editor";
  };
}
