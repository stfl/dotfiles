let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGSjWr1X80phoVLQDpXyn26SAPytikVdGyTK1ifYxR6";

  # /etc/ssh/ssh_host_ed25519_key.pub
  pirol = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+lyPjaizlwlOz9KndAlv+HtUjl5rzXwzbXasB4soe2";
  kondor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIlV7lYyECZGTG1mdp9uj6fkhqS060reE/+v9jZ63dXv";
  servarr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHz3GtkpwHVpbSb4fKqmFoRcH6hN8i+srZens7L5fkm/";
in
{
  "wg-pulswerk-private.age".publicKeys =   [ key pirol kondor ];
  "wg-pulswerk-preshared.age".publicKeys = [ key pirol kondor ];
  "wg-hei-private.age".publicKeys =        [ key pirol kondor ];
  "wg-hei-preshared.age".publicKeys =      [ key pirol kondor ];
  "3datax-ssh-config.age".publicKeys =     [ key ];
  "wg-digirail-private.age".publicKeys =   [ key pirol kondor ];
  "wg-airvpn-norway-conf.age".publicKeys = [ key servarr ];
}
