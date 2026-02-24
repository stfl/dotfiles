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

  networking.firewall.allowedTCPPorts = [80]; # n8n default port

  # FIXME !!!
  networking.firewall.enable = false;

  age.secrets.monica-app-key = {
    file = ../../secrets/monica-app-key.age;
    owner = config.services.monica.user;
  };

  services.monica = {
    enable = true;
    appKeyFile = config.age.secrets.monica-app-key.path;
  };

  environment.systemPackages = with pkgs; [
    llm-agents.zeroclaw
  ];
}
