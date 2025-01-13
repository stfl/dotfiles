{
  lib,
  USER,
  ...
}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.Policy.AutoEnable = "true";
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        ControllerMode = "bredr";
        FastConnectable = true;
        Experimental = true;
        # KernelExperimental = true;
      };
    };
  };

  xdg.autostart.enable = lib.mkDefault true;

  # make sure all firmware is enabled
  hardware.enableAllFirmware = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  services.blueman.enable = lib.mkDefault true;

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

  home-manager.users.${USER} = {...}: {
    # enable forwarding pause/play/.. buttons for bluetooth headsets to media players
    services.mpris-proxy.enable = true;
  };
}
