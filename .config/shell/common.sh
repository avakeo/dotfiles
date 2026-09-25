# bash / zsh 共通 (全 OS) — init.sh から読み込まれる

# ===== PATH / 言語ランタイム =====

export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"  # uv

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

export PYENV_ROOT="$HOME/.pyenv"
[ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - "$DOTFILES_SHELL")"
fi

# ===== エイリアス =====

# ls: eza があれば優先。無ければ os/*.sh で定義した ls を使う
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --color=auto'
  alias ll='eza -alF'
  alias la='eza -a'
  alias l='eza -F'
else
  alias ll='ls -alF'
  alias la='ls -A'
  alias l='ls -CF'
fi

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'

alias c='clear'
alias ..='cd ..'

alias mv='mv -i'
alias cp='cp -i'

alias nivm='nvim'

# Git
alias g='git'
alias gs='git status'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias ga='git add'
alias gaa='git add -A'
alias gl='git pull'
alias gp='git push'
alias gd='git diff'

# ===== 関数 =====

# ディレクトリを作成して移動する
mkdirc() {
  mkdir -p -- "$1" && cd -- "$1"
}

# ディレクトリを作成して main.py を作成する
mkdirpy() {
  mkdir -p -- "$1" && touch -- "$1/main.py"
}

# ディレクトリを作成して main.py を作成し、そのディレクトリに移動する
mkdircpy() {
  mkdir -p -- "$1" && touch -- "$1/main.py" && cd -- "$1"
}
