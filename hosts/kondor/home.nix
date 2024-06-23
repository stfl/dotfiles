{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  imports = [
    ../../modules/home
    ../../modules/home/desktop.nix
    ../../modules/home/emacs.nix
    ../../modules/home/pass.nix
  ];

  home.packages = with pkgs; [
    nvtopPackages.nvidia
  ];

  wayland.windowManager.sway = {
    extraOptions = [
      "--unsupported-gpu"
    ];
    extraSessionCommands = ''
      # Nvidia specific config
      export WLR_NO_HARDWARE_CURSORS=1
      export GBM_BACKEND=nvidia-drm
      export GBM_BACKENDS_PATH=/etc/gbm
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
    '';
  };
}
