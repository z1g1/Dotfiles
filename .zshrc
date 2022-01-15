# Created by newuser for 5.4.2

# Create a new line character that can be sourced in the PROMPT
NEWLINE=$'\n'

# Got help with the prompt from https://zsh-prompt-generator.site/
# Prompt willl appear as
# yyyy-mm-dd hh:mm user@hostname \n
PROMPT="%D %T %n@%M ${NEWLINE}"

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
