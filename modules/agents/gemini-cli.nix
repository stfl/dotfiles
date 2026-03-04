{USER, ...}: {
  home-manager.users.${USER}.imports = [../home/gemini-cli.nix];
}
