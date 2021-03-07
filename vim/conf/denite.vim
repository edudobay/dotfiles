" Denite, successor of Unite
" https://github.com/Shougo/denite.nvim

if executable('ag')
   call denite#custom#var('file_rec', 'command',
      \ ['ag', '--follow', '--nocolor', '--nogroup', '--hidden', '-g', ''])
endif

" Because 'dd' is mapped, pressing 'd' forces us to wait a while.
call denite#custom#map('normal', 'D', '<denite:do_action:delete>')
call denite#custom#map('normal', 'sv', '<denite:do_action:vsplitswitch>')
call denite#custom#map('normal', 'sv', '<denite:do_action:splitswitch>')
call denite#custom#map('normal', 'st', '<denite:do_action:tabswitch>')

" nmap <leader>ff :Denite file_rec/git:--cached:--others:--exclude-standard<CR>
" nmap <leader>fd :Denite -custom-grep-default_opts=-U file_rec/async:<c-r>=expand("%:p:h")<cr><CR>

