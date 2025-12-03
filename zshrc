ANTIGEN_THEME='edudobay/dotfiles@main zsh/themes/edudobay'
declare -A ANTIGEN_BUNDLES_DISABLE

ANTIGEN_ADD_BUNDLES=(
    git
    fzf
    zsh-users/zsh-syntax-highlighting
    # rkh/zsh-jj ## - disabled due to errors
)

[[ -f ~/.zshrc.before ]] && source ~/.zshrc.before

# ---- <Antigen>
source ~/dotfiles/antigen.zsh

antigen use oh-my-zsh

for bundle in ${ANTIGEN_ADD_BUNDLES[@]}; do
    [[ ${ANTIGEN_BUNDLES_DISABLE[$bundle]} = 1 ]] && continue
    antigen bundle "$bundle"
done

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
