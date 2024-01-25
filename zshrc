ANTIGEN_THEME='edudobay/dotfiles@main zsh/themes/edudobay'
declare -A ANTIGEN_BUNDLES_DISABLE

[[ -f ~/.zshrc.before ]] && source ~/.zshrc.before

antigen_add_bundles() {
    for bundle; do
        [[ ${ANTIGEN_BUNDLES_DISABLE[$bundle]} = 1 ]] && continue
        antigen bundle "$bundle"
    done
}

# ---- <Antigen>
source ~/dotfiles/antigen.zsh

antigen use oh-my-zsh

antigen_add_bundles \
    git \
    fzf \
    zsh-users/zsh-syntax-highlighting

if [[ -n $ANTIGEN_THEME ]]; then
    antigen theme $=ANTIGEN_THEME
fi

antigen apply
# ---- </Antigen>

# Run custom scripts
for file in $HOME/dotfiles/zsh/*.zsh; do
   source $file
done

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Avoid an initial error status
## 15 Aug 2020 - might conflict with completion system but it works this way
true
