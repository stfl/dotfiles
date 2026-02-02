# Home-manager specific configuration
# Only import this module in hosts that use home-manager
{ agenix, ... }:
{
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    sharedModules = [
      agenix.homeManagerModules.default
    ];
  };
}
