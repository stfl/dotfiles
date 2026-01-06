{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];

  nix.settings = { sandbox = false; };

  proxmoxLXC = {
    manageNetwork = false;
    privileged = lib.mkDefault false;
    # privileged = true;
  };

  services.fstrim.enable = false; # Let Proxmox host handle fstrim

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.PermitRootLogin = "yes";
  };

  # Cache DNS lookups to improve performance
  services.resolved = {
    extraConfig = ''
      Cache=true
      CacheFromLocalhost=true
    '';
  };

}
