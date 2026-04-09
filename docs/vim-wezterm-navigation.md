# vim と WezTerm のキーナビゲーション設計メモ

## 現状の構成

`Ctrl+hjkl` を vim 内ウィンドウ移動と WezTerm ペイン移動で **共有** している。

```
WezTerm (Ctrl+hjkl)
  │
  ├─ vim/nvim が動いている？
  │    YES → Ctrl+hjkl をそのまま vim に送る
  │             └─ vim: nnoremap / tnoremap <C-hjkl> → <C-w>hjkl
  │
  └─ NO → WezTerm の ActivatePaneDirection で隣のペインに移動
```

### vim 内の `:terminal` 問題と解決策

vim で `tx`（`:belowright terminal`）を開くと、WezTerm から見た前景プロセスが
`vim` ではなく `pwsh.exe` / `bash` になる。
そのまま `Ctrl+h` を押すと `is_vim()` が false を返し、ペイン移動しようとして何も起きない。

**解決策**: vim の `t_ti` / `t_te` を使い、vim 起動・終了時に WezTerm の UserVar `IS_VIM` をセットする。

```vim
" .vimrc
if !empty($WEZTERM_PANE)
  " base64("true") = "dHJ1ZQ=="
  let &t_ti = "\e]1337;SetUserVar=IS_VIM=dHJ1ZQ==\007" . &t_ti
  let &t_te = &t_te . "\e]1337;SetUserVar=IS_VIM=\007"
endif
```

```lua
-- wezterm.lua
local function is_vim(pane)
  if pane:get_user_vars().IS_VIM == "true" then return true end
  local proc = pane:get_foreground_process_name() or ""
  return proc:find("n?vim") ~= nil
end
```

`IS_VIM=true` は vim が生きている間ずっとセットされたままなので、
`:terminal` 内でも `Ctrl+hjkl → vim → tnoremap → <C-w>h` の経路が通る。

---

## 設計上の迷い: キーを分けるべきか？

### 共有する場合（現状）

**メリット**
- WezTerm ペインと vim ウィンドウを意識せず同じキーで移動できる
- nvim の設定とも統一できる

**デメリット**
- UserVar の仕組みが必要で、設定が複雑になる
- vim を終了し忘れると `IS_VIM=true` が残り、WezTerm のペイン移動が効かなくなる可能性がある
- `Ctrl+l` がターミナルのクリア（clear screen）と競合しやすい

### 分ける場合

vim 内ウィンドウ移動に `Ctrl+w` + hjkl（vim デフォルト）を使い、
WezTerm のペイン移動は `Ctrl+hjkl` のままにする。

```vim
" .vimrc から nnoremap / tnoremap <C-hjkl> を削除
" <C-w>hjkl はデフォルトで使える
```

```lua
-- wezterm.lua: smart_move / is_vim を削除し、シンプルにする
{ key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left")  },
{ key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down")  },
{ key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up")    },
{ key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
```

**メリット**
- WezTerm 側の設定がシンプルになる
- UserVar の仕組みが不要
- vim ウィンドウ移動と WezTerm ペイン移動が明確に分離される

**デメリット**
- vim 内で `Ctrl+w` プレフィックスが必要になり、キー数が増える
- WezTerm ペイン移動と vim ウィンドウ移動でキーが違うので慣れが必要

---

## 将来キーを分けたい場合の変更手順

### 1. `.vimrc` の変更

```vim
" 削除する行:
" let &t_ti = "\e]1337;SetUserVar=IS_VIM=dHJ1ZQ==\007" . &t_ti
" let &t_te = &t_te . "\e]1337;SetUserVar=IS_VIM=\007"
" nnoremap <C-h> <C-w>h  (および j/k/l)
" tnoremap <C-h> <C-w>h  (および j/k/l)
```

vim のウィンドウ移動は `<C-w>h/j/k/l` デフォルトキーを使う。
または Leader キーに割り当てる:

```vim
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l
```

### 2. `wezterm.lua` の変更

```lua
-- is_vim / smart_move 関数を削除し、ペイン移動をシンプルに:
{ key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left")  },
{ key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down")  },
{ key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up")    },
{ key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
```

---

## 関連ファイル

| ファイル | 役割 |
|----------|------|
| `~/.vimrc` | vim のウィンドウ移動キーマップ、UserVar 通知 |
| `~/.config/wezterm/wezterm.lua` | WezTerm の smart_move / is_vim |
