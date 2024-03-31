if has('nvim')
  let g:python3_host_prog = stdpath('data') . '/venv-py3/bin/python'
  if !executable(g:python3_host_prog)
    echo "Python " . g:python3_host_prog . " not found. You can :call setup#pynvim#venvs() to set it up."
  endif
endif

let g:node_host_prog = '/usr/local/bin/neovim-node-host'
