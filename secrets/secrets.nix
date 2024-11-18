let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGSjWr1X80phoVLQDpXyn26SAPytikVdGyTK1ifYxR6";

  # /etc/ssh/ssh_host_ed25519_key.pub
  falke = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO2sxIJEgEREgxFMaM7rMPNVg8bW1xNydcu9nU6G/AG6"; # TODO falke key does not exist anymore
  kondor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIlV7lYyECZGTG1mdp9uj6fkhqS060reE/+v9jZ63dXv";
in {
  "wg-pulswerk-private.age".publicKeys = [key falke kondor];
  "wg-pulswerk-preshared.age".publicKeys = [key falke kondor];
  "wg-hei-private.age".publicKeys = [key falke kondor];
  "wg-hei-preshared.age".publicKeys = [key falke kondor];
  "3datax-ssh-config.age".publicKeys = [key falke];
}
