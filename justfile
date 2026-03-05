default: switch

reload *args:
    nh os switch --offline {{args}}

switch *args:
    nh os switch {{args}}

build *args:
    nh os build {{args}}

update *args:
    nh os build --update --diff always {{args}}

deploy hostname target *args:
    NIX_SSHOPTS="-i ~/.ssh/id_ed25519_stfl" \
    nixos-rebuild \
      --target-host {{target}} \
      --sudo switch \
      --flake ".#{{hostname}}"
    # nh os switch \
    #   --hostname {{hostname}} \
    #   --target-host  \
      # -- {{args}}
