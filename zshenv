# XDG_RUNTIME_DIR - from https://git.00dani.me/dot/zsh/commit/f43d8a36fab95c61c623c4b2ed385db2aea8a129
[[ -z $XDG_RUNTIME_DIR ]] && XDG_RUNTIME_DIR=${${TMPDIR-/tmp}%/}/xdg-$UID
if ! [[ -d $XDG_RUNTIME_DIR ]]; then
	mkdir -p $XDG_RUNTIME_DIR
	chmod 0700 $XDG_RUNTIME_DIR
fi

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

# 13 Apr 2020: Added "temporarily" to solve this issue. Don't know now of a better place
export QT_QPA_PLATFORMTHEME="qt5ct"

[[ -f $HOME/.zshenv.local ]] && source $HOME/.zshenv.local
