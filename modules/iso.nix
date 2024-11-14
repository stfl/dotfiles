{pkgs, ...}: {
  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
  networking.firewall.allowedTCPPorts = [22];

  # users.users.root.initialPassword = "nixos";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGSjWr1X80phoVLQDpXyn26SAPytikVdGyTK1ifYxR6"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBiwk8cA73Qqcl9d40C+TOd5xY2eA0LPGzuHITGC3e3h"
  ];

  environment.systemPackages = with pkgs; [
    wget
    dig
    git
    neovim
    htop
    killall
    rsync
    mtr
  ];
}
