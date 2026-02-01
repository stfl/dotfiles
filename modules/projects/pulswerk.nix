{
  config,
  pkgs,
  USER,
  ...
}:
{
  imports = [
    ../wireguard.nix
    ../agenix.nix
    ../dev/python.nix
  ];

  # NOTE: not actually needed
  # networking.extraHosts = ''
  #   127.0.0.1 gebaut.pulswerk.local
  #   127.0.0.1 sustaindock-staging.dokku.pulswerk.local
  # '';

  # ssh -v -L 127.0.0.1:8881:gebaut.pulswerk.local:80 \
  #        -L 127.0.0.1:8882:127.0.0.1:80 \
  #     dokku.pulswerk.local

  # NOTE Access gebaut morphdock staging via http://gebaut.pulswerk.local:8881/anmelden.htm


  age.secrets.wg-pulswerk-private = {
    file = ../../secrets/wg-pulswerk-private.age;
    owner = "systemd-network";
  };
  age.secrets.wg-pulswerk-preshared = {
    file = ../../secrets/wg-pulswerk-preshared.age;
    owner = "systemd-network";
  };

  age.secrets.wg-hei-private = {
    file = ../../secrets/wg-hei-private.age;
    owner = "systemd-network";
  };
  age.secrets.wg-hei-preshared = {
    file = ../../secrets/wg-hei-preshared.age;
    owner = "systemd-network";
  };

  systemd.network = {
    enable = true;
    netdevs."90-pulswerk" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "pulswerk0";
        MTUBytes = "1300";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wg-pulswerk-private.path;
        ListenPort = 9918;
      };
      wireguardPeers = [
        {
          PublicKey = "Z9Xx5qgdfswnFjbpKutlBnQ8SZVur8Q8nrrsc9HTlTw=";
          PresharedKeyFile = config.age.secrets.wg-pulswerk-preshared.path;
          AllowedIPs = [
            "192.168.25.3/32"
            "192.168.22.0/24"
          ];
          Endpoint = "wien.pulswerk.at:51820";
          PersistentKeepalive = 25;
        }
      ];
    };
    networks."90-pulswerk" = {
      matchConfig.Name = "pulswerk0";
      address = [ "192.168.25.3/32" ];
      routes = [{ Destination = "192.168.22.0/24"; }];
      DHCP = "no";
      dns = ["192.168.22.13"];
      domains = ["~pulswerk.local"];
      networkConfig.IPv6AcceptRA = false;
      linkConfig.RequiredForOnline = "no";
    };

    # Hei wireguard configuration
    netdevs."90-hei" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "hei0";
        MTUBytes = "1300";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wg-hei-private.path;
        ListenPort = 9919;
      };
      wireguardPeers = [
        {
          PublicKey = "RDmsyH09C/ElDj4vILZdnR2NfKxJI24KhhA3WUnkkEU=";
          PresharedKeyFile = config.age.secrets.wg-hei-preshared.path;
          AllowedIPs = [
            "192.168.41.11/32"
            "192.168.40.0/24"
          ];
          Endpoint = "remote.hei.at:51820";
          PersistentKeepalive = 25;
        }
      ];
    };
    networks."90-hei" = {
      matchConfig.Name = "hei0";
      address = [ "192.168.41.11/32" ];
      routes = [{ Destination = "192.168.40.0/24"; }];
      DHCP = "no";
      dns = ["192.168.40.3"];
      domains = ["~hei.local"];
      networkConfig.IPv6AcceptRA = false;
      linkConfig.RequiredForOnline = "no";
    };
  };
}
