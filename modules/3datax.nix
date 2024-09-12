{
  config,
  lib,
  pkgs,
  ...
}: {
  age.secrets."3datax-ssh-config" = {
    file = ../secrets/3datax-ssh-config.age;
    path = "/home/stefan/.ssh/config-extra.d/3datax.config";
    mode = "400";
    owner = "stefan";
    symlink = false;
  };
}
