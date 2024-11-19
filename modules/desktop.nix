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
    # wireplumber.configPackages = [
    #   (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
    #     bluez_monitor.properties = {
    #       ["bluez5.enable-sbc-xq"] = true,
    #       ["bluez5.enable-msbc"] = true,
    #       ["bluez5.enable-hw-volume"] = true,
    #       ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
    #     }
    #   '')
    # ];
  };
  # services.pipewire.wireplumber.extraScripts.main."99-alsa-lowlatency" = ''
  #   alsa_monitor.rules = {
  #     {
  #       matches = {{{ "node.name", "matches", "alsa_output.*" }}};
  #       apply_properties = {
  #         ["audio.format"] = "S32LE",
  #         ["audio.rate"] = "96000", -- for USB soundcards it should be twice your desired rate
  #         ["api.alsa.period-size"] = 2, -- defaults to 1024, tweak by trial-and-error
  #         -- ["api.alsa.disable-batch"] = true, -- generally, USB soundcards use the batch mode
  #       },
  #     },
  #   }
  # '';
}
