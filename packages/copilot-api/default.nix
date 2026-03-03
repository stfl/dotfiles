{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  bun2nix,
  nodejs,
  makeWrapper,
}: let
  src = fetchFromGitHub {
    owner = "ericc-ch";
    repo = "copilot-api";
    rev = "v${version}";
    hash = "sha256-rUUqf9QalVZDN3aw9ze5Uh+y5xvH6zdSgGN6ZLDjkDQ="; # src
  };
  version = "0.7.0";
in
  stdenv.mkDerivation {
    pname = "copilot-api";
    inherit version src;

    nativeBuildInputs = [bun2nix.hook bun nodejs makeWrapper];

    bunDeps = bun2nix.fetchBunDeps {
      inherit src;
      bunNix = ./bun.nix;
    };

    dontUseBunBuild = true;

    buildPhase = ''
      runHook preBuild
      bun run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/copilot-api $out/bin
      cp -r dist package.json $out/lib/copilot-api/
      makeWrapper ${nodejs}/bin/node $out/bin/copilot-api \
        --add-flags "$out/lib/copilot-api/dist/main.js"
      runHook postInstall
    '';

    meta = {
      description = "GitHub Copilot as OpenAI/Anthropic-compatible API";
      homepage = "https://github.com/ericc-ch/copilot-api";
      license = lib.licenses.mit;
      mainProgram = "copilot-api";
    };
  }
