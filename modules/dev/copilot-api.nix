{
  copilot-api,
  config,
  ...
}: {
  imports = [copilot-api.nixosModules.default];

  nixpkgs.overlays = [copilot-api.overlays.default];

  age.secrets.github-copilot-token.file = ../../secrets/github-copilot-token.age;

  services.copilot-api = {
    enable = true;
    githubTokenFile = config.age.secrets.github-copilot-token.path;
  };
}
