{
  pkgs,
  lib,
  USER,
  ...
}: {
  home-manager.users.${USER} = {
    imports = [./home/shell.nix];
  };

  environment.systemPackages = with pkgs; [
    wget
    dig
    git
    htop
    killall
    rsync
    cachix
    fh
  ];

  programs.mtr.enable = true;

  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
  };

  # system-wide neovim
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.pathsToLink = ["/share/zsh" "/share/fish"];
}
