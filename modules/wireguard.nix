{
  config,
  lib,
  ...
}:
{
  boot.kernelModules = ["wireguard"];

  # networking.firewall.checkReversePath = lib.mkDefault "loose";
  networking.firewall.checkReversePath = lib.mkDefault false;

  # we need systemd-resolved enabled to configure split DNS
  services.resolved.enable = lib.mkDefault true;
}
