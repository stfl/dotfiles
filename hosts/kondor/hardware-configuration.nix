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

    ({pkgs, ...}: {
      # LACT - Linux AMDGPU Controller
      # This application allows you to overclock, undervolt, set fans curves of AMD GPUs on a Linux system.
      environment.systemPackages = with pkgs; [lact];
      systemd.packages = with pkgs; [lact];
      systemd.services.lactd.wantedBy = ["multi-user.target"];
    })

    # ({pkgs, ...}: {
    #   # AMD's open-source Vulkan driver amdvlkk
    #   hardware.graphics = {
    #     extraPackages = with pkgs; [
    #       amdvlk
    #     ];

    #     extraPackages32 = with pkgs; [
    #       driversi686Linux.amdvlk
    #     ];
    #   };
    # })
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

    initrd.kernelModules = ["amdgpu"];

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
  environment.systemPackages = with pkgs; [
    powertop
    clinfo
  ];

  hardware.enableAllFirmware = true;

  # AMD GPU
  hardware.graphics = {
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
    ];
  };

  # systemd.tmpfiles.rules = ["L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"];

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
