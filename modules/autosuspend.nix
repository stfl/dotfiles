{
  config,
  lib,
  pkgs,
  ...
}:
# based on https://gist.github.com/domenkozar/82886ee82efee623cdc0d19eb81c7fb7
with lib; let
  cfg = config.services.autoSuspend;
in {
  options = {
    services.autoSuspend = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable battery notifier.
        '';
      };
      device = mkOption {
        type = types.str;
        default = "BAT0";
        description = ''
          Device to monitor.
        '';
      };
      operation = mkOption {
        type = types.str;
        default = "hibernate";
        description = ''
          systemctl operation to perform at suspendCapacity
        '';
      };
      notifyCapacity = mkOption {
        type = types.int;
        default = 10;
        description = ''
          Battery level at which a notification shall be sent.
        '';
      };
      suspendCapacity = mkOption {
        type = types.int;
        default = 5;
        description = ''
          Battery level at which a suspend unless connected shall be sent.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.timers.auto-suspend = {
      description = "check battery level";
      timerConfig.OnBootSec = "1m";
      timerConfig.OnUnitInactiveSec = "1m";
      timerConfig.Unit = "auto-suspend.service";
      wantedBy = ["timers.target"];
    };
    systemd.user.services.auto-suspend = {
      description = "battery level notifier";
      serviceConfig.PassEnvironment = "DISPLAY";
      script = ''
        export battery_capacity=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/${cfg.device}/capacity)
        export battery_status=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/${cfg.device}/status)
        if [[ $battery_capacity -le ${builtins.toString cfg.notifyCapacity} && $battery_status = "Discharging" ]]; then
            ${pkgs.libnotify}/bin/notify-send --urgency=critical --hint=int:transient:1 --icon=battery_empty "Battery Low" "You should probably plug-in."
        fi
        if [[ $battery_capacity -le ${builtins.toString cfg.suspendCapacity} && $battery_status = "Discharging" ]]; then
            ${pkgs.libnotify}/bin/notify-send --urgency=critical --hint=int:transient:1 --icon=battery_empty "Battery Critically Low" "Computer will suspend in 60 seconds."
            sleep 60s
            battery_status=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/${cfg.device}/status)
            if [[ $battery_status = "Discharging" ]]; then
                ${pkgs.systemd}/bin/systemctl ${cfg.operation}
            fi
        fi
      '';
    };
  };
}
