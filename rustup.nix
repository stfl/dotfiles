{ config, lib, pkgs, ... }:

with lib;

{
  home.packages = with pkgs; [
    rustup
  ];
}
