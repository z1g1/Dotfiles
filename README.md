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

## tmux Project Workspace Setup Guide

macOS · Homebrew · iTerm2 · zsh

---

### 1. Installation

```bash
# Install tmux and tmuxp
brew install tmux
pip3 install tmuxp --break-system-packages

# Verify
tmux -V       # should return 3.x
tmuxp --version
```

### 2. Shell & tmux Configuration

#### `~/.tmux.conf`

Add the following to your `~/.tmux.conf` (create if it doesn't exist):

```bash
# ---------------------------------------------------------
# Project-aware tmux config
# ---------------------------------------------------------

# Enable true color support (required for subtle pane tinting)
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# When a window's shell exits and you haven't manually named it,
# let tmux auto-rename it again
set -g allow-rename on

# Prevent tmuxp shell_command_before from overriding window names
set -g automatic-rename off
```

#### `~/.zshrc`

Add the following block to the end of your `~/.zshrc`:

```bash
# ---------------------------------------------------------
# tmux project hooks
# Reads .tmux-project from the git root (or cwd) on every
# prompt and applies pane background tint + window name.
# ---------------------------------------------------------
_tmux_project_hook() {
  # Only run inside tmux
  [[ -z "$TMUX" ]] && return

  # Find project root — prefer git root, fall back to cwd
  local project_root
  project_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")

  local config_file="${project_root}/.tmux-project"

  if [[ -f "$config_file" ]]; then
    # Parse only known keys — never blindly source for security
    local pane_color window_name
    pane_color=$(grep -E '^TMUX_PANE_COLOR=' "$config_file" | cut -d'"' -f2)
    window_name=$(grep -E '^TMUX_WINDOW_NAME=' "$config_file" | cut -d'"' -f2)

    # Validate hex color format before passing to tmux
    if [[ "$pane_color" =~ ^#[0-9a-fA-F]{6}$ ]]; then
      tmux select-pane -P "bg=${pane_color}" 2>/dev/null
    fi

    if [[ -n "$window_name" ]]; then
      tmux rename-window "$window_name" 2>/dev/null
    fi
  else
    # Outside a configured project — reset to defaults
    tmux select-pane -P "bg=default" 2>/dev/null
    tmux automatic-rename on 2>/dev/null
  fi
}

# Register the hook so it runs on every prompt
precmd_functions+=(_tmux_project_hook)

# ---------------------------------------------------------
# tmuxp helper: load project into current session
# Deduplicates — won't create a second window if one exists.
# ---------------------------------------------------------
tp() {
  local config=".tmuxp.yaml"

  if [[ ! -f "$config" ]]; then
    echo "No .tmuxp.yaml in $(pwd)"
    return 1
  fi

  # Extract the window_name from the config
  local win_name
  win_name=$(grep 'window_name:' "$config" | head -1 | awk '{print $2}')

  # If a window with that name already exists, just switch to it
  if tmux list-windows -F '#{window_name}' | grep -qx "$win_name"; then
    echo "Window '$win_name' already exists — switching to it"
    tmux select-window -t "$win_name"
  else
    tmuxp load -a -y .
  fi
}
```

After editing, reload your shell:

```bash
source ~/.zshrc
```

---

### 3. Creating Config Files for a Project

Each project gets **two small files** at its root:

#### `.tmuxp.yaml` — layout definition

```yaml
# ~/projects/your-project/.tmuxp.yaml
session_name: dev                  # ignored when using -a (append mode)
start_directory: ./
windows:
  - window_name: your-project      # shows in the tmux status bar
    layout: even-horizontal         # side-by-side vertical split
    panes:
      - []                          # left pane — empty shell
      - []                          # right pane — empty shell
```

#### `.tmux-project` — pane tinting and metadata

```bash
# ~/projects/your-project/.tmux-project
TMUX_PANE_COLOR="#1a1410"
TMUX_WINDOW_NAME="your-project"
```

#### Color reference for picking tints

Keep these **very dark** so they don't fight syntax highlighting. These are starting points — adjust to taste in iTerm2:

| Tint      | Hex       | Feels like     |
|-----------|-----------|----------------|
| Warm brown | `#1a1410` | backend / API  |
| Purple    | `#1a1020` | frontend       |
| Green     | `#101a14` | infra / devops |
| Blue      | `#10141a` | docs / config  |
| Teal      | `#101a1a` | data / scripts |
| Rose      | `#1a1014` | design / UI    |

#### Quick-create script

If you want to scaffold both files fast, add this to your `.zshrc`:

```bash
# Create .tmuxp.yaml and .tmux-project in the current directory
tmux-init() {
  local name="${1:-$(basename "$PWD")}"
  local color="${2:-#10141a}"

  if [[ -f .tmuxp.yaml ]]; then
    echo ".tmuxp.yaml already exists"
    return 1
  fi

  cat > .tmuxp.yaml << EOF
session_name: dev
start_directory: ./
windows:
  - window_name: ${name}
    layout: even-horizontal
    panes:
      - []
      - []
EOF

  cat > .tmux-project << EOF
TMUX_PANE_COLOR="${color}"
TMUX_WINDOW_NAME="${name}"
EOF

  echo "Created .tmuxp.yaml and .tmux-project for '${name}' with color ${color}"
}
```

Usage:

```bash
cd ~/projects/my-new-project
tmux-init                              # uses directory name, default blue
tmux-init my-api "#1a1410"             # custom name and color
```

---

### 4. Daily Usage

#### Starting a tmux session

```bash
tmux new -s dev
```

#### Adding a project to the current session

```bash
# Navigate to any project with config files and run:
cd ~/projects/bocc-backend
tp

cd ~/projects/fs-landing-page
tp

cd ~/projects/prompts
tp
```

Each `tp` call appends a new named window with the configured layout. The pane tinting kicks in automatically from the shell hook as soon as the prompt renders.

#### Switching between project windows

Standard tmux window switching — all in one session:

| Key             | Action                        |
|-----------------|-------------------------------|
| `Ctrl-b 0-9`   | Switch to window by number    |
| `Ctrl-b n / p`  | Next / previous window        |
| `Ctrl-b w`      | Interactive window picker      |

#### If you `cd` into a different project within a pane

The shell hook fires on every prompt. If you `cd` from `bocc-backend` into `fs-landing-page`, **that pane's tint will change** to match the new project. The window name stays as-is (set by tmuxp at creation time) — this is intentional so your status bar stays stable.

#### Removing a project window

Just exit the shells in both panes (`exit` or `Ctrl-d` in each), or kill it:

```bash
# From inside the window
tmux kill-window

# Or from any window, by name
tmux kill-window -t bocc-backend
```
