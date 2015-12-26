# Default editor
export EDITOR=vim VISUAL=vim

# Path for info (as opposed to man) files
export INFOPATH=$HOME/.local/share/info:$INFOPATH

# Less: quit if one screen, avoid clearing, output ANSI colors
export LESS="-F -X -R"

# Prepend user directories to PATH (only if not already present)
user_dir_prepend=(
   bin
   dotfiles/bin
   .local/bin
   .rvm/bin        # for scripting
   .local/npm/bin
)

path=($HOME/${^user_dir_prepend} $path)
unset user_dir_prepend

export PATH
