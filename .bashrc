# ~/.bashrc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# bash / zsh 共通の設定 (OS 判定・エイリアス・PATH など) — Homebrew の PATH もここで通すので最初に読む
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/init.sh" ] && . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/init.sh"

# Set colorful prompt if terminal supports it
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
else
    color_prompt=
fi

PS1='\u@\h:\w\$ '
unset color_prompt

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

# Notify WezTerm (and other terminals) of the current working directory via OSC 7.
# This keeps tab titles in sync whenever the prompt renders (after every cd/command).
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }printf '\e]7;file://%s%s\a' \"\$HOSTNAME\" \"\$PWD\""

# bash / zsh 共通のツール初期化 (starship / fzf / zoxide / yazi) — 補完の初期化より後に読む
[ -n "$DOTFILES_SHELL_DIR" ] && . "$DOTFILES_SHELL_DIR/tools.sh"

# Machine-local overrides (not committed to git)
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
