[[ -o login ]] && return

type rbenv &>/dev/null && {
    function rbenv() {
        eval "$(command rbenv init -)"
        rbenv "$@"
    }
}
