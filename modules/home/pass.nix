{
  config,
  lib,
  pkgs,
  ...
}:
let
  pass-pkg = pkgs.pass-wayland.withExtensions (ext: [
    ext.pass-otp
  ]);

  autoPushHook = pkgs.writeShellScript "auto-push-hook" ''
    timeout 3s ${pkgs.git}/bin/git ls-remote origin --exit-code -q
    if [ $? -gt 0 ]; then
      echo "Sync failed: Cannot reach remote `${pkgs.git}/bin/git remote get-url origin`"
    else
      ${pkgs.git}/bin/git pull --rebase
      ${pkgs.git}/bin/git push -u origin main
    fi
  '';

  PASSWORD_STORE_DIR = config.programs.password-store.settings.PASSWORD_STORE_DIR;
  setupPasswordStore = pkgs.writeShellApplication {
    name = "setup-password-store";
    runtimeInputs = with pkgs; [
      openssh
      git
    ];
    text = ''
      if [ ! -d ${PASSWORD_STORE_DIR} ]; then
         ${pkgs.git}/bin/git clone git@github.com:stfl/password-store.git ${PASSWORD_STORE_DIR}
         ln -s ${autoPushHook} ${PASSWORD_STORE_DIR}/.git/hooks/post-commit
      fi
    '';
  };
in
rec {
  home.packages = with pkgs; [
    wofi-pass
    sequoia-sq
    pass-git-helper

    # --- keyring
    gpg-tui
    xplr # tui file explorer used in gpg-tui
  ];

  programs.password-store = {
    enable = true;
    package = pass-pkg;
  };

  services.pass-secret-service.enable = true;

  home.activation.setupPasswordStore = lib.hm.dag.entryAfter [
    "writeBoundary"
  ] "${lib.getExe setupPasswordStore}";

  # systemd.user.timers.password-store-sync = {
  #   description = "Sync password-store git repo timer";
  #   timerConfig.OnBootSec = "1m";
  #   timerConfig.OnUnitInactiveSec = "1m";
  #   timerConfig.Unit = "password-store-sync.service";
  #   wantedBy = ["timers.target"];
  #   # TODO after Network
  # };
  # systemd.user.services.password-store-sync = {
  #   description = "Sync password-store git repo";
  #   serviceConfig.PassEnvironment = "PASSWORD_STORE_DIR";
  #   script = ''
  #     ret=`${pass-pkg}/bin/pass git pull --no-rebase origin`
  #     if [[ $? != 0 ]]; then
  #          ${pkgs.libnotify}/bin/notify-send \
  #                --urgency=critical --hint=int:transient:1 "password-store pull failed" "$ret"
  #   '';
  # };

  programs.browserpass = {
    enable = true;
    browsers = [
      "brave"
      "firefox"
      "chrome"
    ];
  };

  programs.rbw = {
    enable = true;
    settings = {
      email = "ste.lendl@gmail.com";
      pinentry = pkgs.pinentry-gtk2;
    };
  };

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableZshIntegration = true;
    pinentry.package = pkgs.pinentry-gtk2;
    defaultCacheTtl = 64800; # 18 hours
    defaultCacheTtlSsh = 64800;
    maxCacheTtl = 64800;
    maxCacheTtlSsh = 64800;
    extraConfig = ''
      no-allow-external-cache
    '';
  };

  services.ssh-agent.enable = true;
}
