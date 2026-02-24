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
  networking.domain = "stfl.home";

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
    "d /data/n8n 0750 root root -"
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
      sslCertificate = "/etc/ssl/nginx/cert.pem";
      sslCertificateKey = "/etc/ssl/nginx/key.pem";
      locations."/" = {
        proxyPass = "http://localhost:5678";
        proxyWebsockets = true;
      };
    };
  };

  # Generate self-signed TLS certificate for nginx
  systemd.services.nginx-self-signed-cert = {
    description = "Generate self-signed TLS certificate for nginx";
    wantedBy = ["nginx.service"];
    before = ["nginx.service"];
    unitConfig.ConditionPathExists = "!/etc/ssl/nginx/cert.pem";
    serviceConfig.Type = "oneshot";
    path = [pkgs.openssl];
    script = ''
      mkdir -p /etc/ssl/nginx
      openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 \
        -days 3650 -nodes \
        -keyout /etc/ssl/nginx/key.pem \
        -out /etc/ssl/nginx/cert.pem \
        -subj '/CN=*.${config.networking.domain}' \
        -addext 'subjectAltName=DNS:*.${config.networking.domain},DNS:${config.networking.domain}'
      chmod 640 /etc/ssl/nginx/key.pem
      chgrp nginx /etc/ssl/nginx/key.pem
    '';
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
      sslCertificate = "/etc/ssl/nginx/cert.pem";
      sslCertificateKey = "/etc/ssl/nginx/key.pem";
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

  environment.systemPackages = with pkgs; [
    llm-agents.zeroclaw
  ];
}
