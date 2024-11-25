{
  config,
  pkgs,
  USER,
  ...
}: {
  imports = [
    ../wireguard.nix
    ../agenix.nix
  ];

  home-manager.users.${USER} = {
    pkgs,
    config,
    ...
  }: {
    home.packages = with pkgs; [
      poetry
      pyright
    ];
  };

  networking.extraHosts = ''
    127.0.0.1 gebaut.pulswerk.local
    127.0.0.1 sustaindock-staging.dokku.pulswerk.local
  '';

  # ssh -v -L 127.0.0.1:8881:gebaut.pulswerk.local:80 \
  #        -L 127.0.0.1:8882:127.0.0.1:80 \
  #     dokku.pulswerk.local

  # NOTE Access gebaut morphdock staging via http://gebaut.pulswerk.local:8881/anmelden.htm

  age.secrets.wg-pulswerk-private.file = ../../secrets/wg-pulswerk-private.age;
  age.secrets.wg-pulswerk-preshared.file = ../../secrets/wg-pulswerk-preshared.age;

  networking.wg-quick.interfaces.pulswerk0 = {
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
        allowedIPs = [
          "192.168.25.3/32"
          "192.168.22.0/24"
          # "0.0.0.0/0"
          # "::/0"
        ];
        endpoint = "wien.pulswerk.at:51820";
        # persistentKeepalive = 25;
      }
    ];
  };

  age.secrets.wg-hei-private.file = ../../secrets/wg-hei-private.age;
  age.secrets.wg-hei-preshared.file = ../../secrets/wg-hei-preshared.age;

  networking.wg-quick.interfaces.hei0 = {
    address = ["192.168.41.11/32"];
    privateKeyFile = config.age.secrets.wg-hei-private.path;

    postUp = ''
      ${pkgs.systemd}/bin/resolvectl dns hei0 192.168.40.3
      ${pkgs.systemd}/bin/resolvectl domain hei0 \~hei.local
    '';

    peers = [
      {
        publicKey = "RDmsyH09C/ElDj4vILZdnR2NfKxJI24KhhA3WUnkkEU=";
        presharedKeyFile = config.age.secrets.wg-hei-preshared.path;
        allowedIPs = ["192.168.41.11/32" "192.168.40.0/24"];
        endpoint = "remote.hei.at:51820";
      }
    ];
  };
}
