#!/usr/bin/env bash

dry_run=0
# if -n is passed, don't actually run the commands
if [ "$1" = "-n" ]; then
    shift
    dry_run=1
fi

overlay_url_rev="master@{2%20hours%20ago}"

rm -rf /tmp/emacs-overlay/
mkdir -p /tmp/emacs-overlay/

http -F --download \
    https://github.com/nix-community/emacs-overlay/archive/${overlay_url_rev}.tar.gz \
    | tar xzvf - -C /tmp/emacs-overlay/

overlay_filename=$(ls /tmp/emacs-overlay/)
overlay_rev=${overlay_filename##*-}

nixpkgs_rev=$(cat /tmp/emacs-overlay/${overlay_filename}/flake.lock | jq -r '.nodes.nixpkgs.locked.rev')

if [ $dry_run -eq 1 ]; then
    echo "DRY RUN"
    echo "Overlay rev: ${overlay_rev}"
    echo "Nixpkgs rev: ${nixpkgs_rev}"
    exit 0
fi

nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/${nixpkgs_rev}
nix flake lock --override-input emacs-overlay github:nix-community/emacs-overlay/${overlay_rev}
