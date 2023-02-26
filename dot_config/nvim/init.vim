" ==================================================
" Brad's init.vim
" ==================================================

" ==================================================
" Fundamentals
" ==================================================

set nocompatible            " disable compatibility to old-time vi
filetype plugin on
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set clipboard=unnamedplus   " using system clipboard
set encoding=utf-8

" ==================================================
" Display
" ==================================================
set ruler laststatus=2 showcmd showmode
set list listchars=tab:»-   " replace \t with »---
set cursorline              " highlight current cursorline
set title                   " set the terminal title to the filename
set wrap breakindent        " wrap long lines to the width set by tw
"
" ==================================================
" Indent
" ==================================================

filetype plugin indent on   "allow auto-indenting depending on file type
set autoindent              " indent a new line the same amount as the line just typed
set tabstop=4               " number of columns occupied by a tab 
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set smarttab
set shiftwidth=4            " width for autoindents

set textwidth=78

" ==================================================
" Cool tricks
" ==================================================

" enable spell only if file type is normal text
let spellable = ['markdown', 'gitcommit', 'txt', 'text', 'liquid', 'rst']
autocmd BufEnter * if index(spellable, &ft) < 0 | set nospell | else | set spell | endif



" ==================================================
" Search
" ==================================================

set ignorecase              " case insensitive 
set hlsearch                " highlight search 
set incsearch               " incremental search

" ==================================================
" Stuff to look into
" ==================================================

" https://github.com/vim-airline/vim-airline
"set undofile                " persistent undo
"set undodir=/dir

