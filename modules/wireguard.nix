{
  config,
  lib,
  pkgs,
  ...
}: {
  # we need systemd-resolved enabled to configure split DNS
  services.resolved.enable = true;

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.wireguard = {
    enable = true;
  };
}
