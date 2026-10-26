# macOS 固有 — init.sh から読み込まれる

# Homebrew: brew で入れたツールを以降の command -v で見つけられるよう最初に PATH へ
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

STARSHIP_PALETTE=macos

alias ls='ls -G'  # BSD ls (eza があれば common.sh で上書き)
alias clip='pbcopy'
alias explore='open .'

# LS_COLORS を ~/.dircolors から設定 (coreutils があれば gdircolors、無ければ自前でパース)
if [ -f "$HOME/.dircolors" ]; then
  if command -v gdircolors >/dev/null 2>&1; then
    eval "$(gdircolors -b "$HOME/.dircolors")"
  elif [ -n "$ZSH_VERSION" ]; then
    # 名前 (DIR, LINK...) を dircolors と同じ 2 文字コード (di, ln...) に変換する
    typeset -A _dc_map
    _dc_map=(RESET rs FILE fi DIR di LINK ln MULTIHARDLINK mh FIFO pi SOCK so DOOR do BLK bd CHR cd ORPHAN or MISSING mi SETUID su SETGID sg STICKY_OTHER_WRITABLE tw OTHER_WRITABLE ow STICKY st EXEC ex)
    _lsc=""
    while IFS= read -r _line; do
      [[ "$_line" =~ ^[[:space:]]*(#|$) ]] && continue
      [[ "$_line" =~ ^(TERM|COLORTERM|COLOR|OPTIONS|EIGHTBIT) ]] && continue
      _key="${_line%% *}"
      _val="${_line#* }"; _val="${_val%% #*}"; _val="${_val%% }"
      [[ -z "$_key" || -z "$_val" ]] && continue
      _code="${_dc_map[$_key]:-$_key}"
      _lsc+="${_code}=${_val}:"
    done < "$HOME/.dircolors"
    export LS_COLORS="${_lsc%:}"
    unset _lsc _line _key _val _code _dc_map
  fi
fi

# ===== Obsidian で好きなフォルダを一時的に開く =====
# 一時用 vault の中にシンボリックリンクを作って開く。開いたフォルダには .obsidian/ を作らない
#   obs [パス]  → パス (省略時はカレント) を一時用 vault にリンクして開く。ファイルならそのファイルを新しいタブで開く
#   obs-clean   → 一時用 vault のリンクをすべて消す (リンク先は消さない)
# Obsidian を終了すると、裏で待っているプロセスが obs-clean と同じようにリンクを消す
# 一時用 vault は最初に一度だけ Obsidian の「フォルダを保管庫として開く」で登録する
OBS_TMP_VAULT="${OBS_TMP_VAULT:-$HOME/work/obsidian/tmp}"

obs() {
  local target dir file name link i=2
  target="$(cd "$(dirname "${1:-.}")" && pwd)/$(basename "${1:-.}")" || return 1
  if [ -d "$target" ]; then
    dir="$(cd "$target" && pwd)"; file=""
  elif [ -f "$target" ]; then
    dir="$(dirname "$target")"; file="$(basename "$target")"
  else
    echo "obs: $1 が見つからない" >&2; return 1
  fi

  mkdir -p "$OBS_TMP_VAULT"
  if ! grep -qF "\"$OBS_TMP_VAULT\"" "$HOME/Library/Application Support/obsidian/obsidian.json" 2>/dev/null; then
    echo "obs: $OBS_TMP_VAULT が vault として未登録。Obsidian の「フォルダを保管庫として開く」で一度だけ登録して" >&2
    return 1
  fi

  # Obsidian が動いていないのにリンクが残っていたら、前回の後始末ができていない (再起動など) ので先に消す
  pgrep -xq Obsidian || find "$OBS_TMP_VAULT" -maxdepth 1 -type l -delete

  # 同じフォルダへのリンクがあれば使い回し、名前だけ重なるなら -2, -3 ... を付ける
  name="$(basename "$dir")"; link="$OBS_TMP_VAULT/$name"
  while [ -e "$link" ] || [ -L "$link" ]; do
    [ "$(readlink "$link")" = "$dir" ] && break
    link="$OBS_TMP_VAULT/$name-$i"; i=$((i + 1))
  done
  [ -L "$link" ] || ln -s "$dir" "$link"

  # ファイルは path で指定して新しいタブで開く。フォルダを path で渡すと「見つかりません」になるので vault 名だけで開く
  local enc='import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))'
  if [ -n "$file" ]; then
    open "obsidian://open?path=$(python3 -c "$enc" "$link/$file")&paneType=tab"
  else
    open "obsidian://open?vault=$(python3 -c "$enc" "$(basename "$OBS_TMP_VAULT")")"
  fi

  # Obsidian の終了を待ってリンクを消すプロセスを1つだけ起動する
  # 起動に時間がかかっても終了と取り違えないよう、Obsidian が現れるまで最大 60 秒待ってから終了を待つ
  if ! pgrep -qf obs-tmp-watcher; then
    (nohup sh -c 'i=0; until pgrep -xq Obsidian || [ $i -ge 60 ]; do sleep 1; i=$((i + 1)); done
      while pgrep -xq Obsidian; do sleep 5; done; find "$1" -maxdepth 1 -type l -delete' \
      obs-tmp-watcher "$OBS_TMP_VAULT" >/dev/null 2>&1 &)
  fi
}

obs-clean() {
  find "$OBS_TMP_VAULT" -maxdepth 1 -type l -print -delete
}
