{
  pkgs,
  USER,
  ...
}: {
  home-manager.users.${USER} = {
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
