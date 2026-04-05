#!/usr/bin/env bash
# =============================================================================
# setup-ntfy-claude-notifications.sh
#
# Sets up ntfy as a self-hosted push notification server for Claude Code hooks.
# Sends phone alerts when Claude Code needs input or finishes a task.
#
# Requirements:
#   - Ubuntu 24.04
#   - Tailscale installed and authenticated
#   - Claude Code installed
#   - jq installed (apt install jq)
#
# Usage:
#   chmod +x setup-ntfy-claude-notifications.sh
#   ./setup-ntfy-claude-notifications.sh
#
# What this script does:
#   1. Installs ntfy via official apt repository
#   2. Provisions Tailscale TLS certificate
#   3. Configures ntfy server (HTTPS, auth, deny-all default)
#   4. Creates ntfy users (publisher + subscriber)
#   5. Generates access token for hook script
#   6. Creates hook script (~/.claude/hooks/notify.sh)
#   7. Creates secrets file (~/.claude/.secrets)
#   8. Prints settings.json snippet to add manually
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

# Print a section header
section() {
  echo ""
  echo "============================================================"
  echo "  $1"
  echo "============================================================"
}

# Print an info message
info() {
  echo "  [INFO] $1"
}

# Print an error and exit
die() {
  echo "  [ERROR] $1" >&2
  exit 1
}

# Prompt for a required value (input shown)
prompt_required() {
  local label="$1"
  local var_name="$2"
  local value=""
  while [[ -z "$value" ]]; do
    read -r -p "  >> Enter ${label}: " value
    if [[ -z "$value" ]]; then
      echo "  Value cannot be empty. Please try again."
    fi
  done
  printf -v "$var_name" '%s' "$value"
}

# Prompt for a password (input hidden)
prompt_password() {
  local label="$1"
  local var_name="$2"
  local value=""
  while [[ -z "$value" ]]; do
    read -r -s -p "  >> Enter ${label}: " value
    echo ""
    if [[ -z "$value" ]]; then
      echo "  Value cannot be empty. Please try again."
    fi
  done
  printf -v "$var_name" '%s' "$value"
}

# Confirm a yes/no prompt (defaults to yes)
confirm() {
  local label="$1"
  local answer=""
  read -r -p "  >> ${label} [Y/n]: " answer
  [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]
}

# -----------------------------------------------------------------------------
# Pre-flight checks
# -----------------------------------------------------------------------------

section "Pre-flight checks"

# Must not run as root — we use sudo internally where needed
if [[ "$EUID" -eq 0 ]]; then
  die "Do not run this script as root. Run as your normal user; sudo will be used where needed."
fi

# Check required tools
for cmd in curl jq tailscale sudo; do
  if ! command -v "$cmd" &>/dev/null; then
    die "Required command not found: ${cmd}. Install it before running this script."
  fi
done

info "All pre-flight checks passed."

# -----------------------------------------------------------------------------
# Collect configuration from user
# -----------------------------------------------------------------------------

section "Configuration"

echo ""
echo "  This script will set up ntfy for Claude Code push notifications."
echo "  You will be prompted for usernames, passwords, and topic name."
echo "  Passwords are never stored in this script or shown on screen."
echo ""

# Tailscale hostname — auto-detect from tailscale status
TAILSCALE_HOSTNAME=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')
if [[ -z "$TAILSCALE_HOSTNAME" ]]; then
  die "Could not detect Tailscale hostname. Is Tailscale running and authenticated?"
fi
info "Detected Tailscale hostname: ${TAILSCALE_HOSTNAME}"

# ntfy port
NTFY_PORT="2586"
info "ntfy will listen on port: ${NTFY_PORT}"

# ntfy topic
prompt_required "ntfy topic name (e.g. claude-code)" NTFY_TOPIC

# Publisher username (used by hook script to publish notifications)
PUBLISHER_USER="claudecode"
info "Publisher username: ${PUBLISHER_USER}"

# Publisher password
prompt_password "password for publisher user '${PUBLISHER_USER}'" PUBLISHER_PASS

# Subscriber username (used by ntfy app on your phone to subscribe)
prompt_required "subscriber username for phone app (e.g. your name)" SUBSCRIBER_USER

# Subscriber password
prompt_password "password for subscriber user '${SUBSCRIBER_USER}'" SUBSCRIBER_PASS

# iOS upstream relay (needed for timely iOS push notifications)
USE_UPSTREAM=false
if confirm "Are you using the ntfy iOS app? (Enables upstream relay via ntfy.sh for timely delivery)"; then
  USE_UPSTREAM=true
fi

echo ""
info "Configuration collected. Starting setup..."

# -----------------------------------------------------------------------------
# Step 1: Install ntfy via official apt repository
# -----------------------------------------------------------------------------

section "Step 1: Install ntfy"

# Add signing key from official repository
info "Adding ntfy apt signing key..."
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL -o /etc/apt/keyrings/ntfy.gpg https://archive.ntfy.sh/apt/keyring.gpg

# Add repository
info "Adding ntfy apt repository..."
sudo apt-get install -y apt-transport-https -qq
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/ntfy.gpg] https://archive.ntfy.sh/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/ntfy.list > /dev/null

# Install
info "Installing ntfy..."
sudo apt-get update -qq
sudo apt-get install -y ntfy

info "ntfy installed: $(ntfy --version 2>/dev/null | head -1 || echo 'version unknown')"

# -----------------------------------------------------------------------------
# Step 2: Provision Tailscale TLS certificate
# -----------------------------------------------------------------------------

section "Step 2: Tailscale TLS certificate"

info "Provisioning TLS certificate for ${TAILSCALE_HOSTNAME}..."
sudo tailscale cert "$TAILSCALE_HOSTNAME"

# Cert files are written to current directory — move to /etc/ntfy
CERT_FILE="${TAILSCALE_HOSTNAME}.crt"
KEY_FILE="${TAILSCALE_HOSTNAME}.key"

# Handle case where they were written to ~/ or ./
if [[ -f "${HOME}/${CERT_FILE}" ]]; then
  sudo mv "${HOME}/${CERT_FILE}" /etc/ntfy/
  sudo mv "${HOME}/${KEY_FILE}" /etc/ntfy/
elif [[ -f "./${CERT_FILE}" ]]; then
  sudo mv "./${CERT_FILE}" /etc/ntfy/
  sudo mv "./${KEY_FILE}" /etc/ntfy/
elif [[ ! -f "/etc/ntfy/${CERT_FILE}" ]]; then
  die "Could not locate cert files after tailscale cert. Check manually."
fi

# Lock down permissions — ntfy service user needs read access
sudo chown ntfy:ntfy "/etc/ntfy/${CERT_FILE}" "/etc/ntfy/${KEY_FILE}"
sudo chmod 640 "/etc/ntfy/${CERT_FILE}" "/etc/ntfy/${KEY_FILE}"

info "Certificates installed to /etc/ntfy/"

# -----------------------------------------------------------------------------
# Step 3: Configure ntfy server
# -----------------------------------------------------------------------------

section "Step 3: Configure ntfy server"

# Build upstream block conditionally
UPSTREAM_LINE=""
if [[ "$USE_UPSTREAM" == "true" ]]; then
  UPSTREAM_LINE="upstream-base-url: \"https://ntfy.sh\""
fi

# Write server config — replaces any existing config
sudo tee /etc/ntfy/server.yml > /dev/null << EOF
# ntfy server configuration
# Generated by setup-ntfy-claude-notifications.sh
#
# Documentation: https://ntfy.sh/docs/config/

# Public-facing base URL — used for iOS poll relay and self-references
base-url: "https://${TAILSCALE_HOSTNAME}:${NTFY_PORT}"

# Disable plain HTTP, serve HTTPS only
listen-http: "-"
listen-https: ":${NTFY_PORT}"

# TLS certificate files provisioned via Tailscale
key-file: "/etc/ntfy/${KEY_FILE}"
cert-file: "/etc/ntfy/${CERT_FILE}"

# Auth database — created automatically on first use
auth-file: "/var/lib/ntfy/user.db"

# Deny all anonymous access — all clients must authenticate
auth-default-access: "deny-all"

${UPSTREAM_LINE}
EOF

info "Server config written to /etc/ntfy/server.yml"

# -----------------------------------------------------------------------------
# Step 4: Enable and start ntfy
# -----------------------------------------------------------------------------

section "Step 4: Enable and start ntfy service"

sudo systemctl enable ntfy
sudo systemctl restart ntfy

# Wait briefly for startup
sleep 2

# Verify it started cleanly
if ! sudo systemctl is-active --quiet ntfy; then
  echo ""
  sudo journalctl -u ntfy -n 30 --no-pager
  die "ntfy failed to start. Check journal output above."
fi

info "ntfy is running."
sudo journalctl -u ntfy -n 5 --no-pager | grep -E "INFO|FATAL|ERROR" || true

# -----------------------------------------------------------------------------
# Step 5: Create users and access grants
# -----------------------------------------------------------------------------

section "Step 5: Create ntfy users"

# Publisher user (used by hook script) — write-only to topic
if sudo ntfy user list 2>/dev/null | grep -q "^${PUBLISHER_USER}"; then
  info "Publisher user '${PUBLISHER_USER}' already exists — updating password."
  echo "${PUBLISHER_PASS}" | sudo ntfy user change-pass "${PUBLISHER_USER}" --stdin 2>/dev/null || \
    info "Could not update password — may need to do this manually."
else
  info "Creating publisher user '${PUBLISHER_USER}'..."
  # ntfy user add reads password interactively — pipe it in
  printf '%s\n%s\n' "${PUBLISHER_PASS}" "${PUBLISHER_PASS}" | sudo ntfy user add "${PUBLISHER_USER}" 2>/dev/null || \
    sudo ntfy user add "${PUBLISHER_USER}" <<< $''"${PUBLISHER_PASS}"$'\n'"${PUBLISHER_PASS}" 2>/dev/null || true
fi

# Grant publisher write-only access to the topic
sudo ntfy access "${PUBLISHER_USER}" "${NTFY_TOPIC}" write-only
info "Granted write-only access: ${PUBLISHER_USER} -> ${NTFY_TOPIC}"

# Subscriber user (used by phone app) — read-only from topic
if sudo ntfy user list 2>/dev/null | grep -q "^${SUBSCRIBER_USER}"; then
  info "Subscriber user '${SUBSCRIBER_USER}' already exists — updating password."
  echo "${SUBSCRIBER_PASS}" | sudo ntfy user change-pass "${SUBSCRIBER_USER}" --stdin 2>/dev/null || true
else
  info "Creating subscriber user '${SUBSCRIBER_USER}'..."
  printf '%s\n%s\n' "${SUBSCRIBER_PASS}" "${SUBSCRIBER_PASS}" | sudo ntfy user add "${SUBSCRIBER_USER}" 2>/dev/null || true
fi

# Grant subscriber read-only access to the topic
sudo ntfy access "${SUBSCRIBER_USER}" "${NTFY_TOPIC}" read-only
info "Granted read-only access: ${SUBSCRIBER_USER} -> ${NTFY_TOPIC}"

# -----------------------------------------------------------------------------
# Step 6: Generate access token for hook script
# -----------------------------------------------------------------------------

section "Step 6: Generate publisher access token"

info "Generating access token for '${PUBLISHER_USER}'..."
TOKEN_OUTPUT=$(sudo ntfy token add "${PUBLISHER_USER}" 2>&1)
# Extract token — format is "token tk_xxxx..."
NTFY_TOKEN=$(echo "$TOKEN_OUTPUT" | grep -oP 'tk_[a-z0-9]+' | head -1)

if [[ -z "$NTFY_TOKEN" ]]; then
  die "Failed to extract token from ntfy output. Output was: ${TOKEN_OUTPUT}"
fi

info "Token generated successfully."

# -----------------------------------------------------------------------------
# Step 7: Create hook script
# -----------------------------------------------------------------------------

section "Step 7: Create Claude Code hook script"

mkdir -p "${HOME}/.claude/hooks"

# Copy hook script from repo if available, otherwise create inline
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/notify.sh" ]]; then
  cp "${SCRIPT_DIR}/notify.sh" "${HOME}/.claude/hooks/notify.sh"
  info "Hook script copied from ${SCRIPT_DIR}/notify.sh"
else
  cat > "${HOME}/.claude/hooks/notify.sh" << 'HOOKEOF'
#!/usr/bin/env bash
# Claude Code notification hook
# Reads JSON payload from stdin (Claude Code hook event)
# Sends push notification to self-hosted ntfy via Tailscale
#
# Requires: curl, jq
#
# Non-sensitive config (NTFY_URL, NTFY_TOPIC) injected via ~/.claude/settings.json env block
# Sensitive config (NTFY_TOKEN) sourced from ~/.claude/.secrets (never committed to git)

set -euo pipefail

# Load secrets from local file — exit cleanly if missing (never block Claude Code)
SECRETS_FILE="${HOME}/.claude/.secrets"
if [[ ! -f "${SECRETS_FILE}" ]]; then
  echo "ERROR: secrets file not found at ${SECRETS_FILE}" >&2
  exit 0
fi
# shellcheck source=/dev/null
source "${SECRETS_FILE}"

# Read the full JSON payload from stdin provided by Claude Code
INPUT=$(cat)

# Extract project name from working directory path — fallback gracefully
PROJECT=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' | xargs basename 2>/dev/null || echo "unknown")

# Extract notification message — fallback to generic string
MESSAGE=$(printf '%s' "$INPUT" | jq -r '.message // "Needs your attention"')

# Get hostname
HOST=$(hostname -s 2>/dev/null || echo "unknown")

# Get tmux session and window if running inside tmux
TMUX_INFO=""
if [[ -n "${TMUX:-}" ]]; then
  TMUX_INFO=$(tmux display-message -p '#S:#W' 2>/dev/null || echo "")
fi

# Build notification title: host [session:window] project
if [[ -n "$TMUX_INFO" ]]; then
  TITLE="${HOST} [${TMUX_INFO}] ${PROJECT}"
else
  TITLE="${HOST} — ${PROJECT}"
fi

# Validate required environment variables
# NTFY_URL and NTFY_TOPIC come from settings.json env block
# NTFY_TOKEN comes from ~/.claude/.secrets
NTFY_BASE="${NTFY_URL:?NTFY_URL not set — check env block in ~/.claude/settings.json}"
NTFY_TOPIC_VAL="${NTFY_TOPIC:-claude-code}"
NTFY_TOKEN="${NTFY_TOKEN:?NTFY_TOKEN not set — check ~/.claude/.secrets}"

# Send notification
# || true ensures hook never returns non-zero and never blocks Claude Code
curl -s \
  -H "Authorization: Bearer ${NTFY_TOKEN}" \
  -H "Title: ${TITLE}" \
  -H "Priority: high" \
  -H "Tags: robot,warning" \
  -d "${MESSAGE}" \
  "${NTFY_BASE}/${NTFY_TOPIC_VAL}" > /dev/null 2>&1 || true
HOOKEOF
  info "Hook script created inline (repo copy not found)"
fi

# Hook script must be readable only by owner
chmod 700 "${HOME}/.claude/hooks/notify.sh"

info "Hook script written to ~/.claude/hooks/notify.sh"

# -----------------------------------------------------------------------------
# Step 8: Write secrets file
# -----------------------------------------------------------------------------

section "Step 8: Write secrets file"

SECRETS_PATH="${HOME}/.claude/.secrets"

cat > "${SECRETS_PATH}" << EOF
# Claude Code ntfy notification secrets
# DO NOT commit this file to git
# Add .claude/.secrets to your .gitignore
NTFY_TOKEN=${NTFY_TOKEN}
EOF

# Readable only by owner — contains the access token
chmod 600 "${SECRETS_PATH}"

info "Secrets written to ${SECRETS_PATH} (chmod 600)"

# -----------------------------------------------------------------------------
# Step 9: .gitignore reminder
# -----------------------------------------------------------------------------

section "Step 9: Check .gitignore"

GITIGNORE="${HOME}/.gitignore"
if [[ -f "$GITIGNORE" ]] && grep -q '\.claude/\.secrets' "$GITIGNORE"; then
  info ".claude/.secrets already in ${GITIGNORE}"
else
  info "Adding .claude/.secrets to ${GITIGNORE}"
  echo '.claude/.secrets' >> "$GITIGNORE"
fi

# -----------------------------------------------------------------------------
# Done — print settings.json snippet and phone setup instructions
# -----------------------------------------------------------------------------

section "Setup complete"

echo ""
echo "  ntfy installed and running on port ${NTFY_PORT} (HTTPS)"
echo "  TLS certificate provisioned via Tailscale"
echo "  Users created: ${PUBLISHER_USER} (write), ${SUBSCRIBER_USER} (read)"
echo "  Hook script: ~/.claude/hooks/notify.sh"
echo "  Secrets file: ~/.claude/.secrets (chmod 600)"
echo ""
echo "------------------------------------------------------------"
echo "  ACTION REQUIRED: Add to ~/.claude/settings.json"
echo "------------------------------------------------------------"
echo ""
echo '  Add these keys inside the root {} of your settings.json.'
echo '  Place after your existing last key, separated by a comma:'
echo ""
cat << JSONEOF
  "env": {
    "NTFY_URL": "https://${TAILSCALE_HOSTNAME}:${NTFY_PORT}",
    "NTFY_TOPIC": "${NTFY_TOPIC}"
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
JSONEOF

echo ""
echo "------------------------------------------------------------"
echo "  ACTION REQUIRED: Set up ntfy app on your phone"
echo "------------------------------------------------------------"
echo ""
echo "  1. Install ntfy from App Store or Google Play"
echo "  2. Open app > tap + > Use another server"
echo "  3. Server URL:  https://${TAILSCALE_HOSTNAME}:${NTFY_PORT}"
echo "  4. Topic:       ${NTFY_TOPIC}"
echo "  5. Username:    ${SUBSCRIBER_USER}"
echo "  6. Password:    (the password you entered for ${SUBSCRIBER_USER})"
echo "  7. Make sure Tailscale is active on your phone"
echo ""
echo "------------------------------------------------------------"
echo "  TEST: Run this to send a test notification"
echo "------------------------------------------------------------"
echo ""
echo "  export NTFY_URL=\"https://${TAILSCALE_HOSTNAME}:${NTFY_PORT}\""
echo "  export NTFY_TOPIC=\"${NTFY_TOPIC}\""
echo "  echo '{\"cwd\":\"/home/${USER}/test\",\"message\":\"Test notification\"}' | ~/.claude/hooks/notify.sh"
echo ""
