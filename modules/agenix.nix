{
  config,
  pkgs,
  lib,
  inputs,
  agenix,
  system,
  ...
}: {
  imports = [
    agenix.nixosModules.default
  ];

  environment.systemPackages = [
    inputs.agenix.packages."${system}".default
  ];
}
