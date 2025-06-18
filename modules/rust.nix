({
  pkgs,
  fenix,
  ...
}: {
  nixpkgs.overlays = [fenix.overlays.default];
  environment.systemPackages = with pkgs; [
    (pkgs.fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer-nightly
    cargo-nextest
  ];
})
