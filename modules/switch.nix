{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.ns-usbloader.enable = true;

  # download hekate from here: this is the release in use
  # https://github.com/CTCaer/hekate/releases/tag/v6.2.1
}
