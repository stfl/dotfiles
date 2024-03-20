{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  imports = [
    ../modules/desktop.nix
    ../modules/emacs.nix
    ../modules/pass.nix
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
