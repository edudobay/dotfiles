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
" ## Plugin management

" > vim-plug itself: make its docs available
Plug 'junegunn/vim-plug'

" ----------------------------------------------------------------------------
" ## Visual / Color schemes

" > Color scheme: 'one'
Plug 'rakr/vim-one'

" > Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline_powerline_fonts = 1
let g:airline#extensions#whitespace#checks = [ 'indent' ]

" ----------------------------------------------------------------------------
" ## Language support

" https://github.com/neoclide/coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" > Load syntax for many languages on demand
Plug 'sheerun/vim-polyglot'

Plug 'pearofducks/ansible-vim'

" > Syntax highlighting for roamer, the plain text file manager
" https://github.com/abaldwin88/roamer
Plug 'abaldwin88/roamer.vim'

" > Highlight color names in the same color they represent
Plug 'chrisbra/color_highlight'

" > PO files (gettext)
Plug 'vim-scripts/po.vim--gray'

" ----------------------------------------------------------------------------
" ## Editing features

" > EditorConfig
Plug 'editorconfig/editorconfig-vim'
let g:EditorConfig_verbose = 0

" > Camel case motion
Plug 'bkad/CamelCaseMotion'
let g:camelcasemotion_key = ','

" > Change surroundings
Plug 'tpope/vim-surround'

" > Multiple cursors
Plug 'terryma/vim-multiple-cursors'

" > Auto-close pairs (quotes, brackets, etc)
Plug 'jiangmiao/auto-pairs'

" > Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsListSnippets = "<s-tab>"
let g:UltiSnipsJumpForwardTrigger = "<c-j>"
let g:UltiSnipsJumpBackwardTrigger = "<c-k>"
let g:UltiSnipsSnippetStorageDirectoryForUltiSnipsEdit = s:base_path . '/UltiSnips'
inoremap <c-x><c-k> <c-x><c-k>

" ----------------------------------------------------------------------------
" ## External programs and interfaces

" > NERDTree
Plug 'scrooloose/nerdtree'
let g:NERDTreeIgnore = ['\~$', '^__pycache__$', '\.pyc$']

" > Denite (Unite all interfaces)
Plug 'Shougo/denite.nvim'
call s:sourceLast(s:base_path . '/conf/denite.vim')

" > fzf / Fuzzy finder and picker interfaces
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --iglob "!.git"'
if isdirectory('/usr/local/opt/fzf')  " When fzf installed in a non-standard dir (macOS)
  Plug '/usr/local/opt/fzf'
endif
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" > ack / ag
Plug 'mileszs/ack.vim'
let g:ackprg = 'ag --nogroup --nocolor --column --hidden'

" > Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'vim-vdebug/vdebug'
if exists('g:vdebug_options')
  let g:vdebug_options.path_maps = {"/var/www/html": getcwd()}
endif

" ----------------------------------------------------------------------------
call plug#end()
