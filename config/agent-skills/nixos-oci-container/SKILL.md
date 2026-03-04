---
name: nixos-oci-container
description: >
  Patterns and pitfalls for configuring NixOS OCI containers via
  `virtualisation.oci-containers`. Use this skill whenever the user wants to run a
  container on NixOS — whether starting fresh, adding secrets, wiring up config files,
  debugging why env vars aren't reaching the container, or understanding how systemd
  integrates with podman/docker. Especially useful for agenix secret delivery,
  environment file patterns, and `preStart` scripting. Trigger even if the user just
  mentions "podman on NixOS", "oci container secret", or "container not picking up env".
---

# NixOS OCI Container Patterns

The `virtualisation.oci-containers` NixOS module manages containers as systemd services
(backed by podman or docker). This skill documents the right patterns and common
pitfalls, drawn from real production usage.

---

## Module structure

```nix
virtualisation.oci-containers.containers.<name> = {
  image = "ghcr.io/org/app:v1.2.3";
  environment = { HOST = "0.0.0.0"; };           # plain, non-secret env vars only
  environmentFiles = [ "/run/<name>-cfg/app.env" ];  # KEY=VALUE files (for secrets)
  volumes = [ "/run/<name>-cfg:/app/config" ];   # host:container path mappings
  ports = [ "127.0.0.1:8080:8080" ];             # always bind to 127.0.0.1 for local services
  cmd = [ "--flag" "value" ];                    # override container CMD if needed
  extraOptions = [ "--network=host" ];           # raw podman/docker flags (use sparingly)
};
```

The module generates a systemd service named `${backend}-<name>`, e.g.
`podman-copilot-api` when `virtualisation.oci-containers.backend = "podman"`.

---

## Delivering secrets to the container

### The right pattern: `RuntimeDirectory` + `LoadCredential` + `preStart` + `environmentFiles`

Secrets must never touch the Nix store or appear in `environment`. The correct flow:

1. **`RuntimeDirectory`** creates `/run/<name>` before the service starts and removes
   it when the service stops. Sets `$RUNTIME_DIRECTORY` for use in `preStart`.
   Use `RuntimeDirectoryMode = "0700"` to keep it private.
2. **`LoadCredential`** delivers the secret file into `$CREDENTIALS_DIRECTORY` at
   runtime (systemd-managed; never world-readable).
3. **`preStart`** reads the credential and writes a `KEY=VALUE` file into
   `$RUNTIME_DIRECTORY`.
4. **`environmentFiles`** tells the container runtime to inject the `KEY=VALUE` file
   as environment variables before starting the container.

```nix
systemd.services."${config.virtualisation.oci-containers.backend}-copilot-api" = {
  serviceConfig = {
    RuntimeDirectory = "copilot-api-cfg";       # creates /run/copilot-api-cfg
    RuntimeDirectoryMode = "0700";              # private to root
    LoadCredential = "github-token:${config.age.secrets.github-copilot-token.path}";
  };
  preStart = ''
    printf 'GH_TOKEN=%s\n' "$(cat "$CREDENTIALS_DIRECTORY/github-token")" \
      > "$RUNTIME_DIRECTORY/token.env"
    chmod 600 "$RUNTIME_DIRECTORY/token.env"
  '';
};

virtualisation.oci-containers.containers.copilot-api = {
  image = "ghcr.io/caozhiyuan/copilot-api:v1.1.8";
  environment = {
    HOST = "0.0.0.0";
    COPILOT_API_HOME = "/copilot-config";
  };
  environmentFiles = [ "/run/copilot-api-cfg/token.env" ];  # hardcoded: matches RuntimeDirectory
  volumes = [ "/run/copilot-api-cfg:/copilot-config" ];
  ports = [ "127.0.0.1:4141:4141" ];
};
```

`RuntimeDirectory` is preferred over `systemd.tmpfiles.rules` for this use case:
the directory is created fresh on each start, removed on stop, and requires no
separate declaration. The `volumes` and `environmentFiles` paths are hardcoded
(`/run/<RuntimeDirectory>`) because Nix evaluates them at build time, but since
`RuntimeDirectory = "copilot-api-cfg"` always maps to `/run/copilot-api-cfg`, this
is unambiguous.

### The key insight about service name

The generated systemd unit is `${backend}-<container-name>`. Always reference it
dynamically so the config stays backend-agnostic:

```nix
systemd.services."${config.virtualisation.oci-containers.backend}-copilot-api"
```

---

## Runtime config files

When the app needs a config file (not just env vars), write it to the tmpfs dir in
`preStart`:

```nix
let
  # Build the file in the Nix store — contents are non-secret
  configTemplate = pkgs.writeText "app-config.json" (builtins.toJSON {
    port = 8080;
    logLevel = "info";
  });
in
systemd.services."${config.virtualisation.oci-containers.backend}-myapp" = {
  serviceConfig = {
    RuntimeDirectory = "myapp-cfg";
    RuntimeDirectoryMode = "0700";
  };
  preStart = ''
    install -m 0600 ${configTemplate} "$RUNTIME_DIRECTORY/config.json"
  '';
};
```

`install -m 0600` is better than `cp` because it sets permissions atomically.
The template is in the Nix store (fine — it has no secrets); the final file on tmpfs
can be world-unreadable.

---

## What NOT to do

### ❌ Secrets in `environment`

```nix
environment = { API_KEY = "s3cr3t"; };  # WRONG: ends up in /nix/store, world-readable
```

### ❌ Secrets in `serviceConfig.Environment`

```nix
systemd.services."podman-myapp".serviceConfig.Environment = [ "API_KEY=s3cr3t" ];
# WRONG: visible in `systemctl show`, and critically — does NOT propagate into the
# container process. The container runtime (podman) spawns its own process tree and
# doesn't inherit the systemd unit's Environment.
```

### ❌ `--secret` in `extraOptions`

```nix
extraOptions = [ "--secret" "mysecret" ];  # WRONG: requires out-of-band `podman secret create`
# Not declarative — NixOS can't manage the podman secret store.
# Breaks on fresh deploys and system wipes.
```

---

## Verification checklist

After deploying, verify in this order:

```bash
# 1. Is the systemd service running?
systemctl status podman-copilot-api

# 2. Is the container actually up?
podman ps

# 3. Did the env file get written to tmpfs?
ls -la /run/copilot-api-cfg/

# 4. Check container logs for startup errors
podman logs copilot-api
# or via journald:
journalctl -u podman-copilot-api -f
```

---

## Complete minimal example

A single-file NixOS module that runs a containerized service with an agenix secret:

```nix
{ config, ... }:
{
  # Declare the agenix secret (managed separately in secrets/)
  age.secrets.my-api-key.file = ../../secrets/my-api-key.age;

  # Extend the generated systemd service to add secret delivery and preStart
  systemd.services."${config.virtualisation.oci-containers.backend}-myapp" = {
    serviceConfig = {
      RuntimeDirectory = "myapp-cfg";         # creates /run/myapp-cfg, removed on stop
      RuntimeDirectoryMode = "0700";
      LoadCredential = "api-key:${config.age.secrets.my-api-key.path}";
    };
    preStart = ''
      printf 'API_KEY=%s\n' "$(cat "$CREDENTIALS_DIRECTORY/api-key")" \
        > "$RUNTIME_DIRECTORY/secrets.env"
      chmod 600 "$RUNTIME_DIRECTORY/secrets.env"
    '';
  };

  virtualisation.oci-containers.containers.myapp = {
    image = "ghcr.io/org/myapp:latest";
    environment = {
      PORT = "8080";
    };
    environmentFiles = [ "/run/myapp-cfg/secrets.env" ];
    volumes = [ "/run/myapp-cfg:/app/config:ro" ];
    ports = [ "127.0.0.1:8080:8080" ];
  };
}
```
