{
  pkgs,
  USER,
  ...
}: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
    autoPrune.enable = true;
  };

  environment.systemPackages = with pkgs; [
    podman-compose
    podman-tui
  ];

  users.users.${USER}.extraGroups = ["podman"];
}
