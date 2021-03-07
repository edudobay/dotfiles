# Default editor
EDITOR=vim
VISUAL=vim
export EDITOR VISUAL

# Path for info (as opposed to man) files
INFOPATH=$HOME/.local/share/info:$INFOPATH
export INFOPATH

# Less: quit if one screen, avoid clearing, output ANSI colors
LESS="-F -X -R"
export LESS

# Prepend user directories to PATH (only if not already present).  Note that
# they are prepended in the order they were written -- the last will be first
user_dir_prepend=(bin .local/bin dotfiles/bin)

for dir in "${user_dir_prepend[@]}"; do
   if [[ ":$PATH:" != *":$HOME/$dir:"* ]]; then
      PATH=$HOME/$dir:$PATH
   fi
done
unset user_dir_prepend

export PATH

# X Input Method -> necessary for .XCompose overrides
export \
    QT_IM_MODULE=xim \
    GTK_IM_MODULE=xim
