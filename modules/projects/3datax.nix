{
  config,
  USER,
  ...
}: {
  imports = [
    ../agenix.nix
  ];

  age.secrets."3datax-ssh-config" = {
    file = ../../secrets/3datax-ssh-config.age;
    path = "/home/stefan/.ssh/config-extra.d/3datax.config";
    mode = "400";
    owner = "stefan";
    symlink = false;
  };

  home-manager.users.${USER} = {
    pkgs,
    config,
    ...
  }: {
    programs.git.includes = [
      {
        condition = "gitdir:${config.home.homeDirectory}/work/3datax/";
        contents = {
          init.defaultBranch = "master";
          user.email = "stefan.lendl@3datax.com";
        };
      }
    ];
  };
}
