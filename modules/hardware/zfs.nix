{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.supportedFilesystems = ["zfs"];
  # boot.zfs.forceImportRoot = lib.mkDefault false;

  environment.systemPackages = with pkgs; [
    zfs
  ];

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  # allow zfs export over nfs
  # services.nfs.server.enable = lib.mkDefalt false;
}
