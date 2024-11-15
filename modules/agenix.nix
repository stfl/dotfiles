{
  config,
  pkgs,
  lib,
  agenix,
  system,
  ...
}: {
  imports = [
    agenix.nixosModules.default
  ];

  environment.systemPackages = [
    agenix.packages."${system}".default
  ];
}
