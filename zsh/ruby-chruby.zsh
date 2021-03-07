[[ -o login ]] && return

function _chruby_load() {
  for root in \
    /usr/local/opt/chruby \
    ~/.local/
  do
    if [[ -f $root/share/chruby/chruby.sh ]]; then
      source $root/share/chruby/chruby.sh
      return
    fi
  done

  echo "chruby not found" 1>&2
  return 1
}

type chruby &>/dev/null || function chruby() {
  _chruby_load && chruby "$@"
}
