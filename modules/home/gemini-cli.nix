{
  pkgs,
  config,
  ...
}: {
  programs.gemini-cli = {
    enable = true;
    package = pkgs.llm-agents.gemini-cli;
    defaultModel = "gemini-3-flash";
  };

  home.file = let
    dot = "${config.home.homeDirectory}/.config/dotfiles/config";
  in
    with config.lib.file; {
      ".gemini/settings.json".source = mkOutOfStoreSymlink "${dot}/gemini/settings.json";
    };
}
