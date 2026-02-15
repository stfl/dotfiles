{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    dmidecode
    lm_sensors
    s-tui
    lshw
    pciutils
    clinfo

    batmon
    powertop
  ];

  # requires hardware.fancontrol.config
  # hardware.fancontrol.enable = lib.mkIf config.hardware.fancontrol.config true;
  # hardware.fancontrol.enable = lib.mkDefault false;

  powerManagement.enable = true;
}
