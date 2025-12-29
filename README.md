# Dotfiles

Basic Repository for Linux CLI customization files


## Map Aliases to Dotfiles

``ln -s ~/projects/Dotfiles/.zshrc ~/.zshrc``
``ln -s ~/projects/Dotfiles/.tmux.conf ~/.tmux.conf``
``ln -f -s ~/projects/Dotfiles/.vimrc ~/.vimrc``
``ln -f -s ~/projects/Dotfiles/CLAUDE.md ~/.claude/CLAUDE.md``


## Claude Code Notifications

Get visual alerts when Claude Code needs your attention.

### Option 1: iTerm2 Built-in Notifications (Recommended)

Enable system notifications in iTerm2 to get banner alerts when Claude Code is waiting for input:

1. Open **iTerm2 Preferences** (⌘,)
2. Navigate to **Profiles → Terminal**
3. Enable **"Silence bell"**
4. Enable **"Filter Alerts → Send escape sequence-generated alerts"**
5. (Optional) Configure notification delay to your preference

This will trigger macOS system notifications (banner or alert style) when Claude Code needs your attention.

**Note:** This feature is specific to iTerm2 and not available in the default macOS Terminal.

### Option 2: Custom Notification Hooks (Advanced)

For more control (like bouncing the dock icon), you can use custom notification hooks.

**To enable custom notifications:**

1. Add notification hooks to `.claude/settings.json` (see commented examples in that file)
2. Create a notification script (example provided in `scripts/claude-notify.sh`)
3. Configure hooks to trigger on specific events:
   - `permission_prompt` - When Claude needs tool permissions
   - `idle_prompt` - After 60+ seconds waiting for input
   - `elicitation_dialog` - When Claude needs MCP tool input

See the advanced configuration section in `.claude/settings.json` for implementation details.
