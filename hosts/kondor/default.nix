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
    ../../modules/desktop.nix

    # Customers and Projects
    ../../modules/projects/pulswerk.nix
    ../../modules/projects/oebb.nix
  ];

  networking.hostName = "kondor";

  environment.systemPackages = with pkgs; [
    lshw
    pciutils
  ];

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${USER} = {
    isNormalUser = true;
    description = "Stefan";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    initialPassword = "nixos";
    shell = pkgs.zsh;
  };

  # system-wide neovim
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
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

  nix.settings.trusted-users = ["root" "${USER}"];

  services.syncthing = {
    enable = true;
    user = "${USER}";
    dataDir = "/home/${USER}/syncthing";
    configDir = "/home/${USER}/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
  };

  virtualisation.docker.enable = true;

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
