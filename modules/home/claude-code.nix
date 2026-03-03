{
  lib,
  pkgs,
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
    settings = {
      includeCoAuthoredBy = false;
      model = "opus";
      alwaysThinkingEnabled = true;
      permissions = {
        allow = [
          "Bash(git diff:*)"
          "Edit"
        ];
        ask = [
          "Bash(git push:*)"
        ];
        defaultMode = "acceptEdits";
        deny = [
          "Read(.env)"
        ];
        disableBypassPermissionsMode = "disable";
      };
      statusLine = {
        command = "input=$(cat); echo \"[$(echo \"$input\" | ${lib.getExe pkgs.jq} -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | ${lib.getExe pkgs.jq} -r '.workspace.current_dir')\")\"";
        padding = 0;
        type = "command";
      };
      theme = "dark";
      enabledPlugins = {
        "rust-analyzer-lsp@claude-plugins-official" = true;
      };
      hooks = {
        UserPromptSubmit = [];
        Stop = [];
      };
    };
  };
}
