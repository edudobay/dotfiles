# Python virtual environments

# Common paths to virtualenvwrapper.sh in some distros
# -- Lazy load if available
virtualenv_paths=(
   /usr/share/virtualenvwrapper/virtualenvwrapper_lazy.sh
   /usr/share/virtualenvwrapper/virtualenvwrapper.sh
   /usr/bin/virtualenvwrapper.sh
)

# Use the first path that we find
for venv_path in $virtualenv_paths; do
if [[ -f $venv_path ]]; then
   VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
   source $venv_path
   break
fi
done

unset venv_path virtualenv_paths
