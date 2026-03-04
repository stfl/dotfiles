# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal NixOS configuration repository managing multiple machines using Nix flakes. The configuration includes both NixOS system configuration and home-manager for user-level packages and dotfiles.

## Common Commands

### Build and switch configuration
```bash
just switch                    # Apply configuration changes (default command)
sudo nixos-rebuild switch --flake '.#' --show-trace
```

### Build without switching
```bash
just build
nixos-rebuild build --flake '.#' --show-trace
```

### Update flake inputs
```bash
just update                    # Update flake, build, and show diff
just flake                     # Only update flake.lock
nix flake update
```

### View configuration differences
```bash
just diff
nvd diff /nix/var/nix/profiles/system result
```

### Format Nix files
```bash
alejandra .                    # ALWAYS use alejandra, NEVER use nixfmt
```

### Validate configuration changes
```bash
just build                     # Build configuration to validate syntax
nixos-rebuild build --flake '.#' --show-trace
```
This validates the entire NixOS configuration including home-manager and Hyprland settings without applying changes.

### Build custom ISO
```bash
nix build .#iso
sudo dd if=results/iso/*.iso of=/dev/sda bs=4M status=progress && sync
```

### Remote deployment
```bash
nixos-rebuild \
    --target-host user@hostname \
    --sudo \
    switch \
    --flake ".#hostname"
```

## Architecture

### Flake Structure
- **flake.nix**: Main entry point defining inputs and outputs
- **hosts/**: Per-machine configurations
  - Each host has: `default.nix`, `hardware-configuration.nix`, `home.nix`
  - Current hosts: `kondor` (desktop), `pirol`, `claw-pve` (server VM), `iso` (installation media)
- **modules/**: Reusable NixOS and home-manager modules
  - System modules: desktop environments, services, hardware configurations
  - **modules/home/**: Home-manager specific modules (shell, emacs, email, etc.)
  - **modules/hardware/**: Hardware-specific configurations (bluetooth, ZFS, ZSA keyboards, etc.)
  - **modules/dev/**: Development environment configurations (Python, Rust, Typst, LLM tools)
- **secrets/**: Encrypted secrets managed with agenix
  - **secrets/secrets.nix**: Defines which hosts can decrypt which secrets

### Key Dependencies
- **home-manager**: User environment and dotfiles management
- **agenix**: Age-based secret encryption
- **determinate**: Determinate Systems' Nix enhancements
- **nixos-hardware**: Community hardware configurations
- **emacs-overlay**: Latest Emacs packages
- **fenix**: Rust toolchain management

### Module Organization
Host configurations import relevant modules from `modules/` directory:
- Base system setup via `modules/default.nix` (shell, Nix settings, home-manager integration)
- Optional features: `desktop.nix`, `sway.nix`, `hyprland.nix`, `steam.nix`, `docker.nix`, `virtualization.nix`
- Hardware features: `hardware/bluetooth.nix`, `hardware/zsa.nix` (ZSA keyboards), `hardware/ledger.nix`
- Project-specific configurations in `modules/projects/`

### User Configuration
- Primary user defined by `USER` variable (currently "stefan")
- User home configuration in `hosts/${hostname}/home.nix`
- Home-manager modules in `modules/home/` for shell, emacs, email, password-store, etc.

### Desktop Environments
Two wayland compositors are configured:
- **Sway**: Via `modules/sway.nix` and sway config in home-manager (uses kanshi for display management)
- **Hyprland**: Via `modules/hyprland.nix` with UWSM (Universal Wayland Session Manager, uses native monitor configuration)
- Common tools: waybar, swaylock, alacritty terminal

## Secrets Management with agenix

### Edit a secret
```bash
cd secrets
agenix -e <name-of-secret>.age
```

### Add a new secret
1. Add entry to `secrets/secrets.nix` with authorized host public keys
2. Create the secret file using agenix

### Rekey a secret
When a secret's `publicKeys` change in `secrets.nix`, rekey ONLY the affected file:
```bash
cd secrets
agenix --rekey -i ~/.ssh/id_ed25519_stfl <name-of-secret>.age
```
NEVER rekey all secrets at once — always specify the individual file(s).

### Add a new host to secrets
1. Get the host SSH public key from `/etc/ssh/ssh_host_ed25519_key.pub`
2. Add the key to `secrets/secrets.nix`
3. Rekey the affected secrets (only the ones that reference the new host key):
```bash
cd secrets
agenix --rekey -i ~/.ssh/id_ed25519_stfl <affected-secret>.age
```

## Host: claw-pve

Headless server VM running on Proxmox. FQDN: `claw.stfl.dev`.

### Storage layout
- `/` — system root (ephemeral, rebuilt from NixOS config)
- `/data` — all persistent application data (ext4, separate VM disk labeled `data`)

Application state is bind-mounted from `/data` into the locations services expect (e.g. `/data/n8n` → `/var/lib/private/n8n`, `/data/podman/volumes` → `/var/lib/containers/storage/volumes`).

### Services
- **n8n**: Workflow automation, reverse-proxied via nginx at `https://n8n.stfl.dev`
- **Monica**: Personal CRM, reverse-proxied via nginx at `https://monica.stfl.dev`, data in `/data/monica`, MariaDB in `/data/mariadb`
- **ZeroClaw**: AI agent daemon (Telegram, WhatsApp Web channels), state in `/data/zeroclaw/.zeroclaw/`. Config is created via `zeroclaw onboard --interactive` on the host (not managed by Nix). Anthropic API key injected via `ANTHROPIC_API_KEY` env var from agenix secret.
- **Podman**: Container runtime, volume storage on `/data/podman/volumes`
- **nginx**: Reverse proxy with Let's Encrypt TLS (ACME DNS-01 via Cloudflare) for `*.stfl.dev`

### Management commands
```bash
# Build without deploying (validate changes)
nixos-rebuild build --flake '.#claw-pve' --show-trace

# Deploy to claw
nixos-rebuild --target-host claw.stfl.dev --sudo switch --flake ".#claw-pve"

# Check service status on claw
ssh claw.stfl.dev sudo systemctl status zeroclaw
ssh claw.stfl.dev sudo systemctl status n8n
ssh claw.stfl.dev sudo journalctl -u zeroclaw -f
```

### Adding services to claw-pve
The NixOS config in `hosts/claw-pve/default.nix` should declare everything that can be automated: packages, systemd services, users/groups, tmpfiles rules for `/data` directories, agenix secrets, nginx virtual hosts, and bind mounts. When a service requires manual steps on the host after deployment (interactive onboarding, pairing, initial credentials, etc.), always add those steps to `hosts/claw-pve/README.org` with the exact commands to run on the host.

### Configuration files
- `hosts/claw-pve/default.nix` — main system config (services, users, mounts, systemd units)
- `hosts/claw-pve/README.org` — setup notes and manual post-deployment steps (Proxmox image creation, disk setup, zeroclaw onboarding)

## Claude Code Configuration

The `config/claude/` directory is the git-tracked source for all Claude Code user configuration.
`modules/home/claude-code.nix` symlinks these into `~/.claude/` so Claude Code can read and write
them while changes remain version-controlled.

### Symlinked directories

| Repository path | Symlink target | Contents |
|---|---|---|
| `config/claude/settings.json` | `~/.claude/settings.json` | Claude Code settings (Claude Code writes changes back here) |
| `config/claude/agents/` | `~/.claude/agents/` | Sub-agent definitions, one `.md` file per agent |
| `config/claude/rules/` | `~/.claude/rules/` | Custom rules for Claude Code |
| `config/claude/commands/` | `~/.claude/commands/` | Custom slash commands |
| `config/agents/skills/` | `~/.claude/skills/` | Skill definitions |

### Adding a new sub-agent

Create a `.md` file in `config/claude/agents/`. The file is picked up immediately — no rebuild
needed (the directory is symlinked, not copied).

## Special Considerations

### Hardware Support
- **ZSA Keyboards**: udev rules configured in `modules/hardware/zsa.nix`
- **AMD GPU**: ROCm support for machine learning (Ollama with rocm)
- **Bluetooth**: Managed via `modules/hardware/bluetooth.nix`
- **Ledger**: Hardware wallet support via `modules/hardware/ledger.nix`

### System Services
- **Tailscale**: Enabled on kondor for networking
- **Syncthing**: User-level service for file synchronization
- **Ollama**: AI/LLM service with ROCm support on kondor
- **OpenSSH**: Enabled by default
- **Docker**: System-level installation, user added to docker group

### Display Configuration
- **Sway**: Uses kanshi for dynamic display profile management
  - Get output information: `swaymsg -t get_outputs`
  - Profiles defined in `services.kanshi.settings` in `home.nix`
- **Hyprland**: Uses native monitor configuration
  - Monitor rules defined in `wayland.windowManager.hyprland.settings.monitor`
  - Workspace assignments in `wayland.windowManager.hyprland.settings.workspace`
  - Get output information: `hyprctl monitors`
  - Per-host configuration in `hosts/${hostname}/home.nix` (e.g., kondor: home monitor, beamer, receiver)
