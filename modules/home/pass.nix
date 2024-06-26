{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    wofi-pass
    sequoia-sq
    pass-git-helper
  ];

  programs.password-store = {
    enable = true;
    package = pkgs.pass-wayland.withExtensions (ext: [
      ext.pass-otp
    ]);
  };

  services.pass-secret-service.enable = true;

  programs.browserpass = {
    enable = true;
    browsers = ["brave" "firefox" "chrome"];
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
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    defaultCacheTtl = 64800; # 18 hours
    defaultCacheTtlSsh = 64800;
    maxCacheTtl = 64800;
    maxCacheTtlSsh = 64800;
    # sshKeys = [];
    extraConfig = ''
      allow-emacs-pinentry
      # allow-loopback-pinentry
    '';
  };
}
