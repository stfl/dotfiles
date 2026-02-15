{pkgs, ...}: let
  citrix_workspace = pkgs.citrix_workspace.overrideAttrs (_: {
    version = "25.08.10";
    src = ../packages/citrix/linuxx64-25.08.10.111.tar.gz; # Adjust path as needed
  });
in {
  nixpkgs.config.permittedInsecurePackages = ["libsoup-2.74.3"];

  environment.systemPackages = [citrix_workspace];
}
