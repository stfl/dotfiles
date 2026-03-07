---
name: pfsense
description: >
  Manage pfSense firewall via the pfREST API v2 and SSH. Use this skill whenever the
  user wants to interact with their pfSense router — firewall rules, port forwarding,
  NAT, DHCP reservations, DNS resolver overrides, aliases, VPN, gateways, interfaces,
  backup/restore, or any network configuration on the router. Trigger on mentions of
  "pfSense", "firewall rules", "open a port", "block traffic", "port forward",
  "add DHCP reservation", "DNS override", "network config on router", "NAT rule",
  "pfSense maintenance", "firewall backup", or similar.
---

# pfSense Management via REST API & SSH

pfSense at `pfsense.stfl.dev` (192.168.1.1) with **pfREST API v2** installed.
Two management channels: REST API (primary) and SSH (fallback / advanced).

---

## 1. Authentication

### REST API

```bash
# Get API key from pass — NEVER display it to the user
API_KEY=$(pass show stfl.home/pfsense-rest-api)

# Base curl pattern for all API calls (self-signed cert → -k required)
curl -s -k \
  -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/ENDPOINT" | jq .
```

- Always use `-s` (silent) and `-k` (skip TLS verification — self-signed cert).
- Always pipe through `jq` for readable output.
- **Never** echo, print, or log `$API_KEY`.
- **Never** use `curl -v` with auth headers — it dumps credentials to stderr.

### SSH

```bash
ssh admin@pfsense.stfl.dev
```

SSH is available for operations not covered by the REST API, diagnostics, and emergency recovery.

---

## 2. HATEOAS Navigation

API responses include `_links` with related endpoints. **Use these to discover actions** rather than guessing paths.

```bash
# Example: discover available endpoints from root
curl -s -k -H "X-API-Key: $API_KEY" "https://pfsense.stfl.dev/api/v2/" | jq '._links'
```

Key patterns:
- After creating/modifying a resource, check `_links` for the **apply endpoint**.
- Many resources have a corresponding apply endpoint that must be called to activate changes.
- Use `_links` to find related resources (e.g., from a firewall rule to its interface).

---

## 3. Safety Workflow

### Read-only operations (GET requests)

**No user confirmation needed.** Run any GET/read API call freely to inspect state — firewall rules, aliases, DHCP leases, interfaces, gateways, DNS overrides, etc. Just execute the curl command and present the results.

### Mutations (POST/PUT/PATCH/DELETE) — MANDATORY workflow

**Read → Validate → Confirm → Apply → Verify**

Every mutation MUST follow this workflow:

#### Step 1: Read current state
```bash
curl -s -k -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/firewall/rules" | jq .
```

#### Step 2: Validate & show the user
- Present the current state clearly.
- Show exactly what will change (before → after).
- Check if the change could impact connectivity (see §4).

#### Step 3: Get explicit user confirmation
- Use `AskUserQuestion` to confirm before any write operation.
- For dangerous changes (deny rules, interface modifications, gateway changes), add an extra warning.

#### Step 4: Apply
- POST/PUT/PATCH/DELETE the change.
- If the resource uses staged changes, call the **apply endpoint** from `_links`.

```bash
# Example: apply firewall changes after staging
curl -s -k -X POST \
  -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/firewall/apply" | jq .
```

#### Step 5: Verify
- Re-read the resource to confirm the change took effect.
- Verify the API is still reachable (a simple GET to any endpoint).
- If the API is unreachable after a change, alert the user immediately.

---

## 4. Connectivity Protection (NON-NEGOTIABLE)

**Never** remove, disable, or reorder rules that allow:

| Service | Port(s) | Why |
|---------|---------|-----|
| HTTPS to pfSense (LAN) | 443 (self-signed cert) | Web UI and REST API access |
| SSH to pfSense (LAN) | 22 | Emergency management |
| DNS on LAN | 53 (TCP/UDP) | Name resolution |
| DHCP on LAN | 67-68 (UDP) | IP assignment |
| REST API | (same as web UI port) | This tool's own access |

### Rule ordering: first match wins

- A deny rule placed **above** a permit rule for management access = **lockout**.
- Always check rule position when adding deny rules.
- If adding a deny/reject rule, verify no management-access permits come after it.
- When in doubt, add deny rules at the **bottom** or on **non-LAN** interfaces only.

### Before modifying any rule, check:
1. Does it match management traffic (LAN → pfSense on 22/443)?
2. Does it match DNS/DHCP traffic on LAN?
3. Will reordering affect management access?

If any answer is "yes" → warn the user with specific risk details and require explicit confirmation.

---

## 5. Common Operations

### 5.1 Firewall Rules

```bash
# List all rules
curl -s -k -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/firewall/rules" | jq .

# List rules — filter client-side (interface is an array in the response)
curl -s -k -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/firewall/rules" | jq '[.data[] | select(.interface[] == "lan")]'

# Create a rule (example: allow TCP 8080 from LAN)
curl -s -k -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "pass",
    "interface": ["lan"],
    "ipprotocol": "inet",
    "protocol": "tcp",
    "source": "lan",
    "destination": "any",
    "destination_port": "8080",
    "descr": "Allow LAN to TCP 8080"
  }' \
  "https://pfsense.stfl.dev/api/v2/firewall/rules" | jq .

# Delete a rule (by ID — read first to get current ID!)
curl -s -k -X DELETE \
  -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/firewall/rules?id=5" | jq .

# Apply firewall changes (REQUIRED after create/update/delete)
curl -s -k -X POST \
  -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/firewall/apply" | jq .
```

### 5.2 Aliases (prefer over raw IPs)

```bash
# List aliases
curl -s -k -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/firewall/aliases" | jq .

# Create an alias
curl -s -k -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "trusted_hosts",
    "type": "host",
    "address": ["10.0.0.5", "10.0.0.6"],
    "descr": ["Server A", "Server B"],
    "detail": "Trusted internal hosts"
  }' \
  "https://pfsense.stfl.dev/api/v2/firewall/aliases" | jq .
```

Use aliases in firewall rules instead of hardcoded IPs — easier to maintain and audit.

### 5.3 Port Forwarding / NAT

```bash
# List port forwards
curl -s -k -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/firewall/nat/port_forwards" | jq .

# Create a port forward (example: WAN:8443 → 192.168.1.50:443)
curl -s -k -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "interface": "wan",
    "protocol": "tcp",
    "destination": "wanip",
    "destination_port": "8443",
    "target": "192.168.1.50",
    "local_port": "443",
    "descr": "HTTPS to internal server"
  }' \
  "https://pfsense.stfl.dev/api/v2/firewall/nat/port_forwards" | jq .

# Apply NAT changes
curl -s -k -X POST \
  -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/firewall/nat/apply" | jq .
```

### 5.4 DHCP Static Mappings

```bash
# List DHCP static mappings
curl -s -k -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/services/dhcp_server/static_mappings" | jq .

# Create a static mapping
curl -s -k -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "interface": "lan",
    "mac": "aa:bb:cc:dd:ee:ff",
    "ipaddr": "192.168.1.100",
    "hostname": "mydevice",
    "descr": "My Device"
  }' \
  "https://pfsense.stfl.dev/api/v2/services/dhcp_server/static_mappings" | jq .
```

### 5.5 DNS Resolver Host Overrides

```bash
# List host overrides
curl -s -k -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/services/dns_resolver/host_overrides" | jq .

# Create a host override
curl -s -k -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "host": "myapp",
    "domain": "stfl.dev",
    "ip": ["192.168.1.50"],
    "descr": "Internal app server"
  }' \
  "https://pfsense.stfl.dev/api/v2/services/dns_resolver/host_overrides" | jq .

# Apply DNS resolver changes
curl -s -k -X POST \
  -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/services/dns_resolver/apply" | jq .
```

### 5.6 Interfaces and Gateways

```bash
# List interfaces (read-only by default)
curl -s -k -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/interface" | jq .

# List gateways
curl -s -k -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/routing/gateways" | jq .

# Gateway status
curl -s -k -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/status/gateways" | jq .
```

**Warning**: Interface and gateway modifications can cause total network outage. Always warn the user and require double confirmation.

### 5.7 Filtering, Sorting, and Pagination

```bash
# Filter rules by description containing "SSH"
curl -s -k -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/firewall/rules?query=SSH&query_target=descr" | jq .

# Limit results
curl -s -k -H "X-API-Key: $API_KEY" \
  "https://pfsense.stfl.dev/api/v2/firewall/rules?limit=10&offset=0" | jq .
```

---

## 6. Object ID Warning

**IDs are non-persistent array indices.** They can change when items are added, removed, or reordered.

### Rules:
- **Always re-read** the resource list immediately before referencing an ID.
- **Never cache** IDs across operations.
- When deleting multiple items, **delete from highest ID to lowest** to avoid index shifting.
- After any mutation, re-read to get updated IDs.

```bash
# WRONG: Delete items 2, 3, 4 in order (3 becomes 2 after first delete!)
# RIGHT: Delete items 4, 3, 2 (highest first)
```

---

## 7. SSH Management

SSH (`ssh admin@pfsense.stfl.dev`) is a first-class management channel for operations not available or not practical via REST API.

### Diagnostics

```bash
# View active firewall rules
ssh admin@pfsense.stfl.dev "pfctl -sr"

# View active connections / state table
ssh admin@pfsense.stfl.dev "pfctl -ss"

# View firewall statistics
ssh admin@pfsense.stfl.dev "pfctl -si"

# Network connections
ssh admin@pfsense.stfl.dev "netstat -an"

# ARP table (see MAC ↔ IP mappings)
ssh admin@pfsense.stfl.dev "arp -a"

# Interface status
ssh admin@pfsense.stfl.dev "ifconfig"

# Routing table
ssh admin@pfsense.stfl.dev "netstat -rn"
```

### Backup & Restore

```bash
# List available backups
ssh admin@pfsense.stfl.dev "ls -la /cf/conf/backup/"

# Download current config
scp admin@pfsense.stfl.dev:/cf/conf/config.xml ./pfsense-backup-$(date +%Y%m%d).xml

# Upload and restore a config (DANGEROUS — requires confirmation)
scp ./pfsense-backup.xml admin@pfsense.stfl.dev:/cf/conf/config.xml
ssh admin@pfsense.stfl.dev "/etc/rc.reload_all"
```

### Package Management

```bash
# List installed packages
ssh admin@pfsense.stfl.dev "pkg info"

# Check for available updates
ssh admin@pfsense.stfl.dev "pkg update && pkg upgrade -n"
```

### System Maintenance

```bash
# Reboot (requires user confirmation!)
ssh admin@pfsense.stfl.dev "shutdown -r now"

# Check firmware version
ssh admin@pfsense.stfl.dev "cat /etc/version"

# Filesystem usage
ssh admin@pfsense.stfl.dev "df -h"
```

### Emergency Recovery

If the API or web UI becomes unreachable:

```bash
# Disable packet filter entirely (allows all traffic — EMERGENCY ONLY)
ssh admin@pfsense.stfl.dev "pfctl -d"

# Restart the web UI
ssh admin@pfsense.stfl.dev "/etc/rc.restart_webgui"

# Reload all filter rules from config
ssh admin@pfsense.stfl.dev "/etc/rc.filter_configure"

# Re-enable packet filter after recovery
ssh admin@pfsense.stfl.dev "pfctl -e"
```

**Same safety workflow applies to SSH**: read state, show user, confirm before destructive actions.

---

## 8. Anti-Patterns (NEVER do these)

| Anti-pattern | Why it's dangerous |
|---|---|
| Display or echo `$API_KEY` | Credential leak |
| Use `curl -v` with auth headers | Dumps credentials to stderr |
| Delete without reading current state first | IDs may have shifted |
| Add a broad deny rule at the top of LAN | Locks out management access |
| Modify interfaces without double confirmation | Total network outage |
| Bulk-delete via loop without reading between deletes | Index shifting causes wrong deletions |
| Cache object IDs across multiple operations | IDs are array indices, not stable |
| Apply changes without verifying API reachability after | May not notice a lockout |
| Skip the apply endpoint after mutations | Changes won't take effect |
| Use `pfctl -d` without a plan to re-enable | Firewall is completely open |
