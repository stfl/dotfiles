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
    nh os switch --hostname {{hostname}} --target-host {{target}} {{args}}
