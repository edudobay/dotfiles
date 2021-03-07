set shiftwidth=2

inoremap <buffer> \[     {<cr>;<cr>}<up><end><bs>

inoremap <buffer> \'i if () {<cr>;<cr>}<esc>3Ba
inoremap <buffer> \'e else {<cr>;<cr>}<esc>BC
inoremap <buffer> \'w while () {<cr>;<cr>}<esc>3Ba
inoremap <buffer> \'f for (;;) {<cr>;<cr>}<esc>3Ba
inoremap <buffer> \'v function () {<cr>;<cr>}<esc>3Bi
inoremap <buffer> \'l function () {<cr>;<cr>}<esc>BC


