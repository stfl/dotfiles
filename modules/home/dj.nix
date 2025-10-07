{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    mixxx

    # downloader
    spotdl
    yt-dlp
  ];
}
