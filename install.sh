#!/usr/bin/env bash
set -euo pipefail

DOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP_DIR="$HOME/.dotbackup/$(date +%Y%m%d_%H%M%S)"

# ===== OS detection =====

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      if uname -r | grep -qi microsoft; then
        echo "wsl"
      else
        echo "linux"
      fi
      ;;
    *) echo "unknown" ;;
  esac
}

# ===== Helpers =====

info()    { echo "  $*"; }
success() { echo -e "  \e[32m✓\e[m $*"; }
warn()    { echo -e "  \e[33m!\e[m $*"; }

backup_and_link() {
  local src="$1"
  local dest="$2"

  if [[ ! -e "$src" ]]; then
    warn "skip (not found): $src"
    return
  fi

  if [[ -L "$dest" ]]; then
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/"
    info "backed up: $(basename "$dest")"
  fi

  ln -snf "$src" "$dest"
  success "$(basename "$dest")"
}

# ===== Link targets =====

link_home() {
  echo ""
  echo "Home dotfiles:"

  local files=(.bashrc .zshrc .vimrc .dircolors .gitconfig_shared)
  for name in "${files[@]}"; do
    backup_and_link "$DOTDIR/$name" "$HOME/$name"
  done
}

link_config() {
  local os="$1"
  echo ""
  echo ".config entries:"
  mkdir -p "$HOME/.config"

  # 全プラットフォーム共通
  local entries=(nvim fish git gh starship.toml wezterm)
  for name in "${entries[@]}"; do
    backup_and_link "$DOTDIR/.config/$name" "$HOME/.config/$name"
  done

  # Linux / WSL のみ
  if [[ "$os" == "linux" || "$os" == "wsl" ]]; then
    backup_and_link "$DOTDIR/.config/neofetch" "$HOME/.config/neofetch"
  fi
}

install_vim_plug() {
  echo ""
  echo "vim-plug:"
  local plug_path="$HOME/.vim/autoload/plug.vim"
  if [[ ! -f "$plug_path" ]]; then
    curl -fLo "$plug_path" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    success "vim-plug installed"
  else
    info "vim-plug already exists"
  fi
}

install_tools() {
  echo ""
  echo "Tools:"

  # fzf
  if ! command -v fzf &>/dev/null; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all --no-bash --no-fish
    success "fzf installed"
  else
    info "fzf already installed"
  fi

  # zoxide
  if ! command -v zoxide &>/dev/null; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    success "zoxide installed"
  else
    info "zoxide already installed"
  fi
}

post_install() {
  echo ""
  echo "Git config:"
  git config --global include.path "~/.gitconfig_shared"
  success "include.path set to ~/.gitconfig_shared"
}

# ===== Main =====

usage() {
  echo "Usage: $0 [--debug|-d] [--help|-h]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --debug|-d) set -x ;;
    --help|-h)  usage; exit 0 ;;
    *) warn "Unknown option: $1"; usage; exit 1 ;;
  esac
  shift
done

OS=$(detect_os)
echo "Platform: $OS"

link_home
link_config "$OS"
install_vim_plug
install_tools
post_install

echo ""
echo -e "\e[1;36mInstall completed!\e[m"
