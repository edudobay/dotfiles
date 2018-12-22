# Less: quit if one screen, avoid clearing, output ANSI colors
export LESS="-F -X -R"
# Set color for highlight (standout) mode
export LESS_TERMCAP_so=$'\E[1;37;43m'
export LESS_TERMCAP_se=$'\E[0;39;49m'

[[ -n $TMUX ]] && export TERM=screen-256color

