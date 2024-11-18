{USER, ...}: {
  virtualisation.libvirtd.enable = true;
  # virtualisation.qemu.package = pkgs.qemu_full;  # FIXME seems to not work
  programs.virt-manager.enable = true;
  security.polkit.enable = true;

  users.users."${USER}".extraGroups = ["libvirtd"];

  # TODO home-manager config - this would be nice
  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = ["qemu:///system"];
  #     uris = ["qemu:///system"];
  #   };
  # };
}
