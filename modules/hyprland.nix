{ config, lib, pkgs, USER, ... }:
with lib;

{
  environment.systemPackages = with pkgs; [
    qalculate-gtk
  ];

  programs.hyprland.enable = true;

  home-manager.users.${USER} =
{ config, lib, pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = [ "--all" ];
    };
    settings = {
      monitor = [", preferred, auto, 1"]; # monitor fallback configuration
      input = {
        kb_layout = "us";
        kb_variant = "altgr-intl";
        kb_options = "eurosign:5";
        scroll_method = "2fg";
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          drag_3fg = 1; # enable three-finger drag
          clickfinger_behavior = true; # Button presses with 1, 2, or 3 fingers will be mapped to LMB, RMB, and MMB
          middle_button_emulation = true; # Emulate middle button when both left and right buttons are pressed
          drag_lock = 1;
        };
      };
      cursor = {
        hide_on_key_press = true;
      };
      env = [
        # https://wiki.hypr.land/Configuring/Environment-variables/
        "NIXOS_OZONE_WL, 1"

        # Toolkit Backend Variables
        "GDK_BACKEND,wayland,x11,*" # GTK: Use Wayland if available; if not, try X11 and then any other GDK backend.
        "SDL_VIDEODRIVER,wayland" # Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
        "CLUTTER_BACKEND,wayland" # Clutter package already has Wayland enabled, this variable will force Clutter applications to try and use the Wayland backend

        # Qt Variables
        "QT_AUTO_SCREEN_SCALE_FACTOR,1" # (From the Qt documentation) enables automatic scaling, based on the monitor’s pixel density
        "QT_QPA_PLATFORM,wayland;xcb" # Tell Qt applications to use the Wayland backend, and fall back to X11 if Wayland is unavailable
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1" # Disables window decorations on Qt applications
        "QT_QPA_PLATFORMTHEME,qt5ct" # Tells Qt based applications to pick your theme from qt5ct, use with Kvantum.

        "_JAVA_AWT_WM_NONREPARENTING,1"
        # ECORE_EVAS_ENGINE="wayland_egl";
        "ELM_ACCEL,gl"
        "ELM_DISPLAY,wl"
        "ELM_ENGINE,wayland_egl"

        # Firefox/Thunderbird settings
        "MOZ_DBUS_REMOTE,1"
        "MOZ_ENABLE_WAYLAND,1"
        "MOZ_USE_XINPUT2,1"

        "SAL_USE_VCLPLUGIN,gtk3"

        # pass grimblast edit to satty for simple copy/edit workflow
        "GRIMBLAST_EDITOR,${getExe pkgs.satty} --filename"
      ];
      "$mod" = "SUPER";
      bind = let
          TERMINAL = getExe config.programs.alacritty.package;
          swaylock-bin = getExe pkgs.swaylock;
          calc = getExe pkgs.qalculate-gtk;
          swayosd = "${config.services.swayosd.package}/bin/swayosd-client";
          grimblast = getExe pkgs.grimblast;
          hyprctl = "${pkgs.hyprland}/bin/hyprctl";
        in [
          # Window management
          "$mod SHIFT, Q, killactive"
          "$mod, Q, killactive"

          # Vim-style navigation
          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"

          # Move windows with vim keys
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, L, movewindow, r"

          # Move window to monitor left/right
          "$mod SHIFT, Left, movewindow, mon:l"
          "$mod SHIFT, Right, movewindow, mon:r"

          # Move workspace to monitor left/right
          # "$mod SHIFT CTRL, H, movecurrentworkspacetomonitor, l"
          # "$mod SHIFT CTRL, L, movecurrentworkspacetomonitor, r"
          "$mod SHIFT CTRL, Left, movecurrentworkspacetomonitor, l"
          "$mod SHIFT CTRL, Right, movecurrentworkspacetomonitor, r"

          "$mod, TAB, cyclenext"

          # Application launcher
          "$mod, SPACE, exec, ${getExe pkgs.wofi}"

          # Password manager
          "$mod, G, exec, ${getExe pkgs.wofi-pass} --autotype"

          # Window switcher
          "$mod, BACKSPACE, exec, sh -c '${hyprctl} clients -j | ${pkgs.jq}/bin/jq -r '\"'\"'.[] | \"\\(.address)|\\(.title) [\\(.class)]\"'\"'\"' | ${getExe pkgs.wofi} --dmenu -p \"Switch to:\" | ${pkgs.coreutils}/bin/cut -d\"|\" -f1 | ${pkgs.findutils}/bin/xargs -r -I{} ${pkgs.hyprland}/bin/hyprctl dispatch focuswindow address:{}'"

          # Terminal
          "$mod, RETURN, exec, ${TERMINAL}"

          # Audio controls
          ", XF86AudioLowerVolume, exec, ${swayosd} --output-volume lower --max-volume 120"
          ", XF86AudioRaiseVolume, exec, ${swayosd} --output-volume raise --max-volume 120"
          ", XF86AudioMute, exec, ${swayosd} --output-volume mute-toggle"
          ", XF86AudioMicMute, exec, ${swayosd} --input-volume mute-toggle"

          # Brightness controls
          ", XF86MonBrightnessDown, exec, ${swayosd} --brightness lower"
          ", XF86MonBrightnessUp, exec, ${swayosd} --brightness raise"

          # Split orientation (hyprland uses dwindle layout with togglesplit)
          # "$mod SHIFT, S, togglesplit"
          # "$mod SHIFT, V, togglesplit"
          "$mod, A, togglesplit"

          # Fullscreen
          "$mod, F, fullscreen, 0"

          # Layout modes
          "$mod, S, exec, ${hyprctl} keyword general:layout master"
          "$mod, T, exec, ${hyprctl} keyword general:layout dwindle"
          # "$mod, E, togglesplit"

          # Toggle floating
          "$mod SHIFT, SPACE, togglefloating"

          # Focus parent/child (hyprland doesn't have direct equivalents, using cyclenext)
          # "$mod, O, focusurgentorlast"
          # "$mod, I, cyclenext"

          # Scratchpad (using special workspace in hyprland)
          "$mod, MINUS, togglespecialworkspace, scratch"
          "$mod SHIFT, MINUS, movetoworkspace, special:scratch"

          # Workspace navigation
          "$mod, N, workspace, e+1"
          "$mod, P, workspace, e-1"

          # Reload/restart
          "$mod ALT, R, exec, ${hyprctl} reload"

          # Lock screen
          "$mod ALT, L, exec, ${swaylock-bin} -fF"

          # Suspend
          "$mod ALT, ESCAPE, exec, ${pkgs.systemd}/bin/systemctl suspend"

          # Screenshots (using grimblast)
          # "$mod ALT, P, exec, ${grimblast} --notify save area"
          # "$mod ALT, P, exec, ${grimblast} --cursor --notify --freeze save area - | ${getExe pkgs.satty} --filename -"
          "$mod ALT, P, exec, ${grimblast} edit area"
          "$mod SHIFT, P, exec, ${grimblast} edit output"

          # Calculator
          "$mod, Z, exec, ${calc}"
        ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
        )
          9)
      );

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow" # Move window with Alt + left mouse button
        "$mod, mouse:273, resizewindow" # Resize window with Alt + right mouse button
      ];

      bindn = [
        "$mod, mouse:274, killactive" # Kill with Alt + middle mouse button
      ];

      workspace = [
        ", gapsout:0"
        ", bordersize:0"

        # workspace definitions for smart gaps
        "w[tv1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"
      ];

      # Floating window rules
      windowrulev2 = [
        # Smart gaps / no gaps when "only"
        "bordersize 0, floating:0, onworkspace:w[tv1]"
        "rounding 0, floating:0, onworkspace:w[tv1]"
        "bordersize 0, floating:0, onworkspace:f[1]"
        "rounding 0, floating:0, onworkspace:f[1]"

        # Removable media notification
        "float, title:^(Removable medium is inserted)$"

        # Steam windows (all float except main Steam window)
        "float, class:^(steam)$"
        "tile, class:^(steam)$, title:^(Steam)$"  # Main Steam window should be tiled

        # Volume control
        "float, class:^(Pavucontrol)$"
        "float, title:^(Volume Control)$"

        # VM and remote desktop viewers
        "float, title:^(VM .+)$"  # Virtual machine windows
        "float, title:(noVNC)"
        "float, title:(Proxmox Console)"

        # Bluetooth settings
        "float, title:^(Bluetooth Devices)$"

        # Calculator
        "float, class:^(qalculate-gtk)$"
      ];

      decoration.rounding = 10;

      decoration.shadow = {
        enabled = true;
        range = 50;
        render_power = 4;
        offset = "0 0";
        scale = 1.0;
        # scale = 0.95;
        # ignore_window = false;
        color = "rgba(187, 190, 195, 0.9)";
        color_inactive = "rgba(82, 89, 102, 0.7)";

      };

      decoration = {
        inactive_opacity = 0.8;
        active_opacity = 0.9;

        blur = {
          enabled = true;
          size = 10;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
          noise = 0;
          brightness = 0.90;
        };
      };
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "${../config/wallpapers/wallpaper_dark_sunset.jpg}"
      ];
      wallpaper = [
        ", ${../config/wallpapers/wallpaper_dark_sunset.jpg}"
      ];
      # wallpaper = {
      #     monitor = "DP-1";
      #     path = "${../../static/wallpaper_mountains.jpg}";
      #   # "DP-1,${../../static/wallpaper_mountains.jpg}"
      # };
        # "${main_out}" = ../../static/wallpaper_mountains.jpg;
        # "${beamer}" = "/home/${config.home.username}/Pictures/wallpapers/abstract1k.jpg";
    };
  };

  # Waybar configuration for hyprland
  programs.waybar.settings.mainBar.modules-left = [
    "hyprland/workspaces"
    "hyprland/submap"
    "hyprland/window"
  ];
  programs.waybar.settings.mainBar."hyprland/workspaces" = {
    disable-scroll = false;
    all-outputs = true;
    show-special = true;
    on-scroll-up = "${pkgs.hyprland}/bin/hyprctl dispatch workspace e-1";
    on-scroll-down = "${pkgs.hyprland}/bin/hyprctl dispatch workspace e+1";
    workspace-taskbar = {
      # Enable the workspace taskbar. Default = false
      enable = true;

      # If true, the active/focused window will have an 'active' class. Could cause higher CPU usage due to more frequent redraws. Default = false
      update-active-window = true;

      # Format of the windows in the taskbar. Default = {icon}. Allowed variables: {icon}, {title}
      format = "{icon} {title:.20}";

      # Icon size in pixels. Default = 16
      # icon-size = 16;

      # Either the name of an installed icon theme or an array of themes (ordered by priority). If not set, the default icon theme is used.
      # icon-theme = "some_icon_theme";

      # Orientation of the taskbar (horizontal or "vertical"). Default = "horizontal".
      # orientation = "horizontal";

      # List of regexes. A window will NOT be shown if its window class or title match one or more items. Default = []
      # ignore-list = [ "code", "Firefox - .*" ];

      # Command to run when a window is clicked. Default =  (switch to the workspace as usual). Allowed variables: {address}, {button}
      # on-click-window = "/some/arbitrary/script {address} {button}"
    };
  };
  programs.waybar.settings.mainBar."hyprland/window" = {
    max-length = 50;
    format = "{class} > {title}";
  };
};
}
