{
  pkgs,
  USER,
  ...
}: {
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [docker-compose];

  users.users.${USER}.extraGroups = ["docker"];
}
