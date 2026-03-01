{
  config,
  pkgs,
  USER,
  ...
}: {
  environment.systemPackages = [pkgs.cloudflared];

  age.secrets.cloudflared-tunnel-cert = {
    file = ../secrets/cloudflared-tunnel-cert.age;
    owner = USER;
    path = "/home/${USER}/.cloudflared/cert.pem";
  };
}
