# ~/.bashrc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Set colorful prompt if terminal supports it
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
else
    color_prompt=
fi

PS1='\u@\h:\w\$ '
unset color_prompt

# Enable color support for ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Some useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c='clear'
alias ..='cd ..'

# Avoid overwriting files with mv and cp
alias mv='mv -i'
alias cp='cp -i'

# Git aliases
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

# nautilus
alias explore='nautilus'

# pbcopy
alias clip='xsel --clipboard --input'


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
esac

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# WSL環境ではstarshipのパレットをwslに切り替え
if grep -qi microsoft /proc/version 2>/dev/null; then
  _starship_src="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
  export STARSHIP_CONFIG="/tmp/starship-${USER}.toml"
  sed 's/^palette = "windows"/palette = "wsl"/' "$_starship_src" > "$STARSHIP_CONFIG"
fi
eval "$(starship init bash)"

# . "$HOME/.local/bin/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
export PATH="$HOME/.local/bin:$PATH"

alias vi='/usr/bin/vim.basic'
alias vim='/usr/bin/vim.basic'


# pyenv settings
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"


