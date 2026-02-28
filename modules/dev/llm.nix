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
      mcpServers = {
        nixos = {
          command = lib.getExe pkgs.mcp-nixos;
          args = [];
        };
      };
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
