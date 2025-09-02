{
  pkgs,
  home-manager,
  USER,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/hardware
    ../../modules/hardware/bluetooth.nix
    ../../modules/hardware/zsa.nix
    ../../modules/hardware/ledger.nix

    home-manager.nixosModules.default

    ../../modules
    ../../modules/virtualization.nix
    ../../modules/networkmanager.nix
    ../../modules/docker.nix
    ../../modules/steam.nix
    ../../modules/docker.nix
    # ../../modules/switch.nix
    ../../modules/desktop.nix
    ../../modules/autosuspend.nix

    # Development
    ../../modules/dev

    # Customers and Projects
    ../../modules/projects/oebb.nix
  ];

  networking.hostName = "pirol";

  users.users.${USER} = {
    isNormalUser = true;
    description = "Stefan";
    extraGroups = [
      "wheel"
    ];
    initialPassword = "nixos";
    shell = pkgs.zsh;
    # shell = pkgs.fish;
  };

  programs.fish.enable = true;

  system.stateVersion = "24.11"; # Did you read the comment?

  home-manager.users.${USER} = {
    home.stateVersion = "24.11";
    imports = [ ./home.nix ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    oh-my-fish
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [];
  # networking.firewall.allowedUDPPorts = [];

  services.tailscale = {
    enable = true;
    openFirewall = true;
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

  # Suspend-then-hibernate everywhere
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandlePowerKey = "suspend-then-hibernate";
    IdleAction = "suspend-then-hibernate";
    IdleActionSec = "30m";
  };

  systemd.sleep.extraConfig = "HibernateDelaySec=1h";

  # Suspend the system when battery level drops to 5% or lower
  services.autoSuspend.enable = true;
}
