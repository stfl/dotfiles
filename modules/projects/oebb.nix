{
  config,
  lib,
  pkgs,
  USER,
  ...
}: let
  github-host = "digirail.github.com";
in {
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
