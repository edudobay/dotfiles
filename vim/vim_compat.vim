" Set options for Vim only (not Neovim/nvim)
if has('nvim')
  finish
endif

if !isdirectory(expand("~/.cache/vim/swapfiles"))
  silent !mkdir -p ~/.cache/vim/swapfiles
endif

" nvim already has a sensible default (~/.local/share/nvim/swap)
set directory^=$HOME/.cache/vim/swapfiles//
