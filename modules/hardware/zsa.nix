{USER, ...}: {
  hardware.keyboard.zsa.enable = true;

  programs.zsh.enable = true;

  users.users."${USER}".extraGroups = ["plugdev"];
}
