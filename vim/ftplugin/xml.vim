" close an open tag
inoremap <buffer> <a-t> F<"tyegit>b/F<
inoremap <buffer> <a-r> x"_x:call XMLInsertBlock()<cr>a

function! XMLInsertBlock()
  let ccol = col('.')
  let lnum = line('.')
  let original = getline('.')

  call inputsave()
  let name = input("Tag name: ")
  call inputrestore()
  if name == ''
    return
  endif

  let opening = '<' . name . '>'
  let closing = '</' . name . '>'

  if strlen(original) < ccol
    let line = original . repeat(' ', ccol - strlen(original)) . opening
  else
    let line = strpart(original, 0, ccol) . opening . strpart(original, ccol)
  endif

  call setline('.', line)

  let nspaces = indent(lnum)
  let nspaces2 = nspaces + &shiftwidth
  call append(lnum, [repeat(' ', nspaces2), repeat(' ', nspaces) . closing])
  call cursor(lnum+1, nspaces2+1)
endfunction

