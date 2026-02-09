{
  config,
  lib,
  pkgs,
  ...
}:
let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  # Use the latest kernel version that ZFS supports
  # This automatically pins to a ZFS-compatible kernel
  boot.kernelPackages = latestKernelPackage;

  boot.supportedFilesystems = [ "zfs" ];
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
