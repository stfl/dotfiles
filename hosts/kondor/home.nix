{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  imports = [
    ../../modules/home
    ../../modules/home/desktop.nix
    ../../modules/home/emacs.nix
    ../../modules/home/pass.nix
  ];

  home.packages = with pkgs; [
    nvtopPackages.amd
  ];
}
