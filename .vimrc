" General Settings
set fenc=utf-8
set autoread
set hidden

" Looks Settings
set number
set virtualedit=onemore
set smartindent
set wildmode=list:longest
nnoremap j gj
nnoremap k gk
set t_Co=256
syntax enable
inoremap <silent> jj <ESC>


" Tab Settings
set expandtab
set tabstop=4
set shiftwidth=4

" Search Settings
set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch
set title

" Appearance Settings
set noerrorbells
set shellslash
set showmatch matchtime=1
set laststatus=2
set showcmd
set display=lastline
set list
set listchars=tab:^\ ,trail:~
set history=10000
hi Comment ctermfg=3
set guioptions+=a
set guioptions+=R
set clipboard+=unnamedplus
nnoremap <Esc><Esc> :nohlsearch<CR>

" colorscheme iceberg
