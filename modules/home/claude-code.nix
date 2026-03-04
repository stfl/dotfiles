{
  lib,
  pkgs,
  config,
  ...
}: {
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

  home.file = with config.lib.file; {
    ".claude/settings.json".source = mkOutOfStoreSymlink ../../config/claude/settings.json;
    ".claude/agents".source = mkOutOfStoreSymlink ../../config/claude/agents;
    ".claude/rules".source = mkOutOfStoreSymlink ../../config/claude/rules;
    ".claude/commands".source = mkOutOfStoreSymlink ../../config/claude/commands;
    ".claude/skills".source = mkOutOfStoreSymlink ../../config/agents/skills;
  };
}
