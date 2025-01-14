{
  config,
  pkgs,
  USER,
  ...
}: {
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [docker-compose];

  users.users.${USER}.extraGroups = ["docker"];

  assertions = [
    {
      assertion = !config.networking.nftables.enable;
      message = ''
        Docker does not support nftables.
        You have enabled both:
          - virtualisation.docker.enable = true
          - networking.nftables.enable = true
      '';
    }
  ];
}
