{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  nixGL = import ./nixGL.nix {inherit pkgs config;};
  swaylock-bin =
    if (config.targets.genericLinux.enable == false)
    then "${getExe pkgs.swaylock}"
    else "/usr/bin/swaylock"; # don't use nix' swaylock bin, because it does not work
  TERMINAL = "${getExe config.programs.alacritty.package}";
in {
  imports = [
    ./nixgl-option.nix
  ];

  xdg = {
    enable = true;
    mime.enable = true;
    userDirs = {
      enable = true;
      desktop = "Desktop";
      documents = "Documents";
      download = "Downloads";
      music = "Music";
      pictures = "Pictures";
      videos = "Videos";
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Screenshots";
      };
    };
  };

  home.activation.createScreenshotDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p ${config.xdg.userDirs.extraConfig.XDG_SCREENSHOTS_DIR}
  '';

  home.sessionVariables = {
    inherit TERMINAL;
    BROWSER = "${getExe (nixGL pkgs.brave)}";
  };

  home.packages = with pkgs; [
    # -- browsers
    (nixGL brave)
    (nixGL firefox)

    # -- communication
    (nixGL signal-desktop)
    (nixGL discord)

    libnotify
    xwaylandvideobridge
    wdisplays
    wl-mirror
    kanshi # install the binary in addition to the service for debugging configs

    # -- control Montior and Audio
    brightnessctl
    libpulseaudio # pulsectl
    pavucontrol

    # -- sway and GUI applications
    sway-contrib.grimshot # screenshot tool
    qalculate-gtk
    pcmanfm
    transmission_4-gtk

    zenith # system monitor

    # -- fonts
    symbola
    jetbrains-mono
    source-code-pro
    noto-fonts
    noto-fonts-emoji
    julia-mono
    symbola
    dejavu_fonts
    hicolor-icon-theme
    nerdfonts
  ];

  fonts.fontconfig.enable = true;

  programs.alacritty = {
    enable = true;
    package = nixGL pkgs.alacritty;
    settings = {
      scrolling.history = 100000;
      font = {
        normal.family = "Source Code Pro";
        size = 11.0;
      };
      colors = {
        # Solarized Dark
        primary = {
          background = "0x002b36";
          foreground = "0x9aadaf";
        };
        normal = {
          black = "0x073642";
          red = "0xdc322f";
          green = "0x859900";
          yellow = "0xb58900";
          blue = "0x268bd2";
          magenta = "0xd33682";
          cyan = "0x2aa198";
          white = "0xeee8d5";
        };
        bright = {
          black = "0x002b36";
          red = "0xcb4b16";
          green = "0x586e75";
          yellow = "0x657b83";
          blue = "0x839496";
          magenta = "0x6c71c4";
          cyan = "0x93a1a1";
          white = "0xfdf6e3";
        };
      };
    };
  };

  programs.mpv.enable = true;

  # feh alternative for wayland
  programs.imv = {
    enable = true;
    # settings = {
    #   # alias.x = "close";    # Configuration options for imv. See imv(5).
    # };
  };

  gtk = {
    enable = true;
    # font = TODO;
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  wayland.windowManager.sway = {
    enable = true;

    # we need to update the default package because it overrides with
    # extraSessionCommands, extraOptions and wrapperFeatures
    # package = (nixGL options.wayland.windowManager.sway.package.default);
    systemd = {
      enable = true;
      xdgAutostart = true;
    };
    xwayland = true;
    extraSessionCommands = ''
      # SDL:
      export SDL_VIDEODRIVER=wayland
      export NIXOS_OZONE_WL=1
      export GDK_BACKEND=wayland

      export _JAVA_AWT_WM_NONREPARENTING=1
      export BEMENU_BACKEND=wayland
      export CLUTTER_BACKEND=wayland
      export ECORE_EVAS_ENGINE=wayland_egl
      export ELM_ACCEL=gl
      export ELM_DISPLAY=wl
      export ELM_ENGINE=wayland_egl

      # Firefox wayland environment variable
      export MOZ_DBUS_REMOTE=1
      export MOZ_ENABLE_WAYLAND=1
      export MOZ_USE_XINPUT2=1

      export NO_AT_BRIDGE=1
      export SAL_USE_VCLPLUGIN=gtk3

      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export QT_QPA_PLATFORM=wayland-egl # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORMTHEME="qt5ct"

      export XDG_SESSION_TYPE="wayland"
      export XDG_CURRENT_DESKTOP="sway"
    '';
    extraOptions = [
      "--verbose"
    ];
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
    swaynag.enable = true;
    config = {
      modifier = "Mod4";
      terminal = "${TERMINAL}";
      menu = "${getExe pkgs.wofi}";
      focus = {
        followMouse = "yes";
      };
      fonts = {
        names = ["Source Code Pro"];
        # style = "Bold Semi-Condensed";
        size = 11.0;
      };
      window = {
        hideEdgeBorders = "smart";
      };

      # assigns = {}; TODO
      left = "h";
      down = "j";
      up = "k";
      right = "l";
      # gaps = {}; TODO
      floating.criteria = [
        {title = "Steam - Update News";}
        {class = "Pavucontrol";}
        {title = "Volume Control";}
        {title = "VM .+ \('.+'\).*";} # TODO not working
        {title = ".*noVNC.*";}
        {title = ".*Proxmox Console.*";}
      ];
      bars = []; # disable default bars -> use waybar
      keybindings = let
        cfg = config.wayland.windowManager.sway;
        modifier = cfg.config.modifier;
        menu = cfg.config.menu;
        swayosd_client = "${config.services.swayosd.package}/bin/swayosd-client";
      in
        lib.mkOptionDefault {
          "${modifier}+Shift+q" = "kill";
          "button2" = "kill";

          # "${modifier}+d" = "exec ${menu}";
          "${modifier}+space" = "exec ${menu}";

          # "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10%";
          "XF86AudioLowerVolume" = "exec ${swayosd_client} --output-volume lower --max-volume 120";
          # "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10%";
          "XF86AudioRaiseVolume" = "exec ${swayosd_client} --output-volume raise --max-volume 120";
          # "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMute" = "exec ${swayosd_client} --output-volume mute-toggle";

          # "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          "XF86AudioMicMute" = "exec ${swayosd_client} --input-volume mute-toggle";

          # "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl s 10%-";
          "XF86MonBrightnessDown" = "exec ${swayosd_client} --brightness lower";
          # "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl s 10%+";
          "XF86MonBrightnessUp" = "exec ${swayosd_client} --brightness raise";

          # "Caps_Lock" = "exec ${swayosd_client} --caps-lock";

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

          # change focus between tiling / floating windows
          "${modifier}+Mod1+space" = "focus mode_toggle";

          # focus the parent container
          "${modifier}+o" = "focus parent";

          # focus the child container
          "${modifier}+i" = "focus child";

          # Show the next scratchpad window or hide the focused scratchpad window.
          # If there are multiple scratchpad windows, this command cycles through them.
          # NOTE remove from scratchpad by with toggle floting ($mod+Shift+space)
          "${modifier}+minus" = "scratchpad show"; # NOTE default

          "${modifier}+n" = "workspace next";
          "${modifier}+p" = "workspace prev";

          # "${modifier}+Shift+c" = "reload";  # NOTE default
          "${modifier}+Shift+r" = "restart";

          # NOTE using swaylock installed from Debian!
          "${modifier}+Mod1+l" = "exec ${swaylock-bin} -fF";

          # wofi-pass
          "${modifier}+g" = "exec --no-startup-id ${getExe pkgs.wofi-pass} --autotype";

          # Taking screenshots with grimshot
          "${modifier}+Mod1+p" = "exec --no-startup-id ${getExe pkgs.sway-contrib.grimshot} --notify save area";
          "${modifier}+Shift+p" = "exec --no-startup-id ${getExe pkgs.sway-contrib.grimshot} --notify save active";
          "${modifier}+Ctrl+p" = "exec --no-startup-id ${getExe pkgs.sway-contrib.grimshot} --notify save output";
        };
      seat = {
        "*" = {
          hide_cursor = "when-typing enable";
        };
      };
      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_variant = "altgr-intl";
          xkb_options = "eurosign:5";
        };
        "type:touchpad" = {
          dwt = "enabled";
          tap = "enabled";
          natural_scroll = "enabled";
          middle_emulation = "disabled";
        };
      };
      startup = [
        {
          command = "systemctl --user restart waybar";
          always = true;
        } # TODO this does not automatically restart on hm switch
      ];
    };
  };

  programs.wofi = {
    enable = true;
    settings = {
      mode = "drun";
      location = "center";
      allow_markup = true;
      allow_images = "true";
      iamge_size = 8;
      term = TERMINAL;
      insensitive = true;
      no_actions = "true";
      prompt = "Search";
      key_down = "Down,Ctrl-n,Ctrl-j";
      key_up = "Up,Ctrl-p,Ctrl-k";
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "808080";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
    };
  };

  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${swaylock-bin} -F";
      }
      {
        event = "lock";
        command = "${swaylock-bin} -F";
      }
    ];
    # timeouts = [
    #   {
    #     timeout = 1200;
    #     command = "${swaylock-bin} -fF";
    #   }
    # ];
  };

  services.gammastep = {
    enable = true;
    tray = true;
    latitude = 48.210033;
    longitude = 16.363449;
  };

  services.mako = {
    enable = true;
    anchor = "top-center";
    backgroundColor = "#285577FF";
    borderColor = "#4C7899FF";
    defaultTimeout = 30000; # ms
    # ignoreTimeout = true;
    font = "JetBrains Mono 10";
    borderRadius = 7;
    padding = "8";
    width = 400;
    extraConfig = ''
      outer-margin=40

      [urgency=low]
      border-size=0

      [urgency=high]
      background-color=#bf616a
      border-color=#bf616a
      default-timeout=0
    '';
  };

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "sway-session.target";
    };
    settings = {
      mainBar = let
        swayosd_client = "${config.services.swayosd.package}/bin/swayosd-client";
      in {
        layer = "top";
        position = "top";
        height = 32;
        # output = [
        #   "eDP-1"
        #   "HDMI-A-1"
        # ];
        modules-left = ["sway/workspaces" "sway/scratchpad" "sway/mode" "sway/window"];
        modules-center = ["clock"];
        modules-right = [
          "tray"
          "idle_inhibitor"
          # "cava"
          "pulseaudio"
          "backlight"
          "cpu"
          "memory"
          "disk"
          "temperature"
          "network"
          "battery"
        ];
        "sway/workspaces" = {
          disable-scroll = false;
          all-outputs = true;
        };
        "sway/window" = {
          max-length = 50;
          format = "<span>{shell} > </span>{title}";
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        tray = {
          # "icon-size" = 14;
          # "spacing" = 5;
        };
        memory = {
          format = "{icon} {: >2}%";
          format-icons = ["○" "◔" "◑" "◕" "●"];
          on-click = "${TERMINAL} -e ${getExe pkgs.btop}";
          states = {
            critical = 90;
          };
        };
        temperature = {
          # "thermal-zone" = 2;
          critical-threshold = 80;
          format = " {temperatureC}°C";
        };
        backlight = {
          # // "device" = "acpi_video1";
          # FIXME minimum backlight 5%
          format = "{icon} {percent: >3}%";
          format-icons = ["" ""];
          on-scroll-down = "${swayosd_client} --brightness lower";
          on-scroll-up = "${swayosd_client} --brightness raise";
          # reverse-scrolling = "true";  # TODO broken
          reverse-scrolling = true;
          reverse-mouse-scrolling = false;
          smooth-scrolling-threshold = 0.1;
        };
        network = {
          # "interface" = "wlp2s0"; // (Optional) To force the use of this interface;
          # format = "⚠ Disabled";
          format-wifi = "  {essid}";
          format-ethernet = " {ifname}: {ipaddr}/{cidr}";
          format-disconnected = "⚠ Disconnected";
          format-disabled = "🛪 Disabled";
        };
        pulseaudio = {
          scroll-step = 5;
          format = "{icon} {volume: >3}%";
          format-bluetooth = "{icon} {volume: >3}%";
          format-muted = "󰝟 "; # emoji: 🔇
          format-icons = {
            headphones = "";
            handsfree = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" ""];
          };
          on-click = "${getExe pkgs.pavucontrol}";
          on-click-right = "${swayosd_client} --output-volume mute-toggle";
          on-scroll-down = "${swayosd_client} --output-volume lower --max-volume 120";
          on-scroll-up = "${swayosd_client} --output-volume raise --max-volume 120";
          reverse-scrolling = true;
          reverse-mouse-scrolling = false;
          smooth-scrolling-threshold = 0.1;
          # scroll-step = 0.5;
        };
        battery = {
          interval = 10;
          states.warning = 30;
          states.critical = 10;
          format = "{capacity}% {icon}";
          format-icons = ["" "" "" "" ""];
          format-charging = "{capacity}% 󱐋{icon}";
          format-plugged = "{capacity}% ";
          format-full = "{capacity}% ";
          tooltip-format = "{timeTo}\nHealth: {health} %\nCycles: {cycles}";
        };
        disk = {
          interval = 60;
          states = {
            critical = 90;
          };
          format = " {percentage_used}%"; # 🖴   󰒋
          path = "/";
        };
        cpu = {
          interval = 2;
          on-click = "${TERMINAL} -e ${getExe pkgs.btop}";
          states = {
            normal-load = 60;
            high-load = 80;
            critical = 95;
          };
          format = " {usage: >4}%"; # ䷑  󰘚 
        };
        clock = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt>{calendar}</tt>";
          format = "{:%a  %F  %H:%M}";
        };
      };
    };
    style = ../../config/waybar.css;
  };

  services.swayosd = {
    enable = true;
    topMargin = 0.1;
  };
  systemd.user.services.swayosd.Install.WantedBy = ["sway-session.target"];

  # enable forwarding pause/play/.. buttons for bluetooth headsets to media players
  services.mpris-proxy.enable = true;

  # programs.cava = {
  #   enable = true;
  #   settings = {
  #     general.framerate = 60;
  #     input.method = "alsa";
  #     smoothing.noise_reduction = 88;
  #     color = {
  #       background = "'#000000'";
  #       foreground = "'#FFFFFF'";
  #     };
  #   };
  # };
}
