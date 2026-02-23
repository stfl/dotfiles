{
  config,
  lib,
  pkgs,
  modulesPath,
  USER,
  ...
}: {
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/proxmox-image.nix
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  networking.useDHCP = lib.mkDefault true;

  services.qemuGuest.enable = lib.mkDefault true; # Enable QEMU Guest for Proxmox

  image.modules.proxmox = {
    proxmox.qemuConf.name = config.networking.hostName; # set the VM name in Proxmox to match the hostname
    proxmox.qemuExtraConf = {
      cpu = lib.mkDefault "host";
      onboot = lib.mkDefault 1;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  boot.loader.grub.enable = lib.mkDefault true; # Use the boot drive for GRUB
  boot.loader.grub.devices = ["nodev"];

  nix.settings.trusted-users = ["root" USER]; # Allow remote updates
  nix.settings.experimental-features = ["nix-command" "flakes"]; # Enable flakes

  # Essential Packages
  environment.systemPackages = with pkgs; [
    vim # for emergencies
    git # for pulling Nix flakes
  ];

  # Adding a User and SSH Key
  security.sudo.wheelNeedsPassword = false; # Don't ask for passwords
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Add an admin user
  users.users.${USER} = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGSjWr1X80phoVLQDpXyn26SAPytikVdGyTK1ifYxR6"];
  };
}
