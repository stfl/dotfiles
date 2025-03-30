{
  pkgs,
  modulesPath,
  nixos-hardware,
  USER,
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
    ../../modules/hardware/zfs.nix
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
    "/feather" = {
      label = "FEATHER";
      fsType = "btrfs";
      options = ["compress=zstd"];
    };
    "/feather/Pictures" = {
      label = "FEATHER";
      fsType = "btrfs";
      options = ["subvol=Pictures,compress=zstd"];
    };
    "/home/${USER}/Pictures" = {
      device = "/feather/Pictures";
      options = ["bind"];
    };
  };

  swapDevices = [];

  boot = {
    initrd.availableKernelModules = ["nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod"];

    # kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = ["zfs.zfs_arc_max=17179869184"]; # 16GiB ARC

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

  # Logitech Unify connector
  # installs ltunify : https://github.com/Lekensteyn/ltunify
  hardware.logitech.wireless.enable = true;

  powerManagement = {
    enable = true;
    # cpuFreqGovernor = "ondemand";
    powertop.enable = false;
  };
  environment.systemPackages = [pkgs.powertop];

  hardware.enableAllFirmware = true;

  # AMD GPU
  hardware.graphics.extraPackages = with pkgs; [
    vaapiVdpau
    # rocmPackages.clr.icd
  ];


  # Extra Radeon ROCm stuff
  # systemd.tmpfiles.rules = let
  #   rocmEnv = pkgs.symlinkJoin {
  #     name = "rocm-combined";
  #     paths = with pkgs.rocmPackages; [
  #       rocblas
  #       hipblas
  #       clr
  #     ];
  #   };
  # in [
  #   "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  # ];
}
