[[ -o login ]] && return

function _chruby_load() {
    source ~/.local/share/chruby/chruby.sh
}

type chruby &>/dev/null || function chruby() {
    _chruby_load
    chruby "$@"
}
