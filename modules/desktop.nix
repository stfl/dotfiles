{ config, lib, pkgs, ... }:

with lib;

let
  nixGL = import ./nixGL.nix { inherit pkgs config; };
  swaylock-bin = "/usr/bin/swaylock";   # don't use nix' swaylock bin, because it does not work
in {
  imports = [
    ./nixgl-option.nix
  ];

  home.sessionVariables = {
    TERMINAL = "${config.programs.alacritty.package}/bin/alacritty";
    BROWSER = "${(nixGL pkgs.brave)}/bin/brave";
  };

  home.packages = with pkgs; [
    # -- browsers
    (nixGL brave)
    (nixGL firefox)

    # -- communication
    (nixGL signal-desktop)

    qt5.qtwayland
    libnotify
    xwaylandvideobridge
    wdisplays

    # -- control Montior and Audio
    brightnessctl
    libpulseaudio  # pulsectl
    pavucontrol

    # -- sway and GUI applications
    sway-contrib.grimshot  # screenshot tool
    qalculate-gtk

    # gnome.seahorse
    pass-wayland
    wofi-pass  # TODO add key mapping to sway!!

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
    # quivira       # TODO https://github.com/NixOS/nixpkgs/pull/167228
    nerdfonts
  ];

  programs.alacritty = {
    enable = true;
    package = (nixGL pkgs.alacritty);
    settings = {
      font = {
        normal.family = "Source Code Pro";
        size = 11.0;
      };
      colors = {  # Solarized Dark
        primary = {
          background = "0x002b36";
          foreground = "0x9aadaf";
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
    platformTheme = "gtk";
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
      # QT (needs qt5.qtwayland in systemPackages), needed by VirtualBox GUI:
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export GDK_BACKEND=wayland
    '';
    extraOptions = [
      "--verbose"
      # "--debug"
      # "--unsupported-gpu"
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
        hideEdgeBorders = "smart";
      };

      # assigns = {}; TODO
      left = "h";
      down = "j";
      up = "k";
      right = "l";
      # gaps = {}; TODO
      floating.criteria = [
        { title = "Steam - Update News"; }
        { class = "Pavucontrol"; }
        { title = "Volume Control"; }
        { title = "VM .+ \('.+'\).*"; }  # TODO not working
        { title = ".*noVNC.*"; }
        { title = ".*Proxmox Console.*"; }
      ];
      bars = [];  # disable default bars -> use waybar
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
        # "${modifier}+button2" = "floating toggle";
        # "${modifier}+button2" = "exec program && i3-msg \"[id=$(xdotool getactivewindow)] floating enable\"";
        # bindsym --whole-window $mod+Shift+button2 kill


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
        "${modifier}+Shift+r" = "restart";
# # exit i3 (logs you out of your X session)
# bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

        # NOTE using swaylock installed from Debian!
        "${modifier}+Mod1+l" = "exec ${swaylock-bin} -f";
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
        { command = "systemctl --user restart waybar"; always = true; }  # TODO this does not automatically restart on hm switch
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
      term = "${config.programs.alacritty.package}/bin/alacritty";
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
      show-failed-attempts = true;
    };
  };

  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "${swaylock-bin}"; }
      { event = "lock"; command = "lock"; }
    ];
    timeouts = [
      { timeout = 600; command = "${swaylock-bin} -fF"; }
      { timeout = 1800; command = "systemctl suspend"; }
    ];
  };

  services.gammastep = {
    enable = false;
    tray = true;
    latitude = 48.210033;
    longitude = 16.363449;
    # temperate = {
    #   day = ...;
    #   night = ...;
    # };
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
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        # output = [
        #   "eDP-1"
        #   "HDMI-A-1"
        # ];
        modules-left = [ "sway/workspaces" "sway/scratchpad" "sway/mode" "sway/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "idle_inhibitor" "backlight" "temperature" "cpu" "memory" "disk" "network" "battery" "pulseaudio/slider" ];

        "sway/workspaces" = {
          disable-scroll = false;
          all-outputs = true;
        };
        "sway/window" = {
          max-length = 50;
          format = "<span>{shell} > </span>{title}";
        };
        "pulseaudio/slider" = {
          min = 0;
          max = 100;
          orientation = "horizontal";
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        "tray" = {
          # "icon-size" = 14;
          # "spacing" = 5;
        };
        "memory" = {
          format = "{icon} {: >3}%";
          format-icons = ["○" "◔" "◑" "◕" "●"];
          on-click = "${config.programs.alacritty.package}/bin/alacritty -e htop";
        };
        "temperature" = {
          # // "thermal-zone" = 2;
          # // "hwmon-path" = "/sys/class/hwmon/hwmon2/temp1_input";
          "critical-threshold" = 80;
          # // "format-critical" = "{temperatureC}°C ";
          "format" = " {temperatureC}°C";
        };
        "backlight" = {
          # // "device" = "acpi_video1";
          "format" = "{icon} {percent: >3}%";
          "format-icons" = ["" ""];
          "on-scroll-down" = "brightnessctl -c backlight set 5%-";
          "on-scroll-up" = "brightnessctl -c backlight set +5%";
        };
        "network" = {
          # "interface" = "wlp2s0"; // (Optional) To force the use of this interface;
          "format" = "⚠ Disabled";
          "format-wifi" = " {essid}";
          "format-ethernet" = " {ifname}: {ipaddr}/{cidr}";
          "format-disconnected" = "⚠ Disconnected";
          "on-click" = "foot -e nmtui";
        };
        "pulseaudio" = {
          "scroll-step" = 5;
          "format" = "{icon} {volume: >3}%";
          "format-bluetooth" = "{icon} {volume: >3}%";
          "format-muted" =" muted";
          "format-icons" = {
            "headphones" = "";
            "handsfree" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = ["" ""];
          };
          "on-click" = "pavucontrol";
        };
        battery = {
          format = "{capacity}% {icon}";
          format-icons = ["" "" "" "" ""];
        };
        # ""
        # "custom/hello-from-waybar" = {
        #   format = "hello {}";
        #   max-length = 40;
        #   interval = "once";
        #   exec = pkgs.writeShellScript "hello-from-waybar" ''
        #     echo "from within waybar"
        #   '';
        # };
        disk = {
          interval = 30;
          format = "🖪 {percentage_used}%";
          path = "/";
        };
        cpu = {
          interval = 1;
          on-click = "${config.programs.alacritty.package}/bin/alacritty -e htop";
          format = "🖥 {usage}% {icon}";
          # format = "{icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}";
          format-icons = [
            "<span color='#69ff94'>▁</span>"  # green
            "<span color='#2aa9ff'>▂</span>"  # blue
            "<span color='#f8f8f2'>▃</span>"  # white
            "<span color='#f8f8f2'>▄</span>"  # white
            "<span color='#ffffa5'>▅</span>"  # yellow
            "<span color='#ffffa5'>▆</span>"  # yellow
            "<span color='#ff9977'>▇</span>"  # orange
            "<span color='#dd532e'>█</span>"   # red
          ];
        };
        "clock" = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt>{calendar}</tt>";
          format = "{:%F  %H:%M}";
          format-alt = "{:%F   %T}";
          interval = 1;
        };
      };
    };
    style = ''
      /* -----------------------------------------------------------------------------
      * Base styles
      * -------------------------------------------------------------------------- */

      /* Reset all styles */

      * {
          color: #eceff4;
          border: 0;
          border-radius: 0;
          padding: 0 0;
          font-family:MesloLGS NF;
          /* font-size: 15px; */
          margin-right: 5px;
          margin-left: 5px;
          /* padding-top:3px; */
          /* padding-bottom:3px; */
      }

      window#waybar {
          background:#2e3440;
      }

      #workspaces button {
          color: #d8dee9;
          /* border: 2px;
          // border-color: #4c566a;
          // border-style: solid;
          // border-radius:25px;
          // padding-left: 5px;
          // padding-right: 5px;
*/
    }

      .window-shell {
              font-size: 80%;
      }

      #workspaces button.focused {
          border-color: #81a1c1;
          border: 2px;
        }

      #workspaces button:nth-child(1).visible{
        border-color: #a3be8c;
      }

      #workspaces button.visible:nth-child(1) label{
        color: #a3be8c;
      }

      #workspaces button:nth-child(2).visible{
        border-color: #ebcb8b;
      }

      #workspaces button.visible:nth-child(2) label{
        color: #ebcb8b;
      }

      #workspaces button:nth-child(3).visible{
        border-color: #8fbcbb;
      }

      #workspaces button.visible:nth-child(3) label{
        color: #8fbcbb;
      }

      #workspaces button:nth-child(4).visible{
        border-color: #b48ead;
      }

      #workspaces button.visible:nth-child(4) label{
        color: #b48ead;
      }

      #workspaces button:nth-child(5).visible{
        border-color: #bf616a;
      }

      #workspaces button.visible:nth-child(5) label{
        color: #bf616a;
      }


      #mode {
          color: #a3be8c;
      }

      #battery, #cpu, #memory,#idle_inhibitor, #temperature,#custom-keyboard-layout, #backlight, #network, #pulseaudio, #mode, #tray, #window,#custom-launcher,#custom-power,#custom-pacman, #custom-network_traffic {
          padding: 0 3px;
          border-style: solid;
      }

/* TODO does not work */
      .critical {
          border: 2px;
      }

      /* -----------------------------------------------------------------------------
      * Module styles
      * -------------------------------------------------------------------------- */

      #clock {
          color:#a3be8c;
      }

      #backlight {
          color: #ebcb8b;
      }

      #battery {
          color: #d8dee9;
      }

      #battery.charging {
          color: #81a1c1;
      }

      @keyframes blink {
          to {
              color: #4c566a;
              background-color: #eceff4;
          }
      }

      #battery.critical:not(.charging) {
          background: #bf616a;
          color: #eceff4;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #cpu {
          color:#a3be8c ;
      }

      #memory {
          color: #8B8000;
      }

      #network.disabled {
          color:#bf616a;
      }

      #network{
          color:#ebcb8b;
      }

      #network.disconnected {
          color: #bf616a;
      }

      #pulseaudio {
          color: #b48ead;
      }

      #pulseaudio.muted {
          color: #3b4252;
      }

      #temperature {
          color: #8fbcbb;
      }

      #temperature.critical {
          color: #bf616a;
      }

      #idle_inhibitor {
        color: #8fbcbb;
      }

      #idle_inhibitor.activated {
        color: #bf616a;
      }

      #tray {
          color: #a3be8c;
      }

      #custom-power{
        color: #994C00;
      }


      #custom-launcher{
        color:#b48ead;
      }

      #window{
          border-style: hidden;
          margin-top:1px;
      }
      #mode{
          margin-bottom:3px;
      }

      #custom-keyboard-layout{
        color:#d08770;
      }
    '';
  };



}
