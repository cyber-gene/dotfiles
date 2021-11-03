" Vim settings
set fenc=utf-8
set nobackup
set noswapfile
set autoread
set showcmd

" Visual
set number
set cursorline
set showmatch
set laststatus=2
set cmdheight=2
set ruler

syntax enable

"Tab
set expandtab
set tabstop=2
set shiftwidth=2

" Search
set hlsearch
set ignorecase
set incsearch
set smartcase

" vim-plug
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

" Initialize plugin system
call plug#end()
