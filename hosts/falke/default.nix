# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  home-manager,
  lib,
  ...
}: let
  USER = "stefan";
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    home-manager.nixosModules.default
    ../../modules/steam.nix
    ../../modules/desktop.nix
    ../../modules/wireguard.nix
  ];

  # Bootloader.
  boot = {
    # kernelPackages = lib.mkDefault pkgs.linuxKernel.packages.linux_6_6;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        # graceful = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = false;
      timeout = 5;
    };
  };

  networking.hostName = "falke";

  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant. (not compatible with NetworkManager)

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.utf8";
    LC_IDENTIFICATION = "de_AT.utf8";
    LC_MEASUREMENT = "de_AT.utf8";
    LC_MONETARY = "de_AT.utf8";
    LC_NAME = "de_AT.utf8";
    LC_NUMERIC = "de_AT.utf8";
    LC_PAPER = "de_AT.utf8";
    LC_TELEPHONE = "de_AT.utf8";
    LC_TIME = "de_AT.utf8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  security.polkit.enable = true;

  # security.pam.services.swaylock = {};
  security.pam.services.swaylock.fprintAuth = false;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '')
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${USER} = {
    isNormalUser = true;
    description = "Stefan";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "plugdev" # for zsa
    ];
    initialPassword = "nixos";
    shell = pkgs.zsh;
  };

  # ErgoDox EZ
  hardware.keyboard.zsa.enable = true;

  hardware.ledger.enable = true;

  programs.zsh.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    dig
    git
    htop
    killall
    rsync
    powertop

    cntr

    dmidecode
    lm_sensors
    s-tui

    cryptsetup
    (
      let
        UID = "1000";
        GID = "100";
        mount_name = "crypt-stick";
        disk_part_id = "usb-USB_Flash_Disk_SCY0000000008298-0:0-part1";
      in
        writeScriptBin "mount-crypt-stick" ''
          mkdir -p /mnt/${mount_name}
          ${lib.getExe cryptsetup} luksOpen /dev/disk/by-id/${disk_part_id} ${mount_name}
          mount -o uid=${UID},gid=${GID} /dev/mapper/${mount_name} /mnt/${mount_name}
        ''
    )
    (
      let
        mount_name = "crypt-stick";
      in
        writeScriptBin "umount-crypt-stick" ''
          umount /mnt/${mount_name}
          ${lib.getExe cryptsetup} luksClose /dev/mapper/${mount_name}
        ''
    )
  ];

  # system-wide neovim
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  home-manager.users.${USER} = {
    home.stateVersion = "23.11";
    imports = [./home.nix];
  };

  nix.settings.trusted-users = ["root" "${USER}"];

  services.syncthing = {
    enable = true;
    user = "${USER}";
    dataDir = "/home/${USER}/syncthing";
    configDir = "/home/${USER}/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
  };

  virtualisation.docker.enable = true;
  # TODO KVM and QEMU

  # fonts.packages = with pkgs; [
  #   noto-fonts
  #   fira-code
  #   ubuntu_font_family
  #   jetbrains-mono
  #   source-code-pro
  #   anonymousPro
  # ];
  # fonts.fontDir.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
    ];
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # Suspend-then-hibernate everywhere
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=30m
    '';
  };

  systemd.sleep.extraConfig = "HibernateDelaySec=1h";

  # Suspend the system when battery level drops to 5% or lower
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${pkgs.systemd}/bin/systemctl hibernate"
  '';
}
