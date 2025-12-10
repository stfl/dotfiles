{
  lib,
  pkgs,
  USER,
  ...
}:
with lib;
{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    SDL_VIDEODRIVER= "wayland";
    GDK_BACKEND="wayland";

    _JAVA_AWT_WM_NONREPARENTING= "1";
    # BEMENU_BACKEND="wayland":
    CLUTTER_BACKEND="wayland";
    # ECORE_EVAS_ENGINE="wayland_egl";
    ELM_ACCEL="gl";
    ELM_DISPLAY="wl";
    ELM_ENGINE="wayland_egl";

    # ox wayland environment variable
    MOZ_DBUS_REMOTE="1";
    MOZ_ENABLE_WAYLAND="1";
    MOZ_USE_XINPUT2="1";

    NO_AT_BRIDGE="1";
    SAL_USE_VCLPLUGIN="gtk3";

    QT_WAYLAND_DISABLE_WINDOWDECORATION="1";
    QT_QPA_PLATFORM="wayland-egl";
    QT_QPA_PLATFORMTHEME="qt6ct";
  };

  # Enable GDM for graphical login
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.printing.enable = true;

  security.polkit.enable = true;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    qt5.qtwayland
    kdePackages.qtwayland
    wayland-utils

    pcmanfm
    gimp

    libnotify
    wdisplays

    brightnessctl
    libpulseaudio # pulsectl
    pavucontrol
  ];

  # Xfce D-Bus thumbnailer service
  services.tumbler.enable = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
    # wireplumber.configPackages = [
    #   (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
    #     bluez_monitor.properties = {
    #       ["bluez5.enable-sbc-xq"] = true,
    #       ["bluez5.enable-msbc"] = true,
    #       ["bluez5.enable-hw-volume"] = true,
    #       ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
    #     }
    #   '')
    # ];
  };
  # services.pipewire.wireplumber.extraScripts.main."99-alsa-lowlatency" = ''
  #   alsa_monitor.rules = {
  #     {
  #       matches = {{{ "node.name", "matches", "alsa_output.*" }}};
  #       apply_properties = {
  #         ["audio.format"] = "S32LE",
  #         ["audio.rate"] = "96000", -- for USB soundcards it should be twice your desired rate
  #         ["api.alsa.period-size"] = 2, -- defaults to 1024, tweak by trial-and-error
  #         -- ["api.alsa.disable-batch"] = true, -- generally, USB soundcards use the batch mode
  #       },
  #     },
  #   }
  # '';
  #

  fonts = {
    packages = with pkgs; [
      symbola
      noto-fonts
      noto-fonts-color-emoji
      dejavu_fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.symbols-only
    ];
    fontDir.enable = true;
    fontconfig.enable = true;
  };

  # get completion for system packages
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  home-manager.users.${USER} =
{
  config,
  lib,
  pkgs,
  ...
}:
let
  TERMINAL = "${getExe config.programs.alacritty.package}";
  calculator-pkg = pkgs.qalculate-gtk;
in
{

  xdg = {
    enable = true;
    mime.enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Screenshots";
      };
    };
  };

  home.activation.createScreenshotDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${config.xdg.userDirs.extraConfig.XDG_SCREENSHOTS_DIR}
  '';

  home.sessionVariables = {
    inherit TERMINAL;
    BROWSER = "${getExe pkgs.brave}";
  };

  home.packages = with pkgs; [
    # -- browsers
    brave
    firefox

    # -- communication
    signal-desktop-bin
    # discord
    transmission_4-gtk

    calculator-pkg
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      scrolling.history = 100000;
      font = {
        normal.family = "Sauce Code Pro Nerd Font";
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

  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    font = {
      name = "Noto Sans";
      package = pkgs.noto-fonts;
    };

    gtk3.bookmarks = [
      "file://${config.home.homeDirectory} Home"
      "file://${config.xdg.userDirs.download}"
      "file://${config.xdg.userDirs.documents}"
      "file://${config.xdg.userDirs.music}"
      "file://${config.xdg.userDirs.pictures}"
      "file://${config.xdg.userDirs.videos}"
      "file://${config.home.homeDirectory}/Documents/Finanzielles/Buchhaltung/2025 Buchh. 2025"
      "file://${config.home.homeDirectory}/Documents/Finanzielles/Einreichung%20Versicherung/2025 Vers. 2025"
    ];
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    settings = {
      program_options = {
        file_manager = "${pkgs.pcmanfm}/bin/pcmanfm";
      };
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

  services.gammastep = {
    enable = true;
    latitude = 48.210033;
    longitude = 16.363449;
  };

  services.mako = {
    enable = true;
    settings = {
      anchor = "top-center";
      backgroundColor = "#285577FF";
      borderColor = "#4C7899FF";
      defaultTimeout = 30000; # ms
      # ignoreTimeout = true;
      font = "JetBrains Mono Nerd Font Mono 10";
      borderRadius = 7;
      padding = "8";
      width = 400;
      outer-margin = 40;

      # criteria settings
      "urgency=low" = {
        border-size = 0;
      };
      "urgency=high" = {
        background-color = "#BF616A";
        border-color = "#BF616A";
        default-timeout = 0;
      };
    };
  };

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
    };
    settings = {
      mainBar =
        let
          swayosd_client = "${config.services.swayosd.package}/bin/swayosd-client";
        in
        {
          layer = "top";
          position = "top";
          height = 32;
          modules-center = [ "clock" ];
          modules-right = [
            "tray"
            "systemd-failed-units"
            "idle_inhibitor"
            "pulseaudio"
            "backlight"
            "cpu"
            "memory"
            "disk"
            "temperature"
            "network"
            "battery"
          ];
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
            format-icons = [
              "○"
              "◔"
              "◑"
              "◕"
              "●"
            ];
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
            format-icons = [
              ""
              ""
            ];
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
              default = [
                ""
                ""
              ];
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
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
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
          systemd-failed-units = {
            format = "✗ {nr_failed}";
            hide-on-ok = true;
          };
        };
    };
    style = ../config/waybar.css;
  };

  services.swayosd = {
    enable = true;
    topMargin = 0.1;
  };
  systemd.user.services.swayosd.Install.WantedBy = [ config.wayland.systemd.target ];

  services.espanso = {
    enable = lib.mkDefault true;
    # configs = {};
    matches = {
      base = {
        matches = [
          {
            trigger = ":now";
            replace = "It's {{currentdate}} {{currenttime}}";
          }
          {
            trigger = ":date";
            replace = "{{currentdate}}";
          }
        ];
      };
      global_vars = {
        global_vars = [
          {
            name = "currentdate";
            type = "date";
            params = {
              format = "%F";
            };
          }
          {
            name = "currenttime";
            type = "date";
            params = {
              format = "%R";
            };
          }
        ];
      };
    };
  };
};
}
