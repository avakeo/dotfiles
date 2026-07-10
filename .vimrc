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
  Plug 'wakatime/vim-wakatime'
  Plug 'voldikss/vim-floaterm'        " フロートターミナル (toggleterm.nvim 相当)
  Plug 'jiangmiao/auto-pairs'         " 括弧・引用符の自動補完
  Plug 'machakann/vim-highlightedyank' " ヤンク時に範囲をハイライト (nvim の on_yank 相当)
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
let g:ale_set_signs = 0
let g:ale_virtualtext_cursor = 'disabled'
let g:ale_completion_enabled = 1
set omnifunc=ale#completion#OmniFunc

nmap <silent> gd <Plug>(ale_go_to_definition)
nmap <silent> gr <Plug>(ale_find_references)
nmap <silent> K  <Plug>(ale_hover)
nmap <silent> <Leader>rn <Plug>(ale_rename)
nmap <silent> [d <Plug>(ale_previous_wrap)
nmap <silent> ]d <Plug>(ale_next_wrap)

nnoremap <silent> <Leader>ud :ALEToggle<CR>

let s:matchparen_on = 1
function! s:ToggleMatchParen()
  let s:matchparen_on = !s:matchparen_on
  if s:matchparen_on
    DoMatchParen
    echo 'Bracket highlight ON'
  else
    NoMatchParen
    echo 'Bracket highlight OFF'
  endif
endfunction
nnoremap <silent> <Leader>ui :call <SID>ToggleMatchParen()<CR>

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

" ヤンクハイライト (nvim 側 preference.lua の on_yank と同じ見た目に揃える)
" iceberg は IncSearch/Visual とも cterm=reverse で区別がつかないため、
" bluloco の IncSearch 相当の黄色を明示指定する
let g:highlightedyank_highlight_duration = 300
highlight HighlightedyankRegion ctermfg=234 ctermbg=178 guifg=#161821 guibg=#e3b80d
set noerrorbells
set showmatch matchtime=1
set laststatus=2
" カレントディレクトリからの相対パスを表示
set statusline=%f\ %m%r%h%w\ %=%l,%c%V\ %P
set showcmd
set display=lastline
set list
set listchars=tab:^\ ,trail:~
hi Comment ctermfg=3
" ALE 診断の下線を undercurl（波線）に変更
function! s:AleUndercurl()
  hi ALEError        cterm=undercurl gui=undercurl guisp=#e27878
  hi ALEWarning      cterm=undercurl gui=undercurl guisp=#e2a478
  hi ALEInfo         cterm=undercurl gui=undercurl guisp=#84a0c6
  hi ALEStyleError   cterm=undercurl gui=undercurl guisp=#e27878
  hi ALEStyleWarning cterm=undercurl gui=undercurl guisp=#e2a478
endfunction
autocmd ColorScheme * call s:AleUndercurl()
call s:AleUndercurl()

" 背景透過 (WezTerm の window_background_opacity に合わせる)
function! s:TransparentBg()
  hi Normal      ctermbg=NONE guibg=NONE
  hi NonText     ctermbg=NONE guibg=NONE
  hi EndOfBuffer ctermbg=NONE guibg=NONE
  hi LineNr      ctermbg=NONE guibg=NONE
  hi SignColumn  ctermbg=NONE guibg=NONE
  hi Folded      ctermbg=NONE guibg=NONE
endfunction
autocmd ColorScheme * call s:TransparentBg()
call s:TransparentBg()

" クリップボード
" SSH 接続中(リモート: Ubuntu 等)は OSC 52 経由でローカル端末
" (WezTerm)のクリップボードに同期する。ローカル実行時は OS の
" クリップボードを直接使う。
if !empty($SSH_TTY) || !empty($SSH_CONNECTION)
  function! s:Osc52Yank() abort
    let l:enc = system('base64 | tr -d "\n"', @0)
    let l:seq = "\033]52;c;" . l:enc . "\007"
    call writefile([l:seq], '/dev/tty', 'b')
  endfunction
  augroup osc52_yank
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call s:Osc52Yank() | endif
  augroup END
else
  set clipboard+=unnamed,unnamedplus
endif

" lightline (外部カラースキーム: ~/.vim/autoload/lightline/colorscheme/dotfiles.vim)
let g:lightline = {
  \ 'colorscheme': 'dotfiles',
  \ 'active': {
  \   'right': [ [ 'lineinfo' ], [ 'percent' ], [ 'fileformat', 'fileencoding', 'filetype', 'relativepath' ] ],
  \ },
  \ 'component_expand': {
  \   'linter_errors':   'lightline#ale#errors',
  \   'linter_warnings': 'lightline#ale#warnings',
  \ },
  \ }

" ===== Tab =====
set expandtab
set tabstop=2
set shiftwidth=2
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

" タブを閉じる (tt で開いたターミナルタブ用)
" 最後の1タブだと :tabclose は E784 で失敗するため、ターミナルバッファのときだけバッファを潰す
function! s:CloseTermTab()
  if tabpagenr('$') > 1
    tabclose
  elseif &buftype ==# 'terminal'
    bdelete!
  else
    echohl WarningMsg | echom 'tq: 最後のタブは閉じられません (ターミナル以外)' | echohl None
  endif
endfunction
nnoremap <silent> tq :call <SID>CloseTermTab()<CR>
tnoremap <silent> tq <C-\><C-n>:call <SID>CloseTermTab()<CR>

" トグルターミナル (tx): vim-floaterm のフロートウィンドウを表示/非表示
let g:floaterm_width = 0.8
let g:floaterm_height = 0.6
let g:floaterm_title = ''
if (has('win32') || has('win64')) && empty($WSL_DISTRO_NAME)
  let g:floaterm_shell = 'pwsh.exe -NoLogo'
endif

nnoremap <silent> tx :FloatermToggle<CR>
tnoremap <silent> tx <C-\><C-n>:FloatermToggle<CR>

" アルゴリズム学習用: カレントファイルをさっと実行 (<Leader>r)
let s:runners = {
  \ 'python':     'python3 %s',
  \ 'cpp':        'g++ -std=c++17 -O2 -o /tmp/%s %s && /tmp/%s',
  \ 'c':          'gcc -O2 -o /tmp/%s %s && /tmp/%s',
  \ 'rust':       'rustc -O -o /tmp/%s %s && /tmp/%s',
  \ 'go':         'go run %s',
  \ 'javascript': 'node %s',
  \ 'typescript': 'ts-node %s',
  \ }

function! s:RunCurrentFile()
  let l:ft = &filetype
  if !has_key(s:runners, l:ft)
    echohl WarningMsg | echom "RunCurrentFile: '" . l:ft . "' の実行コマンドが未設定です" | echohl None
    return
  endif
  write
  let l:file = expand('%:p')
  let l:name = expand('%:t:r')
  let l:tpl = s:runners[l:ft]
  if count(l:tpl, '%s') == 3
    let l:cmd = printf(l:tpl, l:name, l:file, l:name)
  else
    let l:cmd = printf(l:tpl, l:file)
  endif
  execute 'FloatermNew --autoclose=0 ' . l:cmd
endfunction

nnoremap <silent> <Leader>r :call <SID>RunCurrentFile()<CR>

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
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l

" ターミナル内: Esc でエディターに戻る（ターミナルは閉じない）
tnoremap <Esc> <C-\><C-n><C-w>p

" ターミナルウィンドウに戻ったとき自動で insert モードに
autocmd WinEnter * if &buftype ==# 'terminal' | startinsert | endif

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
