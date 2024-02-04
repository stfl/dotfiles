{ config, lib, pkgs, ... }:

with lib;

{
  nixGLPrefix = lib.getExe pkgs.nixgl.nixGLIntel;

  home.packages = with pkgs; [
    nixgl.nixGLIntel

    nvtop-intel

    mixxx
  ];
}
