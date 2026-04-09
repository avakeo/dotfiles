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
  Plug 'preservim/nerdtree'           " ファイルツリー
  Plug 'Xuyuanp/nerdtree-git-plugin'  " NERDTree に git ステータス表示
  Plug 'ryanoasis/vim-devicons'       " ファイルアイコン (Nerd Font 必須)
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
set clipboard+=unnamed,unnamedplus

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

" ===== WezTerm スマートナビゲーション =====
" vim 起動中は IS_VIM=true を WezTerm に通知する
" (base64("true") = "dHJ1ZQ==")
" これにより vim 内の :terminal でも Ctrl+hjkl でウィンドウ移動できる
if !empty($WEZTERM_PANE)
  let &t_ti = "\e]1337;SetUserVar=IS_VIM=dHJ1ZQ==\007" . &t_ti
  let &t_te = &t_te . "\e]1337;SetUserVar=IS_VIM=\007"
endif

" ===== NERDTree =====
nnoremap <C-n> :NERDTreeFocus<CR>
nnoremap <Leader>t :NERDTreeToggle<CR>
nnoremap <Leader>tf :NERDTreeFind<CR>

" netrw を無効化して NERDTree を使う
let g:NERDTreeHijackNetrw = 1

" dotfiles も表示
let g:NERDTreeShowHidden = 1

" .git は表示しない
let g:NERDTreeIgnore = ['^\.git$']

" ウィンドウ幅
let g:NERDTreeWinSize = 30

" ファイルを開いたらツリーにフォーカスを戻さない
let g:NERDTreeQuitOnOpen = 0

" 最後のウィンドウが NERDTree だけなら自動終了
autocmd BufEnter * if tabpagenr('$') == 1
  \ && winnr('$') == 1
  \ && exists('b:NERDTree')
  \ && b:NERDTree.isTabTree()
  \ | quit | endif

" ===== Keymaps =====
" ターミナル
if (has('win32') || has('win64')) && empty($WSL_DISTRO_NAME)
  nnoremap tt :tab terminal pwsh.exe -NoLogo<CR>
else
  nnoremap tt :tab terminal<CR>
endif

" トグルターミナル (tx): 同じセッションを下部に表示/非表示
let s:term_buf = 0

function! s:ToggleTerm()
  if s:term_buf > 0 && bufwinnr(s:term_buf) > 0
    " 表示中 → ウィンドウを閉じる（セッションは保持）
    exec bufwinnr(s:term_buf) . "wincmd w"
    hide
  elseif s:term_buf > 0 && bufexists(s:term_buf)
    " バッファはあるがウィンドウにない → 下部に再表示
    botright new
    resize 12
    exec "buffer " . s:term_buf
    startinsert
  else
    " 初回: 新規ターミナルを起動
    botright new
    resize 12
    if (has('win32') || has('win64')) && empty($WSL_DISTRO_NAME)
      terminal pwsh.exe -NoLogo
    else
      terminal
    endif
    let s:term_buf = bufnr("")
  endif
endfunction

nnoremap <silent> tx :call <SID>ToggleTerm()<CR>
" ターミナル内からも tx でトグルできる
tnoremap <silent> tx <C-w>:call <SID>ToggleTerm()<CR>

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
