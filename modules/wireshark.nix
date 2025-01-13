{
  config,
  lib,
  pkgs,
  USER,
  ...
}: {
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # install GUI wireshark
  };

  programs.tcpdump.enable = true;

  users.users.${USER}.extraGroups = ["wireshark"];
}
