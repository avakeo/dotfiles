# dotfiles の更新を 1 日 1 回確認する — tools.sh の末尾で読み込む
#   シェルの起動時に、その日まだ確認していなければ裏で git fetch する (起動は待たせない)
#   fetch が終わったあと、次にプロンプトを出すときに結果を 1 回だけ表示する
#   pull は自動でしない (未コミットの変更があるとコンフリクトするため)
#   dotfiles-check     → 今の状態をすぐ表示する (fetch はしない)
#   dotfiles-check -f  → fetch してから表示する
#   DOTFILES_UPDATE_CHECK=0 を ~/.shell.local に書くと無効になる

[ "${DOTFILES_UPDATE_CHECK:-1}" = 0 ] && return 0

DOTFILES_REPO="$(git -C "$DOTFILES_SHELL_DIR" rev-parse --show-toplevel 2>/dev/null)" || return 0
_dotfiles_cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-update-check"

# ローカルの ref だけで状態をまとめる (ネットワークには出ない)
_dotfiles_report() {
  local behind branches count
  behind="$(git -C "$DOTFILES_REPO" rev-list --count main..origin/main 2>/dev/null)"
  if [ "${behind:-0}" -gt 0 ]; then
    echo "dotfiles: main が origin/main より ${behind} コミット遅れています (cd $DOTFILES_REPO && git pull --rebase --autostash)"
  fi
  branches="$(git -C "$DOTFILES_REPO" branch -r --no-merged origin/main --format='%(refname:lstrip=3)' 2>/dev/null | grep -v '^HEAD$')"
  if [ -n "$branches" ]; then
    count="$(printf '%s\n' "$branches" | wc -l | tr -d ' ')"
    echo "dotfiles: main にまだ入っていないブランチが ${count} つあります: $(printf '%s\n' "$branches" | head -3 | paste -sd ' ' -)$([ "$count" -gt 3 ] && echo ' ...')"
  fi
}

_dotfiles_fetch() {
  # 認証を求められても待たずに失敗させる
  GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="ssh -o BatchMode=yes" \
    git -C "$DOTFILES_REPO" fetch --quiet --prune 2>/dev/null
}

dotfiles-check() {
  [ "$1" = "-f" ] && { _dotfiles_fetch || echo "dotfiles: fetch に失敗しました" >&2; }
  local out; out="$(_dotfiles_report)"
  printf '%s\n' "${out:-dotfiles: 更新はありません}"
}

# fetch の結果 (notice) があれば表示して消す。プロンプトを出す前に毎回呼ぶ
_dotfiles_show_notice() {
  [ -s "$_dotfiles_cache/notice" ] || return 0
  cat "$_dotfiles_cache/notice"
  rm -f "$_dotfiles_cache/notice"
}

mkdir -p "$_dotfiles_cache"
_dotfiles_today="$(date +%F)"
if [ "$(cat "$_dotfiles_cache/last-fetch" 2>/dev/null)" != "$_dotfiles_today" ]; then
  # 先に日付を書いて、同時に開いた他のシェルが fetch を重ねないようにする
  echo "$_dotfiles_today" > "$_dotfiles_cache/last-fetch"
  ( { _dotfiles_fetch && _dotfiles_report > "$_dotfiles_cache/notice.tmp" \
      && mv "$_dotfiles_cache/notice.tmp" "$_dotfiles_cache/notice"; } >/dev/null 2>&1 & )
fi
unset _dotfiles_today

if [ -n "$ZSH_VERSION" ]; then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _dotfiles_show_notice
else
  PROMPT_COMMAND="_dotfiles_show_notice${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi
