#!/usr/bin/env zsh

# set -uo pipefail

setopt extended_glob
echo "---- Unlock ssh keyring:"
ssh-add ~/.ssh/id_*~*.pub

# echo "Unlock gpg keyring"

echo -e "\n---- Unlock Bitwarden"
rbw unlock

echo -e "\n---- Store LDAP password to access alma shares"
cifscreds add -u slendl alma.intra.proxmox.com

echo -e "\n---- Starting Sway"
is_sway=$(systemctl --user is-active sway-session.target)
print "sway-session is $is_sway"

if [[ x$is_sway != xactive ]]; then
    echo "---- Starting Sway ----" >>| ~/.cache/sway.log
    nixGLIntel sway &>> ~/.cache/sway.log
else
    echo "not starting"
    exit 0
fi
