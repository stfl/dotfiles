(
  { pkgs, ... }:
  {
    environment.systemPackages = with pkgs; [
      python3
      poetry
      uv
      basedpyright
      ruff
    ];
  }
)
