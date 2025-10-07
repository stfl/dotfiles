{
  lib,
  USER,
  ...
}:
{
  hardware.bluetooth = {
    enable = lib.mkDefault true;
    # hsphfpd.enable = lib.mkDefault true;  # NOTE conficts with wireplumber
    powerOnBoot = lib.mkDefault true;
    settings.Policy.AutoEnable = lib.mkDefault "true";
    settings = {
      General = {
        ControllerMode = lib.mkDefault "dual";
        FastConnectable = lib.mkDefault false; # uses more power
        Experimental = lib.mkDefault true;
        KernelExperimental = lib.mkDefault true;
      };
    };
  };

  xdg.autostart.enable = lib.mkDefault true;

  # make sure all firmware is enabled
  hardware.enableAllFirmware = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  services.blueman.enable = lib.mkDefault true;

  # home-manager.users.${USER}.dconf.settings."org/blueman/general".notification-daemon = true;

  # enable bluetooth codec preferences
  # https://nixos.wiki/wiki/PipeWire#Bluetooth_Configuration
  # services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
  #   "monitor.bluez.properties" = {
  #     # "bluez5.enable-aptx-hd" = true;
  #     "bluez5.enable-aptx" = true;
  #     "bluez5.enable-sbc-xq" = true;
  #     "bluez5.enable-msbc" = true;
  #     "bluez5.enable-hw-volume" = true;
  #     # "bluez5.roles" = ["hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
  #   };
  # };

  # enable forwarding pause/play/.. buttons for bluetooth headsets to media players
  home-manager.users.${USER}.services.mpris-proxy.enable = true;
}
