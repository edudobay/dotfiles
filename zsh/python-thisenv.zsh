_thisenv_DEFAULT_DEPTH=5

_thisenv_activate_env_root() {
  local dir venv
  dir=$1

  for venv in \
    venv .venv virtualenv .virtualenv env .env
  do
    venv=$dir/$venv
    if [[ ( -d $venv ) && ( -x $venv/bin/python ) && ( -f $venv/bin/activate ) ]]; then
      echo "Activating virtual environment at $(realpath $venv)"
      source $venv/bin/activate
      return 0
    fi
  done

  if [[ -f $dir/Pipfile ]]; then
    echo "Activating virtual environment via pipenv"
    pipenv shell
    return 0
  fi

  return 1
}

_thisenv_show_help() {
  cat <<EOF
usage: thisenv [-d DEPTH]

  -d DEPTH      If a virtual environment is not found directly under the
                current directory, look up in parent directories that are
                at most DEPTH levels up.
EOF
}

thisenv() {
  local depth=$_thisenv_DEFAULT_DEPTH
  local dir

  while getopts 'd:h' arg; do
    case $arg in
      d)
        depth=$OPTARG
        if [[ ! $depth =~ '^[0-9]+$' ]]; then
          echo "Error: invalid depth (must be a number): $depth" 1>&2
          return 2
        fi
        ;;
      h)
        _thisenv_show_help
        return
        ;;
    esac
  done

  dir=$(realpath .)
  while [[ $depth -ge 0 ]]; do
    _thisenv_activate_env_root $dir && return

    [[ $dir = / ]] && break

    dir=$(dirname $dir)
    let depth--
  done

  echo "No virtual environment found here"
  return 1
}

alias thisvenv=thisenv
