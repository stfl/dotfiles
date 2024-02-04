{ config, lib, pkgs, ... }:

with lib;

{
  nixGLPrefix = lib.getExe pkgs.nixgl.nixGLIntel;
}
