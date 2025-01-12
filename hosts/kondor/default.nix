{
  pkgs,
  home-manager,
  USER,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/hardware/zsa.nix
    ../../modules/hardware/ledger.nix

    home-manager.nixosModules.default

    ../../modules
    ../../modules/steam.nix
    ../../modules/virtualization.nix
    ../../modules/docker.nix
    ../../modules/desktop.nix
    ../../modules/wireshark.nix
    ../../modules/networkmanager.nix

    # Customers and Projects
    ../../modules/projects/pulswerk.nix
    ../../modules/projects/oebb.nix
  ];

  networking.hostName = "kondor";

  # random, machine-unique 32bit hostId
  # when using ZFS, ensure that a pool isn’t accidentally imported on a wrong machine.
  # head -c 8 /etc/machine-id
  networking.hostId = "9d041828";

  nixpkgs.hostPlatform = "x86_64-linux";

  environment.systemPackages = with pkgs; [
    stremio

    speedtest-cli

    lshw
    pciutils
  ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${USER} = {
    isNormalUser = true;
    description = "Stefan";
    extraGroups = [
      "wheel"
    ];
    initialPassword = "nixos";
    shell = pkgs.zsh;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  home-manager.users.${USER} = {
    home.stateVersion = "24.05";
    imports = [./home.nix];
  };

  services.syncthing = {
    enable = true;
    user = "${USER}";
    dataDir = "/home/${USER}/syncthing";
    configDir = "/home/${USER}/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
  };

  # fonts.packages = with pkgs; [
  #   noto-fonts
  #   fira-code
  #   ubuntu_font_family
  #   jetbrains-mono
  #   source-code-pro
  #   anonymousPro
  # ];
  # fonts.fontDir.enable = true;

  services.logind = {
    extraConfig = ''
      HandlePowerKey=suspend
      IdleAction=suspend
      IdleActionSec=2h
    '';
  };
}
