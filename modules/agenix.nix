{
  agenix,
  pkgs,
  ...
}: {
  imports = [
    agenix.nixosModules.default
  ];

  environment.systemPackages = [
    agenix.packages.${pkgs.system}.default
  ];
}
