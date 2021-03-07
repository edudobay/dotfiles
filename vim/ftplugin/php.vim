inoremap <buffer> \[     {<cr>;<cr>}<up><end><bs>
inoremap <buffer> \]     []<esc>i<cr><esc>ko

function! PHP_BuildAttributeSetter(name, value)
  return "$this->" . a:name . " = " . a:value . ";"
endfunction

function! PHP_BuildAttributeSetterWithDefaultName(name)
  return PHP_BuildAttributeSetter(a:name, "$" . a:name)
endfunction

function! PHP_AddGetterFunction(methodName, propertyName)
  return "public function " . a:methodName . "()\n{\nreturn $this->" . a:propertyName . ";\n}\n"
endfunction

function! PHP_CallAddAttributeSetter()
  let name = substitute(expand('<cWORD>'), "^\\$", "", "")
  let code = PHP_BuildAttributeSetterWithDefaultName(name)
  exec 'normal caW' . code
endfunction

function! PHP_CallAddGetterFunction()
  let value = expand('<cWORD>')
  let code = PHP_AddGetterFunction(value, value)
  exec 'normal caW' . code
endfunction

inoremap <buffer> <c-k>s <c-o>:call PHP_CallAddAttributeSetter()<cr>
inoremap <buffer> <c-k>ag <c-o>:call PHP_CallAddGetterFunction()<cr>

" Less Shifts
" inoremap <buffer> 4 $
" inoremap <buffer> $ 4
" inoremap <buffer> -. ->
