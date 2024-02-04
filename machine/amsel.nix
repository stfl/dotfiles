{ config, lib, pkgs, ... }:

with lib;

let
  nixGL = import ../modules/nixGL.nix { inherit pkgs config; };
in {
  imports = [
    ../modules/desktop.nix
    ../modules/emacs.nix
  ];

  targets.genericLinux.enable = true;

  nixGLPrefix = lib.getExe pkgs.nixgl.nixGLIntel;

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    nvtop-intel

    (nixGL calibre)

    mixxx

    # -- rust
    rustup

    # downloader
    spotdl
    youtube-dl
  ];
}
