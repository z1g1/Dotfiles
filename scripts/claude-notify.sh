#!/bin/bash
#
# Claude Code Notification Script
# Triggers visual notifications when Claude Code needs attention
#
# Usage: claude-notify.sh [notification_type]
#   notification_type: permission, idle, elicitation, auth (optional)
#
# Hook receives JSON input from Claude Code via stdin containing:
#   - session_id
#   - notification_type
#   - message
#   - etc.

# Get notification type from argument (if provided)
NOTIFY_TYPE="${1:-general}"

# Read JSON input from stdin (sent by Claude Code hook)
if [ -t 0 ]; then
    # If running manually (not from hook), use default message
    MESSAGE="Claude Code needs your attention"
else
    # Parse JSON input from hook
    INPUT=$(cat)
    MESSAGE=$(echo "$INPUT" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)

    # Fall back to default if message not found
    if [ -z "$MESSAGE" ]; then
        MESSAGE="Claude Code needs your attention"
    fi
fi

# Customize notification based on type
case "$NOTIFY_TYPE" in
    permission)
        TITLE="Claude Code - Permission Required"
        SOUND="Glass"
        ;;
    idle)
        TITLE="Claude Code - Waiting for Input"
        SOUND="Ping"
        ;;
    elicitation)
        TITLE="Claude Code - Input Needed"
        SOUND="Purr"
        ;;
    auth)
        TITLE="Claude Code - Authentication"
        SOUND="Hero"
        ;;
    *)
        TITLE="Claude Code"
        SOUND="Glass"
        ;;
esac

# ===== OPTION 1: Bounce iTerm in Dock =====
# This makes iTerm bounce in the dock to get your attention
osascript -e 'tell application "iTerm" to activate' 2>/dev/null &

# ===== OPTION 2: System Notification =====
# Display a banner/alert notification in macOS Notification Center
osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"$SOUND\"" 2>/dev/null &

# ===== OPTION 3: Continuous Dock Bounce (More Aggressive) =====
# Uncomment to make iTerm bounce continuously until you click it
# osascript -e 'tell application "iTerm"' -e 'activate' -e 'set miniaturized of every window to false' -e 'end tell' 2>/dev/null &

# ===== OPTION 4: Custom Visual Alert =====
# Add your own custom notification method here
# Examples:
#   - Flash the screen
#   - Change terminal background color
#   - Send notification to another service (Slack, Discord, etc.)
#   - Play a custom sound

exit 0
