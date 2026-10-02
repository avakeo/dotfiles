# bash / zsh 共通のツール初期化 — .bashrc / .zshrc の末尾 (補完の初期化より後) で読み込む
# init.sh で DOTFILES_SHELL / DOTFILES_OS が設定済みであること

# starship: OS ごとにパレットを切り替える (os/*.sh で STARSHIP_PALETTE を設定)
if command -v starship >/dev/null 2>&1; then
  if [ -n "$STARSHIP_PALETTE" ]; then
    export STARSHIP_CONFIG="/tmp/starship-${USER}.toml"
    sed "s/^palette = \"windows\"/palette = \"$STARSHIP_PALETTE\"/" \
      "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml" > "$STARSHIP_CONFIG"
  fi
  eval "$(starship init "$DOTFILES_SHELL")"
fi

# fzf: 新しい fzf は --zsh / --bash で初期化できる。古い場合は install スクリプトが作るファイルを使う
if command -v fzf >/dev/null 2>&1 && fzf --"$DOTFILES_SHELL" >/dev/null 2>&1; then
  eval "$(fzf --"$DOTFILES_SHELL")"
elif [ -f "$HOME/.fzf.$DOTFILES_SHELL" ]; then
  . "$HOME/.fzf.$DOTFILES_SHELL"
fi

# zoxide (smart cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init "$DOTFILES_SHELL")"
  alias cd='z'
fi

# yazi: y で起動し、q で終了すると最後のディレクトリへ移動 (Q なら移動しない)
# 起動時のディレクトリを YAZI_START_DIR に入れておき、yazi 内の gs で戻れるようにする
# cd は z にエイリアスされているため builtin cd を使う (zoxide の履歴は cd のフックで記録される)
if command -v yazi >/dev/null 2>&1; then
  y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    YAZI_START_DIR="$PWD" command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    # SFTP (sftp://...) で終了した場合などローカルに無い場所へは移動しない
    [[ -d "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi
