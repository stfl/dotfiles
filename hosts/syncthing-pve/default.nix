{ pkgs, ... }:
{
  imports = [
    ../../modules/nix.nix
    ../../modules/hardware/pvect.nix
  ];

  environment.systemPackages = with pkgs; [
    vim
    curl
    htop
  ];

  system.stateVersion = "25.11";

  # Tailscale for networking
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # allow Syncthing GUI port through the firewall
  networking.firewall.allowedTCPPorts = [ 8384 ];

  # Syncthing service
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384"; # Network accessible
    openDefaultPorts = true;
    overrideFolders = false; # false means folders added via the web interface will persist
    overrideDevices = false; # false means devices added via the web interface will persist
    settings = {
      options.relaysEnabled = true;
      options.urAccepted = -1;

      devices = {
        "pixel10" = {
          id = "OX54FI2-6T2MKRI-WP6VQH7-534ONWZ-CUN6VAZ-CDEDY2A-QTBFG2R-PD3MMQG";
          autoAcceptFolders = true;
        };
        "kondor" = {
          id = "4AUUDXR-I4HDZOG-O3IA2G6-UJ6FBLO-B7TMOKD-T2SOUQD-3S53YUP-XL7G6QQ";
          autoAcceptFolders = true;
        };
        "pirol" = {
          id = "ZJYQY7 N-4KXKX7B-3A5YV6K-FTX7K2N-3IYQY7N-4KXKX7B-3A5YV6K-FTX7K2N";
          autoAcceptFolders = true;
        };
        "oneplus7t" = {
          id = "KT7QZCK-HSD66PY-G46HMG3-XSXMAFB-EFYF4JP-JBNANTZ-AL2SZIZ-QPJXLQK";
        };
      };

      folders = {
        "~/Documents" = {
          id = "ckwep-imxta";
          devices = [ "pixel10" "kondor" "oneplus7t" "pirol" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };

        "~/Music" = {
          id = "aahjv-7rmpa";
          devices = [ "kondor" "pirol" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };

        "~/.mixxx" = {
          id = "xcelj-ssdit";
          devices = [ "kondor" "pirol" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };

        "~/Recordings" = {
          id = "8zdv2-vwwhz";
          devices = [ "kondor" "oneplus7t" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };

        "~/Books" = {
          id = "l2sv1-o797j";
          devices = [ "pixel10" "kondor" "oneplus7t" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };
      };
    };
  };
}
