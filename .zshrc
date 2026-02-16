# Created by newuser for 5.4.2

#Support colors at the prompt
# Supported Colors: red, blue, green, cyan, yellow, magenta, black, & white 
# Surround color codes (and any other non-printable chars) with %{....%}. 
autoload -U colors && colors

# Create a new line character that can be sourced in the PROMPT
NEWLINE=$'\n'

# Got help with the prompt from https://zsh-prompt-generator.site/
# Prompt willl appear as
# yyyy-mm-dd hh:mm user_in_blue@hostname_in_green \n
PROMPT="%D %T %{$fg[blue]%}%n%{$reset_color%}@%{$fg[green]%}%M%{$reset_color%} ${NEWLINE}"

# Print the path from Home on the right 
RPROMPT="%~"

# zsh to include the auto compllete file 
autoload -Uz compinit
compinit
# allow zsh to auto complete hidden files 
_comp_options+=(globdots)

# Add in some custom aliases
alias lls="ls"
alias ls="ls -la"
alias g="git"
## Tmux
alias t="tmux"
#Attach to tmux session 0
alias t0="tmux attach-session -t0"
#new tds
alias tds="tmux new-session \; split-window -h -p 50 \; select-pane -t 0 \; "

## Python
alias pynv="python3 -m venv venv" #New virtual environment
alias pyav="source ./venv/bin/activate" # activate virtual environment
alias pydv="deactivate" # activate virtual environment

# Hashicorp autocompletes
#terraform -install-autocomplete


# Use glow to render markdown in the terminal
# my terminal is usually white so alias it to alwasy light mode 
# sudo snap install glow
alias glow="glow -s light"

# Add python to path
export PYTHONPATH

# Start in ~
cd ~/

# Capture last 1000 commands 
SAVEHIST=1000  # Save most-recent 1000 lines
HISTFILE=~/.zsh_history
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"
eval "$(rbenv init -)"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# ---------------------------------------------------------
# tmux project hooks
# Reads .tmux-project from the git root (or cwd) on every
# prompt. Sets status bar color, pane borders, and stores
# the color as a window option so tmux hooks can read it
# on window switch.
# ---------------------------------------------------------
_tmux_project_hook() {
  [[ -z "$TMUX" ]] && return

  local project_root
  project_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")

  local config_file="${project_root}/.tmux-project"

  if [[ -f "$config_file" ]]; then
    local project_color window_name
    project_color=$(grep -E '^TMUX_PROJECT_COLOR=' "$config_file" | cut -d'"' -f2)
    window_name=$(grep -E '^TMUX_WINDOW_NAME=' "$config_file" | cut -d'"' -f2)

    if [[ "$project_color" =~ ^#[0-9a-fA-F]{6}$ ]]; then
      # Store color as a window option so the tmux hook can
      # read it instantly on window switch
      tmux set -w @project_color "$project_color" 2>/dev/null

      # Apply to status bar and pane borders
      tmux set status-style "bg=${project_color},fg=black" 2>/dev/null
      tmux set pane-border-style "fg=${project_color}" 2>/dev/null
      tmux set pane-active-border-style "fg=${project_color}" 2>/dev/null
    fi

    if [[ -n "$window_name" ]]; then
      tmux rename-window "$window_name" 2>/dev/null
    fi
  else
    # Reset to defaults
    tmux set -wu @project_color 2>/dev/null
    tmux set status-style "bg=green,fg=black" 2>/dev/null
    tmux set pane-border-style "fg=default" 2>/dev/null
    tmux set pane-active-border-style "fg=green" 2>/dev/null
    tmux automatic-rename on 2>/dev/null
  fi
}

tmux-init() {
  local name="${1:-$(basename "$PWD")}"
  local color="${2:-#5f87af}"

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
TMUX_PROJECT_COLOR="${color}"
TMUX_WINDOW_NAME="${name}"
EOF

  echo "Created .tmuxp.yaml and .tmux-project for '${name}' with color ${color}"
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

  local win_name
  win_name=$(grep 'window_name:' "$config" | head -1 | awk '{print $2}')

  if tmux list-windows -F '#{window_name}' | grep -qx "$win_name"; then
    echo "Window '$win_name' already exists — switching to it"
    tmux select-window -t "$win_name"
  else
    tmuxp load -a -y .
  fi
}
