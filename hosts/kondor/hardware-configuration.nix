# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  nixos-hardware,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    nixos-hardware.nixosModules.common-hidpi
    nixos-hardware.nixosModules.common-pc-ssd
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-cpu-amd-pstate
    nixos-hardware.nixosModules.common-cpu-amd-zenpower
    nixos-hardware.nixosModules.common-gpu-amd
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];

  boot = {
    initrd.availableKernelModules = ["nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod"];

    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [];

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = false;
      timeout = 5;
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  # Extra Radeon stuff
  systemd.tmpfiles.rules = [
    # "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # hardware.opengl.extraPackages = with pkgs; [
  #   rocmPackages.clr.icd
  # ];

  powerManagement = {
    enable = true;
    # cpuFreqGovernor = "ondemand";
    powertop.enable = true;
  };

  environment.systemPackages = with pkgs; [
    powertop
  ];

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
      ];
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
