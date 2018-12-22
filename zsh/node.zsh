if [[ -d /apps/nvm ]]; then
    NVM_DIR="/apps/nvm"
else
    NVM_DIR="$HOME/.local/nvm"
fi

export NVM_DIR

function _node_load() {
    path prepend ~/.config/yarn/global/node_modules/.bin

    ! whence -p nvm >/dev/null && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
}

function nvm() {
    _node_load && nvm "$@"
}

function node() {
    ! whence -p node >/dev/null && _node_load
    command node "$@"
}

function npm() {
    ! whence -p npm >/dev/null && _node_load
    command npm "$@"
}

function npx() {
    ! whence -p npx >/dev/null && _node_load
    command npx "$@"
}

function yarn() {
    ! whence -p yarn >/dev/null && _node_load
    command yarn "$@"
}

# Path for current project
path+=(./node_modules/.bin)
