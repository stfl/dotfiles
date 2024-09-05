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
      # Hardware cursors not yet working on wlroots
      export WLR_NO_HARDWARE_CURSORS=1
      # Set wlroots renderer to Vulkan to avoid flickering
      export WLR_RENDERER=vulkan

      # OpenGL Variables
      export GBM_BACKEND=nvidia-drm
      export __GL_GSYNC_ALLOWED=0
      export __GL_VRR_ALLOWED=0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      # export GBM_BACKENDS_PATH=/etc/gbm

      # Xwayland compatibility
      export XWAYLAND_NO_GLAMOR=1
    '';
  };
}
