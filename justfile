default: switch
reload:
    sudo nh os switch --offline

switch:
    sudo nh os switch

build:
    sudo nh os build

update:
    sudo nh os test --update --diff always
