function! OpenBufferOrFile(name)
  if bufexists(a:name)
    execute "buffer" a:name
  else
    execute "edit" a:name
  endif
endfunction

function! CSwitchHeaderSource()
  try
    let source_exts = ['.cc', '.cpp', '.c', '.C']
    let header_exts = ['.h', '.hh', '.hpp', '.H']
    let extension = "." . expand('%:e')

    let basename = expand('%:r')

    if index(source_exts, extension) >= 0
      " try a header
      for ext in header_exts
        if filereadable(basename . ext)
          call OpenBufferOrFile(basename . ext)
          return
        endif
      endfor
      let create = input("Unable to find a corresponding header file. Create '" . basename . header_exts[0] . "'? ")
      if tolower(create) == 'y'
        call OpenBufferOrFile(basename . header_exts[0])
      endif
    elseif index(header_exts, extension) >= 0
      " try a source
      for ext in source_exts
        if filereadable(basename . ext)
          call OpenBufferOrFile(basename . ext)
          return
        endif
      endfor
      let create = input("Unable to find a corresponding source file. Create '" . basename . source_exts[0] . "'? ")
      if tolower(create) == 'y'
        call OpenBufferOrFile(basename . source_exts[0])
      endif
    else
      echo "This file wasn't recognized as either a source or header file."
    endif
  catch /^Vim\%((\a\+)\)\=:E37/
    echohl ErrorMsg
    echo "Alterations not saved!"
    echohl None
    return
  endtry
endfunction

function! ChmodExecutable()
  if &modified
    if confirm("File has been modified! Save?", "&Cancel\n\&Yes") != 2
      return
    else
      w
    endif
  endif

  let file = '"' . expand('%') . '"'
  silent exec '!chmod +x ' . file
endfunction

function! ToggleBgLightDark()
  if &bg == 'light'
    set bg=dark
  else
    set bg=light
  endif
endfunction

function! TrimTrailingWhitespace()
  %s/[ \t\r]\+$//e
endfunction

function! TmuxSetBuffer(data)
  python << EOF
  import vim
  from subprocess import Popen, PIPE
  data = vim.eval('a:data')
  proc = Popen(["tmux", "set-buffer", data], stdout=PIPE, stderr=PIPE)
  stdout, stderr = proc.communicate()
  if proc.returncode != 0:
    print "error"
EOF
endfunction

command TmuxCopy call TmuxSetBuffer(getreg('"'))

function LoadColorTheme(name)
  let idx = stridx(a:name, "|")
  if idx > 0
    let theme = strpart(a:name, 0, idx)
    let variant = strpart(a:name, idx+1)
    exec "set bg=" . variant
    exec "colo" theme
  else
    exec "colo" a:name
  endif
endfunction

let g:browser = 'xdg-open'

function! OpenOrNewTab(filename)
  if bufname('%') == ''
    exec "e + " . a:filename
  else
    exec "tabe + " . a:filename
  endif
endfunction

command! -nargs=1 -complete=file TabOpen call OpenOrNewTab(<f-args>)
command! ChmodX call ChmodExecutable()

command! Trim call TrimTrailingWhitespace()

command! Conflicts Ack '^[<>]{7}'

function! OpenURL(url, ...)
  let list = [a:url] + a:000
  let cmd = g:browser . ' "' . join(list, '" "') . '" &'
  exec 'silent !' . cmd
endfunction


let g:cursor_follow_active_window = 1
function! CursorLCHighlight(state)
  if g:cursor_follow_active_window != 1
    return
  endif

  if a:state == 0
    set nocul
  else
    set cul
  endif
endfunction

function! CopyPathToClipboard(format = 'relative')
  if a:format == 'relative'
    let path = expand('%')
  elseif a:format == 'absolute'
    let path = expand('%:p')
  else
    echoerr "CopyPathToClipboard: invalid format: " . a:format
    return
  endif
  call setreg('+', path)
  echo "Path copied to clipboard: " . path
endfunction
