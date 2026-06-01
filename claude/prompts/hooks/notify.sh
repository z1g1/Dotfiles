#!/usr/bin/env bash
# Claude Code notification hook
# Reads JSON payload from stdin (Claude Code hook event)
# Sends push notification to self-hosted ntfy via Tailscale
# Requires: curl, jq
#
# Non-sensitive config (NTFY_URL, NTFY_TOPIC) injected via ~/.claude/settings.json env block
# Sensitive config (NTFY_TOKEN) sourced from ~/.claude/.secrets (never committed to git)

set -euo pipefail

# Load secrets from local file — abort if missing
SECRETS_FILE="${HOME}/.claude/.secrets"
if [[ ! -f "${SECRETS_FILE}" ]]; then
  echo "ERROR: secrets file not found at ${SECRETS_FILE}" >&2
  exit 0  # exit 0 so hook failure never blocks Claude Code
fi
# shellcheck source=/dev/null
source "${SECRETS_FILE}"

# Read the full JSON payload from stdin
INPUT=$(cat)

# Extract project name from working directory, fallback gracefully
PROJECT=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' | xargs basename 2>/dev/null || echo "unknown")

# Extract message, fallback to generic string
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

# Validate required env vars — NTFY_URL/NTFY_TOPIC from settings.json, NTFY_TOKEN from .secrets
NTFY_BASE="${NTFY_URL:?NTFY_URL not set}"
NTFY_TOPIC="${NTFY_TOPIC:-claude-code}"
NTFY_TOKEN="${NTFY_TOKEN:?NTFY_TOKEN not set — check ~/.claude/.secrets}"

# Send notification — fail silently so hook never blocks Claude Code
curl -s \
  -H "Authorization: Bearer ${NTFY_TOKEN}" \
  -H "Title: ${TITLE}" \
  -H "Priority: high" \
  -H "Tags: robot,warning" \
  -d "${MESSAGE}" \
  "${NTFY_BASE}/${NTFY_TOPIC}" > /dev/null 2>&1 || true
