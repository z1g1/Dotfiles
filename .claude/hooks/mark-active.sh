#!/usr/bin/env bash
# UserPromptSubmit hook: records a timestamp proving the user is at the
# keyboard. notify.sh reads this file to cancel pending debounced ntfys.
# Requires: jq

set -euo pipefail

INPUT=$(cat)
SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // "unknown"')
FLAG_DIR="/tmp/claude-notify-${USER:-$(id -un)}"
mkdir -p "$FLAG_DIR"
date +%s > "${FLAG_DIR}/active-${SESSION_ID}"
