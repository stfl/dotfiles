{ config, lib, pkgs, ... }:

with lib;

let
  org-protocol = pkgs.makeDesktopItem {
    name = "org-protocol";
    desktopName = "Org Protocol";
    exec = "emacsclient -- %u";
    terminal = false;
    mimeTypes = ["x-scheme-handler/org-protocol"];
  };
in {

  home.sessionVariables = {
    EDITOR = "${config.programs.emacs.finalPackage}/bin/emacsclient";
    LSP_USE_PLISTS = "true";  # for emacs lsp-mode
  };

  home.sessionPath = [
    "${config.xdg.configHome}/emacs/bin"
  ];

  home.packages = with pkgs; [
    org-protocol
    emacs-lsp-booster

    rnix-lsp

    # -- spelling
    # languagetool
    # ltex-ls
    # enchant
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science de ]))
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
    extraPackages = epkgs: with epkgs; [ vterm ];
  };

  services.emacs = {
    enable = false;
    socketActivation.enable = true;
    defaultEditor = true;
    client.enable = true;
  };

  programs.git.extraConfig.core.editor = "${config.programs.emacs.finalPackage}/bin/emacsclient --no-wait";

  services.gpg-agent.extraConfig = ''
      allow-emacs-pinentry
      # allow-loopback-pinentry
    '';

  services.git-sync = {
    enable = true;
    repositories = {
      doomemacs = {
        interval = 1800;  # 30min (in case inotify does not trigger)
        path = "${config.xdg.configHome}/doom";
        uri = "git@github.com:stfl/doom.d.git";
      };
      org = {
        interval = 600;  # 10min
        path = "${config.home.homeDirectory}/.org";
        uri = "git@github.com:stfl/org.git";
      };
    };
  };

  systemd.user.services.git-sync-org.Unit.After = [ "ssh-agent.service" ];
  systemd.user.services.git-sync-org.Service.Environment = [ "SSH_AUTH_SOCK=%t/ssh-agent" ];
  systemd.user.services.git-sync-org.Service.Restart = mkForce "on-failure";

  # TODO until this has been merged: https://github.com/nix-community/home-manager/pull/4849
  xdg.configFile."systemd/user/git-sync-org.service.d/override.conf".text = ''
    [Service]
    Environment=PATH=${lib.makeBinPath (with pkgs; [ openssh git git-lfs ])}
  '';

  systemd.user.services.git-sync-doomemacs.Unit.After = [ "ssh-agent.service" ];
  systemd.user.services.git-sync-doomemacs.Service.Environment = [ "SSH_AUTH_SOCK=%t/ssh-agent" ];
  systemd.user.services.git-sync-doomemacs.Service.Restart = mkForce "on-failure";


}
