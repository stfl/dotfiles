#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix-prefetch-github bun2nix git

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fetch latest release version from GitHub
LATEST=$(curl -s https://api.github.com/repos/ericc-ch/copilot-api/releases/latest | jq -r '.tag_name' | sed 's/^v//')
echo "Latest version: $LATEST"

# Prefetch source and get hash
SRC_HASH=$(nix-prefetch-github ericc-ch copilot-api --rev "v$LATEST" --json | jq -r '.hash')
echo "Source hash: $SRC_HASH"

# Update version and hash in default.nix
sed -i "s/version = \".*\"/version = \"$LATEST\"/" "$SCRIPT_DIR/default.nix"
sed -i "s|hash = \".*\"; # src|hash = \"$SRC_HASH\"; # src|" "$SCRIPT_DIR/default.nix"

# Clone source and generate bun.nix
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT
git clone --depth 1 --branch "v$LATEST" https://github.com/ericc-ch/copilot-api "$TMPDIR/copilot-api"
cd "$TMPDIR/copilot-api"
bun2nix -o bun.nix
cp bun.nix "$SCRIPT_DIR/bun.nix"

echo "Updated copilot-api to $LATEST"
