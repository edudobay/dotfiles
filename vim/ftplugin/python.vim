setlocal smartindent
"setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class
setlocal et sta

function! PythonAddFunction()
  let lnum = line('.')
  let original = getline('.')

  call inputsave()
  let name = input("Function name: ")
  call inputrestore()
  if name == ''
    return
  endif

  let text = 'def ' . name . '():'

  call setline('.', original . text)
  call cursor(lnum, col([lnum, '$'])-2)
endfunction

inoremap <buffer> \'I def __init__(self):<cr>
inoremap <buffer> \'i if :<left>
inoremap <buffer> \'d def ():<left><left><left>
inoremap <buffer> \'f <C-o>:call PythonAddFunction()<cr>

iab ifmain if __name__ == '__main__':
