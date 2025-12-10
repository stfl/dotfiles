{ config, lib, pkgs, USER, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM  = true;
  };

  home-manager.users.${USER} =
{ config, lib, pkgs, ... }:
with lib;
let
  TERMINAL = "${getExe config.programs.alacritty.package}";
  swaylock-bin = "${getExe pkgs.swaylock}";
  calculator-pkg = pkgs.qalculate-gtk;
  swayosd_client = "${config.services.swayosd.package}/bin/swayosd-client";
  grimblast = "${getExe pkgs.grimblast}";
in {
  wayland.windowManager.hyprland = {
    enable = true;
    # # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;
    systemd = {
      enable = false; # conflicts with UWSM
      # enable = true;
      # variables = ["--all"];
    };
    settings = {
      input = {
        kb_layout = "us";
        kb_variant = "altgr-intl";
        kb_options = "eurosign:5";
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          drag_3fg = 1; # enable three-finger drag
          clickfinger_behavior = true; # Button presses with 1, 2, or 3 fingers will be mapped to LMB, RMB, and MMB
          middle_button_emulation = true; # Emulate middle button when both left and right buttons are pressed
          drag_lock = 1;
        };
      };
      "$mod" = "SUPER";
      bind =
        [
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

          "$mod, TAB, cyclenext"

          # Application launcher
          "$mod, SPACE, exec, ${getExe pkgs.wofi}"

          # Password manager
          "$mod, G, exec, ${getExe pkgs.wofi-pass} --autotype"

          # Window switcher
          "$mod, BACKSPACE, exec, sh -c '${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r '\"'\"'.[] | \"\\(.address)|\\(.title) [\\(.class)]\"'\"'\"' | ${getExe pkgs.wofi} --dmenu -p \"Switch to:\" | ${pkgs.coreutils}/bin/cut -d\"|\" -f1 | ${pkgs.findutils}/bin/xargs -r -I{} ${pkgs.hyprland}/bin/hyprctl dispatch focuswindow address:{}'"

          # Terminal
          "$mod, RETURN, exec, ${TERMINAL}"

          # Audio controls
          ", XF86AudioLowerVolume, exec, ${swayosd_client} --output-volume lower --max-volume 120"
          ", XF86AudioRaiseVolume, exec, ${swayosd_client} --output-volume raise --max-volume 120"
          ", XF86AudioMute, exec, ${swayosd_client} --output-volume mute-toggle"
          ", XF86AudioMicMute, exec, ${swayosd_client} --input-volume mute-toggle"

          # Brightness controls
          ", XF86MonBrightnessDown, exec, ${swayosd_client} --brightness lower"
          ", XF86MonBrightnessUp, exec, ${swayosd_client} --brightness raise"

          # Split orientation (hyprland uses dwindle layout with togglesplit)
          # "$mod SHIFT, S, togglesplit"
          # "$mod SHIFT, V, togglesplit"
          "$mod, A, togglesplit"

          # Fullscreen
          "$mod, F, fullscreen, 0"

          # Layout modes
          "$mod, S, exec, hyprctl keyword general:layout master"
          "$mod, T, exec, hyprctl keyword general:layout dwindle"
          # "$mod, E, togglesplit"

          # Toggle floating
          "$mod ALT, SPACE, togglefloating"

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
          "$mod SHIFT, R, exec, hyprctl reload"

          # Lock screen
          "$mod ALT, L, exec, ${swaylock-bin} -fF"

          # Suspend
          "$mod ALT, ESCAPE, exec, ${pkgs.systemd}/bin/systemctl suspend"

          # Screenshots (using grimblast)
          "$mod ALT, P, exec, ${grimblast} --notify save area"
          "$mod SHIFT, P, exec, ${grimblast} --notify save active"
          "$mod CTRL, P, exec, ${grimblast} --notify save output"

          # Calculator
          "$mod, Z, exec, ${getExe calculator-pkg}"
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
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Kill with middle mouse button
      bindn = [
        # ", mouse:274, killactive"  # in sway this is set on the titlebar only
      ];

      # Floating window rules
      windowrulev2 = [
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
