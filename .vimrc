set nu
set so=2
colo desert
set backspace=indent,eol,start
set nowrap
syntax on
set hidden
set showcmd
set autoread
set wildmenu
set ruler
set guicursor+=a:blinkon0

set autoindent
set smartindent
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

set hlsearch
set incsearch
set ignorecase
set smartcase
filetype plugin indent on

set encoding=utf8
set nobackup
set tags+=tags

map <F3> :redir @a<CR>:g//<CR>:redir END<CR>:new<CR>:put! a<CR>
map <F8> :wa<CR>
map <F9> :!ctags -R .<CR>
map <C-BS> <C-W>

command W w

call plug#begin('~/.vim/plugged')
Plug 'ervandew/supertab'
call plug#end()