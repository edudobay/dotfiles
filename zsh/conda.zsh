# Python/Miniconda virtual environments
: ${CONDA_DIR:=$HOME/.local/miniconda3}

# By default, we don't add conda to the PATH (I've seen it break
# some programs). Activate it using 'condawork' or its alias 'cw'

# Something inspired by virtualenvwrapper's `workon`
function condawork() {
   if [[ $# -lt 1 ]]; then
      echo "Activating miniconda root environment (at $CONDA_DIR)."
      path=($CONDA_DIR/bin $path)
   else
      echo "Activating miniconda environment '$1'."
      source $CONDA_DIR/bin/activate "$1"
   fi
}

function unconda() {
    source deactivate
    path=("${(@)path:#$CONDA_DIR/bin}")
}

alias cw='condawork'
alias sac='source activate'
alias sdac='source deactivate'
