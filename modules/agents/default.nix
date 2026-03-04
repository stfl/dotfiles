{
  pkgs,
  USER,
  ...
}: {
  environment.systemPackages = with pkgs; [
    llm-agents.copilot-language-server
    nodejs
  ];

  home-manager.users.${USER} = {
    programs.aider-chat.enable = true;
  };
}
