just := just_executable() + " --justfile=" + justfile()

switch:
    sudo nixos-rebuild switch --flake '.#' --show-trace

build:
    nixos-rebuild build --flake '.#' --show-trace

diff:
    nvd diff /nix/var/nix/profiles/system result

update:
    nix flake update
    {{ just }} build
    {{ just }} diff
    # read "Continue? [Enter] → Yes, [Ctrl]+[C] → No."
    # {{ just }} switch
