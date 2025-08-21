({pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    poetry
    uv
    basedpyright
    ruff
  ];
})
