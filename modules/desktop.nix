{
  pkgs,
  USER,
  ...
}:
{
  home-manager.users.${USER} = {
    imports = [
      ./home/desktop.nix
    ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    SDL_VIDEODRIVER= "wayland";
    GDK_BACKEND="wayland";

    _JAVA_AWT_WM_NONREPARENTING= "1";
    # BEMENU_BACKEND="wayland":
    CLUTTER_BACKEND="wayland";
    # ECORE_EVAS_ENGINE="wayland_egl";
    ELM_ACCEL="gl";
    ELM_DISPLAY="wl";
    ELM_ENGINE="wayland_egl";

    # ox wayland environment variable
    MOZ_DBUS_REMOTE="1";
    MOZ_ENABLE_WAYLAND="1";
    MOZ_USE_XINPUT2="1";

    NO_AT_BRIDGE="1";
    SAL_USE_VCLPLUGIN="gtk3";

    QT_WAYLAND_DISABLE_WINDOWDECORATION="1";
    QT_QPA_PLATFORM="wayland-egl";
    QT_QPA_PLATFORMTHEME="qt6ct";
  };

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.printing.enable = true;

  security.polkit.enable = true;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    qt5.qtwayland
    kdePackages.qtwayland
    wayland-utils

    pcmanfm
    gimp

    libnotify
    wdisplays
    kanshi # install the binary in addition to the service for debugging configs

    brightnessctl
    libpulseaudio # pulsectl
    pavucontrol
  ];

  # Xfce D-Bus thumbnailer service
  services.tumbler.enable = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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
  #

  fonts = {
    packages = with pkgs; [
      symbola
      noto-fonts
      noto-fonts-color-emoji
      dejavu_fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.symbols-only
    ];
    fontDir.enable = true;
    fontconfig.enable = true;
  };

  # get completion for system packages
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
}
