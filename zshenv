# Default editor
export EDITOR=nvim
export VISUAL=nvim

# Path for info (man’s forgotten cousin) files
typeset -TxU INFOPATH _infopath
_infopath+=(
   $HOME/.local/share/info
)

# Prepend user directories to PATH (only if not already present)
path=(
   $HOME/bin
   $HOME/dotfiles/bin
   $HOME/.local/bin
   /apps/bin
   $path
)

fpath=(
   $HOME/.local/share/zsh/completion
   $fpath
)

# Export PATH and avoid duplicate entries
typeset -xU PATH
