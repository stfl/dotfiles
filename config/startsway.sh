#!/usr/bin/env zsh

# set -uo pipefail

setopt extended_glob
echo -e "\n---- Unlock Bitwarden"
rbw unlock

echo -e "\n---- Store LDAP password to access alma shares"
cifscreds add -u slendl alma.intra.proxmox.com

is_sway=$(systemctl --user is-active sway-session.target)
print "sway-session is $is_sway"

if [[ x$is_sway != xactive ]]; then
    echo -e "\n---- Starting Sway"
    echo "---- Starting Sway ----" >>| ~/.cache/sway.log
    nixGLIntel sway &>> ~/.cache/sway.log
else
    echo "not starting"
    exit 0
fi
