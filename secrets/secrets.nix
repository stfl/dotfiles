let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGSjWr1X80phoVLQDpXyn26SAPytikVdGyTK1ifYxR6";
  falke = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO2sxIJEgEREgxFMaM7rMPNVg8bW1xNydcu9nU6G/AG6";
  kondor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDeRsZ7HWpV+CMDTR5TXR7cHPs6uK8tSQ+B3/0GSXjoy";
in {
  "wg-pulswerk-private.age".publicKeys = [key falke kondor];
  "wg-pulswerk-preshared.age".publicKeys = [key falke kondor];
  "wg-hei-private.age".publicKeys = [key falke kondor];
  "wg-hei-preshared.age".publicKeys = [key falke kondor];
  "3datax-ssh-config.age".publicKeys = [key falke];
}
