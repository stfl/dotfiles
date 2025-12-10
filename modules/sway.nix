{ config, lib, pkgs, USER, ... }:

{
  environment.systemPackages = with pkgs; [
    wlr-protocols
    wl-mirror
    kanshi # install the binary in addition to the service for debugging configs
  ];

  xdg.portal.wlr.enable = true;
  xdg.portal.config.common.default = "*"; # use the first available portal

  security.pam.services.swaylock.fprintAuth = false;

  home-manager.users.${USER} =
{ config, lib, pkgs, ... }:

with lib;
let
  swaylock-bin = "${getExe pkgs.swaylock}";
  TERMINAL = "${getExe config.programs.alacritty.package}";
  calculator-pkg = pkgs.qalculate-gtk;
in

{
  home.packages = with pkgs; [
    # -- sway and GUI applications
    sway-contrib.grimshot # screenshot tool
  ];

  wayland.windowManager.sway = {
    enable = true;

    # we need to update the default package because it overrides with
    # extraSessionCommands, extraOptions and wrapperFeatures
    systemd = {
      enable = true;
      xdgAutostart = true;
    };
    xwayland = true;
    extraSessionCommands = ''
      export XDG_SESSION_TYPE="wayland"
      export XDG_CURRENT_DESKTOP="sway"

      export NIXOS_OZONE_WL="1";
      export SDL_VIDEODRIVER="wayland";
      export GDK_BACKEND="wayland";

      export _JAVA_AWT_WM_NONREPARENTING="1";
      export # BEMENU_BACKEND="wayland":
      export CLUTTER_BACKEND="wayland";
      export # ECORE_EVAS_ENGINE="wayland_egl";
      export ELM_ACCEL="gl";
      export ELM_DISPLAY="wl";
      export ELM_ENGINE="wayland_egl";

      export # ox wayland environment variable
      export MOZ_DBUS_REMOTE="1";
      export MOZ_ENABLE_WAYLAND="1";
      export MOZ_USE_XINPUT2="1";

      export NO_AT_BRIDGE="1";
      export SAL_USE_VCLPLUGIN="gtk3";

      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1";
      export QT_QPA_PLATFORM="wayland-egl";
      export QT_QPA_PLATFORMTHEME="qt5ct";
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
      defaultWorkspace = "1";
      focus = {
        followMouse = "yes";
      };
      fonts = {
        names = [ "Sauce Code Pro Nerd Font" ];
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
        { title = "Removable medium is inserted"; }
        { class = "steam"; } # all steam windows -> "Steam" itself is has floating disabled see extraConfig below
        { class = "Pavucontrol"; }
        { title = "Volume Control"; }
        { title = "VM .+ \('.+'\).*"; } # TODO not working
        { title = ".*noVNC.*"; }
        { title = ".*Proxmox Console.*"; }
        { title = "Bluetooth Devices"; }
        { app_id = "qalculate-gtk"; }
      ];

      bars = [ ]; # disable default bars -> use waybar
      keybindings =
        let
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

          "${modifier}+Mod1+Escape" = "exec --no-startup-id ${pkgs.systemd}/bin/systemctl suspend";

          # wofi-pass
          "${modifier}+g" = "exec --no-startup-id ${getExe pkgs.wofi-pass} --autotype";

          # Taking screenshots with grimshot
          "${modifier}+Mod1+p" =
            "exec --no-startup-id ${getExe pkgs.sway-contrib.grimshot} --notify save area";
          "${modifier}+Shift+p" =
            "exec --no-startup-id ${getExe pkgs.sway-contrib.grimshot} --notify save active";
          "${modifier}+Ctrl+p" =
            "exec --no-startup-id ${getExe pkgs.sway-contrib.grimshot} --notify save output";

          "${modifier}+z" = "exec --no-startup-id ${getExe calculator-pkg}";
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
    extraConfig = ''
      # disable floating criteria again for main "Steam" window
      for_window [title="^Steam$"] floating disable
    '';
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

  # TODO probably not needed
  # programs.waybar.systemd.target = "sway-session.target";

  programs.waybar.settings.mainBar.modules-left = [
    "sway/workspaces"
    "sway/scratchpad"
    "sway/mode"
    "sway/window"
  ];
  programs.waybar.settings.mainBar."sway/workspaces" = {
    disable-scroll = false;
    all-outputs = true;
  };
  programs.waybar.settings.mainBar."sway/window" = {
    max-length = 50;
    format = "<span>{shell} > </span>{title}";
  };

  # fix auto-reloading kanshi service
  # TODO contribute upstream
  systemd.user.services.kanshi = lib.mkIf config.services.kanshi.enable {
    Service.Restart = "always";
    Unit = {
      X-Restart-Triggers = [
        "${config.xdg.configFile."kanshi/config".source}"
      ];
      X-SwitchMethod = "restart";
    };
  };
};

}
