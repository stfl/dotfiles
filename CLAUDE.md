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
nix fmt                        # Uses nixfmt-tree (defined in flake.nix)
```

### Build custom ISO
```bash
nix build .#iso
sudo dd if=results/iso/*.iso of=/dev/sda bs=4M status=progress && sync
```

### Remote deployment
```bash
nixos-rebuild \
    --target-host user@hostname \
    --use-remote-sudo \
    switch \
    --flake ".#hostname"
```

## Architecture

### Flake Structure
- **flake.nix**: Main entry point defining inputs and outputs
- **hosts/**: Per-machine configurations
  - Each host has: `default.nix`, `hardware-configuration.nix`, `home.nix`
  - Current hosts: `kondor` (desktop), `pirol`, `iso` (installation media)
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
- **Sway**: Via `modules/sway.nix` and sway config in home-manager
- **Hyprland**: Via `modules/hyprland.nix` with UWSM (Universal Wayland Session Manager)
- Both use kanshi for dynamic display configuration
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

### Add a new host to secrets
1. Get the host SSH public key from `/etc/ssh/ssh_host_ed25519_key.pub`
2. Add the key to `secrets/secrets.nix`
3. Rekey all secrets with a private key that has access:
```bash
agenix --rekey -i ~/.ssh/id_ed25519_stfl
```

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
- Kanshi manages dynamic display profiles in home-manager
- Get output information: `swaymsg -t get_outputs`
- Profiles defined per-host in `home.nix` (e.g., home monitor, beamer, receiver)