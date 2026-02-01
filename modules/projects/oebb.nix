{
  config,
  lib,
  pkgs,
  USER,
  ...
}:
let
  github-host = "digirail.github.com";

  citrix_workspace = pkgs.citrix_workspace_24_08_0.overrideAttrs (_: {
    src = ../../packages/citrix/linuxx64-24.8.0.98.tar.gz; # Adjust path as needed
  });
in
{
  imports = [
    ../wireguard.nix
    ../agenix.nix
  ];

  environment.systemPackages = with pkgs; [
    keepassxc
    # citrix_workspace # FIXME depends on qtwebengine which is flagged as insecure

    cargo-bitbake
  ];

  # networking.firewall.checkReversePath = "loose";
  # networking.firewall.checkReversePath = false;

  # networking.wg-quick.interfaces.digirail0 = {name, ...}: {
  #   autostart = false;
  #   privateKeyFile = config.age.secrets.wg-digirail-private.path;
  #   address = ["192.168.63.2/32"];
  #   dns = ["192.168.63.1"];

  #   # enable split DNS via systemd-resolved
  #   # postUp = ''
  #   #   # ${pkgs.systemd}/bin/resolvectl domain ${name} \~digiattack.net
  #   # '';

  #   peers = [
  #     {
  #       publicKey = "fD02JAuwSfjKIotk0kVBrVXVUETRwUL0aPpp4iGlPj0=";
  #       allowedIPs = [
  #         "192.168.63.1/32"
  #         "192.168.63.2/32"
  #         "0.0.0.0/0"
  #         # "::/0"
  #       ];
  #       endpoint = "80.121.253.230:51820";
  #       # persistentKeepalive = 25;
  #     }
  #   ];
  # };

  home-manager.users.${USER} =
    { config, ... }:
    {
      programs.git.settings.alias = {
        # digirail alias to apply config for individual commands:
        # `git digirail -- clone git@github.com`
        #  -> automatically rewrites to a git clone git@digirail.github.com
        digirail = "!sh -c 'git -c url.git@${github-host}:.insteadOf=git@github.com: -c url.git@${github-host}:.pushInsteadOf=git@github.com: \"$@\"'";
      };

      programs.git.includes = [
        {
          condition = "gitdir:${config.home.homeDirectory}/work/oebb/";
          contents = {
            user.email = "stefan-digirailbox@stfl.dev";
            url."git@${github-host}:" = {
              insteadOf = "git@github.com:";
              pushInsteadOf = "git@github.com:";
            };
            github.user = "stefan-digirailbox";
          };
        }
      ];

      programs.ssh.matchBlocks."${github-host}" = {
        hostname = "github.com";
        user = "git";
        identityFile = [ "~/.ssh/id_ed25519_oebb" ];
        identitiesOnly = true;
      };

      programs.ssh.matchBlocks = {
        "drb-dev digirail-home2 drb-home2" = {
          hostname = "192.168.1.90";
          user = "root";
          identityFile = [ "~/.ssh/id_ed25519_oebb" ];
          checkHostIP = false;
          port = 13048;
          extraOptions = {
            StrictHostKeyChecking = "no";
            UserKnownHostsFile = "/dev/null";
          };
          setEnv = {
            TERM = "xterm";
          };
        };
        "b2btest.oebb.at" = {
          user = "DigiRailBox";
          identityFile = [ "~/.ssh/id_ed25519_sterling" ];
        };
      };
    };
}
