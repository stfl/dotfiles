{
  lib,
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    mcp-nixos
    llm-agents.claude-code-acp
  ];

  programs.claude-code = {
    package = lib.mkDefault pkgs.llm-agents.claude-code;
    enable = true;
    mcpServers = {
      nixos = {
        command = lib.getExe pkgs.mcp-nixos;
        args = [];
      };
    };
    hooks = {};
  };

  home.file = let
    dot = "${config.home.homeDirectory}/.config/dotfiles/config";
  in
    with config.lib.file; {
      ".claude/settings.json".source = mkOutOfStoreSymlink "${dot}/claude/settings.json";
      ".claude/agents".source = mkOutOfStoreSymlink "${dot}/claude/agents";
      ".claude/rules".source = mkOutOfStoreSymlink "${dot}/claude/rules";
      ".claude/commands".source = mkOutOfStoreSymlink "${dot}/claude/commands";
      ".claude/skills".source = mkOutOfStoreSymlink "${dot}/agents/skills";
    };
}
