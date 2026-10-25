# WSL 固有 — Linux の設定を読み込んだうえで Windows 連携の部分だけ上書きする

. "$DOTFILES_SHELL_DIR/os/linux.sh"

alias clip='clip.exe'
alias explore='explorer.exe .'

# Obsidian で好きなフォルダを一時的に開く (使い方は os/macos.sh の obs と同じ)
# Obsidian は Windows 側で動くので、パスを Windows 形式にして obs.ps1 に渡す
# pwsh.exe (PowerShell 7) があれば使い、無ければ Windows 標準の powershell.exe を使う
_obs_ps1() {
  local ps=powershell.exe
  command -v pwsh.exe >/dev/null 2>&1 && ps=pwsh.exe
  "$ps" -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$DOTFILES_SHELL_DIR/obs.ps1")" "$@"
}
obs() {
  local target
  target="$(realpath -s -e "${1:-.}" 2>/dev/null)" || { echo "obs: $1 が見つからない" >&2; return 1; }
  _obs_ps1 "$(wslpath -w "$target")"
}
obs-clean() { _obs_ps1 -Clean; }
