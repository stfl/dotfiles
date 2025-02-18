{
  config,
  lib,
  pkgs,
  USER,
  ...
}: let
  github-host = "digirail.github.com";

  # Variables controlling connection marks and routing tables IDs. You probably
  # don't need to touch this.
  wgFwMark = 4242;
  wgTable = 4000;
in {
  imports = [
    ../wireguard.nix
    ../agenix.nix
  ];

  environment.systemPackages = with pkgs; [
    keepassxc
    citrix_workspace
  ];

  # networking.firewall.checkReversePath = "loose";
  # networking.firewall.checkReversePath = false;

  # networking.wg-quick.interfaces.digirail0 = {name, ...}: {
  #   autostart = false;
  #   privateKeyFile = config.age.secrets.wg-digirail-private.path;
  #   address = ["192.168.63.2/32"];
  #   dns = ["192.168.63.1"];

  #   # enable split DNS via systemd-resolved
  #   # postUp = ''
  #   #   # ${pkgs.systemd}/bin/resolvectl domain ${name} \~digiattack.net
  #   # '';

  #   peers = [
  #     {
  #       publicKey = "fD02JAuwSfjKIotk0kVBrVXVUETRwUL0aPpp4iGlPj0=";
  #       allowedIPs = [
  #         "192.168.63.1/32"
  #         "192.168.63.2/32"
  #         "0.0.0.0/0"
  #         # "::/0"
  #       ];
  #       endpoint = "80.121.253.230:51820";
  #       # persistentKeepalive = 25;
  #     }
  #   ];
  # };

  home-manager.users.${USER} = {config, ...}: {
    programs.git.aliases = {
      # digirail alias to apply config for individual commands:
      # `git digirail -- clone git@github.com`
      #  -> automatically rewrites to a git clone git@digirail.github.com
      digirail = "!sh -c 'git -c url.git@${github-host}:.insteadOf=git@github.com: -c url.git@${github-host}:.pushInsteadOf=git@github.com: \"$@\"'";
    };

    programs.git.includes = [
      {
        condition = "gitdir:${config.home.homeDirectory}/work/oebb/";
        contents.user.email = "stefan-digirailbox@stfl.dev";
        contents.url."git@${github-host}:" = {
          insteadOf = "git@github.com:";
          pushInsteadOf = "git@github.com:";
        };
      }
    ];

    programs.ssh.matchBlocks."${github-host}" = {
      hostname = "github.com";
      user = "git";
      identityFile = ["${config.home.homeDirectory}/.ssh/id_ed25519"]; # the host local identity file
      identitiesOnly = true;
    };

    programs.ssh.matchBlocks = {
      "digirail-lab1 dr-lab1" = {
        hostname = "192.168.99.10";
        user = "root";
        identityFile = ["${config.home.homeDirectory}/.ssh/id_ed25519_stfl"]; # TODO create a project specific identity file
        identitiesOnly = true;
        port = 13048;
      };
      "digirail-lab2 dr-lab2" = {
        hostname = "192.168.99.11";
        user = "root";
        identityFile = ["${config.home.homeDirectory}/.ssh/id_ed25519_stfl"]; # TODO create a project specific identity file
        identitiesOnly = true;
        port = 13048;
      };
    };
  };

  # the private key must be readable by the systemd-network user
  age.secrets.wg-digirail-private = {
    file = ../../secrets/wg-digirail-private.age;
    owner = "systemd-network";
  };

  # based on this config: https://uint.one/posts/configuring-wireguard-using-systemd-networkd-on-nixos/
  systemd.network = {
    enable = true;

    wait-online = {
      # disable wait-online if no other networkd interface is configured
      enable = lib.mkDefault false;
      anyInterface = true;
    };

    netdevs."10-wg-digirail0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg-digirail0";
        MTUBytes = "1300";
      };
      # See also man systemd.netdev (also contains info on the permissions of the key files)
      wireguardConfig = {
        # Don't use a file from the Nix store as these are world readable. Must be readable by the systemd-network user
        PrivateKeyFile = config.age.secrets.wg-digirail-private.path;
        # ListenPort = 9918;
        FirewallMark = wgFwMark;
        RouteTable = "off";
      };
      wireguardPeers = [
        # configuration since nixos-unstable/nixos-24.11
        {
          PublicKey = "fD02JAuwSfjKIotk0kVBrVXVUETRwUL0aPpp4iGlPj0=";

          AllowedIPs = [
            "0.0.0.0/0"
            # "::/0"
          ];
          # AllowedIPs = [
          #   "192.168.99.0/24"
          #   "192.168.63.1/32"
          #   "192.168.63.2/32"
          #   "0.0.0.0/0"
          #   # "::/0"
          # ];
          Endpoint = "80.121.253.230:51820";
          PersistentKeepalive = 25;
        }
      ];
    };

    networks."10-wg-digirail0" = {
      # See also man systemd.network
      name = "wg-digirail0";
      matchConfig.Name = "wg-digirail0";
      # IP addresses the client interface will have
      address = ["192.168.63.2/32"];
      DHCP = "no";
      dns = ["192.168.63.1"];
      domains = ["~digiattack.net"];
      # linkConfig.ActivationPolicy = "manual";
      networkConfig = {
        Description = "Wireguard network config for ÖBB Digirail";
        DNSOverTLS = "opportunistic";
        IPv6AcceptRA = false;
      };

      routingPolicyRules = [
        {
          Family = "both";
          Table = "main";
          SuppressPrefixLength = 0;
          Priority = 10;
        }
        {
          Family = "both";
          InvertRule = true;
          FirewallMark = wgFwMark;
          Table = wgTable;
          Priority = 11;
        }
      ];
      routes = [
        {
          Destination = "0.0.0.0/0";
          Table = wgTable;
          Scope = "link";
        }
        {
          Destination = "::/0";
          Table = wgTable;
          Scope = "link";
        }
      ];
      linkConfig.RequiredForOnline = false;
    };
  };

  networking.nftables = {
    enable = false;
    ruleset = ''
      table inet wg-wg0 {
        chain preraw {
          type filter hook prerouting priority raw; policy accept;
          iifname != "wg-digirail0" ip daddr 192.168.63.2 fib saddr type != local drop
          # iifname != "wg-digirail0" ip6 daddr $\{wgIpv6} fib saddr type != local drop
        }
        chain premangle {
          type filter hook prerouting priority mangle; policy accept;
          meta l4proto udp meta mark set ct mark
        }
        chain postmangle {
          type filter hook postrouting priority mangle; policy accept;
          meta l4proto udp meta mark ${toString wgFwMark} ct mark set meta mark
        }
      }
    '';
  };

  # this could possibly be simplified by setting either
  networking.firewall.checkReversePath = "loose";
  # networking.firewall.checkReversePath = false;

  # TODO maybe disable IPv6 globally
}
