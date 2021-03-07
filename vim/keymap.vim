" ----------------------------------------------------------------------------
" General
let mapleader = ' '

inoremap <C-]> <Esc>

" Swap : and ; in normal & visual modes — : is much more common
" nnoremap : ;
" nnoremap ; :
" vnoremap : ;
" vnoremap ; :

" ----------------------------------------------------------------------------
" Motions
inoremap <a-up> <c-g>k
inoremap <a-down> <c-g>j
inoremap <s-left> <esc>vb
inoremap <s-right> <esc>lve
nnoremap <s-left> vB
nnoremap <s-right> vE

" ----------------------------------------------------------------------------
" Copy/paste

" Y - Instead of doing the same as yy, copy to clipboard
noremap Y "+y

" ----------------------------------------------------------------------------
" Editing

" Delete HTML tag (tip #1304)
inoremap <C-F><Del> <Esc>vat<Esc>da>`<da>i
"imap <C-F><Del> <Esc>vat<Esc>`<df>`>F<df>i

" Open line below current one
inoremap <A-o> <c-O>$<cr>

" ----------------------------------------------------------------------------
" Opening, writing, quitting
nnoremap <F2>      :w<cr>
inoremap <F2>      <c-O>:w<cr>
" <leader>fW - file write
nnoremap <leader>fW :wa<cr>
" <leader>fW - file new
nnoremap <leader>fN :enew<cr>

" Tabs
nnoremap <leader>T :tabe 
nnoremap <leader>9 :tabp<cr>
nnoremap <leader>0 :tabn<cr>

nnoremap <t_xl> :tabp<cr>
nnoremap <t_xr> :tabn<cr>
nnoremap <c-s-left> :tabp<cr>
nnoremap <c-s-right> :tabn<cr>

" Windows
nnoremap <leader>- :vsplit<cr>
nnoremap <leader>v :vsplit 
nnoremap <leader>_ :split<cr>
nnoremap <leader>h :split 
nnoremap <leader>w <c-w>w
nnoremap <leader>\w <c-w>W
nnoremap <leader><space> <c-^>
" <leader>lw - last window
nnoremap <leader>lw <c-w>p
nnoremap <c-w>; <c-w>p

nnoremap <c-up> <c-w>k
nnoremap <c-down> <c-w>j
nnoremap <c-left> <c-w>h
nnoremap <c-right> <c-w>l

" Buffers
nnoremap     <F5>  :prev<cr>
nnoremap     <F6>  :next<cr>
nnoremap <leader>q :bd<cr>
nnoremap <leader>z :bp<cr>
nnoremap <leader>x :bn<cr>
nnoremap   <a-Up>  :ls<cr>

" ## File/buffer navigation

" fzf
nnoremap <c-p>  :Files<cr>
nnoremap <leader>bb :Buffers<cr>
nnoremap <leader>be :History<cr>
nnoremap <leader>;  :Commands<cr>

" NERDtree
nnoremap <leader>o. :NERDTree<cr>
nnoremap <leader>o, :NERDTreeFind<cr>
nnoremap <leader>oo :NERDTreeToggle<cr>
nnoremap <leader>on :NERDTree ~/Dropbox/Notas/<cr>
nnoremap <leader>oj :NERDTree ~/Dropbox/Notas/gadle/journal<cr>Gk
" <leader>oS = open settings
nnoremap <leader>oS :NERDTree ~/dotfiles/vim/<cr>G

" Denite
nnoremap <leader>ff :Denite file/rec<CR>
nnoremap <leader>fd :Denite file/rec:<c-r>=expand("%:p:h")<cr><CR>

" ----------------------------------------------------------------------------
" Search and replace
nnoremap <leader>s :%s/
nnoremap <leader>S :s/

" Search for word under cursor
nnoremap <leader>/w :Ack <c-r><c-w><cr>
nnoremap <leader>/W :Ack -w <c-r><c-w><cr>

" Look up <cword> in current file and print occurrences
nnoremap [w :g/\<\>/<cr>

nnoremap    <F4> :nohl<cr>
" Clear last search pattern
nnoremap  <s-F4> :let @/ = ""<cr>

" ----------------------------------------------------------------------------
" Quickfix list
nnoremap <leader>cz :cprevious<cr>
nnoremap <leader>cx :cnext<cr>
nnoremap <leader>cc :cc<cr>
nnoremap <leader>C :clist<cr>

" ----------------------------------------------------------------------------
" Compiling and errors
nnoremap <leader>m :make<cr>

" ----------------------------------------------------------------------------
" Settings

nnoremap <leader>'ic :set ignorecase! ic?<cr>
nnoremap <leader>'et :set expandtab! et?<cr>
nnoremap <leader>'nu :set number! nu?<cr>
nnoremap <leader>'nr :set relativenumber! rnu?<cr>
nnoremap <leader>'li :set list! list?<cr>
nnoremap <leader>'lb :set linebreak! lbr?<cr>
nnoremap <leader>'ww :set wrap! wrap?<cr>
nnoremap <F11>       :set wrap! wrap?<cr>

" ----------------------------------------------------------------------------
" Git (Fugitive) commands
nnoremap <leader>gs :Git<cr>
nnoremap <leader>gc :Git commit --verbose<cr>
nnoremap <leader>g!c :Git commit --amend --verbose<cr>

" ----------------------------------------------------------------------------
" Misc insertions

" Insert current date/time
inoremap ;;D- <C-R>=strftime("%Y-%m-%d %H:%M:%S")<cr>
inoremap ;;D/ <C-R>=strftime("%d/%m/%Y %H:%M:%S")<cr>
inoremap ;;d- <C-R>=strftime("%Y-%m-%d")<cr>
inoremap ;;d/ <C-R>=strftime("%d/%m/%Y")<cr>
inoremap ;;t <C-R>=strftime("%H:%M:%S")<cr>
inoremap ;;D@ @ <C-R>=system("date -R")<cr>

" ----------------------------------------------------------------------------
" Colorschemes and fonts (in GUI)

nnoremap  <C-F9> :call ToggleBgLightDark()<cr>

" vim-colorscheme-switcher commands
nnoremap <leader>cor :RandomColorScheme<cr>
nnoremap <leader>con :NextColorScheme<cr>
nnoremap <leader>cop :PrevColorScheme<cr>

nnoremap <C-ScrollWheelUp> :call AddToFontSize(1)<CR>
nnoremap <C-ScrollWheelDown> :call AddToFontSize(-1)<CR>

" ----------------------------------------------------------------------------
" Misc

" Execute line as Ex command
nnoremap <leader>, :exec getline(".")<cr>j

" Impede que Q (modo Ex) seja mapeado para gq (formatação)
" unmap Q
" noremap Q Q

" Terminal mode
if has('nvim')
  tnoremap <Esc> <C-\><C-n>
endif
