" Leader キー
let mapleader = " "

" dotfiles の .vim を runtimepath に追加 (lightline カラースキーム等)
let s:dotfiles_vim = expand('~/dotfiles/.vim')
if isdirectory(s:dotfiles_vim)
  execute 'set runtimepath+=' . s:dotfiles_vim
endif

" ===== vim-plug (auto-install) =====

let data_dir = has('nvim') ? stdpath('data') . '/site' : (has('win32') ? expand('~/vimfiles') : expand('~/.vim'))
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo ' . data_dir . '/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
  Plug 'dense-analysis/ale'           " 軽量 LSP / Lint
  Plug 'itchyny/lightline.vim'        " ステータスライン
  Plug 'maximbaz/lightline-ale'       " lightline に ALE ステータスを表示
  Plug 'tpope/vim-commentary'         " gc でコメントアウト
  Plug 'cocopon/iceberg.vim'          " ダークブルー系テーマ
  Plug 'github/copilot.vim'           " GitHub Copilot
call plug#end()


" テーマは syntax enable の後に設定

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
set background=dark
colorscheme iceberg
set noerrorbells
set showmatch matchtime=1
set laststatus=2
set showcmd
set display=lastline
set list
set listchars=tab:^\ ,trail:~
hi Comment ctermfg=3
set clipboard+=unnamedplus

" lightline (外部カラースキーム: ~/.vim/autoload/lightline/colorscheme/dotfiles.vim)
let g:lightline = {
  \ 'colorscheme': 'dotfiles',
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
" ターミナル
if (has('win32') || has('win64')) && empty($WSL_DISTRO_NAME)
  nnoremap tt :tab terminal pwsh.exe -NoLogo<CR>
  nnoremap tx :belowright terminal ++rows=10 pwsh.exe -NoLogo<CR>
else
  nnoremap tt :tab terminal<CR>
  nnoremap tx :belowright terminal ++rows=10<CR>
endif

nnoremap j gj
nnoremap k gk
inoremap <silent> jj <ESC>
nnoremap <Esc><Esc> :nohlsearch<CR>

" 画面分割 (WezTerm / nvim と統一)
nnoremap <Leader>v :vsplit<CR>
nnoremap <Leader>s :split<CR>
nnoremap <Leader>x :close<CR>

" ウィンドウ移動 (WezTerm の Ctrl+hjkl と統一)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
tnoremap <C-h> <C-w>h
tnoremap <C-j> <C-w>j
tnoremap <C-k> <C-w>k
tnoremap <C-l> <C-w>l

" ウィンドウリサイズ (Ctrl+矢印)
nnoremap <C-Left>  :vertical resize -5<CR>
nnoremap <C-Right> :vertical resize +5<CR>
nnoremap <C-Up>    :resize +5<CR>
nnoremap <C-Down>  :resize -5<CR>
tnoremap <C-Left>  <C-w>:vertical resize -5<CR>
tnoremap <C-Right> <C-w>:vertical resize +5<CR>
tnoremap <C-Up>    <C-w>:resize +5<CR>
tnoremap <C-Down>  <C-w>:resize -5<CR>

" Windows / GUI 用
set guioptions+=a
set guioptions+=R
set shellslash

" Windows: 起動元に応じてシェルを切り替え
if has('win32') || has('win64')
  if !empty($WSL_DISTRO_NAME)
    " WSL から起動: zsh or bash
    if executable('zsh')
      set shell=zsh
    else
      set shell=bash
    endif
  else
    " shell は cmd.exe のまま (vim-plug 等の互換性のため)
    " :terminal だけ PowerShell を使う
    " shell は cmd.exe のまま (vim-plug 等の互換性のため)
    " :terminal は pwsh を明示的に起動
    set termwintype=conpty
  endif
endif
