# dotfiles

## Install

```bash
# Linux / WSL / macOS
git clone https://github.com/avakeo/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

```powershell
# Windows (管理者 or Developer Mode が必要)
git clone https://github.com/<your-username>/dotfiles.git $HOME/dotfiles
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

### nvim LSP サーバー (mason で自動インストールされる)
`pyright` `ts_ls` `rust_analyzer` `lua_ls` `jsonls` `yamlls` `html` `cssls`

### Claude 統合 (codecompanion.nvim)
```bash
export ANTHROPIC_API_KEY=sk-ant-...   # ~/.zshrc.local に書く
```

---

## Keybindings

### WezTerm

Leader = `CTRL+Space`

| キー | 動作 |
|---|---|
| `Leader` + `\|` | 左右に分割 |
| `Leader` + `-` | 上下に分割 |
| `Leader` + `z` | ペインをズーム/解除 |
| `Leader` + `x` | ペインを閉じる |
| `Leader` + `h/j/k/l` | ペイン移動 |
| `CTRL` + `h/j/k/l` | ペイン移動（Leader なし） |
| `Leader` + `</>/+/_` | ペインリサイズ |
| `Leader` + `c` / `CTRL+t` | 新規タブ |
| `CTRL+Tab` / `CTRL+Shift+Tab` | タブ切り替え |
| `CTRL+←/→` | 単語単位で移動 |
| `CTRL+BS` | 単語削除 |

### Neovim

| キー | 動作 |
|---|---|
| `CTRL+n` | ファイルツリーにフォーカス |
| `<Leader>t` | ファイルツリー開閉 |
| `gt` / `gT` | バッファ切り替え |
| `tt` | 新規タブでターミナル起動 |
| `tx` | 下部ペインでターミナル起動 |
| `jj` | インサートモードを抜ける |

**LSP**

| キー | 動作 |
|---|---|
| `gd` | 定義へジャンプ |
| `gD` | 宣言へジャンプ |
| `gr` | 参照一覧 |
| `K` | ホバードキュメント |
| `<Leader>rn` | リネーム |
| `<Leader>ca` | コードアクション |
| `<Leader>f` | フォーマット |

**Claude (codecompanion.nvim)**

| キー | 動作 |
|---|---|
| `<Leader>cc` | チャットを開く |
| `<Leader>ca` | アクション一覧 |
| `<Leader>ci` | インライン補完 |

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
