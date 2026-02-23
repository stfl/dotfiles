{
  config,
  lib,
  pkgs,
  modulesPath,
  USER,
  ...
}: {
  imports = [
    ../../modules/nix.nix
    ../../modules/hardware/pvevm.nix

    ../../modules/docker.nix
  ];

  system.stateVersion = "26.05";
  networking.hostName = "claw";

  # configuration for creating the initial (backup) image
  image.modules.proxmox = {
    proxmox.qemuConf = {
      virtio0 = "local-zfs:vm-9999-disk-0";
      cores = 8;
      memory = 4096;
      net0 = "model=virtio,bridge=vmbr1,firewall=1";
    };
    proxmox.cloudInit.defaultStorage = "local-zfs";
  };
}
