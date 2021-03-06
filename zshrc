# ---- <Antigen>
source ~/dotfiles/antigen.zsh

antigen use oh-my-zsh

antigen bundle git
antigen bundle pip

antigen bundle zsh-users/zsh-syntax-highlighting

antigen theme edudobay/dotfiles zsh/themes/edudobay

antigen apply
# ---- </Antigen>

[[ -f ~/.zshrc.before ]] && source ~/.zshrc.before

# Run custom scripts
for file in $HOME/dotfiles/zsh/*.zsh; do
   source $file
done

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Avoid an initial error status
true
