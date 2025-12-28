default: switch
reload:
    sudo nixos-rebuild switch --flake '.#' --show-trace \
      --option substitute false

switch:
    sudo nixos-rebuild switch --flake '.#' --show-trace

build:
    nixos-rebuild build --flake '.#' --show-trace

diff:
    nvd diff /nix/var/nix/profiles/system result

build-update: flake build

flake:
    nix flake update

update: build-update && diff
