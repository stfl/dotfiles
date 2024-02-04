{ config, lib, pkgs, ... }:

with lib;

{
  targets.genericLinux.enable = true;

  nixGLPrefix = lib.getExe pkgs.nixgl.nixGLIntel;

  home.packages = with pkgs; [
    nixgl.nixGLIntel

    nvtop-intel

    mixxx
  ];
}
