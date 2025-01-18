{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib; {
  home.sessionVariables = {
    PAGER = "less -FR --mouse";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  home.packages = with pkgs; [
    nvd # diffing nix derivations
    nix-diff
    nix-zsh-completions
    just

    git-absorb

    # -- terminal tools
    fd
    jq
    tldr
    httpie

    # yazi # file browser

    unzip
    p7zip

    # various system monitor
    htop
    btop
    zenith # in rust
    s-tui # shows termperature and fan speed
    diskonaut # disk usage

    # --- keyring
    gpg-tui
    xplr # tui file explorer used in gpg-tui
  ];

  programs.fd = {
    enable = true;
    # extraOptions = "--no-ignore-vcs";
  };

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
    userEmail = "git@stfl.dev";
    ignores = ["*~" "*.swp" "my-patches"];
    difftastic = {
      enable = false; # TODO unfortunatly, this breaks things in magit
      background = "dark";
    };
    aliases = {
      a = "add";
      br = "branch";
      c = "commit";
      ca = "commit -a";
      cam = "commit -am";
      cl = "clone";
      co = "checkout";
      d = "diff";
      # dt    = "difftool";
      f = "fetch";
      graph = "log --graph --decorate --oneline --all";
      gr = "log --graph --all --pretty=format:'%Cred%h%Creset %Cgreen%ad%Creset -%C(bold cyan)%d%Creset %s %C(magenta)<%an>%Creset' --date=short";
      h = "help";
      l = "log --topo-order --pretty=format:'%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'";
      lg = "log --graph --pretty=format:'%Cred%h%Creset %Cgreen%ad%Creset -%C(bold cyan)%d%Creset %s %C(magenta)<%an>%Creset' --date=short";
      ls = "ls-files";
      m = "merge";
      pl = "pull";
      pu = "push";
      s = "status";
      rb = "rebase";
      # cp    = "cherry-pick";
    };
    extraConfig = {
      core.pager = "less -FR --mouse";
      init.defaultBranch = "main";
      branch.autoSetupMerge = "always";
      branch.autoSetupRebase = "always";
      sendEmail = {
        annotate = true;
        confirm = "always";
        suppresscc = "all";
      };
      format.signOff = true;
      lfs."https://github.com".locksverify = false; # github does not support lfs locksverify and git-sync complains about it
    };
  };

  programs.ssh = {
    enable = true;
    # package = pkgs.openssh;   // only needed if ssh-client from the system is not desired
    forwardAgent = true;
    addKeysToAgent = "yes";
    controlMaster = "auto";
    controlPersist = "10m";
    hashKnownHosts = true;
    compression = true;
    serverAliveInterval = 10; # seconds
    serverAliveCountMax = 10;
    includes = [
      "${config.home.homeDirectory}/.ssh/config.d/*"
      "${config.home.homeDirectory}/.ssh/config-extra.d/*"
    ];
    matchBlocks."github.com" = {
      user = "git";
      identityFile = ["${config.home.homeDirectory}/.ssh/id_ed25519_stfl"];
      identitiesOnly = true;
    };
  };
  home.file.".ssh/config.d.ln/" = {
    recursive = true;
    source = ../../config/ssh;
    onChange = ''${getExe pkgs.rsync} -rL --chown "stefan:users" --del ~/.ssh/config.d.ln/ ~/.ssh/config.d/'';
  };

  home.activation.createSshConfigExtraDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p ${config.home.homeDirectory}/.ssh/config-extra.d/
  '';

  # workaround to have a full copy of the config
  home.file.".ssh/config" = {
    target = ".ssh/config.ln";
    onChange = ''cat ~/.ssh/config.ln > ~/.ssh/config && chmod 600 ~/.ssh/config'';
  };

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

      setw -g window-status-format "#[fg=colour0,bg=colour0,nobold,nounderscore,noitalics]#[default] #I #W #[fg=colour0,bg=colour0,nobold,nounderscore,noitalics]"

      setw -g window-status-current-format "#[fg=colour0,bg=colour11,nobold,nounderscore,noitalics]#[fg=colour7,bg=colour11] #I  #W #[fg=colour11,bg=colour0,nobold,nounderscore,noitalics]"
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true; # TODO?
    autocd = true;
    # cdpath = [ ];  # List of paths to autocomplete calls to cd.
    autosuggestion = {
      enable = true;
      highlight = "fg=#78888a";
      strategy = ["history"];
    };
    defaultKeymap = "viins";
    dotDir = ".config/zsh";
    history = {
      append = true;
      # expireDuplicatesFirst = true;
      ignoreAllDups = true;
      extended = true; # Save timestamp into the history file.
      ignoreSpace = true;
    };
    historySubstringSearch = {
      enable = true;
      searchDownKey = [
        "^J"
        "^[[B"
      ];
      searchUpKey = [
        "^K"
        "^[[A"
      ];
    };
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
        "line"
        "root"
      ];
    };

    shellAliases = {
      x = "exit";
      g = "git";
      ip = "ip --color=auto";
      ipp = "ip -br addr";
      ipa = "ip -br addr";
      ipl = "ip -br link";
      "--" = "cd -";
      "1" = "cd -1";
      "2" = "cd -2";
      "3" = "cd -3";
      "4" = "cd -4";
      "5" = "cd -5";
      "6" = "cd -6";
      "7" = "cd -7";
      "8" = "cd -8";
      "9" = "cd -9";
    };

    initExtra = ''
      # Directory convenience functions
      setopt auto_pushd
      setopt pushd_ignore_dups
      setopt pushdminus

      bindkey '^A' beginning-of-line
      bindkey '^E' end-of-line

      # Pos1 End buttons
      bindkey '^[[H' beginning-of-line
      bindkey '^[[F' end-of-line

      # Backspace that wraps around lines
      bindkey "^?" backward-delete-char

      # delete in normal mode
      bindkey "^[[3~" delete-char
      bindkey -M vicmd "^[[3~" delete-char

      bindkey "^[OC" forward-char
      bindkey "^[OD" backward-char

      # bindkey '^[[1;5C' forward-word
      # bindkey '^[[1;5D' backward-word
      # bindkey '^[[1;2C' forward-word
      # bindkey '^[[1;2D' backward-word

      # C-left and C-right
      bindkey "^F" vi-forward-word
      bindkey "^[^[[C" vi-forward-word
      bindkey "^[Oc" vi-forward-word
      bindkey "^[[5C" vi-forward-word
      bindkey "^[[1;5C" vi-forward-word
      bindkey "^[^[[D" vi-backward-word
      bindkey "^[Od" vi-backward-word
      bindkey "^[[1;5D" vi-backward-word
      bindkey "^[[5D" vi-backward-word

      bindkey "^_" undo
      bindkey " " magic-space

      # Inserts 'sudo ' at the beginning of the line.
      function prepend-sudo {
        if [[ "$BUFFER" != su(do|)\ * ]]; then
          BUFFER="sudo $BUFFER"
          (( CURSOR += 5 ))
        fi
      }
      zle -N prepend-sudo
      bindkey "^X^S" prepend-sudo

      # Expand aliases
      # function glob-alias {
      #   zle _expand_alias
      #   zle expand-word
      #   zle magic-space
      # }
      # zle -N glob-alias
      # bindkey "^@" glob-alias
    '';

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

    # NOTE prezto bindkeys
    # "^@" glob-alias
    # "^A"-"^C" self-insert
    # "^D" list-choices
    # "^E" vi-add-eol
    # "^F" vi-forward-word
    # "^G" list-expand
    # "^H" vi-backward-delete-char
    # "^I" fzf-completion
    # "^J" accept-line
    # "^K" self-insert
    # "^L" clear-screen
    # "^M" accept-line
    # "^N"-"^P" self-insert
    # "^Q" push-line-or-edit
    # "^R" fzf-history-widget
    # "^S" self-insert
    # "^T" fzf-file-widget
    # "^U" vi-kill-line
    # "^V" vi-quoted-insert
    # "^W" vi-backward-kill-word
    # "^X^R" _read_comp
    # "^X^S" prepend-sudo
    # "^X?" _complete_debug
    # "^XC" _correct_filename
    # "^Xa" _expand_alias
    # "^Xc" _correct_word
    # "^Xd" _list_expansions
    # "^Xe" _expand_word
    # "^Xh" _complete_help
    # "^Xm" _most_recent_file
    # "^Xn" _next_tags
    # "^Xt" _complete_tag
    # "^X~" _bash_list-choices
    # "^Y"-"^Z" self-insert
    # "^[" vi-cmd-mode
    # "^[^[[C" vi-forward-word
    # "^[^[[D" vi-backward-word
    # "^[," _history-complete-newer
    # "^[/" _history-complete-older
    # "^[E" expand-cmd-path
    # "^[M" copy-prev-shell-word
    # "^[OA" history-substring-search-up
    # "^[OB" history-substring-search-down
    # "^[OC" forward-char
    # "^[OD" backward-char
    # "^[OF" end-of-line
    # "^[OH" beginning-of-line
    # "^[OP" _prezto-zle-noop
    # "^[OQ" _prezto-zle-noop
    # "^[OR" _prezto-zle-noop
    # "^[OS" _prezto-zle-noop
    # "^[Oc" vi-forward-word
    # "^[Od" vi-backward-word
    # "^[Q" push-line-or-edit
    # "^[[15~" _prezto-zle-noop
    # "^[[17~" _prezto-zle-noop
    # "^[[18~" _prezto-zle-noop
    # "^[[19~" _prezto-zle-noop
    # "^[[1;5C" vi-forward-word
    # "^[[1;5D" vi-backward-word
    # "^[[200~" bracketed-paste
    # "^[[20~" _prezto-zle-noop
    # "^[[21~" _prezto-zle-noop
    # "^[[23~" _prezto-zle-noop
    # "^[[24~" _prezto-zle-noop
    # "^[[2~" overwrite-mode
    # "^[[3~" delete-char
    # "^[[5;5~" _prezto-zle-noop
    # "^[[5C" vi-forward-word
    # "^[[5D" vi-backward-word
    # "^[[5~" _prezto-zle-noop
    # "^[[6;5~" _prezto-zle-noop
    # "^[[6~" _prezto-zle-noop
    # "^[[A" up-line-or-history
    # "^[[B" down-line-or-history
    # "^[[C" vi-forward-char
    # "^[[D" vi-backward-char
    # "^[[Z" reverse-menu-complete
    # "^[c" fzf-cd-widget
    # "^[e" expand-cmd-path
    # "^[m" copy-prev-shell-word
    # "^[q" push-line-or-edit
    # "^[~" _bash_complete-word
    # "^\\\\"-"^\^" self-insert
    # "^_" undo
    # " " magic-space
    # "!"-"-" self-insert
    # "." expand-dot-to-parent-directory-path
    # "/"-"~" self-insert
    # "^?" backward-delete-char
    # "\M-^@"-"\M-^?" self-insert

    plugins = [
      {
        name = "cd-dot-expansion";
        src = pkgs.fetchFromGitHub {
          owner = "wazum";
          repo = "zsh-directory-dot-expansion";
          rev = "master";
          sha256 = "Hs4n43ceJoTKrh6Z4b/ozZ0McL0IXgdufljRtP++dVs=";
        };
      }
    ];
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    changeDirWidgetCommand = "fd --type d"; # ALT-C
    changeDirWidgetOptions = ["--preview 'tree -C {} | head -200'"];
    defaultCommand = "fd --type f";
    fileWidgetCommand = "fd --type f"; # CTRL-T
    fileWidgetOptions = ["--preview 'head {}'"];
    tmux.enableShellIntegration = false;
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

  xdg.configFile."sqlite3/sqliterc".text = ''
    .mode column
    .headers on
    .separator ROW "\n"
    .nullvalue NULL
  '';
}
