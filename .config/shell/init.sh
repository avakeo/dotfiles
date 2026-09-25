# bash / zsh 共通の初期化 — .bashrc / .zshrc の先頭で読み込む
#   1. OS 判定 (DOTFILES_OS: macos | wsl | linux)  ※ ubuntu / kali は linux
#   2. os/<OS>.sh  … OS 固有の環境変数・エイリアス
#   3. common.sh   … 全 OS 共通のエイリアス・関数・PATH
# ツールの初期化 (starship / fzf / zoxide など) は rc の末尾で tools.sh を読み込む

DOTFILES_SHELL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell"

if [ -n "$ZSH_VERSION" ]; then
  DOTFILES_SHELL=zsh
else
  DOTFILES_SHELL=bash
fi

case "$(uname -s)" in
  Darwin) DOTFILES_OS=macos ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      DOTFILES_OS=wsl
    else
      DOTFILES_OS=linux
    fi
    ;;
  *) DOTFILES_OS=unknown ;;
esac

[ -f "$DOTFILES_SHELL_DIR/os/$DOTFILES_OS.sh" ] && . "$DOTFILES_SHELL_DIR/os/$DOTFILES_OS.sh"
. "$DOTFILES_SHELL_DIR/common.sh"
