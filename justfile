default: switch

reload:
    nh os switch -- --offline

switch:
    nh os switch -- --show-trace

build:
    nh os build -- --show-trace

update:
    nh os test -- --update --diff always
