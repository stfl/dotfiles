{
  config,
  lib,
  pkgs,
  USER,
  ...
}: {
  home-manager.users.${USER} = {
    programs.claude-code = {
      package = pkgs.llm-agents.claude-code;
      enable = true;
    };
    home.packages = with pkgs; [
      llm-agents.copilot-language-server
      llm-agents.gemini-cli
      nodejs
    ];

    programs.aider-chat = {
      enable = true;
      # settings = {};
    };
  };
}
