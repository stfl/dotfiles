#!/usr/bin/env bash

pkill -u $UID polybar
while pgrep -u $UID polybar >/dev/null; do sleep 1; done

export MONITOR=$(xrandr -q | grep primary | cut -d' ' -f1)
export MONITORS=( $(xrandr -q | grep ' connected' | cut -d' ' -f1) )
export MONITOR=${MONITOR:-${MONITORS[0]}}

export LAN=enp0s31f6


# ${POLYBAR_QUICKRELOAD:+--config=$XDG_CONFIG_HOME/dotfiles/modules/themes/alucard/config/polybar/config}
    # --config="$XDG_CONFIG_HOME/dotfiles/modules/themes/alucard/config/polybar/config"

polybar main >$XDG_DATA_HOME/polybar.log 2>&1 &
echo 'Polybar launched...'
