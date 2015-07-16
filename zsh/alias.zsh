# Make file operations less dangerous :P
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ls="ls --color=auto --group-directories-first"
alias l="ls -F"

alias tmux='TERM=xterm-256color tmux'
alias mx='TERM=xterm-256color exec tmux'

# ls colors
eval "$(dircolors)"

function xrun()
{
   "$@" &>/dev/null &
   pid=$!
   job_id=$(jobs -l | grep "$pid" | cut -d ']' -f1 | cut -d '[' -f2)
   disown "%$job_id"
}

