"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

let s:bundle_root = expand('~/.local/vim/dein')
let s:dein_root = s:bundle_root . '/repos/github.com/Shougo/dein.vim'

exec 'set runtimepath+=' . s:dein_root

if dein#load_state(s:bundle_root) != 0
  let s:vimrcs = map(
  \ [
  \   "dein.vim",
  \   "bundles.vim"
  \ ],
  \ "expand('~/dotfiles/vim/') . v:val")
  call dein#begin(s:bundle_root, s:vimrcs)

  " Let dein manage dein
  call dein#add(s:dein_root)

  source ~/dotfiles/vim/bundles.vim

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------

" This hook is not called automatically. It must be called like this according
" to dein.vim documentation.
autocmd VimEnter * call dein#call_hook('post_source')

