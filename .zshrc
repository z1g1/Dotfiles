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
alias t="tmux"
#Attach to tmux session 0
alias t0="tmux attach-session -t0"
#new tds
alias tds="tmux new-session \; split-window -h -p 50 \; select-pane -t 0 \; "

# Start in ~
cd ~/
