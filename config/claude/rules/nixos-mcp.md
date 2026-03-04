# NixOS MCP Usage

When looking up NixOS packages, options, or configuration — always use the `nixos` MCP server tools instead of web search or knowledge from training data. This includes:

- Searching for packages (`mcp__nixos__nix` with `action: "search"`)
- Looking up package details or versions
- Querying NixOS or Home Manager options
- Checking Darwin, flake inputs, or nixvim configuration

Prefer the MCP over WebSearch for anything NixOS-related, as it provides accurate, up-to-date data from the actual nixpkgs channels.
