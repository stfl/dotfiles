{
  config,
  lib,
  pkgs,
  ...
}: {
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.printing.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock.fprintAuth = false;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    qt5.qtwayland
    wayland-utils
    wlr-protocols
  ];

  xdg.portal.wlr.enable = true;
  xdg.portal.config.common.default = "*"; # use the first available portal

  services.blueman.enable = lib.mkIf config.hardware.bluetooth.enable true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '')
    ];
  };
}
