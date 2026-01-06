# Home-manager specific configuration
# Only import this module in hosts that use home-manager
{
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };
}
