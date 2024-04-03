{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  nixGL = import ../modules/nixGL.nix {inherit pkgs config;};
in {
  imports = [
    ../../modules/home/desktop.nix
    ../../modules/home/emacs.nix
    ../../modules/home/pass.nix
  ];

  targets.genericLinux.enable = true;

  nixGLPrefix = getExe pkgs.nixgl.nixGLIntel;

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    nvtopPackages.intel

    (nixGL calibre)

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
