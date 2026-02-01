{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking.useNetworkd = true;

  # NOTE optionally increase systemd loglevel for systemd-networkd
  systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";

  services.connman = {
    enable = true;
    package = pkgs.connmanFull;
    # package = pkgs.connman-gtk;
    enableVPN = true;
    wifi.backend = "iwd";
  };

  environment.systemPackages = with pkgs; [
    cmst  # connman GUI and system tray
  ];

  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
    networks = {
      "10-eth" = {
        matchConfig.Name = "enp10s0";
        networkConfig.DHCP = "yes";
        networkConfig.IPv6AcceptRA = true;
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  services.resolved = {
    enable = lib.mkDefault true;
    fallbackDns = [
      "1.1.1.1"
      "8.8.8.8"
      "2001:4860:4860::8844"
    ];
  };
}
