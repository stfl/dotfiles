{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # gnome.seahorse
    # pass-wayland
    wofi-pass # TODO add key mapping to sway!!

    # pass-secret-service
    # passExtensions.pass-otp
    pass-git-helper
  ];

  programs.password-store = {
    enable = true;
    package = pkgs.pass-wayland.withExtensions (ext: [
      ext.pass-otp
    ]);
  };

  services.pass-secret-service.enable = true;

  # TODO
  # accounts.email.accounts."proxmox".passwordCommand =
  #   "${config.programs.rbw.package}/bin/rbw get webmail.proxmox.com";

  # TODO potentially move sway keybind for wofi-pass here
  # wayland.windowManager.sway.config.keybindings = let
  #   cfg = config.wayland.windowManager.sway;
  #   modifier = cfg.config.modifier;
  # in {
  #   # wofi-pass
  #   "${modifier}+g" = "exec --no-startup-id wofi-pass --autotype";
  # };

  programs.browserpass = {
    enable = true;
    browsers = ["brave" "firefox" "chrome"];
  };

  programs.rbw = {
    enable = true;
    settings = {
      email = "ste.lendl@gmail.com";
      # lock_timeout = 300;
      pinentry = "qt";
    };
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableZshIntegration = true;
    enableSshSupport = true;
    pinentryFlavor = "qt";
    defaultCacheTtl = 64800; # 18 hours
    defaultCacheTtlSsh = 64800;
    maxCacheTtl = 64800;
    maxCacheTtlSsh = 64800;
  };
}
