let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGSjWr1X80phoVLQDpXyn26SAPytikVdGyTK1ifYxR6";
  falke = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO2sxIJEgEREgxFMaM7rMPNVg8bW1xNydcu9nU6G/AG6";
in {
  "wg-pulswerk-private.age".publicKeys = [key falke];
  "wg-pulswerk-preshared.age".publicKeys = [key falke];
}
