"Tab settings
set tabstop=4
set autoindent
set expandtab
set shiftwidth=4

"line number
set nu

"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=~/.vim/repos/github.com/Shougo/dein.vim

  " Required:
  call dein#begin('~/.vim')

  " Let dein manage dein
  " Required:
  call dein#add('Shougo/dein.vim')

  " Add or remove your plugins here:
  call dein#add('Shougo/neosnippet.vim')
  call dein#add('Shougo/neosnippet-snippets')
  call dein#add('altercation/vim-colors-solarized')

  " You can specify revision/branch/tag.
  call dein#add('Shougo/vimshell', { 'rev': '3787e5' })

  " Required:
  call dein#end()

  " Required:
  filetype plugin indent on

  " If you want to install not installed plugins on startup.
  "if dein#check_install()
  "  call dein#install()
  "endif

"End dein Scripts-------------------------

"color setting (solarized)
let g:solarized_termtrans=1
syntax enable
set background=dark
colorscheme solarized

