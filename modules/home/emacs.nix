{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  emacs-pkg = pkgs.emacs-unstable-pgtk;
in {
  home.sessionVariables = {
    EDITOR = "${emacs-pkg}/bin/emacsclient";
    LSP_USE_PLISTS = "true"; # for emacs lsp-mode
  };

  home.sessionPath = [
    "${config.xdg.configHome}/emacs/bin"
  ];

  home.packages = with pkgs; [
    # org-protocol

    # -- nix tooling
    nil # lsp
    alejandra # nix formatter

    # AI
    copilot-node-server
    nodejs # TODO maybe I don't need this anymore
    aider-chat
    # khoj

    ripgrep
    fd
    pinentry-emacs
    zstd
    editorconfig-core-c
    sqlite
    age

    pandoc
    zip

    typst
    typst-lsp
    tree-sitter-grammars.tree-sitter-typst # TODO all grammers may be installed already?

    # -- spelling
    # languagetool
    # ltex-ls
    # enchant
    # (aspellWithDicts (dicts: with dicts; [en en-computers en-science de]))
  ];

  programs.emacs = {
    enable = true;
    package = emacs-pkg;
    extraPackages = epkgs:
      with epkgs; [
        treesit-grammars.with-all-grammars
        vterm
        pdf-tools
      ];
  };

  # services.emacs = {
  #   enable = false;
  #   package = emacs-pkg;
  #   socketActivation.enable = true;
  #   defaultEditor = true;
  #   client.enable = true;
  # };

  # https://github.com/hlissner/dotfiles/commit/0df9027010b424410a4622eba54b979c256f0efb
  # TODO system.userActivationScripts ??
  # system.userActivationScripts = {
  #   installDoomEmacs = ''
  #     if [ ! -d "$XDG_CONFIG_HOME/emacs" ]; then
  #        git clone --depth=1 --single-branch "${cfg.doom.repoUrl}" "$XDG_CONFIG_HOME/emacs"
  #        git clone "${cfg.doom.configRepoUrl}" "$XDG_CONFIG_HOME/doom"
  #     fi
  #   '';
  # };

  programs.git.extraConfig.core.editor = "${emacs-pkg}/bin/emacsclient --no-wait";

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
