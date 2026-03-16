# dotfiles

## Install

```bash
# Linux / WSL / macOS
git clone https://github.com/avakeo/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

```powershell
# Windows (管理者 or Developer Mode が必要)
git clone https://github.com/avakeo/dotfiles.git $HOME/dotfiles
cd $HOME/dotfiles; .\install.ps1
```

初回のみ追加で必要な作業:

```bash
# nvim プラグインのインストール
nvim +":Lazy sync" +qa

# vim プラグインのインストール
vim +PlugInstall +qa
```

---

## Dependencies

### 共通
| ツール | 用途 | インストール |
|---|---|---|
| [Starship](https://starship.rs) | プロンプト | `curl -sS https://starship.rs/install.sh \| sh` |
| [sheldon](https://sheldon.cli.rs) | zsh プラグイン管理 | `cargo install sheldon` |
| [WezTerm](https://wezfurlong.org/wezterm/) | ターミナル | 公式サイト参照 |
| [Neovim](https://neovim.io) v0.9+ | エディタ | `apt/brew install neovim` |
| [Cica](https://github.com/miiton/Cica) | フォント | GitHub からダウンロード |

### Linux / WSL
```bash
sudo apt install zsh git curl vim neovim fish neofetch
```

### macOS
```bash
brew install zsh git neovim fish starship sheldon
```

### Windows 備考
- `install.ps1` が `WEZTERM_CONFIG_FILE` 環境変数を自動設定する
- PowerShell プロファイルは `$PROFILE` から dotfiles をドットソースする形式

### nvim LSP サーバー (mason で自動インストールされる)
`pyright` `ts_ls` `rust_analyzer` `lua_ls` `jsonls` `yamlls` `html` `cssls`

### Claude 統合 (codecompanion.nvim)
```bash
export ANTHROPIC_API_KEY=sk-ant-...   # ~/.zshrc.local に書く
```

---

## Keybindings

> Leader キーの対応表
> | 環境 | Leader |
> |---|---|
> | WezTerm | `CTRL+B` |
> | Neovim / Vim | `Space` |

### WezTerm

Leader = `CTRL+B`

| キー | 動作 |
|---|---|
| `Leader` + `v` | 左右に分割 |
| `Leader` + `s` | 上下に分割 |
| `Leader` + `z` | ペインをズーム/解除 |
| `Leader` + `x` | ペインを閉じる |
| `Leader` + `c` | 画面クリア |
| `Leader` + `h/j/k/l` | ペイン移動 |
| `CTRL` + `h/j/k/l` | ペイン移動（Leader なし） |
| `Leader` + `</>/+/_` | ペインリサイズ |
| `CTRL+t` | 新規タブ |
| `CTRL+Tab` / `CTRL+Shift+Tab` | タブ切り替え |
| `CTRL+←/→` | 単語単位で移動 |
| `CTRL+BS` | 単語削除 |

### Neovim / Vim

Leader = `Space`

**画面分割・移動**

| キー | 動作 |
|---|---|
| `Leader` + `v` | 左右に分割 |
| `Leader` + `s` | 上下に分割 |
| `Leader` + `x` | 分割を閉じる |
| `Leader` + `c` | 画面クリア |
| `CTRL` + `h/j/k/l` | ウィンドウ移動 |
| `Leader` + `</>/+/_` | ウィンドウリサイズ |

**ファイルツリー・タブ**

| キー | 動作 |
|---|---|
| `CTRL+n` | ファイルツリーにフォーカス |
| `Leader` + `t` | ファイルツリー開閉 |
| `gt` / `gT` | バッファ切り替え |
| `tt` | 新規タブでターミナル起動 |
| `tx` | 下部ペインでターミナル起動 |

**Telescope**

| キー | 動作 |
|---|---|
| `Leader` + `ff` | ファイル検索 |
| `Leader` + `fg` | テキスト検索（grep） |
| `Leader` + `fb` | バッファ一覧 |
| `Leader` + `fr` | 最近開いたファイル |
| `Leader` + `fw` | カーソル下の単語を grep |
| `Leader` + `fh` | ヘルプ検索 |

**編集**

| キー | 動作 |
|---|---|
| `jj` | インサートモードを抜ける |
| `j` / `k` | 視覚行移動（折り返し対応） |
| `Esc` `Esc` | 検索ハイライト消去 |
| `[d` / `]d` | 前/次の診断エラーへ移動 |
| `F3` | 相対行番号トグル |

**LSP**

| キー | 動作 |
|---|---|
| `gd` | 定義へジャンプ |
| `gD` | 宣言へジャンプ |
| `gr` | 参照一覧 |
| `K` | ホバードキュメント |
| `Leader` + `rn` | リネーム |
| `Leader` + `ca` | コードアクション |
| `Leader` + `f` | フォーマット |

### PowerShell エイリアス

**bash 互換コマンド**

| コマンド | 説明 |
|---|---|
| `ll` / `la` | ファイル一覧（隠しファイル含む） |
| `touch <file>` | ファイル作成 / タイムスタンプ更新 |
| `grep <pattern> [path]` | 文字列検索 |
| `head` / `tail` | 先頭 / 末尾 N 行表示 |
| `which <cmd>` | コマンドのパスを表示 |
| `find <path> <name>` | ファイル検索 |
| `open <path>` | 既定アプリで開く |
| `df` | ディスク使用量 |
| `env` | 環境変数一覧 |

**git エイリアス**

| コマンド | git コマンド |
|---|---|
| `gs` | `git status` |
| `ga` | `git add` |
| `gaa` | `git add -A` |
| `gcm "msg"` | `git commit -m "msg"` |
| `gacm "msg"` | `git add -A && git commit -m "msg"` |
| `gp` / `gpl` | `git push` / `git pull` |
| `gd` / `gds` | `git diff` / `git diff --staged` |
| `gl` | `git log --oneline --graph` |
| `gco` | `git checkout` |
| `gb` / `gba` | `git branch` / `git branch -a` |
| `gst` / `gstp` | `git stash` / `git stash pop` |

---

## Structure

```
dotfiles/
├── .bashrc
├── .zshrc
├── .vimrc
├── .dircolors
├── Microsoft.PowerShell_profile.ps1
├── install.sh          # Linux / WSL / macOS 用
├── install.ps1         # Windows 用
└── .config/
    ├── nvim/           # Neovim (lazy.nvim)
    ├── wezterm/        # WezTerm
    ├── fish/           # Fish shell
    ├── git/            # Git global settings
    ├── gh/             # GitHub CLI
    ├── neofetch/       # neofetch
    └── starship.toml   # Starship prompt
```
