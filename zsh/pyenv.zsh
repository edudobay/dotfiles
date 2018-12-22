[[ ! -o login ]] || return

export PYENV_ROOT=$HOME/.local/pyenv
if [[ ! -d $PYENV_ROOT ]]; then
    PYENV_ROOT=/apps/pyenv
fi

type $PYENV_ROOT/pyenv &>/dev/null && {
    function pyenv() {
        path+=($PYENV_ROOT/bin)
        eval "$(command pyenv init -)"
        pyenv "$@"
    }
}
