" ===== vim-plug (auto-install) =====
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo ' . data_dir . '/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
  Plug 'dense-analysis/ale'           " 軽量 LSP / Lint
  Plug 'itchyny/lightline.vim'        " ステータスライン
  Plug 'tpope/vim-commentary'         " gc でコメントアウト
call plug#end()

" ===== ALE (LSP / Lint) =====
let g:ale_linters = {
  \ 'python':     ['pylsp'],
  \ 'typescript': ['tsserver'],
  \ 'javascript': ['tsserver'],
  \ 'rust':       ['analyzer'],
  \ }
let g:ale_fixers = {
  \ '*':          ['remove_trailing_lines', 'trim_whitespace'],
  \ 'python':     ['black'],
  \ 'typescript': ['prettier'],
  \ 'javascript': ['prettier'],
  \ 'rust':       ['rustfmt'],
  \ }
let g:ale_fix_on_save = 1
let g:ale_completion_enabled = 1
set omnifunc=ale#completion#OmniFunc

nmap <silent> gd <Plug>(ale_go_to_definition)
nmap <silent> gr <Plug>(ale_find_references)
nmap <silent> K  <Plug>(ale_hover)
nmap <silent> <Leader>rn <Plug>(ale_rename)
nmap <silent> [d <Plug>(ale_previous_wrap)
nmap <silent> ]d <Plug>(ale_next_wrap)

" ===== General =====
set encoding=utf-8
set fenc=utf-8
set autoread
set hidden
set history=10000
set title

" ===== Appearance =====
set number
set virtualedit=onemore
set wildmode=list:longest
set t_Co=256
syntax enable
set noerrorbells
set showmatch matchtime=1
set laststatus=2
set showcmd
set display=lastline
set list
set listchars=tab:^\ ,trail:~
hi Comment ctermfg=3
set clipboard+=unnamedplus

" lightline (ALE ステータスを表示)
let g:lightline = {
  \ 'component_expand': {
  \   'linter_errors':   'lightline#ale#errors',
  \   'linter_warnings': 'lightline#ale#warnings',
  \ },
  \ }

" ===== Tab =====
set expandtab
set tabstop=4
set shiftwidth=4
set smartindent

" ===== Search =====
set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch

" ===== Keymaps =====
nnoremap j gj
nnoremap k gk
inoremap <silent> jj <ESC>
nnoremap <Esc><Esc> :nohlsearch<CR>

" Windows / GUI 用
set guioptions+=a
set guioptions+=R
set shellslash
