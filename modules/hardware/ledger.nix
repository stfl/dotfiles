{pkgs, ...}: {
  hardware.ledger.enable = true;

  environment.systemPackages = with pkgs; [
    ledger-live-desktop
  ];
}
