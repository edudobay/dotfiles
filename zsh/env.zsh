# Less: quit if one screen, avoid clearing, output ANSI colors
export LESS="-F -X -R"

[[ -n $TMUX ]] && export TERM=screen-256color

