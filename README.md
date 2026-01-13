# dotfiles (chezmoi-based)

This repo manages cross-platform dotfiles using [chezmoi].

## Bootstrap

- Install chezmoi, then run:

```sh
chezmoi init --apply abak3o
```

- On Windows, this repo creates a symlink from `~/AppData/Local/nvim` to `~/.config/nvim` so a single Neovim config works on both Windows and Ubuntu.

## Neovim

- Plugin manager: `lazy.nvim`
- LSP: `mason.nvim` + `nvim-lspconfig`
- Completion: `nvim-cmp`
- Treesitter with a minimal set of languages
- Telescope buffer picker on `<leader>fb`
- GitHub Copilot via `zbirenbaum/copilot.lua` (inline only, accept with `Ctrl-l`)

## Shell

- `~/.zshrc` is minimal: starship + `zsh-autosuggestions` + `zsh-syntax-highlighting`
- PowerShell profile adds shared aliases like `g` (git) and `v` (nvim)

[chezmoi]: https://www.chezmoi.io/
