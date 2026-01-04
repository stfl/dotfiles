default: switch

reload:
    nh os switch . --offline

switch:
    nh os switch .

build:
    nh os build .

update:
    nh os test . --update --diff always
