{
  config,
  lib,
  pkgs,
  USER,
  ...
}: let
  github-host = "digirail.github.com";
in {
  age.secrets.wg-digirail-private.file = ../../secrets/wg-digirail-private.age;
  networking.wg-quick.interfaces.digirail0 = {name, ...}: {
    address = ["192.168.63.2/32"];
    privateKeyFile = config.age.secrets.wg-digirail-private.path;

    # enable split DNS via systemd-resolved
    postUp = ''
      ${pkgs.systemd}/bin/resolvectl dns ${name} 192.168.63.1
      ${pkgs.systemd}/bin/resolvectl domain ${name} \~digiattack.net
    '';

    peers = [
      {
        publicKey = "fD02JAuwSfjKIotk0kVBrVXVUETRwUL0aPpp4iGlPj0=";
        allowedIPs = [
          "192.168.63.1/32"
          "192.168.63.2/32"
          # "0.0.0.0/0"
        ];
        endpoint = "80.121.253.230:51820";
        # persistentKeepalive = 25;
      }
    ];
  };

  home-manager.users.${USER} = {
    pkgs,
    config,
    ...
  }: {
    home.packages = with pkgs; [
      act
    ];

    programs.git.aliases = {
      # digirail alias to apply config for individual commands:
      # `git digirail -- clone git@github.com`
      #  -> automatically rewrites to a git clone git@digirail.github.com
      digirail = "!sh -c 'git -c url.git@${github-host}:.insteadOf=git@github.com: -c url.git@${github-host}:.pushInsteadOf=git@github.com: \"$@\"'";
    };

    programs.git.includes = [
      {
        condition = "gitdir:${config.home.homeDirectory}/work/oebb/";
        contents.user.email = "stefan-digirailbox@stfl.dev";
        contents.url."git@${github-host}:" = {
          insteadOf = "git@github.com:";
          pushInsteadOf = "git@github.com:";
        };
      }
    ];

    programs.ssh.matchBlocks."${github-host}" = {
      hostname = "github.com";
      user = "git";
      identityFile = ["${config.home.homeDirectory}/.ssh/id_ed25519_oebb"];
      identitiesOnly = true;
    };
  };
}
