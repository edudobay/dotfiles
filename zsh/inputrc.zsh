# Configure key bindings
# TODO improve comment

[[ -f ~/.zkbd/$TERM-$DISPLAY ]] && source ~/.zkbd/$TERM-$DISPLAY

function _bindkey() {
   [[ -n "$1" ]] && bindkey "$@"
}

_bindkey "${key[Home]}"     beginning-of-line
_bindkey "${key[End]}"      end-of-line

# Ctrl-Home, Ctrl-End
bindkey "\e[1;5H"          beginning-of-line
bindkey "\e[1;5F"          end-of-line

_bindkey "${key[PageUp]}"   history-beginning-search-backward
_bindkey "${key[PageDown]}" history-beginning-search-forward

# Ctrl-Left, Ctrl-Right
bindkey "\e[1;5D"          backward-word
bindkey "\e[1;5C"          forward-word

bindkey '^xp' history-beginning-search-backward
bindkey '^xn' history-beginning-search-forward
bindkey '^f' history-beginning-search-forward
bindkey -s '^r\r' '\C-axrun \r'

