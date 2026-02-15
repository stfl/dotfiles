{USER, ...}: {
  hardware.keyboard.zsa.enable = true;

  users.users."${USER}".extraGroups = ["plugdev"];
}
