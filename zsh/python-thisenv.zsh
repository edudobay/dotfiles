thisenv() {
  for venv in \
    venv .venv virtualenv .virtualenv env .env
  do
    if [[ ( -d $venv ) && ( -x $venv/bin/python ) && ( -f $venv/bin/activate ) ]]; then
      echo "Activating virtual environment at $(realpath $venv)"
      source $venv/bin/activate
      return 0
    fi
  done

  if [[ -f Pipfile ]]; then
    echo "Activating virtual environment via pipenv"
    pipenv shell
  fi

  echo "No virtual environment found here"
  return 1
}

alias thisvenv=thisenv
