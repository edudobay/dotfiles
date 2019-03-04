[[ ! -o login ]] || return

_find_pyenv_root() {
    for possible_root in \
        $HOME/.pyenv \
        $HOME/.local/pyenv \
        /apps/pyenv
    do
        if [[ -d $possible_root ]]; then
            echo $possible_root
            return
        fi
    done
}

export PYENV_ROOT=$(_find_pyenv_root)

type $PYENV_ROOT/pyenv &>/dev/null && {
    function pyenv() {
        path+=($PYENV_ROOT/bin)
        eval "$(command pyenv init -)"
        pyenv "$@"
    }
}
