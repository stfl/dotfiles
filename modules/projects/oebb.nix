{
  config,
  lib,
  pkgs,
  USER,
  ...
}: {
  home-manager.users.${USER} = {
    pkgs,
    config,
    ...
  }: {
    home.packages = with pkgs; [
      act
    ];

    programs.git.includes = [
      {
        condition = "gitdir:${config.home.homeDirectory}/work/oebb/";
        contents.user.email = "stefan-digirailbox@stfl.dev";
      }
    ];
  };
}
