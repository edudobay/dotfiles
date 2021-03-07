" This file is sourced by ./dein.vim

" ----------------------------------------------------------------------------
" Emmet
" let g:user_emmet_leader_key = '<c-z>'
" call dein#add('mattn/emmet-vim')

" ----------------------------------------------------------------------------
" Airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#whitespace#checks = [ 'indent' ]

call dein#add('bling/vim-airline.git')
call dein#add('vim-airline/vim-airline-themes')

" ----------------------------------------------------------------------------
" NERDTree
let g:NERDTreeIgnore = ['\~$', '^__pycache__$', '\.pyc$']

call dein#add('scrooloose/nerdtree.git')

" ----------------------------------------------------------------------------
" EditorConfig
"let g:EditorConfig_core_mode = 'python_builtin'
let g:EditorConfig_verbose = 1

call dein#add('editorconfig/editorconfig-vim')

" ----------------------------------------------------------------------------
" Ultisnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsListSnippets="<s-tab>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
inoremap <c-x><c-k> <c-x><c-k>

call dein#add('SirVer/ultisnips')
call dein#add('honza/vim-snippets')

" ----------------------------------------------------------------------------
" CamelCaseMotion

call dein#add('bkad/CamelCaseMotion')
call camelcasemotion#CreateMotionMappings(',')

" call dein#add('vim-scripts/camelcasemotion.git')

" ----------------------------------------------------------------------------
" fzf
let $FZF_DEFAULT_COMMAND = 'rg --files'

if isdirectory('/usr/local/opt/fzf')
   call dein#add('/usr/local/opt/fzf')
endif

call dein#add('junegunn/fzf.vim')

" ----------------------------------------------------------------------------

call dein#add('Shougo/denite.nvim', {
   \ 'hook_post_source': 'source ~/dotfiles/vim/conf/denite.vim'
   \ })

"-- Suggested-By: Shougo/unite.vim
call dein#add('Shougo/vimproc.vim', {'build': 'make'})

" ----------------------------------------------------------------------------

call dein#add('embear/vim-foldsearch')

call dein#add('mileszs/ack.vim.git', {
   \ 'hook_source': 'source ~/dotfiles/vim/conf/ack-pre.vim',
   \ 'lazy': 1
   \ })

" ----------------------------------------------------------------------------
" ### Language support

""" Load syntax for many languages on demand
call dein#add('sheerun/vim-polyglot')

call dein#add('abaldwin88/roamer.vim')

call dein#add('vim-scripts/po.vim--gray', {'on_ft': ['po']})

call dein#add('GutenYe/json5.vim')
" {'on_path': '*.json5'}

call dein#add('fs111/pydoc.vim.git', {'on_ft': ['python']})

call dein#add('tmhedberg/SimpylFold', {'on_ft': ['python']})
"call dein#add('davidhalter/jedi-vim')

call dein#add('tfnico/vim-gradle')

" ----------------------------------------------------------------------------
" ### Git

call dein#add('airblade/vim-gitgutter')
call dein#add('tpope/vim-fugitive')

" ----------------------------------------------------------------------------
" ### Color schemes

" Dependency for below
call dein#add('xolox/vim-misc')

" Switcher
let g:colorscheme_switcher_define_mappings = 0
call dein#add('xolox/vim-colorscheme-switcher')

let g:colorscheme_manager_define_mappings = 0
call dein#add('Taverius/vim-colorscheme-manager')

call dein#add('rakr/vim-one')
call dein#add('w0ng/vim-hybrid')
call dein#add('chriskempson/vim-tomorrow-theme')
call dein#add('skwp/vim-colors-solarized')
call dein#add('daylerees/colour-schemes', { 'rtp': 'vim/' })
call dein#add('jonathanfilip/vim-lucius')
call dein#add('vim-scripts/phd')
call dein#add('rainglow/vim')
call dein#add('mhartington/oceanic-next')

" No longer needed with neovim!
" call dein#add('godlygeek/csapprox')

" ----------------------------------------------------------------------------
" Other

call dein#add('terryma/vim-multiple-cursors')
call dein#add('chrisbra/color_highlight.git')
call dein#add('vim-scripts/TagHighlight.git')
