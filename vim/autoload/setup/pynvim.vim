if !has('nvim')
  finish
endif

function! s:CheckNvimModule(python)
  exec "silent !" . a:python . " -c 'import pynvim; import neovim'"
endfunction

function! s:CreateVenv(dir, python)
  exec "!" . a:python . " -m venv " . a:dir
  exec "!" . a:dir . "/bin/python3 -m pip install pynvim neovim"
  echomsg "Python environment created: " . a:dir
endfunction

function! s:SetupVenv(python_exe, python)
  if executable(a:python_exe)
    call s:CheckNvimModule(a:python_exe)
    return
  endif

  if !executable(a:python)
    echoerr "Python executable not found: " . a:python
    return
  endif

  call s:CreateVenv(fnamemodify(a:python_exe, ":h:h"), a:python)
endfunction

function! setup#pynvim#venvs()
  call s:SetupVenv(g:python3_host_prog, "python3")
endfunction
