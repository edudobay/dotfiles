# Make file operations less dangerous :P
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias l='ls -F'
alias ll='ls -lh'
alias la='ls -lAh'

alias le='less -FNXmq'

alias ag='ag --hidden'

# alias tmux='TERM=xterm-256color tmux'
# alias mx='TERM=xterm-256color exec tmux'

alias ip4='ip -4 addr'

# ls colors
if [[ $OSTYPE = darwin* ]]; then
  alias ls='ls -G'
else
  eval "$(dircolors)"
  alias ls='ls --color=auto --group-directories-first'
fi

function xrun()
{
   nohup "$@" &>/dev/null &
   disown
}

alias cnf='command-not-found'

function cdgit()
{
   local git_root
   git_root=$(git rev-parse --show-toplevel 2>/dev/null) && \
      cd $git_root
}

function CD()
{
    [[ $# -ne 1 ]] && {
        echo 'Usage: CD <new-dir>'
        return 1
    }
    mkdir -p $1 && cd $1
}
