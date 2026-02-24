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

  system.stateVersion = "26.05";
  networking.hostName = "claw";
  networking.domain = "stfl.home";

  # configuration for creating the initial (backup) image
  image.modules.proxmox = {
    virtualisation.diskSize = 20 * 1024; # 10 GiB
    proxmox.qemuConf = {
      virtio0 = "local-zfs:vm-9999-disk-0,cache=writeback,discard=on,iothread=1";
      cores = 8;
      memory = 4096;
      net0 = "virtio=BC:24:11:07:B1:B3,bridge=vmbr1,firewall=1";
    };
    proxmox.cloudInit.defaultStorage = "local-zfs";
  };

  # services.n8n = {
  #   enable = true;
  #   # taskRunners.enable = true;
  #   openFirewall = true;
  # };

  networking.firewall.allowedTCPPorts = [80 443];

  # FIXME !!!
  networking.firewall.enable = false;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
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
        -subj '/CN=${config.services.monica.hostname}' \
        -addext 'subjectAltName=DNS:${config.services.monica.hostname}'
      chmod 640 /etc/ssl/nginx/key.pem
      chgrp nginx /etc/ssl/nginx/key.pem
    '';
  };

  age.secrets.monica-app-key = {
    file = ../../secrets/monica-app-key.age;
    owner = config.services.monica.user;
  };

  services.monica = {
    enable = true;
    hostname = "monica.${config.networking.domain}";
    appURL = "https://monica.${config.networking.domain}";
    appKeyFile = config.age.secrets.monica-app-key.path;
    nginx = {
      forceSSL = true;
      sslCertificate = "/etc/ssl/nginx/cert.pem";
      sslCertificateKey = "/etc/ssl/nginx/key.pem";
    };
  };

  environment.systemPackages = with pkgs; [
    llm-agents.zeroclaw
  ];
}
