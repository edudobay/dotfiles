[[ -o login ]] && return

export RBENV_ROOT=$HOME/.local/rbenv

# lazy load
type $RBENV_ROOT/rbenv &>/dev/null && {
    function rbenv() {
        path+=($RBENV_ROOT/bin)
        eval "$(command rbenv init -)"
        rbenv "$@"
    }
}
