{
  pkgs,
  home-manager,
  USER,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    home-manager.nixosModules.default

    ../../modules
    ../../modules/virt.nix
    ../../modules/switch.nix
    ../../modules/desktop.nix
    ../../modules/autosuspend.nix
    ../../modules/ledger.nix

    # Customers
    ../../modules/projects/pulswerk.nix
    ../../modules/projects/3datax.nix
  ];

  networking.hostName = "falke";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${USER} = {
    isNormalUser = true;
    description = "Stefan";
    extraGroups = [
      "networkmanager"
      "wheel"
      "wireshark"
      "docker"
      "plugdev" # for zsa
    ];
    initialPassword = "nixos";
    shell = pkgs.zsh;
  };

  system.stateVersion = "23.11"; # Did you read the comment?

  home-manager.users.${USER} = {
    home.stateVersion = "23.11";
    imports = [./home.nix];
  };

  nix.settings.trusted-users = ["root" "${USER}"];

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

  # ErgoDox EZ
  hardware.keyboard.zsa.enable = true;

  programs.zsh.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # install GUI wireshark
  };

  environment.systemPackages = with pkgs; [
    wget
    dig
    git
    htop
    killall
    rsync
    powertop

    ccls

    cntr

    dmidecode
    lm_sensors
    s-tui
    batmon

    tcpdump
    sshfs
    bridge-utils
    ethtool
    smcroute

    cryptsetup
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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

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
