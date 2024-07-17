{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.wireguard = {
    enable = true;
  };

  # we need systemd-resolved enabled to configure split DNS
  services.resolved.enable = true;

  age.secrets.wg-pulswerk-private.file = ../secrets/wg-pulswerk-private.age;
  age.secrets.wg-pulswerk-preshared.file = ../secrets/wg-pulswerk-preshared.age;

  networking.wg-quick.interfaces = {
    pulswerk0 = {
      address = ["192.168.25.3/32"];
      privateKeyFile = config.age.secrets.wg-pulswerk-private.path;

      # enable split DNS via systemd-resolved
      postUp = ''
        ${pkgs.systemd}/bin/resolvectl dns pulswerk0 192.168.22.13
        ${pkgs.systemd}/bin/resolvectl domain pulswerk0 \~pulswerk.local
      '';

      peers = [
        {
          publicKey = "Z9Xx5qgdfswnFjbpKutlBnQ8SZVur8Q8nrrsc9HTlTw=";
          presharedKeyFile = config.age.secrets.wg-pulswerk-preshared.path;
          allowedIPs = ["192.168.25.3/32" "192.168.22.0/24"];
          endpoint = "wien.pulswerk.at:51820";
        }
      ];
    };
  };
}
