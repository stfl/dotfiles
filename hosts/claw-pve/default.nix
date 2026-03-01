{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/nix.nix
    ../../modules/hardware/pvevm.nix
    ../../modules/agenix.nix

    ../../modules/podman.nix
  ];

  # configuration for creating the initial (backup) image
  image.modules.proxmox = {
    virtualisation.diskSize = 20 * 1024; # 20 GiB
    proxmox.qemuConf = {
      # TODO this should be scsi0 with virtio driver and virtio-blk
      virtio0 = "local-zfs:vm-9999-disk-0,cache=writeback,discard=on,iothread=1";
      cores = 8;
      memory = 4096;
      net0 = "virtio=BC:24:11:07:B1:B3,bridge=vmbr1,firewall=1";
    };
    proxmox.cloudInit.defaultStorage = "local-zfs";
  };

  system.stateVersion = "26.05";
  networking.hostName = "claw";
  networking.domain = "stfl.dev";

  fileSystems."/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
  };

  # DynamicUser stores state at /var/lib/private/n8n, not /var/lib/n8n
  fileSystems."/var/lib/private/n8n" = {
    device = "/data/n8n";
    options = ["bind"];
  };

  fileSystems."/var/lib/containers/storage/volumes" = {
    device = "/data/podman/volumes";
    options = ["bind"];
  };

  systemd.tmpfiles.rules = [
    "d /data/n8n 0755 root root -"
    "d /data/podman/volumes 0755 root root -"

    "d /data/monica 0750 monica monica -"
  ];

  networking.firewall.allowedTCPPorts = [80 443];

  # FIXME !!!
  networking.firewall.enable = false;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts."n8n.${config.networking.domain}" = {
      forceSSL = true;
      useACMEHost = config.networking.domain;
      locations."/" = {
        proxyPass = "http://localhost:5678";
        proxyWebsockets = true;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "s@stfl.dev";
    certs.${config.networking.domain} = {
      domain = "*.${config.networking.domain}";
      extraDomainNames = [config.networking.domain];
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.cloudflare-dns-api-token.path;
      group = "nginx";
    };
  };

  age.secrets.cloudflared-tunnel-credentials.file = ../../secrets/cloudflared-tunnel-credentials.age;
  age.secrets.cloudflare-dns-api-token.file = ../../secrets/cloudflare-dns-api-token.age;

  services.cloudflared = {
    enable = true;
    tunnels."b601c4a2-8fa7-490e-adf8-d3590537b35e" = {
      credentialsFile = config.age.secrets.cloudflared-tunnel-credentials.path;
      default = "http_status:404";
      ingress = {
        "n8n.stfl.dev" = "http://localhost:5678";
        "monica.stfl.dev" = "http://localhost:80";
        "claw.stfl.dev" = "http://localhost:42617";
      };
    };
  };

  age.secrets.monica-app-key = {
    file = ../../secrets/monica-app-key.age;
    owner = config.services.monica.user;
  };

  services.mysql.dataDir = "/data/mariadb";

  services.monica = {
    enable = true;
    hostname = "monica.${config.networking.domain}";
    appURL = "https://monica.${config.networking.domain}";
    appKeyFile = config.age.secrets.monica-app-key.path;
    dataDir = "/data/monica";
    nginx = {
      forceSSL = true;
      useACMEHost = config.networking.domain;
    };
  };

  services.n8n = {
    enable = true;
    environment = {
      WEBHOOK_URL = "https://n8n.${config.networking.domain}/";
      # Workaround: module bug coerces null _FILE vars in LoadCredential
      N8N_RUNNERS_AUTH_TOKEN_FILE = "/dev/null";
    };
  };

  users.users.zeroclaw = {
    isSystemUser = true;
    group = "zeroclaw";
    home = "/data/zeroclaw";
    createHome = true;
  };
  users.groups.zeroclaw = {};

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "zeroclaw" ''
      exec sudo -E -u zeroclaw ${pkgs.lib.getExe pkgs.llm-agents.zeroclaw} --config-dir ${config.users.users.zeroclaw.home}/.zeroclaw "$@"
    '')
    (pkgs.writeShellScriptBin "cli-proxy-api" ''
      exec sudo -u zeroclaw ${pkgs.lib.getExe pkgs.llm-agents.cli-proxy-api} "$@"
    '')
  ];

  systemd.services.zeroclaw = {
    description = "ZeroClaw AI Agent Daemon";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    restartTriggers = [pkgs.llm-agents.zeroclaw];

    serviceConfig = {
      Type = "simple";
      User = "zeroclaw";
      Group = "zeroclaw";
      WorkingDirectory = "/data/zeroclaw";
      StateDirectory = "zeroclaw";
      Restart = "on-failure";
      RestartSec = 10;
      ExecStart = "${pkgs.lib.getExe pkgs.llm-agents.zeroclaw} daemon";
    };
  };

  systemd.services.cli-proxy-api = {
    description = "CLI Proxy API - OpenAI compatible proxy";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    restartTriggers = [pkgs.llm-agents.cli-proxy-api];

    serviceConfig = {
      Type = "simple";
      User = "zeroclaw";
      Group = "zeroclaw";
      WorkingDirectory = "/data/zeroclaw/.cli-proxy-api";
      Restart = "on-failure";
      RestartSec = 10;
      ExecStart = "${pkgs.lib.getExe pkgs.llm-agents.cli-proxy-api}";
    };
  };

  services.nginx.virtualHosts."${config.networking.fqdn}" = {
    forceSSL = true;
    useACMEHost = config.networking.domain;
    locations."/" = {
      proxyPass = "http://127.0.0.1:42617";
      proxyWebsockets = true;
    };
  };
}
