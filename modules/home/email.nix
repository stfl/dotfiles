{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.mbsync.enable = true;
  services.mbsync = {
    enable = true;
    frequency = "*:0/5";
    verbose = true;
    postExec = "${pkgs.notmuch}/bin/notmuch new --verbose";
  };

  programs.notmuch = {
    enable = true;
    new.tags = [ "new" ];
    hooks.postNew = "${pkgs.afew}/bin/afew -t -n -v";
  };

  programs.msmtp = {
    enable = true;
  };

  programs.afew.enable = true;
  xdg.configFile."afew/config".source = lib.mkForce ../../config/afew/config;
}
