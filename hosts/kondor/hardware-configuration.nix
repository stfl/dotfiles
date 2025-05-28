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
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/nix" = {
      device = "rpool/nix";
      fsType = "zfs";
    };

    "/home" = {
      device = "rpool/home";
      fsType = "zfs";
    };

    # TODO
    # "/" = {
    #   device = "rpool/root";
    #   fsType = "zfs";
    #   # the zfsutil option is needed when mounting zfs datasets without "legacy" mountpoints
    #   # options = ["zfsutil"];
    # };

    # TODO
    # fileSystems."/var" = {
    #   device = "rpool/var";
    #   fsType = "zfs";
    #   # options = ["zfsutil"];
    # };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/swap";
      randomEncryption = true;
    }
  ];

  boot = {
    initrd.availableKernelModules = ["nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod"];

    initrd.kernelModules = ["amdgpu"];

    kernelParams = ["zfs.zfs_arc_max=17179869184"]; # 16GiB ARC

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
      timeout = 5;
    };
  };

  # Logitech Unify connector
  # installs ltunify : https://github.com/Lekensteyn/ltunify
  hardware.logitech.wireless.enable = true;

  hardware.enableAllFirmware = true;

  # AMD GPU
  hardware.graphics = {
    enable = true;
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
