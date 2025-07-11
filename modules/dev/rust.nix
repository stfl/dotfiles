({
  pkgs,
  fenix,
  USER,
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
    cargo-binutils

    llvmPackages.bintools
    clang
    gcc
    glibc
    binutils
  ];

  home-manager.users.${USER}.home.file.".cargo/config.toml".text = ''
    [target.x86_64-unknown-linux-gnu]
    linker = "clang"
    rustflags = ["-Clink-arg=-fuse-ld=lld"]
  '';
})
