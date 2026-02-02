{ config, USER, ... }:
let
  # Capture NixOS config for use inside home-manager module
  nixosConfig = config;
in
{
  age.secrets.rclone-drive-client-secret = {
    file = ../secrets/rclone-drive-client-secret.age;
    owner = USER;
  };
  age.secrets.rclone-drive-token = {
    file = ../secrets/rclone-drive-token.age;
    owner = USER;
  };

  home-manager.users.${USER} =
    { config, ... }:
    {
      programs.rclone = {
        enable = true;
        remotes.drive = {
          config = {
            type = "drive";
            user = "s@stfl.dev";
            client_id = "817680142024-l5o7r3floehs2a1kqhfjignqgne8icje.apps.googleusercontent.com";
          };
          secrets = {
            client_secret = nixosConfig.age.secrets.rclone-drive-client-secret.path;
            token = nixosConfig.age.secrets.rclone-drive-token.path;
          };
          mounts.Documents = {
            enable = true;
            mountPoint = config.xdg.userDirs.documents;
            options = {
              dir-cache-time = "5000h";
              poll-interval = "10s";
            };
            logLevel = "INFO";
          };
        };
      };
    };
}
