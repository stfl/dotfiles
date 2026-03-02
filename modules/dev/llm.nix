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
      hooks = {
        "record-prompt-time" = ''
          #!/usr/bin/env bash
          date +%s > /tmp/claude-prompt-start
        '';
        "notify-on-stop" = let
          notify = lib.getExe pkgs.libnotify;
        in ''
          #!/usr/bin/env bash
          start=$(cat /tmp/claude-prompt-start 2>/dev/null || echo 0)
          now=$(date +%s)
          elapsed=$((now - start))
          [ $elapsed -lt 60 ] && exit 0
          mins=$((elapsed / 60))
          secs=$((elapsed % 60))
          ${notify} -t 10000 "Claude Code" "Claude has finished (''${mins}m ''${secs}s)"
        '';
      };
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
          UserPromptSubmit = [
            {
              matcher = "";
              hooks = [
                {
                  type = "command";
                  command = "bash ~/.claude/hooks/record-prompt-time";
                }
              ];
            }
          ];
          Stop = [
            {
              matcher = "";
              hooks = [
                {
                  type = "command";
                  command = "bash ~/.claude/hooks/notify-on-stop";
                }
              ];
            }
          ];
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
