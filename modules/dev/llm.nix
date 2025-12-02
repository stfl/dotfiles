{
  config,
  lib,
  pkgs,
  USER,
  ...
}:

{
  home-manager.users.${USER} = {
    programs.claude-code = {
      enable = true;
    };
    home.packages = with pkgs; [
      claude-code-router
      copilot-language-server
      nodejs
    ];

    programs.aider-chat = {
      enable = true;
      # settings = {};
    };
  };
}
