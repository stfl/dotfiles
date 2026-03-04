{config, ...}: {
  age.secrets.github-copilot-token.file = ../../secrets/github-copilot-token.age;

  systemd.tmpfiles.rules = [
    "d /run/copilot-api-cfg 0700 root root - -"
  ];

  systemd.services."${config.virtualisation.oci-containers.backend}-copilot-api" = {
    serviceConfig = {
      LoadCredential = "github-token:${config.age.secrets.github-copilot-token.path}";
    };
    preStart = ''
      printf 'GH_TOKEN=%s\n' "$(cat "$CREDENTIALS_DIRECTORY/github-token")" \
        > /run/copilot-api-cfg/token.env
      chmod 600 /run/copilot-api-cfg/token.env
    '';
  };

  virtualisation.oci-containers.containers.copilot-api = {
    image = "ghcr.io/caozhiyuan/copilot-api:v1.1.8";
    environment = {
      HOST = "0.0.0.0";
      COPILOT_API_HOME = "/copilot-config";
    };
    environmentFiles = ["/run/copilot-api-cfg/token.env"];
    volumes = ["/run/copilot-api-cfg:/copilot-config"];
    ports = ["127.0.0.1:4141:4141"];
  };
}
