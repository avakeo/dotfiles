# yazi 導入と dotfiles 見直しの記録 (2026-09 〜 10)

yazi を入れたのをきっかけに、キーやコマンドがぶつからないよう dotfiles 全体を見直した記録。
「何を変えたか」に加えて、その裏にあるネットワークと Linux / シェルの仕組みもメモしておく。

## 変更の全体像

| 領域 | 変更 |
|---|---|
| yazi | 設定を dotfiles で管理。Enter の挙動、md プレビュー、git 状態表示、移動キー、削除確認、Marta 連携、SFTP |
| シェル | `.bashrc` / `.zshrc` の共通部分を `.config/shell/` に移し、OS ごと (macOS / Linux / WSL) に分割 |
| tmux | 画像プレビューのパススルー、ペイン移動 (prefix 連打・Alt+hjkl)、重複ファイルの削除 |
| nvim | nvim-tree → yazi.nvim、render-markdown.nvim を削除、起動時の通知を整理 |
| その他 | 使っていない `.chezmoi.toml.tmpl` を削除 |

dotfiles の外で行ったこと:

- yomiyasu (日本語推敲スキル) を Claude Code のプラグインとして導入 (`claude plugin install yomiyasu@yomiyasu`)
- 自作スキル置き場 `~/work/skills` と、`~/.claude/skills` へのリンクスクリプト `link.sh` を作成
- yazi で誤ってゴミ箱に送った `~/work/bad-personality` を復元

---

## ネットワーク編

### SFTP は SSH の上で動く

```
yazi (SFTP クライアント)
  │  sftp://viber
  ▼
TCP 22 番ポート ── SSH (暗号化・認証) ── viber の sshd
                     └─ その上で SFTP サブシステムが動く
```

- SFTP は FTP とは別物で、**SSH の接続の中で動くファイル転送の仕組み**。ポートも認証も SSH と同じなので、`ssh viber` で入れるなら SFTP も使える。
- 「SSH で入れるか」は、先に次のコマンドで確認した。`BatchMode=yes` はパスワード入力を待たずに失敗させるオプションで、鍵認証が通るかだけを確かめられる。
  ```sh
  ssh -o BatchMode=yes -o ConnectTimeout=6 viber 'echo connected'
  ```
- `ssh -G viber` を実行すると、`~/.ssh/config` を解釈した最終的な接続設定 (ホスト名、ユーザー、試す鍵の順番など) が表示される。設定が効いているか確かめるのに便利。

### viber の IP アドレス (100.x.x.x) は Tailscale

- `~/.ssh/config` の viber は `100.111.233.57` になっている。`100.64.0.0/10` は CGNAT 用に予約された範囲で、Tailscale はここから各端末にアドレスを割り当てる。
- Tailscale は WireGuard を使ったオーバーレイ VPN。家の外からでも、この 100.x のアドレスで直接 SSH できる。

### 鍵ファイルと SSH エージェント

| 方式 | 仕組み | 今回 |
|---|---|---|
| SSH エージェント | 秘密鍵を持つプロセスに Unix ソケット (`$SSH_AUTH_SOCK`) 経由で署名を頼む | 使わなかった |
| 鍵ファイル | 秘密鍵のファイルを直接読む | **採用** (`~/.ssh/id_ed25519`) |

- この Mac の `$SSH_AUTH_SOCK` は WezTerm が用意したソケット (`~/.local/share/wezterm/agent.<番号>`) で、番号が変わりうる。yazi の設定には固定のパスしか書けないので、鍵ファイルを直接指定した。
- 鍵にパスフレーズが付いているかは、次のコマンドで確かめた (成功したらパスフレーズなし)。
  ```sh
  ssh-keygen -y -P "" -f ~/.ssh/id_ed25519
  ```
- 逆向き (viber から この Mac へ) に接続するには、Mac 側で「システム設定 → 一般 → 共有 → リモートログイン」をオンにして sshd を動かす必要がある。

### 端末のエスケープシーケンスは SSH の中を通る

ターミナルに流れる文字の中に、制御用の特殊な文字列 (OSC シーケンス) を混ぜると、端末 (WezTerm) に指示を出せる。これは画面に表示する文字と同じ経路を通るので、**SSH 越しでも tmux の中からでも届く**。

| シーケンス | 用途 | どこで使っているか |
|---|---|---|
| OSC 52 | クリップボードへのコピー | tmux のコピーモード → SSH 越しに Mac のクリップボードへ |
| OSC 7 | 今いるディレクトリを端末に通知 | シェルのプロンプト表示時。WezTerm のタブ名の更新に使う |
| OSC 1337 SetUserVar | 端末に変数を渡す | vim が起動中かを WezTerm に伝える (`IS_VIM`) |
| 画像プロトコル (Kitty / iTerm2) | 画像の表示 | yazi のプレビュー |

tmux はこれらのシーケンスを基本的に自分で受け止めてしまう。外側の WezTerm まで素通しさせるため、`.tmux.conf` に次を追加した。

```tmux
set -g allow-passthrough on            # 画像などのシーケンスを外の端末へ通す
set -ga update-environment TERM        # 接続し直したとき端末の種類を引き継ぐ
set -ga update-environment TERM_PROGRAM
```

### セッション維持: tmux と WezTerm の違い

- tmux はサーバーとクライアントに分かれていて、シェルなどのプロセスはサーバーが持つ。SSH が切れてもサーバーは残るので、`tmux attach` で元に戻れる。**リモートでは tmux が必須**。
- 手元の Mac では WezTerm だけで分割・タブを使い、tmux は使わない方針にした。両方を使うとペイン操作が 2 階層になり、キーがぶつかるため。
- WezTerm にも tmux と同じサーバー/クライアント構成 (`unix_domains`) があるが、手元でセッションを残す必要がないので入れていない。

---

## Linux / シェル編

### dotfiles はシンボリックリンクで配る

```
~/.zshrc          → ~/dotfiles/.zshrc
~/.config/yazi    → ~/dotfiles/.config/yazi
~/.config/shell   → ~/dotfiles/.config/shell
```

- `install.sh` は、既存のファイルを `~/.dotbackup/<日時>/` に退避してから `ln -snf` でリンクを張る。
- **見つかった問題**: この Mac の `~/.tmux.conf` がリンクではなくコピーになっていて、dotfiles 側の変更が反映されていなかった。`readlink` で確認できる。
  ```sh
  readlink ~/.tmux.conf   # 何も出なければリンクではない
  ```

### シェルの読み込み順

```
.zshrc / .bashrc
  ├─ 先頭: .config/shell/init.sh
  │    ├─ OS 判定 → DOTFILES_OS = macos | linux | wsl
  │    ├─ os/<OS>.sh   OS 固有 (brew の PATH、clip、ls の種類など)
  │    └─ common.sh    全 OS 共通 (エイリアス、関数、PATH、nvm、pyenv)
  ├─ 中盤: シェル固有 (zsh のオプション、補完、キー割り当て、プロンプト)
  ├─ 末尾: .config/shell/tools.sh (starship、fzf、zoxide、yazi の y)
  └─ 最後: ~/.zshrc.local / ~/.bashrc.local (マシン固有、git 管理外)
```

順番に意味がある。

- **brew の PATH は最初**: `/opt/homebrew/bin` が PATH に入る前に `command -v eza` などを実行すると、入っているのに「無い」と判定される。
- **ツールの初期化は補完の後**: zoxide や fzf は、補完の仕組み (`compinit`) が準備できてから読み込むよう推奨されている。
- **`.local` は最後**: マシンごとの設定で、共通の設定を上書きできるようにするため。

### OS の判定方法

```sh
uname -s                          # Darwin (macOS) / Linux
grep -qi microsoft /proc/version  # Linux のうち WSL かどうか
```

- Ubuntu と Kali はどちらも Debian 系 (apt) なので、まとめて `linux` として扱う。Kali だけの設定は `~/.zshrc.local` に書く。
- WSL は `linux.sh` を読み込んだあと、Windows 連携の部分 (`clip.exe`、`explorer.exe`) だけを上書きする。

### GNU と BSD のコマンドの違い

macOS のコマンドは BSD 系、Linux は GNU 系で、同じ名前でもオプションが違う。

| コマンド | macOS (BSD) | Linux (GNU) |
|---|---|---|
| `ls` の色付け | `ls -G` | `ls --color=auto` |
| `dircolors` | 標準では無い (`brew install coreutils` で `gdircolors`) | ある |
| `sed -i` | `sed -i ''` (空の引数が必要) | `sed -i` |
| bash | 3.2 (2007 年の版。連想配列などが使えない) | 5.x |

`os/macos.sh` と `os/linux.sh` に分けたのは、この違いを吸収するため。

### エイリアスと `builtin`

- zoxide のために `alias cd='z'` にしているので、スクリプトの中で `cd` と書くと z が呼ばれる。
- `builtin cd` と書くと、エイリアスや関数を飛ばして、シェル組み込みの本物の `cd` を呼べる。yazi の `y` 関数ではこれを使っている。zoxide の履歴は cd のフック (`chpwd`) で記録されるので、`builtin cd` でも残る。

### PATH の順番

- PATH は前にあるものが優先される。今は `~/.local/bin` が Homebrew より前にあるので、同じ名前のコマンドがあれば `~/.local/bin` の方が使われる。
- どれが使われるかは、zsh なら `whence -a <コマンド>`、bash なら `type -a <コマンド>` で確認できる。

### 消えたファイルを探す: mtime と ctime

yazi でゴミ箱に送ったフォルダを探したときに使った知識。

| 時刻 | 意味 | 移動 (mv) したとき |
|---|---|---|
| mtime | 中身が変わった時刻 | **変わらない** |
| ctime | ファイルの情報 (名前・場所・権限) が変わった時刻 | **変わる** |

- ゴミ箱への移動は `mv` と同じなので、`ls -lt ~/.Trash` (mtime 順) で見ると、移動したばかりのものが古い日付に紛れてしまう。
- `ls -lact ~/.Trash` (ctime 順) なら、移動した時刻の順に並ぶ。
- ディレクトリの mtime は、**中にファイルを追加・削除したとき**に更新される。「どのフォルダから消えたか」は、親ディレクトリの mtime で当たりを付けられる。
  ```sh
  find ~/work -maxdepth 5 -type d -mmin -120   # 2 時間以内に中身が変わったディレクトリ
  ```
- git 管理下なら、`git status` で消えたファイルがわかり、`git restore <パス>` で戻せる。

---

## yazi の設定

### 設定ファイル

| ファイル | 内容 | git |
|---|---|---|
| `.config/yazi/yazi.toml` | 開き方 (nvim、Marta)、md プレビュー、git 状態の取得 | 管理 |
| `.config/yazi/keymap.toml` | 追加したキー (デフォルトとの差分だけ) | 管理 |
| `.config/yazi/init.lua` | git.yazi の初期化 | 管理 |
| `.config/yazi/package.toml` | 使うプラグインの一覧 (`ya pkg install` で復元) | 管理 |
| `.config/yazi/plugins/` | プラグイン本体 | 管理しない |
| `.config/yazi/vfs.toml` | SFTP の接続先 (IP・ユーザー・鍵) | 管理しない (マシン固有) |

### 追加したキー

| キー | 動作 |
|---|---|
| `Enter` | ディレクトリなら入る、ファイルなら nvim で開く (smart-enter) |
| `o` (ディレクトリ上) | Marta で開く |
| `g.` / `gw` | `~/dotfiles` / `~/work` へ移動 |
| `gs` | yazi を起動したディレクトリへ戻る |
| `gm` | 今いるディレクトリを Marta で開く (ドラッグ & ドロップ用) |
| `gv` | SFTP で viber へ |
| 確認ダイアログの `Enter` | **キャンセル** (`y` でのみ削除などを実行) |

### ぶつからないよう避けたキー

外側のアプリが先に受け取ってしまうので、yazi では使わない。

| キー | 先に受け取るもの |
|---|---|
| `Ctrl+h/j/k/l` | WezTerm のペイン移動 (nvim の中なら nvim に渡る) |
| `Alt+h/j/k/l` | tmux のペイン移動 |
| `Ctrl+\` | WezTerm の Leader キー |
| `Ctrl+t` | WezTerm の新規タブ (yazi.nvim では無効化) |

### つまずいたところ

- **opener の引数**: yazi 26 では `"$@"` ではなく `%s` と書く。古い書き方のままだと、nvim がファイルを受け取れずに空のバッファで開いた。
- **SFTP の設定**: `[sftp.<名前>]` と書く。推測で `[services.<名前>]` や `type` / `kind` と書いて 2 回失敗した。公式ドキュメント (https://yazi-rs.github.io/docs/configuration/vfs) を先に読むべきだった。
- **`y` の cd**: SFTP の場所で yazi を終了すると `sftp://...` へ `cd` しようとして失敗していた。ローカルに実在するディレクトリのときだけ移動するよう修正した。

---

## nvim

- nvim-tree を yazi.nvim に置き換えた。`<Leader>t` で今のファイルの場所、`<C-n>` で前回の yazi を再開、`nvim .` で起動したときも yazi が開く。
- render-markdown.nvim を削除した。md は yazi のプレビュー (glow) で見る。
- 起動時の通知を整理した。lazy.nvim の更新通知を止め、nvim-notify の背景色を指定して警告を消した。
- yazi.nvim の中では、ターミナルモードの `tx` (toggleterm) のせいで yazi の `t` が入力待ちになるので、yazi の画面の中だけ `t` をそのまま送るようにした。

---

## まだ残っていること

- [ ] Finder の設定スクリプト `macos/defaults.sh` (検索範囲を現在のフォルダに、リスト表示など)。作業が途中で止まっている
- [ ] Ubuntu / Kali / WSL の実機で、分割したシェル設定が動くかの確認 (Mac 上で `uname` を偽装した確認だけ済み)
- [ ] SFTP 上のファイルを nvim で編集・保存したときに、viber 側へ書き戻されるかの確認
- [ ] `gm` (Marta) が Linux でも反応してエラーになる件
- [ ] `client.is_stopped is deprecated` の警告 (cmp-nvim-lsp の更新で直る可能性あり)
- [ ] 他人のスキル・プラグインの一覧を dotfiles で管理し、`install.sh` から `claude plugin install` する仕組み
- [ ] `origin/main` への push (ここまでのコミットは未 push)

## 関連ファイル

- `.config/shell/` — シェルの共通設定 (`init.sh`、`common.sh`、`tools.sh`、`os/*.sh`)
- `.config/yazi/` — yazi の設定
- `.config/nvim/lua/plugins/yazi.lua` — yazi.nvim
- `.tmux.conf` — tmux
- `install.sh` — リンクの作成とツールのインストール
- `docs/vim-wezterm-navigation.md` — Ctrl+hjkl を vim と WezTerm で共有する仕組み
