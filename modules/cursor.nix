{
  config,
  lib,
  pkgs,
  USER,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    code-cursor
  ];
}
