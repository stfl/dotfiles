{USER, ...}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  # make sure all firmware is enabled
  hardware.enableAllFirmware = true;

  services.blueman.enable = true;

  # enable bluetooth codec preferences
  # https://nixos.wiki/wiki/PipeWire#Bluetooth_Configuration
  services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.roles" = ["hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
    };
  };

  home-manager.users.${USER} = {pkgs, ...}: {
    # enable forwarding pause/play/.. buttons for bluetooth headsets to media players
    services.mpris-proxy.enable = true;
  };
}
