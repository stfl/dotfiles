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
    nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel
  ];

  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod"];
      kernelModules = [];
    };
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
    resumeDevice = "/dev/disk/by-label/swap";

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
        # graceful = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = false;
      timeout = 5;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  swapDevices = [{device = "/dev/disk/by-label/swap";}];

  nixpkgs.hostPlatform = "x86_64-linux";

  powerManagement = {
    enable = true;
    # cpuFreqGovernor = "ondemand";
    powertop.enable = true;
  };

  services.throttled.enable = false; # i7-13700H is not supported

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
      ];
    };
  };
}
