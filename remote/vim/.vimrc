" ============================================================================
" Lean Remote Vim Configuration
" ============================================================================

" ----------------------------------------------------------------------------
" General Settings
" ----------------------------------------------------------------------------
set nocompatible              " Disable vi compatibility
filetype plugin indent on     " Enable file type detection
syntax on                     " Enable syntax highlighting

" ----------------------------------------------------------------------------
" UI
" ----------------------------------------------------------------------------
set number                    " Show line numbers
set relativenumber            " Relative line numbers
set ruler                     " Show cursor position
set showcmd                   " Show command in bottom bar
set cursorline                " Highlight current line
set wildmenu                  " Visual autocomplete for command menu
set showmatch                 " Highlight matching brackets
set laststatus=2              " Always show status line

" ----------------------------------------------------------------------------
" Search
" ----------------------------------------------------------------------------
set incsearch                 " Search as characters are entered
set hlsearch                  " Highlight search matches
set ignorecase                " Case insensitive search
set smartcase                 " Case sensitive if uppercase present

" Clear search highlight with <leader>/
nnoremap <leader>/ :nohlsearch<CR>

" ----------------------------------------------------------------------------
" Tabs & Spaces
" ----------------------------------------------------------------------------
set tabstop=4                 " Visual spaces per TAB
set softtabstop=4             " Spaces per TAB when editing
set shiftwidth=4              " Spaces for autoindent
set expandtab                 " Tabs are spaces
set smartindent               " Smart autoindenting

" ----------------------------------------------------------------------------
" Navigation
" ----------------------------------------------------------------------------
set backspace=indent,eol,start " Make backspace work as expected
set scrolloff=8               " Keep 8 lines above/below cursor

" Move by visual line
nnoremap j gj
nnoremap k gk

" ----------------------------------------------------------------------------
" File Handling
" ----------------------------------------------------------------------------
set autoread                  " Auto reload files changed outside vim
set hidden                    " Allow hidden buffers
set nobackup                  " No backup files
set noswapfile                " No swap files

" ----------------------------------------------------------------------------
" Performance
" ----------------------------------------------------------------------------
set lazyredraw                " Don't redraw during macros
set updatetime=300            " Faster update time

" ----------------------------------------------------------------------------
" Status Line
" ----------------------------------------------------------------------------
set statusline=%F             " Full path
set statusline+=%m            " Modified flag
set statusline+=%=            " Switch to right side
set statusline+=%l/%L         " Current line / total lines
set statusline+=\ [%p%%]      " Percentage through file
set statusline+=\ Col:%c      " Column number

" ----------------------------------------------------------------------------
" Leader Key Mappings
" ----------------------------------------------------------------------------
let mapleader = " "

" Quick save
nnoremap <leader>w :w<CR>

" Quick quit
nnoremap <leader>q :q<CR>

" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" ----------------------------------------------------------------------------
" Local Overrides (optional)
" ----------------------------------------------------------------------------
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
