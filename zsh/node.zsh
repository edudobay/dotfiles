# Always load bin for globally installed NPM & Yarn packages
path+=(
    ~/.yarn/bin
    ~/.local/share/npm-packages/bin
)

for PNPM_HOME in ~/.local/share/pnpm ~/Library/pnpm; do
    if [[ -d "$PNPM_HOME" ]]; then
        export PNPM_HOME
        path+=($PNPM_HOME/bin)
        break
    fi
done

# Path for current project
path+=(./node_modules/.bin)
