{
  lib,
  USER,
  ...
}:
{
  # Disable wireless support via wpa_supplicant. (not compatible with NetworkManager)
  networking.wireless.enable = false;

  networking.networkmanager.enable = true;

  users.users.${USER}.extraGroups = [ "networkmanager" ];

  home-manager.users.${USER} = {
    services.network-manager-applet.enable = true;

    # TODO what is the package and path?
    # programs.waybar.settings.mainBar.network.on-click = "nm-connection-editor";
  };

  services.resolved = {
    enable = lib.mkDefault true;
    fallbackDns = [
      "8.8.8.8"
      "2001:4860:4860::8844"
    ];
  };
}
