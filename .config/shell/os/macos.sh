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
