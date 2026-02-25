{
  config,
  pkgs,
  lib,
  modulesPath,
  disko,
  USER,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    disko.nixosModules.disko
    ./disko.nix

    ../../modules/nix.nix
    ../../modules/agenix.nix
    ../../modules/podman.nix
  ];

  system.stateVersion = "26.05";
  networking.hostName = "opencloud";
  networking.domain = "stfl.home";
  networking.useDHCP = lib.mkDefault true;

  # Boot (BIOS/SeaBIOS — GRUB device auto-set by disko via EF02 partition)
  boot.loader.grub.enable = true;
  boot.growPartition = true;

  # QEMU guest
  services.qemuGuest.enable = true;

  # User
  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
  users.users.${USER} = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGSjWr1X80phoVLQDpXyn26SAPytikVdGyTK1ifYxR6"];
  };

  nix.settings.trusted-users = [USER];

  environment.systemPackages = with pkgs; [
    cloud-utils
    parted
    vim
    git
    bottom
  ];

  # Firewall
  networking.firewall.allowedTCPPorts = [443];

  # ── Self-signed TLS ──────────────────────────────────────────────────
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

  # ── Nginx reverse proxy ──────────────────────────────────────────────
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    # OpenCloud
    virtualHosts."opencloud.${config.networking.domain}" = {
      forceSSL = true;
      sslCertificate = "/etc/ssl/nginx/cert.pem";
      sslCertificateKey = "/etc/ssl/nginx/key.pem";
      locations."/" = {
        proxyPass = "http://127.0.0.1:9200";
        proxyWebsockets = true;
      };
    };

    # Collabora Online
    virtualHosts."office.${config.networking.domain}" = {
      forceSSL = true;
      sslCertificate = "/etc/ssl/nginx/cert.pem";
      sslCertificateKey = "/etc/ssl/nginx/key.pem";
      locations."/" = {
        proxyPass = "http://127.0.0.1:9980";
        proxyWebsockets = true;
      };
    };
  };

  # ── OpenCloud ────────────────────────────────────────────────────────
  services.opencloud = {
    enable = true;
    url = "https://opencloud.${config.networking.domain}";
    stateDir = "/data/opencloud";
    environment = {
      PROXY_TLS = "false";
    };
    settings = {
      COLLABORATION_APP_WOPIAPP_PROXY_URL = "https://office.${config.networking.domain}";
    };
  };

  # ── Collabora Online ────────────────────────────────────────────────
  services.collabora-online = {
    enable = true;
    settings = {
      ssl.enable = false; # TLS terminated at nginx
    };
  };

  # ── Persistent Data Directories ────────────────────────────────────
  systemd.tmpfiles.rules = [
    "d /data/opencloud 0750 opencloud opencloud -"
    "d /data/cool 0750 cool cool -"
  ];
}
