set runtimepath^=~/dotfiles/neovim
let runtimepath=&runtimepath

lua package.path = vim.fn.expand('~/dotfiles/neovim') .. '/lua/?.lua;' .. package.path

source ~/dotfiles/neovim/init.lua
