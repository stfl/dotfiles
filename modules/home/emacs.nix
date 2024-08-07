{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # TODO this should already exist in emacs 29.2
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
    LSP_USE_PLISTS = "true"; # for emacs lsp-mode
  };

  home.sessionPath = [
    "${config.xdg.configHome}/emacs/bin"
  ];

  home.packages = with pkgs; [
    org-protocol
    emacs-lsp-booster

    # -- nix tooling
    nil # lsp
    alejandra # formatter
    codeium

    nodejs

    pandoc
    zip

    # -- spelling
    # languagetool
    # ltex-ls
    # enchant
    # (aspellWithDicts (dicts: with dicts; [en en-computers en-science de]))
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
    extraPackages = epkgs: with epkgs; [vterm pdf-tools];
  };

  services.emacs = {
    enable = false;
    socketActivation.enable = true;
    defaultEditor = true;
    client.enable = true;
  };

  programs.git.extraConfig.core.editor = "${config.programs.emacs.finalPackage}/bin/emacsclient --no-wait";

  services.git-sync = {
    enable = true;
    repositories = {
      org = {
        interval = 600; # 10min
        path = "${config.home.homeDirectory}/.org";
        uri = "git@github.com:stfl/org.git";
        extraPackages = with pkgs; [git-lfs];
      };
      doomemacs = {
        interval = 600;
        path = "${config.xdg.configHome}/doom";
        uri = "git@github.com:stfl/doom.d.git";
      };
    };
  };

  systemd.user.services.git-sync-org = {
    Unit.Requires = ["gpg-agent-ssh.socket"];
    Install.WantedBy = mkForce ["sway-session.target"];
    Service = {
      Environment = ["SSH_AUTH_SOCK=${config.systemd.user.sockets.gpg-agent-ssh.Socket.ListenStream}"];
      WorkingDirectory = "${config.home.homeDirectory}/.org";
      ExecStartPre = "${pkgs.git-sync}/bin/git-sync -n -s";
      Restart = mkForce "on-failure";
    };
  };

  systemd.user.services.git-sync-org-resume = {
    Unit.After = ["suspend.target"];
    Install.WantedBy = ["suspend.target"];
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user --no-block restart git-sync-org.service";
    };
  };

  systemd.user.services.git-sync-doomemacs = {
    Unit.Requires = ["gpg-agent-ssh.socket"];
    Install.WantedBy = mkForce ["sway-session.target"];
    Service = {
      Environment = ["SSH_AUTH_SOCK=${config.systemd.user.sockets.gpg-agent-ssh.Socket.ListenStream}"];
      WorkingDirectory = "${config.xdg.configHome}/doom";
      ExecStartPre = "${pkgs.git-sync}/bin/git-sync -n -s";
      Restart = mkForce "on-failure";
    };
  };

  systemd.user.services.git-sync-doomemacs-resume = {
    Unit.After = ["suspend.target"];
    Install.WantedBy = ["suspend.target"];
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user --no-block restart git-sync-doomemacs.service";
    };
  };
}
