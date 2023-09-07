{ pkgs, lib, config, options, ... }:

with lib;

let
  nixGL = import ./nixGL.nix { inherit pkgs config; };
  swaylock_bin = "/usr/bin/swaylock";
in {
  home.username = "slendl";
  home.homeDirectory = "/home/slendl";
  home.stateVersion = "23.05";

  xdg.enable = true;
  xdg.mime.enable = true;
  targets.genericLinux.enable = true;

  programs.home-manager.enable = true;

  # set default nixGL prefix for this machine
  nixGLPrefix = lib.getExe pkgs.nixgl.nixGLIntel;

  fonts.fontconfig.enable = true;

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    nixpkgs-fmt

    (nixGL brave)

    gitAndTools.gh
    gitAndTools.git-crypt
    act

    nix-zsh-completions
    bat
    # fasd
    fd
    jq
    # ripgrep
    tldr
    httpie
    feh

    # sway // wayland
    # waybar
    # wlogout

    emacs29
    # cmake
    # gnumake
    # xdotool

    # exercism

    poetry
    nodejs_20
    yarn

    brightnessctl
    # arandr

    # libnotify
    # dex  # https://wiki.archlinux.org/index.php/XDG_Autostart
    # xss-lock  # i3lock
    libpulseaudio  # pulsectl

    # (nixGL signal-desktop)

    source-code-pro
    noto-fonts

    nixgl.nixGLIntel
  ];

  programs.ripgrep = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    # enableFishIntegration = true;
    nix-direnv.enable = true;
    stdlib = ''
      layout_anaconda() {
        local ACTIVATE="$HOME/.anaconda3/bin/activate"

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
    difftastic.enable = true;
    userName = "Stefan Lendl";
    userEmail = "ste.lendl@gmail.com";
    ignores = [ "*~" "*.swp" ];
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
  };

  programs.ssh = {
    enable = true;
    forwardAgent = false;
    controlMaster = "auto";
    controlPersist = "10m";
    includes = [ "~/.ssh/config.d/*" ];
  };
  home.file.".ssh/config.d/" = {
    recursive = true;
    source = ./config/ssh;
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

      # TODO > i can't be botherd to make this work...
      # if-shell "[[ #{client_width} > 180 ]]" \
      # "set -g status-right \"#[fg=colour0,bg=colour0,nobold,nounderscore,noitalics]#[fg=colour10,bg=colour0]  %a #[fg=colour11,bg=colour0,nobold,nounderscore,noitalics]#[fg=colour7,bg=colour11] %d. %h  %H:%M #[fg=colour14,bg=colour11,nobold,nounderscore,noitalics]#[fg=colour15,bg=colour14] #H \"" \
      # "set -g status-right \"#[fg=colour11,bg=colour0,nobold,nounderscore,noitalics]#[fg=colour7,bg=colour11] %d. %h  %H:%M #[fg=colour14,bg=colour11,nobold,nounderscore,noitalics]#[fg=colour15,bg=colour14] #H \""

      setw -g window-status-format "#[fg=colour0,bg=colour0,nobold,nounderscore,noitalics]#[default] #I #W #[fg=colour0,bg=colour0,nobold,nounderscore,noitalics]"

      setw -g window-status-current-format "#[fg=colour0,bg=colour11,nobold,nounderscore,noitalics]#[fg=colour7,bg=colour11] #I  #W #[fg=colour11,bg=colour0,nobold,nounderscore,noitalics]"
    '';
  };

  programs.fish = {
    enable = true;
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
    enableFishIntegration = true;
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
    enableFishIntegration = true;
  };

  programs.lsd = {
    enable = true;
    enableAliases = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  # TODO wayland replacement
  # programs.rofi = {
  #   enable = true;
  #   cycle = true;
  #   extraConfig = {
  #     kb-accept-entry = "Return,Control+m,KP_Enter";
  #     kb-row-down = "Down,Control+n,Control+j";
  #     kb-row-up = "Up,Control+p,Control+k";
  #     kb-remove-to-eol = "";
  #     kb-primary-paste = "Control+V,Shift+Insert";
  #     kb-secondary-paste = "Control+v,Insert";
  #   };
  # };

  programs.alacritty = {
    enable = true;
    package = (nixGL pkgs.alacritty);
    settings = {
      font = {
        normal.family = "Source Code Pro";
        size = 8.0;
      };
      colors = {  # Solarized Dark
        primary = {
          background = "0x002b36";
          foreground = "0x839496";
        };
        normal = {
          black =   "0x073642";
          red =     "0xdc322f";
          green =   "0x859900";
          yellow =  "0xb58900";
          blue =    "0x268bd2";
          magenta = "0xd33682";
          cyan =    "0x2aa198";
          white =   "0xeee8d5";
        };
        bright = {
          black =   "0x002b36";
          red =     "0xcb4b16";
          green =   "0x586e75";
          yellow =  "0x657b83";
          blue =    "0x839496";
          magenta = "0x6c71c4";
          cyan =    "0x93a1a1";
          white =   "0xfdf6e3";
        };
      };
    };
  };

  wayland.windowManager.sway = {
    enable = true;

    # we need to update the default package because it overrides with
    # extraSessionCommands, extraOptions and wrapperFeatures
    package = (nixGL options.wayland.windowManager.sway.package.default);
    systemd = {
      enable = true;
      xdgAutostart = true;
    };
    xwayland = true;
    extraSessionCommands = ''
      # SDL:
      export SDL_VIDEODRIVER=wayland
      # QT (needs qt5.qtwayland in systemPackages), needed by VirtualBox GUI:
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export EDITOR=emacsclient
    '';
    extraOptions = [
      "--verbose"
      #     "--debug"
      #     "--unsupported-gpu"
    ];
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
    swaynag.enable = true;
    config = {
      modifier = "Mod4";
      terminal = "${config.programs.alacritty.package}/bin/alacritty";
      menu = "${pkgs.wofi}/bin/wofi";
      focus = {
        followMouse = "yes";
      };
      fonts = {
        names = [ "Source Code Pro" ];
        # style = "Bold Semi-Condensed";
        size = 11.0;
      };
      window = {
        # rest TODO
        hideEdgeBorders = "smart";
      };

      # assigns = {}; TODO
      left = "h";
      down = "j";
      up = "k";
      right = "l";
      # floating = {}; TODO
      # gaps = {}; TODO
      bars = [
        {
          position = "top";
          # TODO swaybar
        }
      ];
      keybindings = let
        cfg = config.wayland.windowManager.sway;
        modifier = cfg.config.modifier;
        menu = cfg.config.menu;
      in lib.mkOptionDefault {
        "${modifier}+Shift+q" = "kill";
        # "${modifier}+d" = "exec ${menu}";
        "${modifier}+space" = "exec ${menu}";

# bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status
# bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status
# bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status
# bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status

# bindsym XF86MonBrightnessDown exec --no-startup-id brightnessctl s "10%-"
# bindsym XF86MonBrightnessUp exec --no-startup-id brightnessctl s "10%+"

# bindsym $mod+Return exec i3-sensible-terminal

# set $movemouse "sh -c 'eval `xdotool getactivewindow getwindowgeometry --shell`; xdotool mousemove $((X+WIDTH/2)) $((Y+HEIGHT/2))'"
# bindsym $mod+h focus left; exec $movemouse
# bindsym $mod+j focus down; exec $movemouse
# bindsym $mod+k focus up; exec $movemouse
# bindsym $mod+l focus right; exec $movemouse

# # alternatively, you can use the cursor keys:
# bindsym $mod+Left focus left; exec $movemouse
# bindsym $mod+Down focus down; exec $movemouse
# bindsym $mod+Up focus up; exec $movemouse
# bindsym $mod+Right focus right; exec $movemouse

# # move focused window
# bindsym $mod+Shift+j move down; exec $movemouse
# bindsym $mod+Shift+k move up; exec $movemouse
# bindsym $mod+Shift+l move right; exec $movemouse
# bindsym $mod+Shift+h move left; exec $movemouse

# # alternatively, you can use the cursor keys:
# bindsym $mod+Shift+Left move left; exec $movemouse
# bindsym $mod+Shift+Down move down; exec $movemouse
# bindsym $mod+Shift+Up move up; exec $movemouse
# bindsym $mod+Shift+Right move right; exec $movemouse

        # split in horizontal orientation
        "${modifier}+Shift+s" = "split horizontal";
        # split in vertical orientation
        "${modifier}+Shift+v" = "split vertical";
        "${modifier}+a" = "split toggle";

        # enter fullscreen mode for the focused container
        "${modifier}+f" = "fullscreen toggle";

        # change container layout (stacked, tabbed, toggle split)
        "${modifier}+s" = "layout stacking";
        "${modifier}+t" = "layout tabbed";
        "${modifier}+e" = "layout toggle all";

        # toggle tiling / floating
        # "${modifier}+Shift+space floating toggle";  NOTE default

        # change focus between tiling / floating windows
        "${modifier}+Mod1+space" = "focus mode_toggle";

        # focus the parent container
        "${modifier}+o" = "focus parent";

        # focus the child container
        "${modifier}+i" = "focus child";

        # move the currently focused window to the scratchpad
        # "${modifier}+Shift+minus" = "move scratchpad";  # NOTE default

        # Show the next scratchpad window or hide the focused scratchpad window.
        # If there are multiple scratchpad windows, this command cycles through them.
        # NOTE remove from scratchpad by with toggle floting ($mod+Shift+space)
        "${modifier}+minus" = "scratchpad show";  # NOTE default

        "${modifier}+n" = "workspace next";
        "${modifier}+p" = "workspace prev";

        # # reload the configuration file
        # "${modifier}+Shift+c" = "reload";  # NOTE default
# # restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
# bindsym $mod+Shift+r restart
# # exit i3 (logs you out of your X session)
# bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

        # NOTE using swaylock installed from Debian!
        "${modifier}+Mod1+l" = "exec ${swaylock_bin} -f";
      };
      seat = {
        "*" = {
          hide_cursor = "when-typing enable";
        };
      };
      # startup = [  TODO
      #   { command = "systemctl --user restart waybar"; always = true; }
      # ];
    };
  };

  programs.wofi = {
    enable = true;
    settings = {
      mode = "drun";
      location = "center";
      allow_markup = true;
      # width = 250;

      allow_images = "true";
      iamge_size = 8;
      # term = "alacritty";
      insensitive = true;
      no_actions = "true";
      prompt = "Search";

      key_down = "Down,Control_L-n,Control_L-j";
      key_up = "Up,Control_L-p,Control_L-k";
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "808080";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      # line-color = "ffffff";
      show-failed-attempts = true;
    };
  };

  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "${swaylock_bin}"; }
      { event = "lock"; command = "lock"; }
    ];
    timeouts = [
      { timeout = 60; command = "${swaylock_bin} -fF"; }
    ];
  };

  # TODO wayland replacement
  # services.redshift = {
  #   enable = true;
  #   # Vienna/Austria
  #   latitude = 48.210033;
  #   longitude = 16.363449;
  #   settings.redshift.brightness-night = "0.7";
  # };

  # we need to force overwrite the entire i3 config here
  # nix also tries to write the config
  # TODO migrate to sway and configuration powered by nix
  # xdg.configFile."i3/config".source = lib.mkForce ./config/i3/config;
  home.sessionVariables.TERMINAL = "${config.programs.alacritty.package}/bin/alacritty";

  # TODO wayland replacement
  # services.dunst.enable = true;

  # TODO waybar
  # services.polybar = {
  #   package = pkgs.polybarFull;
  #   enable = true;
  #   script = "polybar main >$XDG_DATA_HOME/polybar.log 2>&1 &";
  # };

  # xdg.configFile."polybar" = { source = ./config/polybar; recursive = true; };

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableSshSupport = true;
    extraConfig = ''
      allow-emacs-pinentry
      # allow-loopback-pinentry
    '';
  };

  services.syncthing = {
    enable = true;
    tray.enable = true;
  };
}
