# Runbook: ntfy Claude Code Push Notifications

**System:** Ubuntu 24.04 (development VM on Proxmox, HP EliteDesk 800 G3)
**Purpose:** Send push notifications to iPhone when Claude Code needs input or finishes a task
**Transport:** Self-hosted ntfy behind Tailscale — private, no public exposure
**Last updated:** 2026-04-05

---

## Architecture

```
Claude Code (tmux session)
    |
    |  Notification / Stop hook event
    v
~/.claude/hooks/notify.sh
    |
    |  HTTPS POST (Bearer token auth)
    v
ntfy server (port 2586, TLS via Tailscale cert)
    |
    |  Tailscale MagicDNS
    v
ntfy iOS app (Tailscale active on iPhone)
    |
    |  upstream poll relay (ntfy.sh -> APNs)
    v
iPhone push notification
```

---

## File Locations

| File | Purpose |
|------|---------|
| `/etc/ntfy/server.yml` | ntfy server configuration |
| `/etc/ntfy/<hostname>.crt` | Tailscale TLS certificate |
| `/etc/ntfy/<hostname>.key` | Tailscale TLS private key |
| `/var/lib/ntfy/user.db` | ntfy auth database (users, tokens, ACLs) |
| `~/.claude/hooks/notify.sh` | Claude Code hook script |
| `~/.claude/.secrets` | NTFY_TOKEN (never committed to git) |
| `~/.claude/settings.json` | Claude Code config (env block + hooks) |

---

## Server Configuration

**Listen:** `:2586` (HTTPS only -- HTTP disabled)
**Auth default:** `deny-all` -- all access requires explicit grants
**Upstream relay:** `https://ntfy.sh` (required for timely iOS APNs delivery)

### `/etc/ntfy/server.yml` key settings

```yaml
base-url: "https://<tailscale-hostname>:2586"
listen-http: "-"
listen-https: ":2586"
key-file: "/etc/ntfy/<hostname>.key"
cert-file: "/etc/ntfy/<hostname>.crt"
auth-file: "/var/lib/ntfy/user.db"
auth-default-access: "deny-all"
upstream-base-url: "https://ntfy.sh"
```

---

## Users and Access

| Username | Role | Topic | Access | Used by |
|----------|------|-------|--------|---------|
| `claudecode` | publisher | `claude-code` | write-only | Hook script (token auth) |
| `<subscriber>` | subscriber | `claude-code` | read-only | ntfy phone app (password auth) |

Token-based auth is used for the hook script -- tokens can be revoked individually without changing the password.

---

## Claude Code Integration

### Hook events wired

- **`Notification`** -- fires when Claude Code is waiting for input or permission
- **`Stop`** -- fires when Claude Code finishes a response

### Notification format

The hook script includes contextual information in the notification title:

- **Hostname** -- which machine Claude Code is running on
- **tmux session:window** -- which tmux session and window needs attention (if running in tmux)
- **Project name** -- derived from the working directory

Example titles:
- `devbox [main:claude] my-project` (inside tmux)
- `devbox -- my-project` (outside tmux)

### `~/.claude/settings.json` additions

```json
"env": {
  "NTFY_URL": "https://<tailscale-hostname>:2586",
  "NTFY_TOPIC": "claude-code"
},
"hooks": {
  "Notification": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/notify.sh",
          "timeout": 5
        }
      ]
    }
  ],
  "Stop": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/notify.sh",
          "timeout": 5
        }
      ]
    }
  ]
}
```

### `~/.claude/.secrets`

```
NTFY_TOKEN=<token>
```

> **Git:** `.claude/.secrets` must be in `.gitignore`. Never commit this file.

---

## Phone Setup

1. Install ntfy app (App Store / Google Play)
2. Open app, tap +, select "Use another server"
3. Server URL: `https://<tailscale-hostname>:2586`
4. Topic: `claude-code`
5. Username: your subscriber username
6. Password: your subscriber password
7. Tailscale must be active on your phone to reach the server

---

## Operational Procedures

### Check service status

```bash
sudo systemctl status ntfy
sudo journalctl -u ntfy -n 50 --no-pager
```

### Restart service

```bash
sudo systemctl restart ntfy
sudo systemctl status ntfy
```

### Send a test notification manually

```bash
export NTFY_URL="https://<tailscale-hostname>:2586"
export NTFY_TOPIC="claude-code"
echo '{"cwd":"/home/user/test","message":"Test notification"}' | ~/.claude/hooks/notify.sh
```

### Test hook script with debug output

```bash
export NTFY_URL="https://<tailscale-hostname>:2586"
export NTFY_TOPIC="claude-code"
echo '{"cwd":"/home/user/test","message":"Test notification"}' | bash -x ~/.claude/hooks/notify.sh
```

### List ntfy users

```bash
sudo ntfy user list
```

### List access tokens for publisher

```bash
sudo ntfy token list claudecode
```

### Revoke a compromised token

```bash
# List tokens to find the token ID
sudo ntfy token list claudecode

# Revoke by token value
sudo ntfy token remove claudecode <token_value>
```

### Rotate the publisher token

```bash
# 1. Revoke the old token
sudo ntfy token remove claudecode <old_token>

# 2. Generate a new token
sudo ntfy token add claudecode
# Note the new token value -- it will only be shown once

# 3. Update ~/.claude/.secrets
nano ~/.claude/.secrets
# Replace NTFY_TOKEN=<old> with NTFY_TOKEN=<new>

# 4. Test
export NTFY_URL="https://<tailscale-hostname>:2586"
export NTFY_TOPIC="claude-code"
echo '{"cwd":"/tmp","message":"Token rotation test"}' | ~/.claude/hooks/notify.sh
```

### Renew Tailscale TLS certificate

Tailscale certs are valid for 90 days and should be renewed before expiry.

```bash
# Check expiry
openssl x509 -enddate -noout -in /etc/ntfy/<hostname>.crt

# Renew -- tailscale cert overwrites existing files
sudo tailscale cert <tailscale-hostname>

# Move if written to home directory
sudo mv ~/<hostname>.crt /etc/ntfy/
sudo mv ~/<hostname>.key /etc/ntfy/
sudo chown ntfy:ntfy /etc/ntfy/<hostname>.crt /etc/ntfy/<hostname>.key
sudo chmod 640 /etc/ntfy/<hostname>.crt /etc/ntfy/<hostname>.key

# Restart ntfy to load new cert
sudo systemctl restart ntfy
```

### Add a new subscriber user

```bash
sudo ntfy user add <username>
sudo ntfy access <username> claude-code read-only
```

### Remove a user

```bash
sudo ntfy user del <username>
```

---

## Troubleshooting

### Notification not arriving on phone

1. Confirm Tailscale is active on phone
2. Confirm ntfy app is subscribed to the correct topic on the correct server
3. Send a test notification manually (see above) and check for errors
4. Check ntfy service is running: `sudo systemctl status ntfy`
5. Check ntfy logs: `sudo journalctl -u ntfy -n 50 --no-pager`
6. If iOS notifications are delayed (30+ min), verify `upstream-base-url: "https://ntfy.sh"` is set in `server.yml`

### Hook script fails with "NTFY_URL not set"

The env vars are only injected by Claude Code -- not available in a normal shell. Use `export` for manual testing.

### Hook script fails with "NTFY_TOKEN not set"

The secrets file is missing or not being sourced. Check:

```bash
ls -la ~/.claude/.secrets
cat ~/.claude/.secrets
```

### ntfy fails to start -- port conflict

Check what is on port 2586:

```bash
sudo ss -tlnp | grep :2586
```

### ntfy fails to start -- TLS error

Cert files may have wrong ownership:

```bash
ls -la /etc/ntfy/*.crt /etc/ntfy/*.key
sudo chown ntfy:ntfy /etc/ntfy/*.crt /etc/ntfy/*.key
sudo chmod 640 /etc/ntfy/*.crt /etc/ntfy/*.key
sudo systemctl restart ntfy
```

### 401 Unauthorized errors in ntfy logs

Token has been revoked or is incorrect. Rotate the token (see procedure above).

---

## Security Notes

- ntfy is only reachable via Tailscale -- not exposed to the public internet
- `auth-default-access: deny-all` -- anonymous access is blocked
- Publisher uses token auth (not password) -- tokens are scoped and revocable
- Subscriber uses password auth via the ntfy phone app
- Hook script uses `|| true` on curl -- notification failures never block Claude Code
- `~/.claude/.secrets` is `chmod 600` -- readable only by owner
- `~/.claude/.secrets` must be in `.gitignore` -- never committed to git
- Token should be rotated if exposed (e.g. accidentally pasted in chat)
