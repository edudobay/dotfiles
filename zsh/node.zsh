# Always load bin for globally installed NPM & Yarn packages
path+=(
    ~/.yarn/bin
    ~/.local/npm-packages/bin
)

if [[ -d ~/Library/pnpm ]]; then
    export PNPM_HOME=~/Library/pnpm/
    path+=($PNPM_HOME)
fi

# Path for current project
path+=(./node_modules/.bin)
