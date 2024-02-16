{ pkgs, lib, config, options, ... }:

with lib;

{
  xdg.enable = true;
  xdg.mime.enable = true;

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.sessionVariables = {
    PAGER = "less -FR --mouse";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  home.packages = with pkgs; [
    nixpkgs-fmt
    nvd

    # -- git and github runner
    gitAndTools.gh
    gitAndTools.git-crypt
    act
    git-absorb

    # -- terminal tools
    nix-zsh-completions
    fd
    jq
    tldr
    httpie
    feh

    yazi # file browser

    atop
    htop
    # mtr  >> does not work as unprivilgeded user

    # --- keyring
    gpg-tui
    xplr       # tui file explorer used in gpg-tui
    git-crypt

    # -- python
    poetry
  ];

  programs.ripgrep = {
    enable = true;
    arguments = [
      # Don't let ripgrep vomit really long lines to my terminal, and show a preview.
      "--max-columns=150"
      "--max-columns-preview"

      # Add my 'web' type.
      # "--type-add 'web:*.{html,css,js}*'"

      # Search hidden files / directories (e.g. dotfiles) by default
      # --hidden

      "--glob=!.git/*"

      # Set the colors.
      "--colors=line:style:bold"

      # Because who cares about case!?
      "--smart-case"
    ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    stdlib = ''
      layout_anaconda() {
        local ACTIVATE="${config.home.homeDirectory}/.anaconda3/bin/activate"

        if [ -n "$1" ]; then
          # Explicit environment name from layout command.
          local env_name="$1"
          source $ACTIVATE $env_name
        elif (grep -q name: environment.yml); then
          # Detect environment name from `environment.yml` file in `.envrc` directory
          source $ACTIVATE `grep name: environment.yml | sed -e 's/name: //' | cut -d "'" -f 2 | cut -d '"' -f 2`
        else
          (>&2 echo No environment specified);
          exit 1;
        fi;
      }
    '';
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Stefan Lendl";
    userEmail = "ste.lendl@gmail.com";
    ignores = [ "*~" "*.swp" "my-patches" ];
    aliases = {
      a     = "add";
      br    = "branch";
      c     = "commit";
      ca    = "commit -a";
      cam   = "commit -am";
      cl    = "clone";
      co    = "checkout";
      d     = "diff";
      # dt    = "difftool";
      f     = "fetch";
      graph = "log --graph --decorate --oneline --all";
      gr    = "log --graph --all --pretty=format:'%Cred%h%Creset %Cgreen%ad%Creset -%C(bold cyan)%d%Creset %s %C(magenta)<%an>%Creset' --date=short";
      h     = "help";
      l     = "log --topo-order --pretty=format:'%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'";
      lg    = "log --graph --pretty=format:'%Cred%h%Creset %Cgreen%ad%Creset -%C(bold cyan)%d%Creset %s %C(magenta)<%an>%Creset' --date=short";
      ls    = "ls-files";
      m     = "merge";
      pl    = "pull";
      pu    = "push";
      s     = "status";
      rb    = "rebase";
      # cp    = "cherry-pick";
    };
    extraConfig = {
      core.pager = "less -FR --mouse";
      branch.autoSetupMerge = "always";
      branch.autoSetupRebase = "always";
      sendEmail = {
        annotate = true;
        confirm = "always";
        suppresscc = "all";
      };
      format.signOff = true;
      lfs."https://github.com".locksverify = false;    # github does not support lfs locksverify and git-sync complains about it
    };
  };

  programs.ssh = {
    enable = true;
    package = pkgs.openssh;
    forwardAgent = false;
    controlMaster = "auto";
    controlPersist = "10m";
    serverAliveInterval = 10; # seconds
    includes = [ "~/.ssh/config.d/*" ];
    extraConfig = ''
      AddKeysToAgent yes
    '';
  };
  home.file.".ssh/config.d/" = {
    recursive = true;
    source = ../config/ssh;
  };

  services.ssh-agent.enable = true;

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    keyMode = "vi";
    shortcut = "a";
    historyLimit = 300000;
    newSession = true;
    customPaneNavigationAndResize = true;
    resizeAmount = 10;
    escapeTime = 0;
    terminal = "screen-256color";
    shell = "${pkgs.zsh}/bin/zsh";

    plugins = with pkgs; [
      tmuxPlugins.yank
    ];

    extraConfig = ''
      set-option -g -q mouse on

      # emacs-like split
      bind-key v split-window -h
      bind-key s split-window -v

      # cycle pane selection
      bind C-a select-pane -t :.+

      bind-key p paste-buffer
      bind-key -T copy-mode-vi 'v' send-keys -X begin-selection

      # reorder windows in status bar by drag & drop
      bind-key -n MouseDrag1Status swap-window -t=

      bind-key W choose-session
      bind-key -n C-l send-keys 'C-l' \; clear-history


      # This tmux statusbar config was (originally) created by tmuxline.vim
      # on Mon, 08 Aug 2016
      setw -g monitor-activity on
      set-window-option -g clock-mode-colour colour11

      set -g status "on"
      # set -g status-utf8 "on"
      set -g status-style bg="colour0"
      set -g status-style "none"
      set -g status-justify "left"
      set -g status-left-length "100"
      set -g status-right-length "100"
      set -g status-left-style "none"
      set -g status-right-style "none"
      set -g message-style bg="colour11"
      set -g message-style fg="colour7"
      set -g message-command-style bg="colour11"
      set -g message-command-style fg="colour7"
      set -g pane-border-style fg="colour11"
      # set -g pane-active-border-style fg="colour14"
      set-option -g pane-active-border fg="colour166"
      setw -g window-status-style fg="colour10"
      setw -g window-status-style bg="colour0"
      setw -g window-status-style "none"
      setw -g window-status-activity-style bg="colour0"
      setw -g window-status-activity-style "none"
      setw -g window-status-activity-style fg="colour14"
      setw -g window-status-separator ""

      set -g status-left "#[fg=colour15,bg=colour14,bold] #S #[fg=colour14,bg=colour11,nobold,nounderscore,noitalics]#[fg=colour7,bg=colour11] #F #[fg=colour11,bg=colour0,nobold,nounderscore,noitalics]"

      # TODO > i can't be botherd to make this work...
      # if-shell "[[ #{client_width} > 180 ]]" \
      # "set -g status-right \"#[fg=colour0,bg=colour0,nobold,nounderscore,noitalics]#[fg=colour10,bg=colour0]  %a #[fg=colour11,bg=colour0,nobold,nounderscore,noitalics]#[fg=colour7,bg=colour11] %d. %h  %H:%M #[fg=colour14,bg=colour11,nobold,nounderscore,noitalics]#[fg=colour15,bg=colour14] #H \"" \
      # "set -g status-right \"#[fg=colour11,bg=colour0,nobold,nounderscore,noitalics]#[fg=colour7,bg=colour11] %d. %h  %H:%M #[fg=colour14,bg=colour11,nobold,nounderscore,noitalics]#[fg=colour15,bg=colour14] #H \""

      setw -g window-status-format "#[fg=colour0,bg=colour0,nobold,nounderscore,noitalics]#[default] #I #W #[fg=colour0,bg=colour0,nobold,nounderscore,noitalics]"

      setw -g window-status-current-format "#[fg=colour0,bg=colour11,nobold,nounderscore,noitalics]#[fg=colour7,bg=colour11] #I  #W #[fg=colour11,bg=colour0,nobold,nounderscore,noitalics]"
    '';
  };

  programs.zsh = {
    enable = true;
    profileExtra = ''
      # Need to disable features to support TRAMP
      if [ "$TERM" = dumb ]; then
          unsetopt zle prompt_cr prompt_subst
          whence -w precmd >/dev/null && unfunction precmd
          whence -w preexec >/dev/null && unfunction preexec
          unset RPS1 RPROMPT
          PS1='$ '
          PROMPT='$ '
      fi
    '';
    prezto = {
      enable = true;
      pmodules = [
        "environment"
        "terminal"
        "editor"
        "history"
        "history-substring-search"
        "directory"
        "spectrum"
        "syntax-highlighting"
        "utility"
        "completion"
        "autosuggestions"
        "archive"
        # "fasd"
        "git"
        "rsync"
        # "prompt"  > starship instead
        # "ssh"
        # "gpg"
      ];
      editor = {
        keymap = "vi";
        dotExpansion = true;
      };
    };

    shellAliases = {
      x = "exit";
      ip = "ip --color=auto";
      ipp = "ip -br addr";
      ipa = "ip -br addr";
      ipl = "ip -br link";
    };
    # workaround when using prezto, which sets up $PATH in .zprofile which is sourced after .zshenv
    initExtra = mkIf config.programs.zsh.prezto.enable ''
      # need to setup $PATH properly again to prefer nix installed packages
      . "${pkgs.nix}/etc/profile.d/nix.sh"
      typeset -U path
    '';
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    changeDirWidgetCommand = "fd --type d";  # ALT-C
    changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    defaultCommand = "fd --type f";
    fileWidgetCommand = "fd --type f";   # CTRL-T
    fileWidgetOptions = [ "--preview 'head {}'" ];
    tmux.enableShellIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.lsd = {
    enable = true;
    enableAliases = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  programs.bat = {
    enable = true;
    config = {
      map-syntax = [
        "*.jenkinsfile:Groovy"
        "*.props:Java Properties"
      ];
      # pager = "less -FR";  # TODO use $PAGER?
    };
    # extraPackages = [];
# https://github.com/nix-community/home-manager/blob/master/modules/programs/bat.nix
  };

  services.syncthing = {
    enable = true;
    # tray.enable = true;
  };

  accounts.email = {
    maildirBasePath = "Mail";
    accounts = {
      "proxmox" = {
        address = "s.lendl@proxmox.com";
        primary = true;
        realName = "Stefan Lendl";
        userName = "s.lendl";
        passwordCommand = "${config.programs.rbw.package}/bin/rbw get webmail.proxmox.com";
        # signature = {TODO};
        folders = {
          drafts = "Entw&APw-rfe";
          inbox = "Inbox";
          sent = "Gesendete Objekte";
        };
        imap = {
          host = "webmail.proxmox.com";
          # port = 993;
          tls.enable = true;
          # imapnotify = {
          #   enable = true;
          #   boxes = [
          #     "Inbox";
          #   ];
          # };
        };
        smtp = {
          host = "mail.proxmox.com";
          port = 25;
          tls.enable = false;
          # port =
        };
        msmtp = {
          enable = true;
          extraConfig = {
            auth = "off";
          };
        };
        mbsync = {
          enable = true;
          create = "both";  # TODO "maildir" // imap" // "both" ??
          # remove = "both";
        };
        # mu.enable = true;
        notmuch.enable = true;
        # thunderbird.enable = true;
      };
    };
  };

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
  xdg.configFile."afew/config".source = lib.mkForce ../config/afew/config;
}
