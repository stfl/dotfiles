{pkgs, ...}: {
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

  powerManagement.enable = true;
}
