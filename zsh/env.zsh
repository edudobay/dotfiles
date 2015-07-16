# Path for info (as opposed to man) files
export INFOPATH=$HOME/.local/share/info:$INFOPATH

# Less: quit if one screen, avoid clearing, output ANSI colors
export LESS="-F -X -R"

export EDITOR=vim

[[ -n $TMUX ]] && export TERM=screen-256color

