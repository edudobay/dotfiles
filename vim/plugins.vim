call plug#begin(stdpath('data') . '/plugged')

if !exists("*plug#begin")
  echoerr "Cannot initialize plugins: vim-plug could not be found"
  finish
endif

let s:base_path = expand('<sfile>:p:h')
let s:lateinit_scripts = []

function! s:sourceLast(name)
  call add(s:lateinit_scripts, a:name)
endfunction

function! s:sourceLateInitScripts()
  for script in s:lateinit_scripts
    exec 'source ' . script
  endfor
endfunction

autocmd VimEnter * call s:sourceLateInitScripts()

" ----------------------------------------------------------------------------
" Colorschemes
Plug 'rakr/vim-one'

" ----------------------------------------------------------------------------

" > Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline_powerline_fonts = 1
let g:airline#extensions#whitespace#checks = [ 'indent' ]

" > NERDTree
Plug 'scrooloose/nerdtree'
let g:NERDTreeIgnore = ['\~$', '^__pycache__$', '\.pyc$']

" > EditorConfig
Plug 'editorconfig/editorconfig-vim'
let g:EditorConfig_verbose = 1

" > Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" > Denite (Unite all interfaces)
Plug 'Shougo/denite.nvim'
call s:sourceLast(s:base_path . '/conf/denite.vim')

" > fzf / Fuzzy finder and picker interfaces
let $FZF_DEFAULT_COMMAND = 'rg --files'
if isdirectory('/usr/local/opt/fzf')  " When fzf installed in a non-standard dir (macOS)
  Plug '/usr/local/opt/fzf'
endif
Plug 'junegunn/fzf.vim'

" > ack / ag
Plug 'mileszs/ack.vim'
let g:ackprg = 'ag --nogroup --nocolor --column --hidden'

" > Load syntax for many languages on demand
Plug 'sheerun/vim-polyglot'

" > Syntax highlighting for roamer, the plain text file manager
" https://github.com/abaldwin88/roamer
Plug 'abaldwin88/roamer.vim'

" > Highlight color names in the same color they represent
Plug 'chrisbra/color_highlight'

" > Camel case motion
Plug 'bkad/CamelCaseMotion'
let g:camelcasemotion_key = ','

" ----------------------------------------------------------------------------
call plug#end()
