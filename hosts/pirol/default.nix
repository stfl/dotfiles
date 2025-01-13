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
    ../../modules/virtualization.nix
    ../../modules/networkmanager.nix
    # ../../modules/switch.nix
    ../../modules/desktop.nix
    ../../modules/autosuspend.nix
  ];

  networking.hostName = "pirol";

  users.users.${USER} = {
    isNormalUser = true;
    description = "Stefan";
    extraGroups = [
      "wheel"
      "docker"
    ];
    initialPassword = "nixos";
    shell = pkgs.zsh;
  };

  system.stateVersion = "24.11"; # Did you read the comment?

  home-manager.users.${USER} = {
    home.stateVersion = "24.11";
    imports = [./home.nix];
  };

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

  environment.systemPackages = with pkgs; [
    dmidecode
    lm_sensors
    s-tui
    batmon
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [];
  # networking.firewall.allowedUDPPorts = [];

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
  services.autoSuspend.enable = true;
}
