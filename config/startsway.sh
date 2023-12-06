#!/usr/bin/env zsh

set -euxo pipefail

setopt extended_glob
echo "Unlock ssh keyring"
ssh-add ~/.ssh/id_*~*.pub

# echo "Unlock gpg keyring"

echo "Unlock Bitwarden"
rbw unlock

echo "Enter LDAP password to access alma shares"
cifscreds add -u slendl alma.intra.proxmox.com

echo "---- Starting Sway ----" >>| ~/.cache/sway.log
nixGLIntel sway &>> ~/.cache/sway.log
