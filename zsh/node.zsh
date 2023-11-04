# Always load bin for globally installed NPM & Yarn packages
path+=(
    ~/.yarn/bin
    ~/.local/npm-packages/bin
)

# Path for current project
path+=(./node_modules/.bin)
