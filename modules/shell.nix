{
  pkgs,
  USER,
  ...
}:
{
  home-manager.users.${USER} = {
    imports = [ ./home/shell.nix ];
  };

  environment.systemPackages = with pkgs; [
    wget
    dig
    git
    htop
    killall
    rsync
    cachix
    fh # flakehub client
    parted
    pv
    dust
    fd
    jq
    procs # ps/pgrep alternative
    bottom # (btm) top alternative
    broot # interactive tree with fuzzy search
    xh # curl/httpie alternative
    tldr
    unzip
    p7zip
    btop
    s-tui # shows termperature and fan speed
  ];

  programs.mtr.enable = true;

  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    autosuggestions = {
      enable = true;
      async = true;
    };
  };

  # system-wide neovim
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.pathsToLink = [
    "/share/zsh"
    "/share/fish"
  ];
}
