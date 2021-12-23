if has('nvim')
  let g:python_host_prog  = stdpath('data') . '/venv-py2/bin/python'
  let g:python3_host_prog = stdpath('data') . '/venv-py3/bin/python'
  if !executable(g:python3_host_prog)
    echo "Python " . g:python3_host_prog . " not found. You can :call setup#pynvim#venvs() to set it up."
  endif
endif

