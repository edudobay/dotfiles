_dotenv_load() {
  cmds=$(\
    sed -e 's/^\(export \)\?//g' | \
    dotenv-read \
  )
  echo "$cmds"
  eval "$cmds"
}

dotenv-load() {
  if [[ $# -ge 1 ]]; then
    cat "$@" | _dotenv_load
  else
    _dotenv_load
  fi
}
