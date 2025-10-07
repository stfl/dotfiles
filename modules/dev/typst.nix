(
  { pkgs, ... }:
  {
    environment.systemPackages = with pkgs; [
      typst
      tinymist
      typstyle
      typst-live
      tree-sitter-grammars.tree-sitter-typst # TODO all grammers may be installed already?
    ];
  }
)
