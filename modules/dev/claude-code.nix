{USER, ...}: {
  home-manager.users.${USER}.imports = [../home/claude-code.nix];
}
