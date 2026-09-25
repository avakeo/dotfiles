# Linux (Ubuntu / Kali など) 固有 — init.sh から読み込まれる (WSL でも wsl.sh の先頭で読み込む)

alias ls='ls --color=auto'  # GNU ls (eza があれば common.sh で上書き)
alias clip='xsel --clipboard --input'
alias explore='xdg-open .'

# Debian 系の vim パッケージ (vim-tiny ではなく vim.basic を使う)
if [ -x /usr/bin/vim.basic ]; then
  alias vi='/usr/bin/vim.basic'
  alias vim='/usr/bin/vim.basic'
fi

if [ -f "$HOME/.dircolors" ] && command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b "$HOME/.dircolors")"
fi
